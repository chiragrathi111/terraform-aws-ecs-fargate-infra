module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  container_port       = var.container_port
  single_nat_gateway   = false # 1 NAT GW per AZ for HA in prod
}

module "rds" {
  source = "../../modules/rds"

  project_name       = var.project_name
  environment        = var.environment
  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.network.rds_sg_id

  instance_class          = "db.r6g.large"
  allocated_storage       = 100
  max_allocated_storage   = 500
  multi_az                = true # HA for prod
  backup_retention_period = 30
  deletion_protection     = true
  skip_final_snapshot     = false
}

module "ecs" {
  source = "../../modules/ecs"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  alb_sg_id          = module.network.alb_sg_id
  ecs_sg_id          = module.network.ecs_sg_id

  container_image = var.container_image
  container_port  = var.container_port
  task_cpu        = 1024
  task_memory     = 2048
  desired_count   = 3
  min_capacity    = 3
  max_capacity    = 10

  environment_variables = {
    APP_ENV = var.environment
  }

  secrets = {
    DB_CREDENTIALS = module.rds.secret_arn
  }
}
