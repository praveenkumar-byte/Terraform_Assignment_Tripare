variable "project_name" {
  description = "Short name used to prefix and tag all network resources."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc.) used in tags and naming."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to spread public/private subnets across. Must have at least 2 for ALB + RDS multi-AZ support."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ, in the same order as availability_zones."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per AZ, in the same order as availability_zones."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "If true, create only one NAT gateway (cost saving, used in dev). If false, create one NAT gateway per AZ for high availability (used in prod)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
