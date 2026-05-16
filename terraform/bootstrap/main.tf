data "aws_caller_identity" "current" {}

locals {
  name_prefix       = "${var.env}-${var.system_name}"
  state_bucket_name = "${local.name_prefix}-tfstate-${data.aws_caller_identity.current.account_id}"
}

module "state_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.13"

  bucket        = local.state_bucket_name
  force_destroy = false

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  versioning = {
    status = "Enabled"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  lifecycle_rule = [
    {
      id     = "expire-noncurrent-state-versions"
      status = "Enabled"

      noncurrent_version_transition = [
        {
          noncurrent_days = 90
          storage_class   = "STANDARD_IA"
        },
      ]

      noncurrent_version_expiration = {
        noncurrent_days = 365
      }

      abort_incomplete_multipart_upload_days = 7
    },
  ]
}

