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

resource "aws_instance" "ec2_test_foreach_instance" {  # тестовые инстансы для проверки работы цикла for_each
  for_each = var.test_foreach_instances
  instance_type = each.value.instance_type
  ami = each.value.ami
  tags = each.value.tags
}

resource "aws_security_group" "ec2_instance_sg" { # security group
  name        = "ec2 test security group"
  description = "Test security group"

  dynamic "ingress" { # входящие соединения
    for_each = ["80","443"]
    content {
      from_port   = ingress.value
      protocol    = "tcp"
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }

  }
  egress {  # исходящие соединения
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}