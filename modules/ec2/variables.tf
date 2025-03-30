variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for the name of resources created by this module"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (can only be t3.small or t3.medium)"
  type        = string
  default     = "t3.small"
  
  validation {
    condition     = contains(["t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be either t3.small or t3.medium according to organization policy."
  }
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access (if not creating a new one)"
  type        = string
  default     = null
}

variable "create_key_pair" {
  description = "Whether to create a new key pair"
  type        = bool
  default     = false
}

variable "key_pair_public_key" {
  description = "Public key material for key pair creation"
  type        = string
  default     = ""
  sensitive   = true
}

variable "user_data" {
  description = "User data script for the instance"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Whether to replace the instance when user_data changes"
  type        = bool
  default     = true
}

variable "detailed_monitoring" {
  description = "Whether to enable detailed monitoring for the instance"
  type        = bool
  default     = false
}

variable "disable_api_termination" {
  description = "Whether to enable termination protection"
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "Whether the instance is EBS optimized"
  type        = bool
  default     = null
}

variable "cpu_credits" {
  description = "Credit option for CPU usage (standard or unlimited)"
  type        = string
  default     = "standard"
}

variable "root_block_device" {
  description = "Configuration for the root volume of the instance"
  type        = map(any)
  default = {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }
}

variable "ebs_block_devices" {
  description = "List of maps defining EBS volumes to attach during instance creation"
  type        = list(map(any))
  default     = []
}

variable "additional_ebs_volumes" {
  description = "List of maps defining additional EBS volumes to create and attach to the instance"
  type        = list(map(any))
  default     = []
}

variable "additional_tags" {
  description = "Additional tags to apply to the EC2 instance"
  type        = map(string)
  default     = {}
}

variable "create_eip" {
  description = "Whether to create and associate an Elastic IP"
  type        = bool
  default     = false
}

variable "metadata_http_endpoint" {
  description = "Whether the metadata service is available"
  type        = string
  default     = "enabled"
}

variable "metadata_http_tokens" {
  description = "Whether or not the metadata service requires session tokens (IMDSv2)"
  type        = string
  default     = "required"
}

variable "metadata_http_put_response_hop_limit" {
  description = "The desired HTTP PUT response hop limit for instance metadata requests"
  type        = number
  default     = 1
}

variable "metadata_instance_metadata_tags" {
  description = "Whether to allow access to instance tags from the instance metadata service"
  type        = string
  default     = "enabled"
}

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
  description = "Name of the application that this instance supports"
  type        = string
}

variable "owner" {
  description = "Team or individual owner of this resource"
  type        = string
}

variable "subnet_override" {
  description = "Optional specific subnet ID to use instead of the first private subnet"
  type        = string
  default     = null
}

variable "default_subnet_id" {
  description = "Default subnet ID to use if no private subnets are found in the VPC"
  type        = string
  default     = "subnet-09c5957862a36e90c" # Replace with an actual default subnet ID from your environment
}

variable "standard_security_group_name" {
  description = "Name of the organization's standard security group for EC2 instances"
  type        = string
  default     = "eks-dev-eastus-node-20250311160035075900000004"
}

variable "standard_iam_role_name" {
  description = "Name of the organization's standard IAM role for EC2 instances"
  type        = string
  default     = "node-group-1-eks-node-group-2025031116004943500000000a"
}

variable "standard_instance_profile_name" {
  description = "Name of the organization's standard instance profile for EC2 instances"
  type        = string
  default     = "eks-50cac2fc-979a-5ce3-4f3a-f0c18e74fe2c"
}