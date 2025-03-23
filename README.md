## OpsVerse Terraform Modules

This repository contains reusable Terraform modules for AWS infrastructure.

### EC2 Module

#### Inputs:
- `instance_type`: The type of EC2 instance (default: `t2.micro`)
- `ami_id`: The AMI ID to use for the instance

#### Outputs:
- `instance_id`: The ID of the created EC2 instance

#### Usage Example:
```hcl
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.medium"
  ami_id        = "ami-12345678"
}
```

### S3 Module

#### Inputs:
- `bucket_name`: The name of the S3 bucket
- `versioning_enabled`: Whether to enable versioning (default: `false`)

#### Outputs:
- `bucket_arn`: The ARN of the created S3 bucket

#### Usage Example:
```hcl
module "s3" {
  source            = "./modules/s3"
  bucket_name       = "my-terraform-bucket"
  versioning_enabled = true
}
```
