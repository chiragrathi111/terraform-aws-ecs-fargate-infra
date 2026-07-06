module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  container_port       = var.container_port
  single_nat_gateway   = true # cheaper for dev - single NAT GW
}

module "rds" {
  source = "../../modules/rds"

  project_name       = var.project_name
  environment        = var.environment
  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.network.rds_sg_id

  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  multi_az             = false # single AZ for dev
  deletion_protection  = false
  skip_final_snapshot  = true
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
  task_cpu        = 256
  task_memory     = 512
  desired_count   = 1
  min_capacity    = 1
  max_capacity    = 2

  environment_variables = {
    APP_ENV = var.environment
  }

  secrets = {
    DB_CREDENTIALS = module.rds.secret_arn
  }
}
