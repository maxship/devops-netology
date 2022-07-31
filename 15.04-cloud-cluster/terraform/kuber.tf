// k8s cluster
resource "yandex_kubernetes_cluster" k8s-cluster {
  name        = "k8s-cluster"
  description = "kubernetes cluster"
  release_channel = "STABLE"
  network_policy_provider = "CALICO"

  network_id = "${yandex_vpc_network.vpc-netology.id}"

  kms_provider {
    key_id = "${yandex_kms_symmetric_key.sym-key-1.id}" // ключ шифрования
  }

  master {
    version   = "1.19"
    public_ip = true

    regional {
      region = "ru-central1"

      location {
        zone      = "${yandex_vpc_subnet.public-subnet-a.zone}"
        subnet_id = "${yandex_vpc_subnet.public-subnet-a.id}"
      }

      location {
        zone      = "${yandex_vpc_subnet.public-subnet-b.zone}"
        subnet_id = "${yandex_vpc_subnet.public-subnet-b.id}"
      }

      location {
        zone      = "${yandex_vpc_subnet.public-subnet-c.zone}"
        subnet_id = "${yandex_vpc_subnet.public-subnet-c.id}"
      }
    }

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "15:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = "${yandex_iam_service_account.k8s-editor.id}"
  node_service_account_id = "${yandex_iam_service_account.k8s-editor.id}"
      depends_on              = [
    yandex_resourcemanager_folder_iam_binding.editor,
    yandex_resourcemanager_folder_iam_binding.images-puller,
  ]
}

resource "yandex_iam_service_account" "k8s-editor" {
  name        = "k8s-editor"
  description = "service account for kubernetes"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  # Сервисному аккаунту назначается роль "editor".
  folder_id = local.folder_id
  role      = "editor"
  members   = [
   "serviceAccount:${yandex_iam_service_account.k8s-editor.id}"
  ]
  depends_on = [yandex_iam_service_account.k8s-editor]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = local.folder_id
  role      = "container-registry.images.puller"
  members   = [
   "serviceAccount:${yandex_iam_service_account.k8s-editor.id}"
  ]
  depends_on = [yandex_iam_service_account.k8s-editor]

}

// k8s node group
resource "yandex_kubernetes_node_group" "k8s-node-group" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-cluster.id}"
  name        = "k8s-node-roup"
  description = "kubernetes node group"
  version     = "1.19"

  instance_template {
    platform_id = "standard-v2"

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
    }

    network_interface {
      nat                = true
      subnet_ids         = [
        "${yandex_vpc_subnet.public-subnet-a.id}"
      ]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      initial = 3
      max     = 6
      min     = 3
    }
  }

  allocation_policy {
      location {
        zone      = "${yandex_vpc_subnet.public-subnet-a.zone}"
      }
  }

}