variable "env" {
  description = "Environment identifier used as the leading segment in resource names (e.g. dev, stg, prd)."
  type        = string
}

variable "system_name" {
  description = "Short system name used as the second segment in resource names (e.g. sbcs)."
  type        = string
}

variable "aws_region" {
  description = "AWS region where the Cognito user pool resides. Used to build issuer/jwks URLs."
  type        = string
}

variable "custom_domain" {
  description = "Fully qualified custom domain for Cognito Hosted UI (e.g. auth.dev.example.com)."
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID that owns the parent of custom_domain. Used for ACM DNS validation and alias record."
  type        = string
}

variable "callback_urls" {
  description = "OAuth redirect URIs allowed by the user pool client."
  type        = list(string)
  default     = ["http://localhost:3000/api/auth/callback/cognito"]
}

variable "logout_urls" {
  description = "Sign-out redirect URIs allowed by the user pool client."
  type        = list(string)
  default     = ["http://localhost:3000/"]
}

variable "token_validity" {
  description = "Validity for access / id / refresh tokens. unit must be one of seconds|minutes|hours|days."
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

variable "password_policy" {
  description = "User pool password policy."
  type = object({
    min_length        = number
    require_lowercase = bool
    require_uppercase = bool
    require_numbers   = bool
    require_symbols   = bool
  })
  default = {
    min_length        = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }
}
