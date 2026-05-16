output "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state files."
  value       = module.state_bucket.s3_bucket_id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket that stores Terraform state files."
  value       = module.state_bucket.s3_bucket_arn
}

output "backend_config_snippet" {
  description = "Backend configuration snippet to copy into other Terraform stacks. Uses S3 native state locking (Terraform >= 1.11)."
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket       = "${module.state_bucket.s3_bucket_id}"
        key          = "<stack-name>/terraform.tfstate"
        region       = "${var.aws_region}"
        use_lockfile = true
        encrypt      = true
      }
    }
  EOT
}
