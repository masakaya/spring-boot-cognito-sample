variable "env" {
  description = "Environment identifier used as the leading segment in resource names. Use 'shared' to create a tfstate bucket for env-shared stacks (domain/dns, domain/acm)."
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prd", "shared"], var.env)
    error_message = "env must be one of: dev, stg, prd, shared."
  }
}

variable "system_name" {
  description = "Short system name used as the second segment in resource names (e.g. sbcs)."
  type        = string
  default     = "sbcs"
}

variable "project_name" {
  description = "Long project name used in default tags."
  type        = string
  default     = "spring-boot-cognito-sample"
}

variable "aws_region" {
  description = "AWS region where the tfstate backend resources are created."
  type        = string
  default     = "ap-northeast-1"
}

variable "tags" {
  description = "Additional tags merged into default_tags."
  type        = map(string)
  default     = {}
}
