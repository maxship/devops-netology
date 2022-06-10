# NAT instance
#resource "yandex_compute_instance" "nat-public" {
#  platform_id = "standard-v1"
#  name = "nat-public"
#  zone = "ru-central1-a"
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