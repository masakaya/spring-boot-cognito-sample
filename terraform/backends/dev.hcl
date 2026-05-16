# Dev-environment backend config for stacks under terraform/environment/dev/*.
# The 'dev' bucket/table are created by terraform/bootstrap with env=dev.
# Replace <ACCOUNT_ID> with the target AWS account ID.
#
# Usage (from a stack directory, e.g. terraform/environment/dev/cognito):
#   terraform init \
#     -backend-config=../../../backends/dev.hcl \
#     -backend-config=backend.hcl

bucket       = "dev-sbcs-tfstate-<ACCOUNT_ID>"
region       = "ap-northeast-1"
use_lockfile = true
