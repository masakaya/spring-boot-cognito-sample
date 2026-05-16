resource "aws_route53_zone" "public" {
  name          = var.domain_name
  comment       = "Public hosted zone for ${var.domain_name} (managed by ${var.project_name})"
  force_destroy = false
}
