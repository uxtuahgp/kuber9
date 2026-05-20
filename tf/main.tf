resource "yandex_vpc_network" "kuber" {
  name = var.vpc_net_name
}
resource "yandex_vpc_subnet" "kuber" {
  name           = var.vpc_suba_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.kuber.id
  v4_cidr_blocks = var.default_cidr
}


data "yandex_compute_image" "ubuntu" {
  family = var.vm_ansible_family
}
resource "yandex_compute_instance" "kube-master-01" {
  name            = "kube-master-01"
  hostname        = "kube-master-01"
  platform_id = var.vm_ansible_platform
  resources {
    cores         = var.vms_resources.kubemaster.cores
    memory        = var.vms_resources.kubemaster.memory
    core_fraction = var.vms_resources.kubemaster.fraction
 }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.kuber.id
    nat       = true
  }


  metadata = {
    serial-port-enable = var.vms_md.serial
    ssh-keys           = "core:${var.vms_md.key}"
  }
}


resource "yandex_compute_instance" "kube-worker-01" {
  name            = "kube-worker-01"
  hostname        = "kube-worker-01"
  platform_id = var.vm_ansible_platform
  resources {
    cores         = var.vms_resources.kubeworker.cores
    memory        = var.vms_resources.kubeworker.memory
    core_fraction = var.vms_resources.kubeworker.fraction
 }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.kuber.id
    nat       = true
  }


  metadata = {
    serial-port-enable = var.vms_md.serial
    ssh-keys           = "core:${var.vms_md.key}"
  }
}


resource "yandex_compute_instance" "kube-worker-02" {
  name            = "kube-worker-02"
  hostname        = "kube-worker-02"
  platform_id = var.vm_ansible_platform
  resources {
    cores         = var.vms_resources.kubeworker.cores
    memory        = var.vms_resources.kubeworker.memory
    core_fraction = var.vms_resources.kubeworker.fraction
 }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.kuber.id
    nat       = true
  }


  metadata = {
    serial-port-enable = var.vms_md.serial
    ssh-keys           = "core:${var.vms_md.key}"
  }
}

resource "yandex_compute_instance" "kube-worker-03" {
  name            = "kube-worker-03"
  hostname        = "kube-worker-03"
  platform_id = var.vm_ansible_platform
  resources {
    cores         = var.vms_resources.kubeworker.cores
    memory        = var.vms_resources.kubeworker.memory
    core_fraction = var.vms_resources.kubeworker.fraction
 }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.kuber.id
    nat       = true
  }


  metadata = {
    serial-port-enable = var.vms_md.serial
    ssh-keys           = "core:${var.vms_md.key}"
  }
}
resource "yandex_compute_instance" "kube-worker-04" {
  name            = "kube-worker-04"
  hostname        = "kube-worker-04"
  platform_id = var.vm_ansible_platform
  resources {
    cores         = var.vms_resources.kubeworker.cores
    memory        = var.vms_resources.kubeworker.memory
    core_fraction = var.vms_resources.kubeworker.fraction
 }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.kuber.id
    nat       = true
  }


  metadata = {
    serial-port-enable = var.vms_md.serial
    ssh-keys           = "core:${var.vms_md.key}"
  }
}
