locals {
  zone-a       = "ru-central1-a"
  zone-b       = "ru-central1-b"
  zone-c       = "ru-central1-c"
  cloud_id  = "b1g3me49qkcgicgvrgv2"
  folder_id = "b1gj9rb3c81n03tkl2e7"
  cig_count = 3
  object_name = "test-image" # имя загружаемого в бакет объекта
  object_source = "../img/falloutboy.png" # путь к объекту, загружаемому в бакет
  mdb_mysql_user       = "test_user"
  mdb_mysql_password   = "test_pass@#$"
}