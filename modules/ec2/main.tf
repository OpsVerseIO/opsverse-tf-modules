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
    Environment       = var.environment
    CostCenter       = var.cost_center
    Application      = var.application_name
    Owner            = var.owner
    ManagedBy        = "Terraform"
    CreationDate     = timestamp()
  }
}

# Data source to find the Apps VPC
data "aws_vpc" "apps_vpc" {
  filter {
    name   = "tag:Name"
    values = ["eks-dev-eastus"]
  }
}

# Get all private subnets in the apps-vpc
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.apps_vpc.id]
  }
  
  # Use an org-specific tag to identify private subnets
  # You may need to adjust this filter based on your actual tagging
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}

# Fallback subnet ID in case no private subnets are found
locals {
  # We'll use the first subnet ID from the list if available, or the provided override
  # If neither is available, we'll use a default value that you can replace
  subnet_id = var.subnet_override != null ? var.subnet_override : (
    length(data.aws_subnets.private.ids) > 0 ? data.aws_subnets.private.ids[0] : var.default_subnet_id
  )
}

# Latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Use the organization's standard security group
data "aws_security_group" "standard_sg" {
  name = var.standard_security_group_name
  vpc_id = data.aws_vpc.apps_vpc.id
}

# Use the organization's standard IAM role for EC2 instances
data "aws_iam_role" "standard_role" {
  name = var.standard_iam_role_name
}

data "aws_iam_instance_profile" "standard_profile" {
  name = var.standard_instance_profile_name
}

# Create key pair if specified
resource "aws_key_pair" "instance_key" {
  count      = var.create_key_pair && var.key_pair_public_key != "" ? 1 : 0
  key_name   = "${var.name_prefix}-key"
  public_key = var.key_pair_public_key

  tags = local.default_tags
}

# EC2 Instance
resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [data.aws_security_group.standard_sg.id]
  associate_public_ip_address = false # Always in private subnet, so no public IP
  key_name                    = var.create_key_pair && var.key_pair_public_key != "" ? aws_key_pair.instance_key[0].key_name : var.key_name
  iam_instance_profile        = data.aws_iam_instance_profile.standard_profile.name
  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change
  monitoring                  = var.detailed_monitoring
  disable_api_termination     = var.disable_api_termination
  ebs_optimized               = var.ebs_optimized

  dynamic "root_block_device" {
    for_each = var.root_block_device != null ? [var.root_block_device] : []
    content {
      volume_type           = lookup(root_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(root_block_device.value, "volume_size", 20)
      iops                  = lookup(root_block_device.value, "iops", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      encrypted             = lookup(root_block_device.value, "encrypted", true)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      # Handle tags separately to avoid type mismatch issues
      tags = local.default_tags
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(ebs_block_device.value, "volume_size", 20)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
    }
  }

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_instance_metadata_tags
  }

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  tags = merge(
    local.default_tags,
    {
      Name = var.name_prefix
    },
    var.additional_tags
  )

  lifecycle {
    create_before_destroy = true
    # Using a fixed set of commonly ignored attributes instead of a variable
    ignore_changes = [
      tags["CreationDate"],
      user_data,
      metadata_options
    ]
  }
}

# EBS Volumes (optional)
resource "aws_ebs_volume" "this" {
  for_each = { for idx, volume in var.additional_ebs_volumes : idx => volume }

  availability_zone = aws_instance.this.availability_zone
  size              = each.value.size
  type              = lookup(each.value, "type", "gp3")
  iops              = lookup(each.value, "iops", null)
  throughput        = lookup(each.value, "throughput", null)
  encrypted         = lookup(each.value, "encrypted", true)
  kms_key_id        = lookup(each.value, "kms_key_id", null)
  snapshot_id       = lookup(each.value, "snapshot_id", null)

  # Tags are handled separately to avoid type issues
  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-volume-${each.key}"
    }
  )
}

# Volume Attachments for additional EBS volumes
resource "aws_volume_attachment" "this" {
  for_each = { for idx, volume in var.additional_ebs_volumes : idx => volume }

  device_name  = each.value.device_name
  volume_id    = aws_ebs_volume.this[each.key].id
  instance_id  = aws_instance.this.id
  force_detach = lookup(each.value, "force_detach", true)
}

# Elastic IP (optional)
resource "aws_eip" "this" {
  count = var.create_eip ? 1 : 0

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-eip"
    }
  )
}

# EIP Association (if EIP is created)
resource "aws_eip_association" "this" {
  count = var.create_eip ? 1 : 0

  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this[0].id
}