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
  description = "Primary AWS region for the ACM certificate (used by regional services such as ALB / API Gateway)."
  type        = string
  default     = "ap-northeast-1"
}

variable "tags" {
  description = "Additional tags merged into default_tags."
  type        = map(string)
  default     = {}
}
