resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.opsverse_official.id]
  subnet_id     = aws_subnet.default.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}

resource "aws_security_group" "opsverse_official" {
  name        = "opsverse-official"
  description = "OpsVerse official security group"
  vpc_id      = aws_vpc.apps_vpc.id
}

resource "aws_vpc" "apps_vpc" {
  cidr_block = "10.0.0.0/16"
}