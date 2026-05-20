###cloud vars


variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  default = "b1g8d1us93gouobagkui"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  default = "b1gjfbcv5j7vudl3n81h"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "zone_b" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}


variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "zone_b_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_net_name" {
  type        = string
  default     = "kuber"
  description = "VPC network"
}


variable "vpc_suba_name" {
  type        = string
  default     = "kuber_a"
  description = "subnet A name"
}

variable "vpc_subb_name" {
  type        = string
  default     = "kuber_b"
  description = "subnet B name"
}


variable "vms_resources" {
  type        = map
  default     = {
    web = {
      cores         = 2
      memory        = 2
      fraction = 5
    }
    db = {
      cores         = 2
      memory        = 4
      fraction = 20
    }
    kubemaster = {
      cores         = 2
      memory        = 8
      fraction      = 20
    }
    kubeworker = {
      cores         = 2
      memory        = 4
      fraction      = 5
    }
  }
}

variable  "vms_md" {
  type       = map
  default    = {
    serial  = 1
    key     = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLFQBGmKA6PF2ywadndvwutcoG4Sq4p00vIE1ECxhx6quoPkQu35Pbfb/zc/lqKeWUnRw+OgS6IVxDAveZ1jZRc= alex@uxtu-note"
  }
}

