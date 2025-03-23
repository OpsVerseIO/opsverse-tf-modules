resource "aws_s3_bucket" "opsverse_bucket" {
  bucket = "opsverse-${var.bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "log"
    enabled = true
    prefix  = "log/"
    expiration {
      days = 90
    }
  }
}

variable "bucket_name" {
  description = "The name of the S3 bucket (without prefix)"
  type        = string
}