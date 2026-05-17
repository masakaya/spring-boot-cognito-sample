variable "env" {
  description = "Environment identifier used as the leading segment of resource names (e.g. <env>-<system>-tfstate-<account>). Pass 'shared' for env-cross stacks (domain/*)."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["dev", "stg", "prd", "shared"], var.env)
    error_message = "env must be one of: dev, stg, prd, shared."
  }
}

variable "system_name" {
  description = "Short system name used as the second segment of resource names. Must satisfy the S3 bucket name charset because it feeds into the bucket name."
  type        = string
  default     = "sbcs"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,18}[a-z0-9])?$", var.system_name))
    error_message = "system_name must be 1-20 chars of lowercase alphanumerics or hyphens, starting and ending with alphanumeric."
  }
}

variable "project_name" {
  description = "Long project name placed in the Project tag (display-only, not used in resource names)."
  type        = string
  default     = "spring-boot-cognito-sample"
  nullable    = false
}

variable "aws_region" {
  description = "AWS region in which the tfstate bucket is created. Must match the region used in terraform/backends/<env>.hcl."
  type        = string
  default     = "ap-northeast-1"
  nullable    = false
}

variable "tags" {
  description = "Extra tags merged on top of default_tags."
  type        = map(string)
  default     = {}
  nullable    = false
}
