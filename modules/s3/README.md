# AWS S3 Bucket Terraform Module (Organization-Specific)

This Terraform module creates an S3 bucket following the organization's policies and standards for internal usage.

## Organization Policies Implemented

- Enforces bucket name prefixing with "opsverse-"
- Blocks all public access by default
- Enables server-side encryption by default (AES256)
- Configurable versioning (enabled by default)
- Applies the organization's standard tagging system
- Enforces secure bucket configurations

## Features

- Comprehensive lifecycle rule management
- CORS configuration support
- Bucket logging
- Event notifications (Lambda, SQS, SNS)
- Replication configuration
- Custom bucket policies
- KMS encryption support

## Usage

```hcl
module "s3_bucket" {
  source = "./path/to/module"

  # Required parameters
  bucket_name      = "customer-data"
  application_name = "crm-system"
  owner            = "data-team"
  
  # Optional: Environment information
  environment = "production"
  cost_center = "IT-Apps-123"
  
  # Optional: Lifecycle rules
  lifecycle_rules = [
    {
      id      = "log-expiry"
      enabled = true
      prefix  = "logs/"
      expiration_days = 90
    },
    {
      id      = "archive-transition"
      enabled = true
      prefix  = "archives/"
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]
  
  # Optional: Additional tags
  additional_tags = {
    DataClassification = "confidential"
    BackupSchedule     = "daily"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Input Variables

Refer to the `variables.tf` file for the complete list of input variables and their descriptions.

## Outputs

Refer to the `outputs.tf` file for the complete list of outputs provided by this module.

## Security Best Practices

1. All buckets have public access blocking enabled by default
2. Server-side encryption is enabled by default using AES256
3. Bucket versioning is enabled by default to prevent accidental deletions
4. Option to use KMS keys for enhanced encryption security
5. All bucket operations are logged when logging is enabled

## Organization Standards

- **Naming**: All bucket names are prefixed with "opsverse-" 
- **Security**: Public access is blocked on all buckets
- **Encryption**: All data is encrypted at rest
- **Tagging**: Standard organizational tags are applied to all buckets

## Lifecycle Management

This module provides flexible lifecycle rule configuration for:

- Transitioning objects to cost-effective storage classes
- Setting expiration policies for objects
- Managing versioned objects
- Cleaning up incomplete multipart uploads

## Notifications

The module supports configuring event notifications to:

- Lambda functions
- SQS queues
- SNS topics

This allows integration with other AWS services for event-driven workflows.

## License

This module is licensed under the MIT License. See the LICENSE file for details.