output "state_bucket_names" {
  description = "Map of env name to the S3 bucket name that holds its tfstate."
  value       = { for env, b in module.state_bucket : env => b.s3_bucket_id }
}

output "state_bucket_arns" {
  description = "Map of env name to the S3 bucket ARN."
  value       = { for env, b in module.state_bucket : env => b.s3_bucket_arn }
}

output "backend_config_snippets" {
  description = "Map of env name to a backend HCL snippet to paste into other Terraform stacks. Uses S3 native state locking (Terraform >= 1.11)."
  value = {
    for env, b in module.state_bucket : env => <<-EOT
      terraform {
        backend "s3" {
          bucket       = "${b.s3_bucket_id}"
          key          = "<stack-name>/terraform.tfstate"
          region       = "${var.aws_region}"
          use_lockfile = true
          encrypt      = true
        }
      }
    EOT
  }
}
