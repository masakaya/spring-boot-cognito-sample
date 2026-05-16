locals {
  custom_domain_labels = split(".", var.custom_domain)
  ses_domain           = join(".", slice(local.custom_domain_labels, 1, length(local.custom_domain_labels)))
  sender_email         = "${var.ses_sender_local_part}@${local.ses_domain}"
}

resource "aws_sesv2_email_identity" "this" {
  email_identity = local.ses_domain

  tags = {
    Name = "${local.name_prefix}-ses-identity"
  }
}

resource "aws_route53_record" "ses_dkim" {
  for_each = toset(aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens)

  zone_id         = var.route53_zone_id
  name            = "${each.value}._domainkey.${local.ses_domain}"
  type            = "CNAME"
  ttl             = 600
  records         = ["${each.value}.dkim.amazonses.com"]
  allow_overwrite = true
}
