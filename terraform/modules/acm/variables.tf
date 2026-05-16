variable "env" {
  description = "Environment identifier used as the leading segment in the Name tag (e.g. dev, stg, prd). Empty string omits the env segment (used by env-shared stacks like domain/)."
  type        = string
  default     = ""
}

variable "system_name" {
  description = "Short system name used as the second segment in the Name tag (e.g. sbcs)."
  type        = string
}

variable "domain_name" {
  description = "Primary FQDN to issue the ACM certificate for."
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

variable "subject_alternative_names" {
  description = "SANs added to the certificate (e.g. [\"*.example.com\"]). Leave empty for a single-domain cert."
  type        = list(string)
  default     = []
}

variable "zone_id" {
  description = "Route53 hosted zone ID used for DNS validation records."
  type        = string
}

variable "validation_record_ttl" {
  description = "TTL applied to the Route53 DNS validation records."
  type        = number
  default     = 60
}

variable "wait_for_validation" {
  description = "Whether terraform apply waits until the certificate is fully validated by ACM."
  type        = bool
  default     = true
}

variable "name_suffix" {
  description = "Optional suffix appended to the Name tag (e.g. \"apne1\" / \"use1\"). Empty value omits the suffix."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags merged into the certificate's tags."
  type        = map(string)
  default     = {}
}
