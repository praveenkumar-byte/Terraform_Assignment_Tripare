aws_region  = "us-west-2"
project_name = "devops-portfolio"

availability_zones   = ["us-west-2a", "us-west-2b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
single_nat_gateway   = true

container_image = "nginx:latest"
container_port  = 80
task_cpu        = 256
task_memory     = 512
desired_count   = 1
min_capacity    = 1
max_capacity    = 2

db_instance_class          = "db.t3.micro"
db_multi_az                = false
db_backup_retention_period = 1
db_deletion_protection     = false
db_skip_final_snapshot     = true
