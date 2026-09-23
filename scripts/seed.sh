#!/usr/bin/env bash
set -euo pipefail

DB_CONTAINER="hotel_bookings_db"
DB_USER="app"
DB_NAME="hotel_bookings"
SEED_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/sql/seed/seed_data.sql"

if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
    echo "Error: ${DB_CONTAINER} is not running. Start it with: docker compose up -d" >&2
    exit 1
fi

echo "Seeding ${DB_NAME}..."
docker exec -i "${DB_CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" < "${SEED_FILE}"

COUNT=$(docker exec -i "${DB_CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -tAc "SELECT COUNT(*) FROM hotel_bookings;")
echo "Done. hotel_bookings now has ${COUNT} rows."
