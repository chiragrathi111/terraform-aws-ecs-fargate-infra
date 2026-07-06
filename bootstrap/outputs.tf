output "state_bucket_name" {
  description = "S3 bucket name — use this in env/*/backend.tf"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name — use this in env/*/backend.tf"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "usage_instructions" {
  description = "Copy these values into your env/*/backend.tf files"
  value       = <<-EOT

    ============================================
    BOOTSTRAP COMPLETE! Update your backend.tf:
    ============================================

    backend "s3" {
      bucket         = "${aws_s3_bucket.terraform_state.id}"
      key            = "app/<ENV>/terraform.tfstate"
      region         = "${var.aws_region}"
      dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
      encrypt        = true
    }

    Replace <ENV> with "dev" or "prod".
    ============================================
  EOT
}
