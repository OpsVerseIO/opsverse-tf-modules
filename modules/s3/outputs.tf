output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.this.region
}

output "versioning_enabled" {
  description = "Whether versioning is enabled on the bucket"
  value       = var.enable_versioning
}

output "encryption_type" {
  description = "Type of encryption used for the bucket"
  value       = var.kms_key_id == null ? "AES256" : "aws:kms"
}

output "kms_key_id" {
  description = "ARN of KMS key used for encryption (if any)"
  value       = var.kms_key_id
}

output "public_access_blocked" {
  description = "Whether public access is blocked on the bucket"
  value       = (
    aws_s3_bucket_public_access_block.this.block_public_acls &&
    aws_s3_bucket_public_access_block.this.block_public_policy &&
    aws_s3_bucket_public_access_block.this.ignore_public_acls &&
    aws_s3_bucket_public_access_block.this.restrict_public_buckets
  )
}

output "lifecycle_rules_count" {
  description = "Number of lifecycle rules applied to the bucket"
  value       = length(var.lifecycle_rules)
}

output "cors_rules_count" {
  description = "Number of CORS rules applied to the bucket"
  value       = length(var.cors_rules)
}

output "tags" {
  description = "Tags applied to the S3 bucket"
  value       = aws_s3_bucket.this.tags
}