variable "system_name" {
  description = "Short system name used in resource naming (e.g. sbcs)."
  type        = string
  default     = "sbcs"
}

variable "project_name" {
  description = "Long project name used in default tags."
  type        = string
  default     = "spring-boot-cognito-sample"
}

variable "aws_region" {
  description = "AWS region for the Route53 provider session (Route53 itself is global)."
  type        = string
  default     = "ap-northeast-1"
}

variable "domain_name" {
  description = "Apex domain name (FQDN, e.g. example.com) for the public hosted zone."
  type        = string

  validation {
    condition = (
      length(var.domain_name) > 0
      && !endswith(var.domain_name, ".")
      && !startswith(var.domain_name, "*.")
      && can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$", var.domain_name))
    )
    error_message = "domain_name must be a lowercase FQDN with at least two labels, no trailing dot, and no wildcard prefix."
  }
}

variable "tags" {
  description = "Additional tags merged into default_tags."
  type        = map(string)
  default     = {}
}
