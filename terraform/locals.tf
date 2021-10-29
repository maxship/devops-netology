#locals.tf

locals {
  ec2_instance_type_map = { # в зависимости от названия воркспейса назначаем тип инстанса ec2
    stage   = "t3.micro"    # везде указан один тип, чтобы при развертывании не вылезти за рамки бесплатного тарифа
    prod    = "t3.micro"
    default = "t3.micro"
  }
  ec2_instance_count_map = { # задаем количество запущенных инстансов в зависимости от воркспейса
    stage   = 1
    prod    = 2
    default = 1
  }
}