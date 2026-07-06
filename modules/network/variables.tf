variable "project_name" {
  type        = string
  description = "Project/prefix name used for tagging resources"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, prod, etc.)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to spread subnets across"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (one per AZ)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (one per AZ)"
}

variable "single_nat_gateway" {
  type        = bool
  description = "true = 1 NAT GW for all AZs (cheaper, for dev). false = 1 NAT GW per AZ (HA, for prod)"
  default     = true
}

variable "container_port" {
  type        = number
  description = "Port the ECS container listens on (used to scope the ECS security group)"
  default     = 8080
}

variable "db_port" {
  type        = number
  description = "Port RDS listens on (used to scope the RDS security group)"
  default     = 5432
}
