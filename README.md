# OpsVerse Terraform Modules

This repository contains reusable Terraform modules for AWS infrastructure.

## EC2 Module

### Inputs:
- `instance_type`: The type of EC2 instance (default: `t2.micro`)
- `ami_id`: The AMI ID to use for the instance
- `subnet_id`: The ID of the subnet where the instance will be launched
- `security_group_ids`: A list of security group IDs to associate with the instance

### Outputs:
- `instance_id`: The ID of the created EC2 instance

### Usage Example:
```hcl
module "ec2" {
  source            = "github.com/OpsVerseIO/opsverse-tf-modules//modules/ec2?ref=main"
  instance_type     = "t3.medium"
}
```

---

## S3 Module

### Inputs:
- `bucket_name`: The name of the S3 bucket
- `versioning_enabled`: Whether to enable versioning (default: `false`)

### Outputs:
- `bucket_arn`: The ARN of the created S3 bucket

### Usage Example:
```hcl
module "s3" {
  source            = "github.com/OpsVerseIO/opsverse-tf-modules//modules/s3?ref=main"
  bucket_name       = "my-terraform-bucket"
  versioning_enabled = true
}
```

---

## Using This Repository as a Terraform Registry

To use these modules in your Terraform configuration, reference them directly from this repository:

```hcl
module "ec2" {
  source = "github.com/OpsVerseIO/opsverse-tf-modules//modules/ec2?ref=main"
}

module "s3" {
  source = "github.com/OpsVerseIO/opsverse-tf-modules//modules/s3?ref=main"
}
```

Replace `main` with the desired branch or tag to use a specific version of the module.
---
## State Management
Use S3 for remote state management as below:
```
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "<your repo name>/envs/dev/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
```
