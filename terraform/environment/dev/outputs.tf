output "user_pool_id" {
  description = "Cognito User Pool ID."
  value       = module.cognito.user_pool_id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN."
  value       = module.cognito.user_pool_arn
}

output "client_id" {
  description = "Cognito User Pool App Client ID."
  value       = module.cognito.client_id
}

output "client_secret" {
  description = "Cognito User Pool App Client secret."
  value       = module.cognito.client_secret
  sensitive   = true
}

output "issuer_url" {
  description = "OIDC issuer URL (Spring Boot spring.security.oauth2.client.provider.cognito.issuer-uri)."
  value       = module.cognito.issuer_url
}

output "jwks_uri" {
  description = "JWKS URI."
  value       = module.cognito.jwks_uri
}

output "hosted_ui_base_url" {
  description = "Hosted UI base URL (custom domain)."
  value       = module.cognito.hosted_ui_base_url
}

output "authorization_endpoint" {
  description = "OAuth2 authorization endpoint."
  value       = module.cognito.authorization_endpoint
}

output "token_endpoint" {
  description = "OAuth2 token endpoint."
  value       = module.cognito.token_endpoint
}

output "userinfo_endpoint" {
  description = "OIDC userInfo endpoint."
  value       = module.cognito.userinfo_endpoint
}

output "logout_endpoint" {
  description = "Hosted UI logout endpoint."
  value       = module.cognito.logout_endpoint
}

output "cognito_domain_cloudfront_distribution" {
  description = "CloudFront distribution backing the Cognito custom domain."
  value       = module.cognito.cognito_domain_cloudfront_distribution
}

output "ses_email_identity_arn" {
  description = "SES email identity ARN used by Cognito."
  value       = module.cognito.ses_email_identity_arn
}

output "ses_email_identity_domain" {
  description = "Domain registered as the SES email identity."
  value       = module.cognito.ses_email_identity_domain
}

output "ses_from_email_address" {
  description = "From address Cognito uses for emails (SES sender)."
  value       = module.cognito.ses_from_email_address
}
