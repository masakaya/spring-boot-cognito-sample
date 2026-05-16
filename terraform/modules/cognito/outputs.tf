locals {
  issuer_url         = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
  hosted_ui_base_url = "https://${aws_cognito_user_pool_domain.this.domain}"
}

output "user_pool_id" {
  description = "Cognito User Pool ID."
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN."
  value       = aws_cognito_user_pool.this.arn
}

output "client_id" {
  description = "Cognito User Pool App Client ID."
  value       = aws_cognito_user_pool_client.this.id
}

output "client_secret" {
  description = "Cognito User Pool App Client secret."
  value       = aws_cognito_user_pool_client.this.client_secret
  sensitive   = true
}

output "issuer_url" {
  description = "OIDC issuer URL for the user pool (use as spring.security.oauth2.client.provider.cognito.issuer-uri)."
  value       = local.issuer_url
}

output "jwks_uri" {
  description = "JWKS URI for verifying JWTs issued by the user pool."
  value       = "${local.issuer_url}/.well-known/jwks.json"
}

output "hosted_ui_base_url" {
  description = "Base URL of the Hosted UI (custom domain)."
  value       = local.hosted_ui_base_url
}

output "authorization_endpoint" {
  description = "OAuth2 authorization endpoint."
  value       = "${local.hosted_ui_base_url}/oauth2/authorize"
}

output "token_endpoint" {
  description = "OAuth2 token endpoint."
  value       = "${local.hosted_ui_base_url}/oauth2/token"
}

output "userinfo_endpoint" {
  description = "OIDC userInfo endpoint."
  value       = "${local.hosted_ui_base_url}/oauth2/userInfo"
}

output "logout_endpoint" {
  description = "Hosted UI logout endpoint."
  value       = "${local.hosted_ui_base_url}/logout"
}

output "cognito_domain_cloudfront_distribution" {
  description = "CloudFront distribution domain that backs the Cognito custom domain. Use as the alias target if you manage DNS outside this stack."
  value       = aws_cognito_user_pool_domain.this.cloudfront_distribution
}

output "ses_email_identity_arn" {
  description = "ARN of the SES email identity used by Cognito to deliver verification / reset / MFA emails."
  value       = aws_sesv2_email_identity.this.arn
}

output "ses_email_identity_domain" {
  description = "Domain registered as the SES email identity (derived from custom_domain)."
  value       = aws_sesv2_email_identity.this.email_identity
}

output "ses_from_email_address" {
  description = "From address Cognito uses when sending emails through SES."
  value       = local.sender_email
}
