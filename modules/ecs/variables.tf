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

variable "alb_sg_id" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}

variable "container_image" {
  type        = string
  description = "Full image URI, e.g. <account>.dkr.ecr.<region>.amazonaws.com/app:tag"
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "task_cpu" {
  type        = number
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096)"
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "Fargate task memory in MB"
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
  default = 3
}

variable "environment_variables" {
  type        = map(string)
  description = "Plain env vars injected into the container"
  default     = {}
}

variable "secrets" {
  type        = map(string)
  description = "Map of ENV_VAR_NAME => Secrets Manager / SSM ARN, injected as ECS task secrets"
  default     = {}
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "log_retention_days" {
  type    = number
  default = 14
}
