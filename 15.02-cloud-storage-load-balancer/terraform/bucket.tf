// Создаем сервисный аккаунт
resource "yandex_iam_service_account" "sa" {
  name        = "service-account"
  description = "service account to manage S3"
}

// Назначаем права
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role = "editor"
  member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
  depends_on = [yandex_iam_service_account.sa]
}

// Создаем ключ доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Создаем бакет
resource "yandex_storage_bucket" "s3" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "s3-bucket-netology-2022"
}

// Загружаем тестовую картинку в бакет
resource "yandex_storage_object" "test-object" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "s3-bucket-netology-2022"
  key        = "test-image" # имя объекта в бакете
  source     = "../img/falloutboy.png" # относительный путь к файлу, загружаемому как объект.
  acl = "public-read" # открываем доступ на чтение всем
  depends_on = [yandex_storage_bucket.s3]
}
