variable "vpc_id" {
  description = "The VPC ID where the instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID for the EC2 instance"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Key pair name to access the instance"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the instance"
  type        = map(string)
  default     = {}
}