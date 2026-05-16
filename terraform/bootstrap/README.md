# Terraform Bootstrap (tfstate Backend)

このスタックは、ほかの Terraform スタックが利用する **共有 state バックエンド** (S3) を AWS 上に作成する。`dev` / `stg` / `prd` の環境別および、環境横断のリソース (例: `domain/dns`, `domain/acm`) 用の `shared` を、同じコードを使い分けて作成する。

state lock は Terraform 1.10 で導入され 1.11 で GA となった **S3 native locking** (`use_lockfile = true`) を利用するため、DynamoDB は作成しない。

## 作成リソース

リソース名は `${env}-${system_name}` をプレフィックスとして付与する (例: `dev-sbcs`)。

| リソース | 役割 |
| --- | --- |
| S3 バケット `<env>-<system>-tfstate-<account-id>` | tfstate および lockfile (`*.tflock`) の保管。バージョニング・SSE-S3・Public Access Block・HTTPS/TLS 強制を有効化 |

## 前提

- Terraform `>= 1.15.0`
- AWS Provider `~> 6.0`
- 利用モジュール:
  - [`terraform-aws-modules/s3-bucket/aws`](https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws) `~> 5.13`

## ファイル構成

```
terraform/bootstrap/
├── versions.tf   providers.tf   variables.tf
├── main.tf       outputs.tf     README.md
├── envs/
│   └── dev.tfvars  stg.tfvars  prd.tfvars  shared.tfvars
└── state/                       # -state=state/<env>.tfstate の格納先 (.gitkeep のみ commit)
```

## 変数

| 変数 | 用途 | 例 |
| --- | --- | --- |
| `env` | リソース名の先頭セグメント。`dev` / `stg` / `prd` / `shared` のいずれか (`shared` は環境横断スタック用) | `dev` |
| `system_name` | リソース名の 2 セグメント目に入る短い識別子 (S3 バケット名の 63 文字制限を考慮した短縮形) | `sbcs` |
| `project_name` | `default_tags` の `Project` に使う長い名前 | `spring-boot-cognito-sample` |
| `aws_region` | バックエンドリソースを作る AWS リージョン | `ap-northeast-1` |
| `tags` | `default_tags` に追加マージするタグ (任意) | `{}` |

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

# shared (環境横断スタック用: domain/dns, domain/acm など)
terraform plan  -var-file=envs/shared.tfvars -state=state/shared.tfstate
terraform apply -var-file=envs/shared.tfvars -state=state/shared.tfstate
```

> **注意**: `-var-file` と `-state` の環境名は必ず揃えること (取り違えると別環境のリソースを上書きしてしまう)。

apply 後、output を見たい場合も `-state` を明示する。`backend_config_snippet` がそのままほかのスタックに貼り付け可能:

```bash
terraform output -state=state/dev.tfstate backend_config_snippet
```

## ほかのスタックでの利用例

各スタックの `backend.tf` は最小定義のみ:

```hcl
terraform {
  backend "s3" {
    encrypt = true
  }
}
```

残りの設定は `-backend-config` で 2 段に分けて渡す。共通部分 (`bucket` / `region` / `use_lockfile`) はスコープごとに `terraform/backends/<scope>.hcl` に集約してあり、スタック固有の `key` のみが各スタックの `backend.hcl` に入る:

```bash
# domain/* (env=shared スコープ)
cd terraform/domain/acm
terraform init \
  -backend-config=../../backends/shared.hcl \
  -backend-config=backend.hcl

# environment/dev/* (env=dev スコープ)
cd terraform/environment/dev/cognito
terraform init \
  -backend-config=../../../backends/dev.hcl \
  -backend-config=backend.hcl
```

複数指定された `-backend-config` は Terraform 内部でマージされる。`<ACCOUNT_ID>` プレースホルダは利用時に置換すること。

## なぜ bootstrap の state はローカル管理なのか

「state を保存する S3 バケットを作る Terraform」が、その S3 バケットを backend にしようとすると鶏卵問題になる。そのため bootstrap だけは **ローカル state** で運用し、`state/*.tfstate` は Git に含めない (`.gitignore` で除外済み)。

どうしてもリモート化したい場合は、apply 完了後に同ディレクトリへ `backend "s3"` ブロックを追加し:

```bash
terraform init -migrate-state
```

で移行できる。

## 注意

- `force_destroy = false` を設定しているため、中身が空でない限り `terraform destroy` ではバケットは削除されない。意図的に削除する場合は引数を一時的に変更してから実施する。
- `.terraform.lock.hcl` は Git にコミットすること (依存プロバイダーバージョンの再現性確保のため)。
- 既に DynamoDB ロックで `terraform init` 済みのスタックがある場合は、backend 設定変更後に `terraform init -reconfigure` (state は移行不要) を実行してロック方式を切り替えること。
