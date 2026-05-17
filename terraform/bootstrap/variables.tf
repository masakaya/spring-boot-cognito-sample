variable "envs" {
  description = "List of environment identifiers to create tfstate buckets for. Each entry produces an S3 bucket named '<env>-<system_name>-tfstate-<account_id>'. Use 'shared' for env-cross stacks (domain/*)."
  type        = list(string)
  default     = ["dev", "shared"]
  nullable    = false

  validation {
    condition     = alltrue([for e in var.envs : contains(["dev", "stg", "prd", "shared"], e)])
    error_message = "envs may only contain: dev, stg, prd, shared."
  }

  validation {
    condition     = length(var.envs) == length(distinct(var.envs))
    error_message = "envs must not contain duplicates."
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
  description = "AWS region in which the tfstate buckets are created. Must match the region used in terraform/backends/<env>.hcl."
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
