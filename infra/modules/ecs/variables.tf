variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "container_image" {
  description = "Image to run, e.g. nginx:latest or <account>.dkr.ecr.<region>.amazonaws.com/app:tag."
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "task_cpu" {
  description = "Fargate task-level vCPU units (256, 512, 1024, ...)."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task-level memory in MB."
  type        = number
  default     = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 2
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for DB credentials, injected into the container as env vars."
  type        = string
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "tags" {
  type    = map(string)
  default = {}
}
