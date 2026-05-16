locals {
  default_tags = merge(
    {
      Project   = var.project_name
      System    = var.system_name
      Env       = var.env
      ManagedBy = "Terraform"
      Stack     = "cognito"
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
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = local.default_tags
  }
}
