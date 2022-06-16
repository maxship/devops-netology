// Создаем балансировщик
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
    target_group_id = "${yandex_compute_instance_group.lamp_cig.load_balancer.0.target_group_id}"

    // Проверка состояния
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}