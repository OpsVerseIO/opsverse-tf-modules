data "aws_vpc" "apps_vpc" {
  filter {
    name   = "tag:Name"
    values = ["apps-vpc"]
  }
}

data "aws_security_group" "opsverse_official" {
  filter {
    name   = "group-name"
    values = ["opsverse-official"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [data.aws_security_group.opsverse_official.id]
  subnet_id     = data.aws_vpc.apps_vpc.id
}
