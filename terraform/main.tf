#main.tf
provider "aws" {
  region  = "eu-north-1"
  profile = "tf_admin_1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
        name   = "name"
        values = ["*-amd64-server-*"]
    }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "Test Ubuntu instance"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
