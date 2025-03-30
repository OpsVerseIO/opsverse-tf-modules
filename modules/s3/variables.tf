variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name to use for the S3 bucket (will be prefixed with 'opsverse-')"
  type        = string
}

variable "use_prefix" {
  description = "Whether to use bucket_prefix instead of bucket name (adds randomized suffix)"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Whether to allow force destruction of the bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership setting for the bucket. Valid values: BucketOwnerPreferred, ObjectWriter, BucketOwnerEnforced"
  type        = string
  default     = "BucketOwnerEnforced"
}

variable "acl" {
  description = "S3 bucket ACL (Note: only applies if object_ownership is not BucketOwnerEnforced)"
  type        = string
  default     = "private"
}

variable "enable_versioning" {
  description = "Whether to enable versioning on the bucket"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN of KMS key to use for encryption (if not provided, AES256 will be used)"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether to use Amazon S3 Bucket Keys for SSE-KMS"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules to apply to the bucket"
  type        = any
  default     = []
}

variable "cors_rules" {
  description = "List of CORS rules to apply to the bucket"
  type        = any
  default     = []
}

variable "enable_logging" {
  description = "Whether to enable logging for the bucket"
  type        = bool
  default     = false
}

variable "logging_target_bucket" {
  description = "Target bucket for S3 access logs (required if enable_logging is true)"
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Prefix for S3 access logs in the target bucket"
  type        = string
  default     = "logs/"
}

variable "lambda_notifications" {
  description = "List of Lambda function notifications for the bucket"
  type        = any
  default     = []
}

variable "queue_notifications" {
  description = "List of SQS queue notifications for the bucket"
  type        = any
  default     = []
}

variable "topic_notifications" {
  description = "List of SNS topic notifications for the bucket"
  type        = any
  default     = []
}

variable "replication_configuration" {
  description = "Replication configuration for the bucket"
  type        = any
  default     = null
}

variable "policy" {
  description = "Bucket policy as a JSON string"
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Additional tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}

# Organization standard tags
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "cost_center" {
  description = "Cost center for billing and resource tracking"
  type        = string
  default     = "IT-Infrastructure"
}

variable "application_name" {
  description = "Name of the application that this bucket supports"
  type        = string
}

variable "owner" {
  description = "Team or individual owner of this resource"
  type        = string
}