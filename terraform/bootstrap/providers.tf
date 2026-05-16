provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Project   = var.project_name
        System    = var.system_name
        Env       = var.env
        ManagedBy = "Terraform"
        Stack     = "bootstrap"
      },
      var.tags,
    )
  }
}
