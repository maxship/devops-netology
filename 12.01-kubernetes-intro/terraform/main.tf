terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.68.0"
    }
  }
}

provider "yandex" {
  cloud_id  = "b1g3me49qkcgicgvrgv2"
  folder_id = "b1g4fb7qmqpe9rvo57q2"
  zone      = "ru-central1-a"
}

# Инстанс minikube
resource "yandex_compute_instance" "minikube-01" {
  name = "minikube-master"
  platform_id = "standard-v1"
  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8mfc6omiki5govl68h" # Ubuntu-20.04
      size = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-01.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }  
}


resource "yandex_vpc_network" "network-01" {
  name = "network-01"
}

resource "yandex_vpc_subnet" "subnet-01" {
  name       = "subnet-01"
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone       = "ru-central1-a"
  network_id = "${yandex_vpc_network.network-01.id}"
}
