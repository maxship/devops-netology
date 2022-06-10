resource "yandex_lb_target_group" "tg-1" {
  name      = "target-group-1"
  region_id = "ru-central1"

  target {
    subnet_id = "${yandex_vpc_subnet.public-subnet.id}"
    address   = "${yandex_compute_instance.vm-lamp[*].network_interface.0.ip_address}"
  }
}