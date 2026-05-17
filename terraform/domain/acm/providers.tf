locals {
  default_tags = merge(
    {
      Project   = var.project_name
      System    = var.system_name
      Env       = "shared"
      ManagedBy = "Terraform"
      Stack     = "acm"
    },
    var.tags,
  )
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"

  default_tags {
    tags = local.default_tags
  }
}
