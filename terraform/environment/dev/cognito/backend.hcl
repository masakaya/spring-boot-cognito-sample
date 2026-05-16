# Usage:
#   terraform init \
#     -backend-config=../../../backends/dev.hcl \
#     -backend-config=backend.hcl
# Common settings (bucket / region / use_lockfile) live in
# terraform/backends/dev.hcl.

key = "environment/dev/cognito/terraform.tfstate"
