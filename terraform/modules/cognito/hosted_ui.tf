resource "aws_cognito_user_pool_client" "this" {
  name         = "${local.name_prefix}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret               = true
  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "profile", "email"]

  access_token_validity  = var.token_validity.access.value
  id_token_validity      = var.token_validity.id.value
  refresh_token_validity = var.token_validity.refresh.value

  token_validity_units {
    access_token  = var.token_validity.access.unit
    id_token      = var.token_validity.id.unit
    refresh_token = var.token_validity.refresh.unit
  }
}

module "acm" {
  source = "../acm"

  providers = {
    aws = aws.us_east_1
  }

  env         = var.env
  system_name = var.system_name
  domain_name = var.custom_domain
  zone_id     = var.route53_zone_id
}

resource "aws_cognito_user_pool_domain" "this" {
  domain          = var.custom_domain
  user_pool_id    = aws_cognito_user_pool.this.id
  certificate_arn = module.acm.certificate_arn
}

resource "aws_route53_record" "auth_alias" {
  zone_id = var.route53_zone_id
  name    = var.custom_domain
  type    = "A"

  alias {
    name                   = aws_cognito_user_pool_domain.this.cloudfront_distribution
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
