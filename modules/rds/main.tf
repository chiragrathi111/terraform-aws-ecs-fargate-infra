locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Auto-generate a strong password and keep it out of state/plan output & git.
resource "random_password" "master" {
  length  = 20
  special = false # avoids characters RDS engines sometimes reject
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = { Name = "${local.name_prefix}-db-subnet-group" }
}

resource "aws_db_instance" "this" {
  identifier     = "${local.name_prefix}-db"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result
  port     = var.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-final-snapshot"

  tags = { Name = "${local.name_prefix}-db" }
}

# Store the generated credentials in Secrets Manager so ECS tasks can pull
# them at runtime instead of hardcoding env vars.
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${local.name_prefix}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.master.result
    host     = aws_db_instance.this.address
    port     = var.port
    dbname   = var.db_name
  })
}
