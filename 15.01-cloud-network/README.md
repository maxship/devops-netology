# Домашнее задание к занятию "15.1. Организация сети"

Домашнее задание будет состоять из обязательной части, которую необходимо выполнить на провайдере Яндекс.Облако и дополнительной части в AWS по желанию. Все домашние задания в 15 блоке связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
Все задания требуется выполнить с помощью Terraform, результатом выполненного домашнего задания будет код в репозитории. 

Перед началом работ следует настроить доступ до облачных ресурсов из Terraform используя материалы прошлых лекций и [ДЗ](https://github.com/netology-code/virt-homeworks/tree/master/07-terraform-02-syntax ). А также заранее выбрать регион (в случае AWS) и зону.

---
## Задание 1. Яндекс.Облако (обязательное к выполнению)

1. Создать VPC.
- Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.
- Создать в vpc subnet с названием public, сетью 192.168.10.0/24.
- Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1
- Создать в этой публичной подсети виртуалку с публичным IP и подключиться к ней, убедиться что есть доступ к интернету.
3. Приватная подсеть.
- Создать в vpc subnet с названием private, сетью 192.168.20.0/24.
- Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс
- Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее и убедиться что есть доступ к интернету

Resource terraform для ЯО
- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet)
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table)
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance)
---
## Задание 2*. AWS (необязательное к выполнению)

1. Создать VPC.
- Cоздать пустую VPC с подсетью 10.10.0.0/16.
2. Публичная подсеть.
- Создать в vpc subnet с названием public, сетью 10.10.1.0/24
- Разрешить в данной subnet присвоение public IP по-умолчанию. 
- Создать Internet gateway 
- Добавить в таблицу маршрутизации маршрут, направляющий весь исходящий трафик в Internet gateway.
- Создать security group с разрешающими правилами на SSH и ICMP. Привязать данную security-group на все создаваемые в данном ДЗ виртуалки
- Создать в этой подсети виртуалку и убедиться, что инстанс имеет публичный IP. Подключиться к ней, убедиться что есть доступ к интернету.
- Добавить NAT gateway в public subnet.
3. Приватная подсеть.
- Создать в vpc subnet с названием private, сетью 10.10.2.0/24
- Создать отдельную таблицу маршрутизации и привязать ее к private-подсети
- Добавить Route, направляющий весь исходящий трафик private сети в NAT.
- Создать виртуалку в приватной сети.
- Подключиться к ней по SSH по приватному IP через виртуалку, созданную ранее в публичной подсети и убедиться, что с виртуалки есть выход в интернет.

Resource terraform
- [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
- [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)
- [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)

---

# Решение

## Задание 1. Яндекс.Облако

### 1. Создание VPC.

```terraform
# VPC network
resource "yandex_vpc_network" "vpc-network" {
  name = "vpc"
}
```
### 2. Публичная подсеть.

Создаем публичную подсеть.

```terraform
# public subnet
resource "yandex_vpc_subnet" "public-subnet" {
  name       = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone       = "ru-central1-a"
  network_id = "${yandex_vpc_network.vpc-network.id}"
}
```

Создаем NAT инстанс и присваиваем ему внутренний IP адрес в публичной сети. В качестве образа указываем готовый образ NAT на основе Ubuntu `fd80mrhj8fl2oe87o4e1`.

```terraform
# NAT instance
resource "yandex_compute_instance" "nat-public" {
  platform_id = "standard-v1"
  name = "nat-public"
  zone = "ru-central1-a"

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1" # nat-instance-ubuntu
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public-subnet.id}"
    ip_address = "192.168.10.254"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
```

Создаем в публичной подсети тестовую ВМ с внешним IP.

```terraform
# VM in public subnet
resource "yandex_compute_instance" "vm-public" {
  platform_id = "standard-v1"
  allow_stopping_for_update = true
  name = "vm-public"
  zone = "ru-central1-a"

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8mfc6omiki5govl68h" # Ubuntu-20.04
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public-subnet.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
```
Подключаемся к этой ВМ и проверяем доступность интернета.

```shell
# применяем конфигурацию
$ terraform apply
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

nat_public_external_ip = "51.250.86.203"
vm_private_internal_ip = "192.168.20.27"
vm_public_external_ip = "51.250.81.228"

# подключаемся к публичной ВМ
$ ssh ubuntu@51.250.81.228

# проверяем внешний IP
ubuntu@fhmauirago7b8tenqhv8:~$ curl 2ip.ru
51.250.81.228
```

### 3. Приватная подсеть.

Создаем таблицу маршрутизации, направляющую весь исходящий трафик private сети в NAT-инстанс.

```terraform
# routing table for private subnet
resource "yandex_vpc_route_table" "routing-table-private" {
  network_id = "${yandex_vpc_network.vpc-network.id}"
  name       = "rt-private"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-public.network_interface.0.ip_address # ip адрес NAT инстанса
  }
}
```
Создаем приватную подсеть.

```terraform
# private subnet
resource "yandex_vpc_subnet" "private-subnet" {
  name       = "private"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone       = "ru-central1-a"
  network_id = "${yandex_vpc_network.vpc-network.id}"
  route_table_id = "${yandex_vpc_route_table.routing-table-private.id}"
}
```

Создаем ВМ в приватной подсети.

```terraform
# VM in private subnet
resource "yandex_compute_instance" "vm-private" {
  platform_id = "standard-v1"
  allow_stopping_for_update = true
  name = "vm-private"
  zone = "ru-central1-a"

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8mfc6omiki5govl68h" # Ubuntu-20.04
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.private-subnet.id}"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
```
Подключаемся в этой ВМ через виртуалку, созданную ранее проверяем доступ к интернету.

```shell
# копируем на vm-public приватный ssh ключ, т.к. без него не получится подсоединиться из одной вм в другую.
$ scp /home/maxship/.ssh/id_ed25519 ubuntu@51.250.81.228:/home/ubuntu/.ssh/
id_ed25519                                                                                                            100%  464     3.6KB/s   00:00
$ ssh ubuntu@51.250.81.228
ubuntu@fhmauirago7b8tenqhv8:~$ ls ~/.ssh
authorized_keys  id_ed25519

# Подсоединяемся к vm-private из vm-public.
ubuntu@fhmauirago7b8tenqhv8:~$ ssh ubuntu@192.168.20.27
...
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-96-generic x86_64)
...

# Проверяем внешний IP. Он совпадает с IP NAT инстанса, что и требовалось получить.
ubuntu@fhmr654qjt2eomm6mt20:~$ curl 2ip.ru
51.250.86.203
```

