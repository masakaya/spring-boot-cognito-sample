# Usage (after the initial local-state apply that creates the bucket):
#   terraform init -migrate-state \
#     -backend-config=../backends/<env>.hcl \
#     -backend-config=backend.hcl \
#     -state=state/<env>.tfstate
#
# Common settings (bucket / region / use_lockfile) come from
# terraform/backends/<env>.hcl. Each env's bootstrap state lives in its own
# bucket:
#   env=dev    -> s3://dev-sbcs-tfstate-<account>/bootstrap/terraform.tfstate
#   env=shared -> s3://shared-sbcs-tfstate-<account>/bootstrap/terraform.tfstate

key = "bootstrap/terraform.tfstate"
