module "acm_apne1" {
  source = "../../modules/acm"

  providers = {
    aws = aws
  }

  system_name               = var.system_name
  domain_name               = var.domain_name
  subject_alternative_names = local.subject_alternative_names
  zone_id                   = local.zone_id
  name_suffix               = "apne1"
}

module "acm_use1" {
  source = "../../modules/acm"

  providers = {
    aws = aws.use1
  }

  system_name               = var.system_name
  domain_name               = var.domain_name
  subject_alternative_names = local.subject_alternative_names
  zone_id                   = local.zone_id
  name_suffix               = "use1"
}
