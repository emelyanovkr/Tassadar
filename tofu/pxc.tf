data "yandex_compute_image" "pxc" {
  family    = local.pxc_config.image_family
  folder_id = "standard-images"
}

resource "yandex_compute_disk" "pxc_data" {
  for_each = local.pxc_nodes

  name       = "${each.key}-data"
  type       = local.pxc_config.data_disk_type
  zone       = var.subnets[each.value.subnet_key].zone
  size       = local.pxc_config.data_disk_size
  block_size = local.pxc_config.data_disk_blocksize

  labels = {
    role       = "pxc-data"
    node       = each.key
    managed_by = "opentofu"
  }
}

resource "yandex_compute_instance" "pxc" {
  for_each = local.pxc_nodes

  name                      = each.key
  hostname                  = each.key
  platform_id               = local.pxc_config.platform_id
  zone                      = var.subnets[each.value.subnet_key].zone
  allow_stopping_for_update = true

  resources {
    cores         = local.pxc_config.cores
    memory        = local.pxc_config.memory
    core_fraction = local.pxc_config.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.pxc.id
      size     = local.pxc_config.boot_disk_size
      type     = local.pxc_config.boot_disk_type
    }
  }

  secondary_disk {
    disk_id     = yandex_compute_disk.pxc_data[each.key].id
    device_name = "data"
    auto_delete = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.pxc[each.value.subnet_key].id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.pxc.id]
  }

  metadata = {
    ssh-keys           = "ubuntu:${trimspace(file(pathexpand(var.ssh_public_key_path)))}"
    serial-port-enable = "0"
    user-data          = <<-EOT
      #cloud-config
      ssh_pwauth: false
      disable_root: true
    EOT
  }

  labels = {
    role       = "pxc"
    node       = each.key
    managed_by = "opentofu"
  }
}
