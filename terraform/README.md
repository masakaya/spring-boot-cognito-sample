# Terraform Infrastructure

このディレクトリには本プロジェクトの全 Terraform スタックが入っている。新しい環境を立ち上げる、既存環境を更新する際の入口ドキュメント。

## ディレクトリ構成

| パス | 役割 |
| --- | --- |
| `bootstrap/` | tfstate バケット (env ごと) を作成するスタック。最初に apply する。詳細: [bootstrap/README.md](./bootstrap/README.md) |
| `backends/` | 各スタックの `-backend-config` 共通部分。`shared.hcl` (env-cross 用) と `dev.hcl` (dev 用)。`<ACCOUNT_ID>` プレースホルダは利用時に置換 |
| `modules/` | 再利用可能なモジュール (`acm`, `cognito`)。スタックではなく呼び出される側 |
| `domain/` | 環境横断スタック。`dns` (Route53 hosted zone)、`acm` (us-east-1 の証明書、dns を `terraform_remote_state` で参照) |
| `environment/<env>/` | 環境別スタック。`modules/*` を呼び出して env 単位のリソースを構成 (現状 `dev` のみ) |

## 前提ツール / 認証

### Terraform / 補助ツール

`.mise.toml` でバージョン pin:

| ツール | バージョン | 用途 |
| --- | --- | --- |
| `terraform` | 1.15.3 | 本体 |
| `terraform-docs` | 0.24.0 | `modules/*/README.md` の自動生成 |

`terraform/.terraform-version` も併設 (tfenv / asdf / IDE 拡張など mise 以外のツール用)。Terraform をアップグレードするときは **`.mise.toml`、`terraform/.terraform-version`、各スタックの `versions.tf` の `required_version`** を同時更新すること。

```bash
mise install              # .mise.toml の通り install
terraform version         # 1.15.3
mise x -- terraform-docs --version  # v0.24.0
```

### AWS 認証

環境変数 or プロファイル経由。`bootstrap/` は state バケットを作るアカウント (= 利用するアカウント) で実行する。

```bash
aws sts get-caller-identity   # 想定したアカウント / ロールであることを確認
```

## スタック適用順序

```
bootstrap (env=shared) ─┐
                        ├─→ domain/dns ─→ domain/acm ─┐
bootstrap (env=dev)  ───┘                             ├─→ environment/dev
                                                      ┘
```

| 順 | スタック | 内容 | 依存 |
| --- | --- | --- | --- |
| 1 | `bootstrap` (env=shared) | `shared-sbcs-tfstate-<account>` バケット作成 | なし |
| 2 | `bootstrap` (env=dev) | `dev-sbcs-tfstate-<account>` バケット作成 | なし (shared と独立) |
| 3 | `domain/dns` | Route53 public hosted zone | shared バケット |
| 4 | `domain/acm` | ACM 証明書 (us-east-1) | `domain/dns` の outputs (`zone_id`) |
| 5 | `environment/dev` | Cognito User Pool + 周辺 (`modules/cognito`) | `domain/dns`, `domain/acm` の outputs (tfvars 経由で手動転記) |

各スタックの詳細手順は当該ディレクトリ内のコメント / README を参照。

## 通常運用 (各スタックの init / apply)

### bootstrap

2 フェーズ (ローカル apply → S3 へ migrate)。詳細は [bootstrap/README.md](./bootstrap/README.md) を参照。

### domain/* (env-cross)

```bash
cd terraform/domain/dns       # または domain/acm
terraform init \
  -backend-config=../../backends/shared.hcl \
  -backend-config=backend.hcl
terraform plan
terraform apply
```

### environment/dev

```bash
cd terraform/environment/dev
terraform init \
  -backend-config=../../backends/dev.hcl \
  -backend-config=backend.hcl
terraform plan
terraform apply
```

> **env を切り替えるとき**: 同じディレクトリで別 env の backend に init し直す場合は、必ず `rm -rf .terraform` (または `terraform init -reconfigure`) を挟む。

## クロススタック参照

- `domain/acm/data.tf` が `terraform_remote_state.dns` 経由で `domain/dns` の `zone_id` を読み込む
- `environment/dev` は今のところ `terraform.tfvars` に **`route53_zone_id` / `custom_domain` を手動転記** する運用 (将来 `terraform_remote_state` 化を検討)
- `modules/*` はモジュールなので state は持たない (呼び出し元のスタックの state に含まれる)

## .gitignore とコミット対象

| 対象 | 扱い |
| --- | --- |
| `.terraform/` | 無視 (init で再生成可) |
| `*.tfstate`, `*.tfstate.*` | 無視 (機微情報を含むため) |
| `*.auto.tfvars` | 無視 |
| `bootstrap/state/*.tfstate` | 無視 (Phase 1 の一時ファイル) |
| `.terraform.lock.hcl` | **コミット** (依存プロバイダーバージョンの再現性確保) |
| `*.tfvars` (`backend.hcl` 以外) | プロジェクト都合で判断 (秘匿値があれば無視、それ以外はコミット) |

## モジュール ドキュメントの再生成

`modules/*/README.md` の `<!-- BEGIN_TF_DOCS -->` 〜 `<!-- END_TF_DOCS -->` の範囲は [terraform-docs](https://terraform-docs.io/) で自動生成している。手書きの導入文 (使用例など) はマーカー外に書く。設定は `terraform/.terraform-docs.yml`。

variables / outputs / resources を変更したら以下で再生成してから commit する:

```bash
mise x -- terraform-docs -c terraform/.terraform-docs.yml terraform/modules/acm
mise x -- terraform-docs -c terraform/.terraform-docs.yml terraform/modules/cognito
```

## 新環境の追加手順 (例: stg を追加するとき)

1. `terraform/backends/stg.hcl` を作成 (`backends/dev.hcl` を参考に `bucket` を `stg-sbcs-tfstate-<ACCOUNT_ID>` に)
2. `bootstrap` を env=stg で apply → migrate (`bootstrap/README.md` の手順)
3. `terraform/environment/stg/` を新規作成 (`environment/dev/` のファイル一式をコピーして `env` 値や `terraform.tfvars` を調整、`backend.hcl` の `key` を `environment/stg/terraform.tfstate` に)
4. `terraform init` → `apply`
