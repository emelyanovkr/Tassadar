terraform {
  required_version = ">= 1.8"

  required_providers {
    local = {
      source = "hashicorp/local"
    }

    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
