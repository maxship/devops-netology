// DB cluster
resource "yandex_mdb_mysql_cluster" "cluster-mysql-netology" {
  name                = "mysql-netology"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.vpc-netology.id
  version             = "8.0"
  folder_id           = local.folder_id
  deletion_protection = false // "true" - защита от непреднамеренного удаления

  backup_window_start {
    hours   = 23
    minutes = 59
  }
  resources {
    resource_preset_id = "b1.medium" // Intel Broadwell с производительнотью CPU до 50%
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  maintenance_window {
    type = "ANYTIME"
  }

  host {
    zone      = local.zone-a
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
  }

  host {
    zone      = local.zone-b
    subnet_id = yandex_vpc_subnet.private-subnet-b.id
  }

}

// DB
resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.cluster-mysql-netology.id
  name       = "netology_db"
  depends_on = [yandex_mdb_mysql_cluster.cluster-mysql-netology]
}

// DB user
resource "yandex_mdb_mysql_user" "test_user" {
  cluster_id = yandex_mdb_mysql_cluster.cluster-mysql-netology.id
  name       = local.mdb_mysql_user
  password   = local.mdb_mysql_password


  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }


  connection_limits {
    max_questions_per_hour   = 10
    max_updates_per_hour     = 20
    max_connections_per_hour = 30
    max_user_connections     = 10
  }

  global_permissions = ["PROCESS"]

  authentication_plugin = "SHA256_PASSWORD"
}