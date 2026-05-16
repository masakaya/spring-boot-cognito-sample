# Usage:
#   terraform init \
#     -backend-config=../../backends/shared.hcl \
#     -backend-config=backend.hcl
# Common settings (bucket / region / use_lockfile) live in
# terraform/backends/shared.hcl.

key = "domain/acm/terraform.tfstate"
