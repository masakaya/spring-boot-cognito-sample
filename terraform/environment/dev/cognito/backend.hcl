# Usage:
#   terraform init -backend-config=backend.hcl
# Replace <ACCOUNT_ID> with the target AWS account ID (matches the bucket created by terraform/bootstrap).

bucket         = "dev-sbcs-tfstate-<ACCOUNT_ID>"
dynamodb_table = "dev-sbcs-tfstate-lock"
region         = "ap-northeast-1"
key            = "environment/dev/cognito/terraform.tfstate"
