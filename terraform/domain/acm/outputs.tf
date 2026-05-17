output "certificate_arn_apne1" {
  description = "ARN of the ACM certificate issued in ap-northeast-1 (for ALB / API Gateway)."
  value       = module.acm_apne1.certificate_arn
}

output "certificate_arn_use1" {
  description = "ARN of the ACM certificate issued in us-east-1 (for CloudFront)."
  value       = module.acm_use1.certificate_arn
}

output "certificate_domain_name" {
  description = "Primary domain name covered by the certificates."
  value       = var.domain_name
}

output "certificate_subject_alternative_names" {
  description = "SANs covered by the certificates."
  value       = local.subject_alternative_names
}

output "validation_route53_record_fqdns_apne1" {
  description = "FQDNs of the Route53 validation records created for the ap-northeast-1 certificate."
  value       = module.acm_apne1.validation_record_fqdns
}

output "validation_route53_record_fqdns_use1" {
  description = "FQDNs of the Route53 validation records created for the us-east-1 certificate."
  value       = module.acm_use1.validation_record_fqdns
}
