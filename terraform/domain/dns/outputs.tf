output "zone_id" {
  description = "Route53 hosted zone ID."
  value       = aws_route53_zone.public.zone_id
}

output "zone_arn" {
  description = "Route53 hosted zone ARN."
  value       = aws_route53_zone.public.arn
}

output "zone_name" {
  description = "Route53 hosted zone name (apex domain)."
  value       = aws_route53_zone.public.name
}

output "name_servers" {
  description = "Authoritative name servers to register at the domain registrar for delegation."
  value       = aws_route53_zone.public.name_servers
}
