# AWS EC2 Instance Terraform Module (Organization-Specific)

This Terraform module creates an EC2 instance following the organization's policies and standards for internal usage.

## Organization Policies Implemented

- Always uses the designated "apps-vpc" for all instances
- Only deploys instances in private subnets
- Uses the latest Ubuntu AMI automatically
- Restricts instance types to t3.small or t3.medium only
- Applies the organization's standard IAM role and security group
- Includes standardized tagging for all resources


## Usage

```hcl
module "ec2_instance" {
  source = "./modules/ec2/"

  # Required parameters
  name_prefix      = "test-app-server"
  instance_type    = "t3.medium"  # Only t3.small or t3.medium allowed
  application_name = "inventory-system"
  owner            = "platform-team"
  
  # Optional: Environment information
  environment = "production"
  cost_center = "IT-Apps-123"
  
  # Optional: Root volume configuration
  root_block_device = {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
  }
  
  # Optional: Additional EBS volumes
  additional_ebs_volumes = [
    {
      device_name = "/dev/sdf"
      size        = 100
      type        = "gp3"
      encrypted   = true
    }
  ]
  
  # Optional: Additional tags
  additional_tags = {
    BackupSchedule = "daily"
    Compliance     = "sox"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Inputs

Refer to the `variables.tf` file for the complete list of input variables and their descriptions.

## Outputs

Refer to the `outputs.tf` file for the complete list of outputs provided by this module.

## Organization Standards

- **VPC**: Always uses the VPC tagged with name "apps-vpc"
- **Subnet**: Uses private subnets within the apps-vpc
- **AMI**: Automatically selects the latest Ubuntu 22.04 LTS AMI
- **Instance Types**: Limited to t3.small or t3.medium only
- **Security**: Uses the organization's standard security group
- **IAM**: Uses the organization's standard IAM role and instance profile
- **Tagging**: Applies standard organizational tags to all resources

## Best Practices

1. Always specify a meaningful `name_prefix` to identify resources
2. Fill in the required organization tagging fields (application_name, owner)
3. Enable detailed monitoring for critical instances
4. Consider encrypting EBS volumes with organization-specific KMS keys
5. Use standardized naming conventions for consistency

## License

This module is licensed under the MIT License. See the LICENSE file for details.