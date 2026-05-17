locals {
  default_tags = merge(
    {
      Project   = var.project_name
      System    = var.system_name
      ManagedBy = "Terraform"
      Stack     = "bootstrap"
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
