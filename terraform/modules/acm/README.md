# Module: acm

DNS 検証 (Route53) を使った ACM 証明書を 1 枚発行する再利用モジュール。

`apply` 中に検証用の Route53 レコードを作成し、必要なら検証完了まで待機する (`wait_for_validation`)。SAN 追加や CloudFront 用途のため `us-east-1` での発行も呼び出し側で対応可能 (provider alias を渡す)。

## 使用例

```hcl
module "cert_us_east_1" {
  source = "../../modules/acm"

  providers = { aws = aws.us_east_1 }

  env                       = var.env
  system_name               = var.system_name
  domain_name               = "auth.${var.domain_name}"
  subject_alternative_names = ["*.auth.${var.domain_name}"]
  zone_id                   = var.route53_zone_id
  name_suffix               = "use1"
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
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Primary FQDN to issue the ACM certificate for. | `string` | n/a | yes |
| <a name="input_system_name"></a> [system\_name](#input\_system\_name) | Short system name used as the second segment in the Name tag (e.g. sbcs). | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 hosted zone ID used for DNS validation records. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment identifier used as the leading segment in the Name tag (e.g. dev, stg, prd). Empty string omits the env segment (used by env-shared stacks like domain/). | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Optional suffix appended to the Name tag (e.g. "apne1" / "use1"). Empty value omits the suffix. | `string` | `""` | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | SANs added to the certificate (e.g. ["*.example.com"]). Leave empty for a single-domain cert. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags merged into the certificate's tags. | `map(string)` | `{}` | no |
| <a name="input_validation_record_ttl"></a> [validation\_record\_ttl](#input\_validation\_record\_ttl) | TTL applied to the Route53 DNS validation records. | `number` | `60` | no |
| <a name="input_wait_for_validation"></a> [wait\_for\_validation](#input\_wait\_for\_validation) | Whether terraform apply waits until the certificate is fully validated by ACM. | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | ARN of the validated ACM certificate. When wait\_for\_validation is false, falls back to the unvalidated certificate ARN. |
| <a name="output_certificate_domain_name"></a> [certificate\_domain\_name](#output\_certificate\_domain\_name) | Primary FQDN covered by the certificate. |
| <a name="output_domain_validation_options"></a> [domain\_validation\_options](#output\_domain\_validation\_options) | Raw domain\_validation\_options for the certificate. |
| <a name="output_subject_alternative_names"></a> [subject\_alternative\_names](#output\_subject\_alternative\_names) | SANs covered by the certificate. |
| <a name="output_validation_record_fqdns"></a> [validation\_record\_fqdns](#output\_validation\_record\_fqdns) | FQDNs of the Route53 DNS validation records. |
<!-- END_TF_DOCS -->
