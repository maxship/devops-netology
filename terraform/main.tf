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

locals { # блок переменных
  ec2_instance_type_map = { # в зависимости от названия воркспейса назначаем тип инстанса ec2
    stage = "t3.micro"
    prod  = "t3.micro"
  }
  ec2_instance_count_map = { # задаем количество запущенных инстансов в зависимости от воркспейса
    stage =2
    prod =0
  }
}
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.ec2_instance_type_map[terraform.workspace]
  count = local.ec2_instance_count_map[terraform.workspace]
  vpc_security_group_ids = [aws_security_group.my_ec2_instance.id]
  tags = {
    Name  = "Test Ubuntu instance 1"
    Owner = "Max Shipitsyn"
  }
  user_data = file("apache2.sh")
}

resource "aws_security_group" "my_ec2_instance" {
  name        = "My ec2 test security group"
  description = "My first sg"
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
