output "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state files."
  value       = module.state_bucket.s3_bucket_id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket that stores Terraform state files."
  value       = module.state_bucket.s3_bucket_arn
}

output "state_lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking."
  value       = module.state_lock.dynamodb_table_id
}

output "state_lock_table_arn" {
  description = "ARN of the DynamoDB table used for Terraform state locking."
  value       = module.state_lock.dynamodb_table_arn
}

output "backend_config_snippet" {
  description = "Backend configuration snippet to copy into other Terraform stacks."
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${module.state_bucket.s3_bucket_id}"
        key            = "<stack-name>/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${module.state_lock.dynamodb_table_id}"
        encrypt        = true
      }
    }
  EOT
}
