# Домашнее задание к занятию "7.2. Облачные провайдеры и синтаксис Терраформ."

Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. 
Поэтому в рамках первого *необязательного* задания предлагается завести свою учетную запись в AWS (Amazon Web Services).

## Задача 1. Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

Остальные задания можно будет выполнять и без этого аккаунта, но с ним можно будет увидеть полный цикл процессов. 

AWS предоставляет достаточно много бесплатных ресурсов в первых год после регистрации, подробно описано [здесь](https://aws.amazon.com/free/).
1. Создайте аккаут aws.
1. Установите c aws-cli https://aws.amazon.com/cli/.
1. Выполните первичную настройку aws-sli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html.
1. Создайте IAM политику для терраформа c правами
    * AmazonEC2FullAccess
    * AmazonS3FullAccess
    * AmazonDynamoDBFullAccess
    * AmazonRDSFullAccess
    * CloudWatchFullAccess
    * IAMFullAccess
1. Добавьте переменные окружения 
    ```
    export AWS_ACCESS_KEY_ID=(your access key id)
    export AWS_SECRET_ACCESS_KEY=(your secret access key)
    ```
1. Создайте, остановите и удалите ec2 инстанс (любой с пометкой `free tier`) через веб интерфейс. 

В виде результата задания приложите вывод команды `aws configure list`.

---

```
vagrant@vagrant:~$ aws configure list --profile tf_admin_1
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile               tf_admin_1           manual    --profile
access_key     ****************YL6R shared-credentials-file
secret_key     ****************bsbG shared-credentials-file
    region               eu-north-1      config-file    ~/.aws/config
```


## Задача 2. Созданием ec2 через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
1. Зарегистрируйте провайдер для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте
блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион 
внутри блока `provider`.
1. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунта. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения. 
1. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
1. В файле `main.tf` создайте рессурс [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке 
`Example Usage`, но желательно, указать большее количество параметров. 
1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
1. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
    * AWS account ID,
    * AWS user ID,
    * AWS регион, который используется в данный момент, 
    * Приватный IP ec2 инстансы,
    * Идентификатор подсети в которой создан инстанс.  
1. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 


В качестве результата задания предоставьте:
1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
1. Ссылку на репозиторий с исходной конфигурацией терраформа.  
 
---

1. Для создания своего ami образа можно воспользоваться сервисом [EC2 Image Builder](https://eu-north-1.console.aws.amazon.com/imagebuilder/home?region=eu-north-1#/landingPage).

2. [Ссылка на репозиторий с получившейся конфигурацией](https://github.com/maxship/devops-netology/tree/main/terraform).

```tf
#versions.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}
```
```tf
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
```
```tf
#outputs.tf
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "aws_region" {
  value = data.aws_region.current.name
}

output "instance_ip_addr" {
  value = aws_instance.ec2_instance.private_ip
  description = "The private IP address of the main server instance."
}

output "subnet_name" {
  value = aws_instance.ec2_instance.subnet_id
}
```

```
Outputs:

account_id = "233275083821"
aws_region = "eu-north-1"
caller_user = "AIDATMUCHJQW3I5ATZMZO"
instance_ip_addr = "172.31.32.72"
subnet_name = "subnet-b39b21c8"
```
