# ============================================================
# Bootstrap: S3 Bucket + DynamoDB Table for Terraform State
# ============================================================
# Run this ONCE before deploying any environment.
# This creates the backend infrastructure that all environments use.
#
# Usage:
#   cd bootstrap
#   terraform init
#   terraform apply
#
# After this completes, you can run env/dev and env/prod.
# ============================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Bootstrap uses LOCAL state (chicken-and-egg: can't use S3 before it exists)
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

# -------------------------------------------------------
# Generate a unique suffix to make bucket name globally unique
# -------------------------------------------------------
resource "random_id" "bucket_suffix" {
  byte_length = 4 # produces 8 hex characters (e.g., "a1b2c3d4")
}

# -------------------------------------------------------
# S3 Bucket for Terraform State
# -------------------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state-${random_id.bucket_suffix.hex}"

  # Prevent accidental deletion of this bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    ManagedBy   = "terraform-bootstrap"
    Project     = var.project_name
  }
}

# Enable versioning — lets you recover previous state files
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Block all public access — state files should NEVER be public
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------------------------------
# DynamoDB Table for State Locking
# -------------------------------------------------------
# When one developer runs `terraform apply`, this table holds a lock.
# If another developer tries to run `apply` at the same time,
# they get: "Error: state locked by <first developer>"
# This prevents two people from modifying infrastructure simultaneously.
# -------------------------------------------------------
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST" # No capacity planning needed, very cheap
  hash_key     = "LockID"          # Required by Terraform

  attribute {
    name = "LockID"
    type = "S" # String type
  }

  tags = {
    Name        = "Terraform State Lock Table"
    ManagedBy   = "terraform-bootstrap"
    Project     = var.project_name
  }
}
