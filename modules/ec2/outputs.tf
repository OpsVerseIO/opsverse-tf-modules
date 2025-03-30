output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.this.arn
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance (if associated)"
  value       = var.create_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.this.instance_state
}

output "instance_availability_zone" {
  description = "Availability Zone of the EC2 instance"
  value       = aws_instance.this.availability_zone
}

output "security_group_id" {
  description = "ID of the standard security group attached to the instance"
  value       = data.aws_security_group.standard_sg.id
}

output "security_group_name" {
  description = "Name of the standard security group attached to the instance"
  value       = data.aws_security_group.standard_sg.name
}

output "iam_role_name" {
  description = "Name of the standard IAM role attached to the instance"
  value       = data.aws_iam_role.standard_role.name
}

output "iam_role_arn" {
  description = "ARN of the standard IAM role attached to the instance"
  value       = data.aws_iam_role.standard_role.arn
}

output "iam_instance_profile_name" {
  description = "Name of the standard IAM instance profile attached to the instance"
  value       = data.aws_iam_instance_profile.standard_profile.name
}

output "vpc_id" {
  description = "ID of the apps-vpc used for the instance"
  value       = data.aws_vpc.apps_vpc.id
}

output "key_pair_name" {
  description = "Name of the key pair attached to the instance"
  value       = var.create_key_pair && var.key_pair_public_key != "" ? aws_key_pair.instance_key[0].key_name : var.key_name
}

output "eip_id" {
  description = "ID of the Elastic IP attached to the instance (if created)"
  value       = var.create_eip ? aws_eip.this[0].id : null
}

output "eip_public_ip" {
  description = "Public IP address of the Elastic IP attached to the instance (if created)"
  value       = var.create_eip ? aws_eip.this[0].public_ip : null
}

output "ebs_volume_ids" {
  description = "IDs of the additional EBS volumes attached to the instance"
  value       = { for idx, volume in aws_ebs_volume.this : idx => volume.id }
}

output "root_block_device_volume_id" {
  description = "ID of the root block device volume"
  value       = aws_instance.this.root_block_device[0].volume_id
}

output "tags" {
  description = "Tags applied to the EC2 instance"
  value       = aws_instance.this.tags
}