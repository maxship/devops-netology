locals {
  zone-a       = "ru-central1-a"
  zone-b       = "ru-central1-b"
  zone-c       = "ru-central1-c"
  cloud_id  = "b1g3me49qkcgicgvrgv2"
  folder_id = "b1g4fb7qmqpe9rvo57q2"
  cig_count = 3
  bucket_name = "s3-bucket-netology-2022"
  object_name = "test-image" # имя загружаемого в бакет объекта
  object_source = "../img/falloutboy.png" # путь к объекту, загружаемому в бакет
  key_name    = "symmetric-key-1" # Имя ключа KMS.
  key_desc    = "Ключ для шифрования бакетов"
  mdb_mysql_user       = "test_user"
  mdb_mysql_password   = "test_pass@#$"
}