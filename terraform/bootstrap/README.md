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
├── backend.tf    backend.hcl              # 初回 apply 後の S3 移行用
└── state/                                  # 初回 apply 専用 (.gitkeep のみ commit)
```

## 変数

`env` のみ環境ごとに変える。残りは `variables.tf` のデフォルト値で運用するため、tfvars ファイルは置かない。必要があれば `-var=<name>=<value>` で個別に上書きする。

| 変数 | 用途 | デフォルト |
| --- | --- | --- |
| `env` | リソース名の先頭セグメント。`dev` / `stg` / `prd` / `shared` のいずれか (`shared` は環境横断スタック用) | — (必須) |
| `system_name` | リソース名の 2 セグメント目に入る短い識別子 (S3 バケット名の 63 文字制限を考慮した短縮形) | `sbcs` |
| `project_name` | `default_tags` の `Project` に使う長い名前 | `spring-boot-cognito-sample` |
| `aws_region` | バックエンドリソースを作る AWS リージョン | `ap-northeast-1` |
| `tags` | `default_tags` に追加マージするタグ (任意) | `{}` |

## 運用フロー

bootstrap は **「初回はローカル state でバケットを作る → 作ったバケットへ state を移行する → 以降は S3 backend で運用」** の 2 フェーズで進める。

### Phase 1 — 初回 apply (ローカル state)

`backend.tf` があると S3 backend として init されてしまうので、最初の `terraform init` は `-backend=false` で抑止する。

```bash
cd terraform/bootstrap
rm -rf .terraform
terraform init -backend=false

# dev
terraform apply -var=env=dev    -state=state/dev.tfstate

# stg / prd / shared も同様
terraform apply -var=env=stg    -state=state/stg.tfstate
terraform apply -var=env=prd    -state=state/prd.tfstate
terraform apply -var=env=shared -state=state/shared.tfstate
```

> **注意**: `-var=env=...` と `-state=state/<env>.tfstate` の env は必ず揃えること。

### Phase 2 — state を S3 へ migrate

Phase 1 で作ったバケットに、bootstrap 自身の state を移行する。env ごとに 1 回ずつ実施:

```bash
# dev
rm -rf .terraform
terraform init -migrate-state \
  -backend-config=../backends/dev.hcl \
  -backend-config=backend.hcl \
  -state=state/dev.tfstate
# プロンプトに yes と回答 → state が s3://dev-sbcs-tfstate-<account>/bootstrap/terraform.tfstate へ移動
# state/dev.tfstate と state/dev.tfstate.backup はもう不要 (削除して構わない)

# shared
rm -rf .terraform
terraform init -migrate-state \
  -backend-config=../backends/shared.hcl \
  -backend-config=backend.hcl \
  -state=state/shared.tfstate
# (stg / prd も同様、対応する backends/<env>.hcl があれば)
```

### 以降の通常運用

env を切り替えるたびに backend 設定が変わるので、`rm -rf .terraform` (または `terraform init -reconfigure`) を挟む。

```bash
cd terraform/bootstrap
rm -rf .terraform
terraform init \
  -backend-config=../backends/dev.hcl \
  -backend-config=backend.hcl
terraform plan  -var=env=dev
terraform apply -var=env=dev
```

apply 後の output:

```bash
terraform output backend_config_snippet   # ほかのスタックに貼り付け可
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

# environment/dev (env=dev スコープ)
cd terraform/environment/dev
terraform init \
  -backend-config=../../backends/dev.hcl \
  -backend-config=backend.hcl
```

複数指定された `-backend-config` は Terraform 内部でマージされる。`<ACCOUNT_ID>` プレースホルダは利用時に置換すること。

## なぜ 2 フェーズ構成なのか

「state を保存する S3 バケットを作る Terraform」自身の state を、その S3 バケットへ最初から書き込むことはできない (鶏卵問題)。そこで:

1. **初回だけ** ローカル state でバケットを作る (`-backend=false` + `-state=state/<env>.tfstate`)
2. バケットが出来た直後に `terraform init -migrate-state` で **そのバケットへ state を移行**
3. 以降は他スタックと同じく S3 backend + `use_lockfile` で運用

これにより bootstrap state も S3 versioning とロックで保護され、複数人開発でも安全。`state/*.tfstate` は `.gitignore` 済みで、移行後は実体ファイルも不要 (`state/` ディレクトリは新環境追加時の Phase 1 のために残す)。

## 注意

- `force_destroy = false` を設定しているため、中身が空でない限り `terraform destroy` ではバケットは削除されない。意図的に削除する場合は引数を一時的に変更してから実施する。
- `.terraform.lock.hcl` は Git にコミットすること (依存プロバイダーバージョンの再現性確保のため)。
- env を切り替えるときは必ず `rm -rf .terraform` (または `terraform init -reconfigure -backend-config=...`) を挟む。`.terraform/` には直前 env の backend 設定がキャッシュされているため、これを忘れると別 env の state を更新してしまう。
