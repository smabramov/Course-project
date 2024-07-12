terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}


provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id                 = "b1gttf81lmg2v759uobi"
  folder_id                = "b1g8381i07tsfq06pnmc"
}


