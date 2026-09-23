aws_region   = "us-west-2"
project_name = "devops-portfolio"

availability_zones   = ["us-west-2a", "us-west-2b"]
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]
single_nat_gateway   = false

container_image = "nginx:latest"
container_port  = 80
task_cpu        = 1024
task_memory     = 2048
desired_count   = 2
min_capacity    = 2
max_capacity    = 6

db_instance_class          = "db.r6g.large"
db_multi_az                = true
db_backup_retention_period = 30
db_deletion_protection     = true
db_skip_final_snapshot     = false