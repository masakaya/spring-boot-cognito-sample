data "aws_caller_identity" "current" {}

locals {
  subject_alternative_names = ["*.${var.domain_name}"]
  tfstate_bucket            = "shared-${var.system_name}-tfstate-${data.aws_caller_identity.current.account_id}"
  tfstate_lock_table        = "shared-${var.system_name}-tfstate-lock"
}

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket         = local.tfstate_bucket
    key            = "domain/dns/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = local.tfstate_lock_table
    encrypt        = true
  }
}

locals {
  zone_id = data.terraform_remote_state.dns.outputs.zone_id
}
