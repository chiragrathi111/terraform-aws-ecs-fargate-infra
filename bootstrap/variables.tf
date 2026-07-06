variable "aws_region" {
  type        = string
  description = "AWS region for the state bucket and lock table"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name used as prefix for bucket and table names"
  default     = "myapp"
}
