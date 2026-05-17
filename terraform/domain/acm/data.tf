data "aws_caller_identity" "current" {}

locals {
  tfstate_bucket = "shared-${var.system_name}-tfstate-${data.aws_caller_identity.current.account_id}"
}

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket       = local.tfstate_bucket
    key          = "domain/dns/terraform.tfstate"
    region       = var.aws_region
    use_lockfile = true
    encrypt      = true
  }
}

locals {
  zone_id                   = data.terraform_remote_state.dns.outputs.zone_id
  domain_name               = trimsuffix(data.terraform_remote_state.dns.outputs.zone_name, ".")
  subject_alternative_names = ["*.${local.domain_name}"]
}
