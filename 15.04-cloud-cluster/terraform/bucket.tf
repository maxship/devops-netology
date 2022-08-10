// Создаем сервисный аккаунт
resource "yandex_iam_service_account" "sa" {
  name        = "service-account"
  description = "service account to manage S3"
}

// Назначаем права
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = local.folder_id
  role = "editor"
  member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
  depends_on = [yandex_iam_service_account.sa]
}

// Создаем ключ доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Создаем ключ шифрования
resource "yandex_kms_symmetric_key" "sym-key-1" {
  name              = "Ключ для шифрования бакетов"
  description       = "Symmetric-Key-1"
  default_algorithm = "AES_256"
  rotation_period   = "168h"
}

// Создаем бакет
resource "yandex_storage_bucket" "s3" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "s3-bucket-netology-2022"
  // Включаем шифрование на стороне сервера по умолчанию
  server_side_encryption_configuration {
    rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = yandex_kms_symmetric_key.sym-key-1.id
      sse_algorithm     = "aws:kms"
    }
  }
  }
}

// Загружаем тестовую картинку в бакет
resource "yandex_storage_object" "test-object" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = yandex_storage_bucket.s3.id
  key        = local.object_name # имя объекта в бакете
  source     = local.object_source # относительный путь к файлу, загружаемому как объект.
  acl = "public-read" # открываем доступ на чтение всем
  depends_on = [yandex_storage_bucket.s3]
}
