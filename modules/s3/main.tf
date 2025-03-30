terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.aws_region
}

# Define default tags to be applied to all resources
locals {
  default_tags = {
    Environment  = var.environment
    CostCenter   = var.cost_center
    Application  = var.application_name
    Owner        = var.owner
    ManagedBy    = "Terraform"
    CreationDate = timestamp()
  }
}

# S3 Bucket with organization's standard configuration
resource "aws_s3_bucket" "this" {
  bucket = var.use_prefix ? null : "opsverse-${var.bucket_name}"
  bucket_prefix = var.use_prefix ? "opsverse-${var.bucket_name}-" : null
  force_destroy = var.force_destroy

  tags = merge(
    local.default_tags,
    {
      Name = "opsverse-${var.bucket_name}"
    },
    var.additional_tags
  )

  lifecycle {
    # Prevent recreation of bucket due to timestamp changes
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# Bucket ACL
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_acl" "this" {
  # Only apply ACL if bucket ownership allows it
  count  = var.object_ownership == "BucketOwnerEnforced" ? 0 : 1
  bucket = aws_s3_bucket.this.id
  acl    = var.acl
  
  # This dependency is necessary to avoid race conditions
  depends_on = [aws_s3_bucket_ownership_controls.this]
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

# Public access block (enforced in all organization buckets)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"
      
      # Optional prefix
      filter {
        prefix = lookup(rule.value, "prefix", null)
      }

      # Expiration configuration
      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration_days", null) != null ? [1] : []
        
        content {
          days = rule.value.expiration_days
        }
      }

      # Transition configuration
      dynamic "transition" {
        for_each = lookup(rule.value, "transitions", [])
        
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      # Noncurrent version expiration
      dynamic "noncurrent_version_expiration" {
        for_each = lookup(rule.value, "noncurrent_version_expiration_days", null) != null ? [1] : []
        
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }

      # Noncurrent version transitions
      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transitions", [])
        
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  # This dependency is to ensure versioning is configured first
  depends_on = [aws_s3_bucket_versioning.this]
}

# CORS configuration if specified
resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.cors_rules

    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers", ["*"])
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = lookup(cors_rule.value, "expose_headers", [])
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", 3000)
    }
  }
}

# Bucket logging configuration if enabled
resource "aws_s3_bucket_logging" "this" {
  count = var.enable_logging ? 1 : 0
  
  bucket = aws_s3_bucket.this.id
  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

# Event notifications
resource "aws_s3_bucket_notification" "this" {
  count  = (length(var.lambda_notifications) + length(var.queue_notifications) + length(var.topic_notifications)) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "lambda_function" {
    for_each = var.lambda_notifications

    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lookup(lambda_function.value, "filter_prefix", null)
      filter_suffix       = lookup(lambda_function.value, "filter_suffix", null)
    }
  }

  dynamic "queue" {
    for_each = var.queue_notifications

    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = lookup(queue.value, "filter_prefix", null)
      filter_suffix = lookup(queue.value, "filter_suffix", null)
    }
  }

  dynamic "topic" {
    for_each = var.topic_notifications

    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = lookup(topic.value, "filter_prefix", null)
      filter_suffix = lookup(topic.value, "filter_suffix", null)
    }
  }
}

# Replication configuration if enabled
resource "aws_s3_bucket_replication_configuration" "this" {
  count = var.replication_configuration != null ? 1 : 0
  
  bucket = aws_s3_bucket.this.id
  role   = var.replication_configuration.role

  dynamic "rule" {
    for_each = var.replication_configuration.rules

    content {
      id     = lookup(rule.value, "id", null)
      status = lookup(rule.value, "status", "Enabled")
      
      filter {
        prefix = lookup(rule.value, "filter_prefix", "")
      }

      destination {
        bucket        = rule.value.destination_bucket
        storage_class = lookup(rule.value, "destination_storage_class", "STANDARD")
      }
    }
  }

  # This dependency ensures versioning is enabled before replication
  depends_on = [aws_s3_bucket_versioning.this]
}

# Optional bucket policy
resource "aws_s3_bucket_policy" "this" {
  count  = var.policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.policy
}