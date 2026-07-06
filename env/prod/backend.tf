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

  # Remote state + locking.
  # FIRST run: cd bootstrap && terraform apply
  # Then copy the bucket name from bootstrap output here.
  backend "s3" {
    bucket         = "myapp-terraform-state-REPLACE_WITH_BOOTSTRAP_OUTPUT"
    key            = "app/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "myapp-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
