#main.tf
provider "aws" {
  region  = "eu-north-1"
  profile = "tf_admin_1" # название профиля задано командой "aws configure" на локальной машине
}

data "aws_ami" "ubuntu" { # ищем последнюю версию убунту
  most_recent = true
  filter {
    name   = "name"
    values = ["*-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.ec2_instance_type_map[terraform.workspace]
  count                  = local.ec2_instance_count_map[terraform.workspace] # количество запущеных инстансов
  vpc_security_group_ids = [aws_security_group.ec2_instance_sg.id]
  user_data              = file("apache2.sh") # вставлен скрипт, устанавливающий apache2
  lifecycle {
    create_before_destroy = true # перед изменением инстанса сначала создается новый, потом гасится старый
  }
  tags = {
    Name  = "Web server ${count.index}"
    Owner = "Max Shipitsyn"
  }

}

/*variable "instances" {
  description = ""
  type        = map(string)
  prod     = {
    instance_type           = "t2.micro",
    instance_count = 2
  }
  stage     = {
  instance_type           = "t2.micro",
  instance_count = 2
  }
}*/


/*resource "aws_instance" "ec2_instance_amazon" {
  ami = ami-0d15082500b576303
  instance_type = "t3.micro"
  for_each = {
    [terraform.workspace]   = 1
  }


  tags = {
    Name = "Server "
  }
}*/

resource "aws_security_group" "ec2_instance_sg" {
  name        = "ec2 test security group"
  description = "Test security group"
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}