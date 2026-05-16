# Shared (env-cross) backend config for stacks under terraform/domain/*.
# The 'shared' bucket/table are created by terraform/bootstrap with env=shared.
# Replace <ACCOUNT_ID> with the target AWS account ID.
#
# Usage (from a stack directory, e.g. terraform/domain/acm):
#   terraform init \
#     -backend-config=../../backends/shared.hcl \
#     -backend-config=backend.hcl

bucket       = "shared-sbcs-tfstate-<ACCOUNT_ID>"
region       = "ap-northeast-1"
use_lockfile = true
