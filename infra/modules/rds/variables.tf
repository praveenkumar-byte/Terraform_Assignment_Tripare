variable "project_name" {
  description = "Short name used to prefix and tag all RDS resources."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID the database subnet group and security group are created in."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group. RDS instances launch into these — no public subnets."
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group ID (typically the ECS tasks' SG) that is allowed to reach RDS on the database port. This is what enforces 'RDS only accessible from ECS/Fargate'."
  type        = string
}

variable "engine" {
  description = "Database engine."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = "16.4"
}

variable "port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "instance_class" {
  description = "RDS instance class. Smaller in dev (e.g. db.t3.micro), larger in prod (e.g. db.r6g.large)."
  type        = string
}

variable "allocated_storage" {
  description = "Initial allocated storage in GB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for RDS storage autoscaling in GB."
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Whether to deploy a standby replica in a second AZ. Should be true in prod, false in dev to save cost."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups. Short in dev (e.g. 1), long in prod (e.g. 30)."
  type        = number
  default     = 1
}

variable "deletion_protection" {
  description = "If true, prevents accidental deletion of the RDS instance via the API/Terraform. Should be true in prod, false in dev."
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Whether to encrypt storage at rest with KMS."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "If true, no final snapshot is taken on destroy. Convenient in dev, should be false in prod."
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Name of the default database created on the instance."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the database."
  type        = string
  default     = "app_admin"
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
