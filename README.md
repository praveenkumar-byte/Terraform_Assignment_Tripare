# Hotel Bookings Platform — Infra & Data Assignment

Terraform for an ALB → ECS/Fargate → RDS setup on AWS (dev/prod environments),
plus a local Postgres environment for the hotel bookings schema, seed data,
and backup/restore.

## Repo layout

```
infra/
  modules/
    network/   VPC, public/private subnets, IGW, NAT gateway(s)
    ecs/       ALB, ALB/ECS security groups, ECS cluster, task def, service, autoscaling
    rds/       RDS subnet group, RDS security group, Postgres instance, Secrets Manager
  envs/
    dev/       smaller instance, 1 NAT gateway, no deletion protection, 1-day backups
    prod/      Multi-AZ, 1 NAT per AZ, deletion protection on, 30-day backups
.github/workflows/terraform.yml   fmt/init/validate/plan on PRs, plan posted as a PR comment + artifact
docker-compose.yml                 local Postgres 16
sql/migrations/                    schema (hotel_bookings, booking_events, index)
sql/seed/                          seed data script
scripts/backup.sh, restore.sh, seed.sh
```

## Architecture

Internet → ALB (public subnets) → ECS Fargate tasks (private subnets) → RDS (private subnets).

Each tier's security group only allows the tier in front of it as a source —
ALB SG allows 80 from the internet, ECS SG allows the container port only
from the ALB SG, RDS SG allows 5432 only from the ECS SG. RDS has no public
IP and lives in the private subnets, so it's unreachable from anywhere
except the ECS tasks, regardless of what else changes in the VPC later.

DB credentials aren't passed as plain Terraform variables — `rds` generates
a random password, stores it in Secrets Manager, and `ecs` wires the task
definition to read it at container start via the `secrets` block, so the
password never appears in state as a plaintext task-definition value or in
`terraform.tfvars`.

## Terraform — running it

```bash
cd infra/envs/dev   # or infra/envs/prod
terraform fmt -check -recursive ../../
terraform init                    # needs an existing S3 bucket + DynamoDB table for the backend (see backend.tf)
terraform validate
terraform plan -refresh=false
```

No `apply` is expected for this assignment — `plan` against real AWS
credentials, or `init -backend=false` if you just want to check the config
without wiring up a real S3 backend, is enough to validate the code.

### dev vs prod

| | dev | prod |
|---|---|---|
| RDS instance | db.t3.micro | db.r6g.large |
| Multi-AZ | no | yes |
| Backup retention | 1 day | 30 days |
| Deletion protection | off | on |
| NAT gateways | 1 (shared) | 1 per AZ |
| ECS task size | 256 CPU / 512 MB | 1024 CPU / 2048 MB |
| Desired task count | 1 | 2 (autoscales to 6) |

Both environments call the exact same three modules — only `terraform.tfvars`
and `backend.tf` differ per environment.

## GitHub Actions (Part 3)

`.github/workflows/terraform.yml` runs on every PR touching `infra/**`, for
both `dev` and `prod` as a matrix. It runs `fmt -check`, `init -backend=false`
(no real backend credentials needed just to validate/plan), `validate`, then
`plan -refresh=false`. The plan output is both posted as a PR comment and
uploaded as a workflow artifact (`tfplan-dev` / `tfplan-prod`), so it's
visible either way.

## Local database (Parts 4-6)

```bash
docker compose up -d
```

This starts Postgres 16 and runs everything in `sql/migrations/` on first
boot (via Postgres's `docker-entrypoint-initdb.d` mechanism), creating
`hotel_bookings`, `booking_events`, and the index described below.

Seed ~150 bookings (spread across 5 cities, 4 orgs, 4 statuses, with
events on ~60% of bookings):

```bash
./scripts/seed.sh
```

### The index

The query being optimized:

```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

`city` is filtered by equality and `created_at` by a range, so the index is
a composite btree with the equality column first — `(city, created_at)` —
which lets Postgres do a single index range scan instead of a sequential
scan over the whole table. `org_id`, `status`, and `amount` are added via
`INCLUDE` rather than as extra key columns, since they're only ever
selected/aggregated, never filtered or sorted on — this lets Postgres
satisfy the query straight from the index (index-only scan) without a heap
fetch, once the visibility map is up to date (`VACUUM` after a bulk load).

```sql
CREATE INDEX idx_hotel_bookings_city_created_at
    ON hotel_bookings (city, created_at)
    INCLUDE (org_id, status, amount);
```

Check the plan actually uses it:

```bash
docker exec -it hotel_bookings_db psql -U app -d hotel_bookings \
  -c "EXPLAIN ANALYZE SELECT org_id, status, COUNT(*), SUM(amount) FROM hotel_bookings WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days' GROUP BY org_id, status;"
```

## Backup and restore (Part 6)

```bash
./scripts/backup.sh
```

Creates a timestamped custom-format `pg_dump` in `backups/`
(`hotel_bookings_YYYYMMDD_HHMMSS.dump`) and records it as the "latest"
backup in `backups/latest.txt`.

```bash
./scripts/restore.sh                      # restores the latest backup
./scripts/restore.sh backups/some_file.dump  # or a specific one
```

Restore doesn't overwrite the live `hotel_bookings` database — it creates a
brand-new database (`hotel_bookings_restore_<timestamp>`) inside the same
Postgres container and restores the dump into that, which is what "fresh
local database" means here without spinning up a second container.

### Verifying the restore worked

`restore.sh` already does this automatically at the end — it compares
`SELECT COUNT(*) FROM hotel_bookings` between the source database and the
newly restored one and exits non-zero if they don't match. To check by hand:

```bash
docker exec -it hotel_bookings_db psql -U app -d hotel_bookings_restore_<timestamp> \
  -c "SELECT COUNT(*) FROM hotel_bookings; SELECT COUNT(*) FROM booking_events;"
```

Compare those counts against the same queries run against `hotel_bookings`
(the original). You can also spot-check a row:

```bash
docker exec -it hotel_bookings_db psql -U app -d hotel_bookings_restore_<timestamp> \
  -c "SELECT * FROM hotel_bookings ORDER BY created_at DESC LIMIT 1;"
```

If you want to drop a restored test database afterward:

```bash
docker exec -it hotel_bookings_db psql -U app -d postgres -c "DROP DATABASE hotel_bookings_restore_<timestamp>;"
```
