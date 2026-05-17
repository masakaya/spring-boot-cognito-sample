# Module: cognito

Cognito User Pool 一式 (User Pool / App Client / Hosted UI Custom Domain / SES 連携によるメール送信) を 1 セット作る再利用モジュール。

含まれる主なリソース:

- `aws_cognito_user_pool` (email username + auto-verified email)
- `aws_cognito_user_pool_client` (OAuth2 設定、callback / logout URL)
- `aws_cognito_user_pool_domain` (Hosted UI Custom Domain、`us-east-1` の ACM 証明書を必要とする)
- SES 設定 (sender domain identity、DKIM、Cognito の FROM アドレス連携)

## 使用例

```hcl
module "cognito" {
  source = "../../modules/cognito"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  env             = var.env
  system_name     = var.system_name
  aws_region      = var.aws_region
  custom_domain   = "auth.dev.example.com"
  route53_zone_id = var.route53_zone_id
  callback_urls   = ["https://app.dev.example.com/api/auth/callback/cognito"]
  logout_urls     = ["https://app.dev.example.com/"]
}
```

## ドキュメント

以下は [terraform-docs](https://terraform-docs.io/) で自動生成されている。下記マーカーコメントに挟まれた範囲は **手で編集しない** こと (再生成方法は `terraform/README.md` を参照)。

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_route53_record.auth_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ses_dkim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_sesv2_email_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_email_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where the Cognito user pool resides. Used to build issuer/jwks URLs. | `string` | n/a | yes |
| <a name="input_custom_domain"></a> [custom\_domain](#input\_custom\_domain) | Fully qualified custom domain for Cognito Hosted UI (e.g. auth.dev.example.com). | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment identifier used as the leading segment in resource names (e.g. dev, stg, prd). | `string` | n/a | yes |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route53 hosted zone ID that owns the parent of custom\_domain. Used for ACM DNS validation, Hosted UI alias, and SES DKIM CNAME records. | `string` | n/a | yes |
| <a name="input_system_name"></a> [system\_name](#input\_system\_name) | Short system name used as the second segment in resource names (e.g. sbcs). | `string` | n/a | yes |
| <a name="input_callback_urls"></a> [callback\_urls](#input\_callback\_urls) | OAuth redirect URIs allowed by the user pool client. | `list(string)` | <pre>[<br/>  "http://localhost:3000/api/auth/callback/cognito"<br/>]</pre> | no |
| <a name="input_logout_urls"></a> [logout\_urls](#input\_logout\_urls) | Sign-out redirect URIs allowed by the user pool client. | `list(string)` | <pre>[<br/>  "http://localhost:3000/"<br/>]</pre> | no |
| <a name="input_password_policy"></a> [password\_policy](#input\_password\_policy) | User pool password policy. | <pre>object({<br/>    min_length        = number<br/>    require_lowercase = bool<br/>    require_uppercase = bool<br/>    require_numbers   = bool<br/>    require_symbols   = bool<br/>  })</pre> | <pre>{<br/>  "min_length": 8,<br/>  "require_lowercase": true,<br/>  "require_numbers": true,<br/>  "require_symbols": false,<br/>  "require_uppercase": true<br/>}</pre> | no |
| <a name="input_ses_sender_local_part"></a> [ses\_sender\_local\_part](#input\_ses\_sender\_local\_part) | Local part of the SES verified sender address. Combined with the parent of custom\_domain to form the from address (e.g. "noreply" + "dev.example.com" -> noreply@dev.example.com). | `string` | `"noreply"` | no |
| <a name="input_token_validity"></a> [token\_validity](#input\_token\_validity) | Validity for access / id / refresh tokens. unit must be one of seconds\|minutes\|hours\|days. | <pre>object({<br/>    access  = object({ value = number, unit = string })<br/>    id      = object({ value = number, unit = string })<br/>    refresh = object({ value = number, unit = string })<br/>  })</pre> | <pre>{<br/>  "access": {<br/>    "unit": "minutes",<br/>    "value": 60<br/>  },<br/>  "id": {<br/>    "unit": "minutes",<br/>    "value": 60<br/>  },<br/>  "refresh": {<br/>    "unit": "days",<br/>    "value": 30<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_authorization_endpoint"></a> [authorization\_endpoint](#output\_authorization\_endpoint) | OAuth2 authorization endpoint. |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | Cognito User Pool App Client ID. |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | Cognito User Pool App Client secret. |
| <a name="output_cognito_domain_cloudfront_distribution"></a> [cognito\_domain\_cloudfront\_distribution](#output\_cognito\_domain\_cloudfront\_distribution) | CloudFront distribution domain that backs the Cognito custom domain. Use as the alias target if you manage DNS outside this stack. |
| <a name="output_hosted_ui_base_url"></a> [hosted\_ui\_base\_url](#output\_hosted\_ui\_base\_url) | Base URL of the Hosted UI (custom domain). |
| <a name="output_issuer_url"></a> [issuer\_url](#output\_issuer\_url) | OIDC issuer URL for the user pool (use as spring.security.oauth2.client.provider.cognito.issuer-uri). |
| <a name="output_jwks_uri"></a> [jwks\_uri](#output\_jwks\_uri) | JWKS URI for verifying JWTs issued by the user pool. |
| <a name="output_logout_endpoint"></a> [logout\_endpoint](#output\_logout\_endpoint) | Hosted UI logout endpoint. |
| <a name="output_ses_email_identity_arn"></a> [ses\_email\_identity\_arn](#output\_ses\_email\_identity\_arn) | ARN of the SES email identity used by Cognito to deliver verification / reset / MFA emails. |
| <a name="output_ses_email_identity_domain"></a> [ses\_email\_identity\_domain](#output\_ses\_email\_identity\_domain) | Domain registered as the SES email identity (derived from custom\_domain). |
| <a name="output_ses_from_email_address"></a> [ses\_from\_email\_address](#output\_ses\_from\_email\_address) | From address Cognito uses when sending emails through SES. |
| <a name="output_token_endpoint"></a> [token\_endpoint](#output\_token\_endpoint) | OAuth2 token endpoint. |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | Cognito User Pool ARN. |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | Cognito User Pool ID. |
| <a name="output_userinfo_endpoint"></a> [userinfo\_endpoint](#output\_userinfo\_endpoint) | OIDC userInfo endpoint. |
<!-- END_TF_DOCS -->
