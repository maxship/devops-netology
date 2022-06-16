resource "yandex_compute_instance_group" "lamp_cig" {
    name                    = "lamp-cig"
    folder_id               = var.folder_id
    service_account_id      = "${yandex_iam_service_account.sa.id}"

    instance_template {
        platform_id = "standard-v1"
        resources {
            memory          = 2
            cores           = 2
        }

        boot_disk {
            initialize_params {
                image_id    = "fd827b91d99psvq5fjit" # LAMP
            }
        }

        network_interface {
            subnet_ids      = ["${yandex_vpc_subnet.public-subnet.id}"]
            network_id      = "${yandex_vpc_network.vpc-network.id}"
#            nat             = true
        }

        scheduling_policy {
            preemptible = true  # Прерываемая
        }

        metadata = {
            ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
            user-data       = <<EOF
#!/bin/bash
apt install httpd -y
cd /var/www/html
echo '<html><img src="https://storage.yandexcloud.net/s3-bucket-netology-2022/test-image?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=YCAJEqyI_Z3imZpF-dxZ25V0x%2F20220616%2Fru-central1%2Fs3%2Faws4_request&X-Amz-Date=20220616T142345Z&X-Amz-Expires=3600&X-Amz-Signature=ADD6A854BB4CC5F30CF547095B9403E3769341D4B0C631EBFACD20CD8F718F92&X-Amz-SignedHeaders=host"</html>' > index.html
service httpd start
EOF
      }
   }

    scale_policy {
        fixed_scale {
            size    = 3
        }
    }

    deploy_policy {
        max_creating    = 3
        max_expansion   = 3
        max_deleting    = 3
        max_unavailable = 1
    }

    allocation_policy {
        zones   = [var.zone]
    }

    load_balancer {
        target_group_name   = "lamp-tg"
    }

    health_check {
        http_options {
            port    = 80
            path    = "/"
        }
    }

    depends_on = [
        yandex_iam_service_account.sa,
        yandex_storage_bucket.s3,
        yandex_vpc_network.vpc-network,
        yandex_vpc_subnet.public-subnet,
        yandex_resourcemanager_folder_iam_member.sa-editor
    ]
}