output "certificate_arn" {
  description = "ARN of the validated ACM certificate. When wait_for_validation is false, falls back to the unvalidated certificate ARN."
  value = (
    var.wait_for_validation
    ? aws_acm_certificate_validation.this[0].certificate_arn
    : aws_acm_certificate.this.arn
  )
}

output "certificate_domain_name" {
  description = "Primary FQDN covered by the certificate."
  value       = aws_acm_certificate.this.domain_name
}

output "subject_alternative_names" {
  description = "SANs covered by the certificate."
  value       = aws_acm_certificate.this.subject_alternative_names
}

output "domain_validation_options" {
  description = "Raw domain_validation_options for the certificate."
  value       = aws_acm_certificate.this.domain_validation_options
}

output "validation_record_fqdns" {
  description = "FQDNs of the Route53 DNS validation records."
  value       = [for r in aws_route53_record.validation : r.fqdn]
}
