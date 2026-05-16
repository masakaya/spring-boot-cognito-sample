provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Project   = var.project_name
        System    = var.system_name
        Env       = "shared"
        ManagedBy = "Terraform"
        Stack     = "dns"
      },
      var.tags,
    )
  }
}
