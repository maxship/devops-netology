# NAT instance
resource "yandex_compute_instance" "nat-instance" {
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

  scheduling_policy {
    preemptible = true  # Прерываемая
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

  scheduling_policy {
    preemptible = true  # Прерываемая
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public-subnet.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

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

  scheduling_policy {
    preemptible = true  # Прерываемая
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.private-subnet.id}"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}