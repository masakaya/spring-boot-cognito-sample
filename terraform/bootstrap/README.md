# Terraform Bootstrap (tfstate Backend)

このスタックは、ほかの Terraform スタックが利用する **共有 state バックエンド** (S3 バケット) を AWS 上に作成する。`var.envs` に列挙された全環境ぶんを **1 回の apply** で作る (`dev`, `shared`, 将来 `stg`/`prd` 追加可)。

state lock は Terraform 1.10 で導入され 1.11 で GA となった **S3 native locking** (`use_lockfile = true`) を利用するため、DynamoDB は作成しない。

このスタック自身の state は **ローカル管理** (`backend "local"`)。「state を入れる S3 を作る Terraform」が自分の state をその S3 に置こうとすると鶏卵問題になるため、bootstrap は構造的に local 固定。これに依存するのは bootstrap だけで、ほかの全スタックは S3 backend を使う。

## 作成リソース

リソース名は `${env}-${system_name}` をプレフィックスとして付与する (例: `dev-sbcs`)。

| リソース | 役割 |
| --- | --- |
| S3 バケット `<env>-<system>-tfstate-<account-id>` (env ごと 1 個) | tfstate と lockfile (`*.tflock`) の保管。バージョニング・SSE-S3・Public Access Block・HTTPS/TLS 強制・非現行版ライフサイクルを有効化 |

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
└── backend.tf                    # backend "local" {}
```

## 変数

| 変数 | 用途 | デフォルト |
| --- | --- | --- |
| `envs` | 作成する環境のリスト。各要素 `e` ごとに `e-<system_name>-tfstate-<account>` が作られる。値は `dev` / `stg` / `prd` / `shared` のみ | `["dev", "shared"]` |
| `system_name` | リソース名の 2 セグメント目に入る短い識別子 (S3 バケット名の 63 文字制限を考慮した短縮形) | `sbcs` |
| `project_name` | `default_tags` の `Project` に使う長い名前 | `spring-boot-cognito-sample` |
| `aws_region` | バケットを作る AWS リージョン (`terraform/backends/<env>.hcl` の region と一致させること) | `ap-northeast-1` |
| `tags` | `default_tags` に追加マージするタグ (任意) | `{}` |

## 運用

```bash
cd terraform/bootstrap
terraform init
terraform plan
terraform apply
```

これだけ。`var.envs` を増やせば次の apply で追加 env のバケットができる:

```bash
terraform apply -var='envs=["dev","stg","prd","shared"]'
```

apply 後、他スタックの `terraform/backends/<env>.hcl` に貼り付ける backend スニペットが output で得られる:

```bash
terraform output -raw 'backend_config_snippets[\"dev\"]'
```

## 注意

- `force_destroy = false` を設定しているため、中身が空でない限り `terraform destroy` ではバケットは削除されない。意図的に削除するときは引数を一時的に変更する。
- `.terraform.lock.hcl` は Git にコミットすること (依存プロバイダーバージョンの再現性確保のため)。
- bootstrap の `terraform.tfstate` (ローカル) は `.gitignore` 済み。紛失すると bucket を Terraform から触れなくなるので、必要なら別途バックアップ (例: `aws s3 cp terraform.tfstate s3://...` を手動運用) しておく。あるいは [`import` ブロック](https://developer.hashicorp.com/terraform/language/import) で復旧する。
