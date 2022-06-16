// VPC network
resource "yandex_vpc_network" "vpc-network" {
  name = "vpc"
}

// public subnet
resource "yandex_vpc_subnet" "public-subnet" {
  name       = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone       = var.zone
  network_id = "${yandex_vpc_network.vpc-network.id}"
}

// private subnet
#resource "yandex_vpc_subnet" "private-subnet" {
#  name       = "private"
#  v4_cidr_blocks = ["192.168.20.0/24"]
#  zone       = var.zone
#  network_id = "${yandex_vpc_network.vpc-network.id}"
#  route_table_id = "${yandex_vpc_route_table.routing-table-private.id}"
#}

// routing table for private subnet
#resource "yandex_vpc_route_table" "routing-table-private" {
#  network_id = "${yandex_vpc_network.vpc-network.id}"
#  name       = "rt-private"
#
#  static_route {
#    destination_prefix = "0.0.0.0/0" # перенаправление трафика со всех адресов
#    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address # ip адрес NAT инстанса
#  }
#}

// NAT instance
#resource "yandex_compute_instance" "nat-instance" {
#  platform_id = "standard-v1"
#  name = "nat-public"
#  zone = var.zone
#
#  resources {
#    cores = 2
#    memory = 4
#  }
#
#  boot_disk {
#    initialize_params {
#      image_id = "fd80mrhj8fl2oe87o4e1" # nat-instance-ubuntu
#    }
#  }
#
#  network_interface {
#    subnet_id = "${yandex_vpc_subnet.public-subnet.id}"
#    ip_address = "192.168.10.254"
#    nat = true
#  }
#
#  metadata = {
#    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
#  }
#}