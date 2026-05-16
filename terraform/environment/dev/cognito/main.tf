module "cognito" {
  source = "../../../modules/cognito"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  env             = var.env
  system_name     = var.system_name
  aws_region      = var.aws_region
  custom_domain   = var.custom_domain
  route53_zone_id = var.route53_zone_id
  callback_urls   = var.callback_urls
  logout_urls     = var.logout_urls
  token_validity  = var.token_validity
}
