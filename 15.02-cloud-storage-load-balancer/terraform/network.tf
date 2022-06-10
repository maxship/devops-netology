# VPC network
resource "yandex_vpc_network" "vpc-network" {
  name = "vpc"
}

# public subnet
resource "yandex_vpc_subnet" "public-subnet" {
  name       = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone       = "ru-central1-a"
  network_id = "${yandex_vpc_network.vpc-network.id}"
}

# private subnet
#resource "yandex_vpc_subnet" "private-subnet" {
#  name       = "private"
#  v4_cidr_blocks = ["192.168.20.0/24"]
#  zone       = "ru-central1-a"
#  network_id = "${yandex_vpc_network.vpc-network.id}"
#  route_table_id = "${yandex_vpc_route_table.routing-table-private.id}"
#}

# routing table for private subnet
#resource "yandex_vpc_route_table" "routing-table-private" {
#  network_id = "${yandex_vpc_network.vpc-network.id}"
#  name       = "rt-private"
#
#  static_route {
#    destination_prefix = "0.0.0.0/0" # перенаправление трафика со всех адресов
#    next_hop_address   = yandex_compute_instance.nat-public.network_interface.0.ip_address # ip адрес NAT инстанса
#  }
#}