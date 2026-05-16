# Usage:
#   terraform init -backend-config=backend.hcl
# Replace <ACCOUNT_ID> with the target AWS account ID.
# The 'shared' bucket is created by bootstrap with env=shared.

bucket         = "shared-sbcs-tfstate-<ACCOUNT_ID>"
dynamodb_table = "shared-sbcs-tfstate-lock"
region         = "ap-northeast-1"
key            = "domain/dns/terraform.tfstate"
