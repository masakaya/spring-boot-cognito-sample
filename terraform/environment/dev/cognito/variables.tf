variable "env" {
  description = "Environment identifier (dev|stg|prd)."
  type        = string
  default     = "dev"
}

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
  description = "Primary AWS region."
  type        = string
  default     = "ap-northeast-1"
}

variable "custom_domain" {
  description = "Fully qualified custom domain for Cognito Hosted UI (e.g. auth.dev.example.com)."
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID that owns the parent of custom_domain."
  type        = string
}

variable "callback_urls" {
  description = "OAuth redirect URIs allowed by the user pool client."
  type        = list(string)
  default     = ["http://localhost:3000/callback/auth"]
}

variable "logout_urls" {
  description = "Sign-out redirect URIs allowed by the user pool client."
  type        = list(string)
  default     = ["http://localhost:3000/"]
}

variable "token_validity" {
  description = "Token validity overrides (see modules/cognito for shape)."
  type = object({
    access  = object({ value = number, unit = string })
    id      = object({ value = number, unit = string })
    refresh = object({ value = number, unit = string })
  })
  default = {
    access  = { value = 60, unit = "minutes" }
    id      = { value = 60, unit = "minutes" }
    refresh = { value = 30, unit = "days" }
  }
}

variable "tags" {
  description = "Additional tags merged into provider default_tags."
  type        = map(string)
  default     = {}
}
