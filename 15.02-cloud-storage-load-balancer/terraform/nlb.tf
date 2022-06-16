resource "yandex_lb_target_group" "lamp-tg" {
  name      = "lamp-target-group"
  region_id = "ru-central1"

#  target {
#    subnet_id = "${yandex_vpc_subnet.my-subnet.id}"
#    address   = "${yandex_compute_instance.my-instance-2.network_interface.0.ip_address}"
#  }
}


resource "yandex_lb_network_load_balancer" "lamp-nlb" {
  name = "network-load-balancer"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.lamp-tg.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}