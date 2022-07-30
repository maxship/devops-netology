terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.76.0"
    }
  }
}

provider "yandex" {
  cloud_id  = local.cloud_id
  folder_id = local.folder_id
}