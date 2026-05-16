# Terraform Bootstrap (tfstate Backend)

このスタックは、ほかの Terraform スタックが利用する **共有 state バックエンド** (S3 + DynamoDB) を AWS 上に作成する。`dev` / `stg` / `prd` の 3 環境ぶんを **同じコードを使い分けて** 作成する。

## 作成リソース

リソース名は `${system_name}-${environment}` をプレフィックスとして付与する。

| リソース | 役割 |
| --- | --- |
| S3 バケット `<system>-<env>-tfstate-<account-id>` | tfstate の保管。バージョニング・SSE-S3・Public Access Block・HTTPS/TLS 強制を有効化 |
| DynamoDB テーブル `<system>-<env>-tfstate-lock` | state の排他ロック (`LockID` ハッシュキー、PAY_PER_REQUEST、PITR、削除保護) |

利用モジュール:

- [`terraform-aws-modules/s3-bucket/aws`](https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws) `~> 5.13`
- [`terraform-aws-modules/dynamodb-table/aws`](https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws) `~> 5.5`

## ファイル構成

```
terraform/bootstrap/
├── versions.tf     providers.tf   variables.tf
├── main.tf         outputs.tf     README.md
├── envs/
│   ├── dev.tfvars  stg.tfvars     prd.tfvars
└── state/                          # -state=state/<env>.tfstate の格納先 (.gitkeep のみ commit)
```

## 初回 apply (環境ごと)

ローカル state は **`-state` フラグで環境ごとに別ファイル** に分離する (`state/<env>.tfstate`)。`terraform workspace` は使わない。

```bash
cd terraform/bootstrap
terraform init

# dev
terraform plan  -var-file=envs/dev.tfvars -state=state/dev.tfstate
terraform apply -var-file=envs/dev.tfvars -state=state/dev.tfstate

# stg
terraform plan  -var-file=envs/stg.tfvars -state=state/stg.tfstate
terraform apply -var-file=envs/stg.tfvars -state=state/stg.tfstate

# prd
terraform plan  -var-file=envs/prd.tfvars -state=state/prd.tfstate
terraform apply -var-file=envs/prd.tfvars -state=state/prd.tfstate
```

> **注意**: `-var-file` と `-state` の環境名は必ず揃えること (取り違えると別環境のリソースを上書きしてしまう)。

apply 後、output を見たい場合も `-state` を明示:

```bash
terraform output -state=state/dev.tfstate backend_config_snippet
```

apply 後、`terraform output backend_config_snippet` でほかのスタックに貼り付ける `backend "s3"` ブロックが取得できる。

## ほかのスタックでの利用例

```hcl
terraform {
  backend "s3" {
    bucket         = "spring-boot-cognito-sample-dev-tfstate-123456789012"
    key            = "app/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "spring-boot-cognito-sample-dev-tfstate-lock"
    encrypt        = true
  }
}
```

## なぜ bootstrap の state はローカル管理なのか

「state を保存する S3 バケットを作る Terraform」が、その S3 バケットを backend にしようとすると鶏卵問題になる。そのため bootstrap だけは **ローカル state** で運用し、`state/*.tfstate` は Git に含めない (`.gitignore` で除外済み)。

どうしてもリモート化したい場合は、apply 完了後に同ディレクトリへ `backend "s3"` ブロックを追加し:

```bash
terraform init -migrate-state
```

で移行できる。

## 注意

- `force_destroy = false` および `deletion_protection_enabled = true` を設定しているため、`terraform destroy` ではバケット/テーブルは削除されない。意図的に削除する場合は引数を一時的に変更してから実施する。
- `.terraform.lock.hcl` は Git にコミットすること (依存プロバイダーバージョンの再現性確保のため)。
