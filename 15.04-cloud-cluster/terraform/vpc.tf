// VPC network
resource "yandex_vpc_network" "vpc-netology" {
  name = "vpc"
}

// public subnets
resource "yandex_vpc_subnet" "public-subnet" {
  name       = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone       = "ru-central1-a"
  network_id = "${yandex_vpc_network.vpc-netology.id}"
}
resource "yandex_vpc_subnet" "public-subnet-a" {
  name       = "public-a"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone       = local.zone-a
  network_id = "${yandex_vpc_network.vpc-netology.id}"
}
resource "yandex_vpc_subnet" "public-subnet-b" {
  name       = "public-b"
  v4_cidr_blocks = ["192.168.30.0/24"]
  zone       = local.zone-b
  network_id = "${yandex_vpc_network.vpc-netology.id}"
}
resource "yandex_vpc_subnet" "public-subnet-c" {
  name       = "public-c"
  v4_cidr_blocks = ["192.168.40.0/24"]
  zone       = local.zone-c
  network_id = "${yandex_vpc_network.vpc-netology.id}"
}
// private subnets
resource "yandex_vpc_subnet" "private-subnet" {
  name       = "private"
  v4_cidr_blocks = ["192.168.50.0/24"]
  zone       = "ru-central1-a"
  network_id = "${yandex_vpc_network.vpc-netology.id}"
  route_table_id = "${yandex_vpc_route_table.routing-table-private.id}"
}
resource "yandex_vpc_subnet" "private-subnet-a" {
  name       = "private-a"
  v4_cidr_blocks = ["192.168.60.0/24"]
  zone       = local.zone-a
  network_id = "${yandex_vpc_network.vpc-netology.id}"
  route_table_id = "${yandex_vpc_route_table.routing-table-private.id}"
}
resource "yandex_vpc_subnet" "private-subnet-b" {
  name       = "private-b"
  v4_cidr_blocks = ["192.168.70.0/24"]
  zone       = local.zone-b
  network_id = "${yandex_vpc_network.vpc-netology.id}"
  route_table_id = "${yandex_vpc_route_table.routing-table-private.id}"
}


// routing table for private subnet
resource "yandex_vpc_route_table" "routing-table-private" {
  network_id = "${yandex_vpc_network.vpc-netology.id}"
  name       = "rt-private"

  static_route {
    destination_prefix = "0.0.0.0/0" # перенаправление трафика со всех адресов
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address # ip адрес NAT инстанса
  }
}



