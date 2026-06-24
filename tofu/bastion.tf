data "yandex_compute_image" "bastion" {
  family    = local.bastion_config.image_family
  folder_id = "standard-images"
}

resource "yandex_compute_instance" "bastion" {
  name                      = "${var.name_prefix}-bastion"
  hostname                  = "${var.name_prefix}-bastion"
  platform_id               = local.bastion_config.platform_id
  zone                      = var.subnets[local.bastion_config.subnet_key].zone
  allow_stopping_for_update = true

  resources {
    cores         = local.bastion_config.cores
    memory        = local.bastion_config.memory
    core_fraction = local.bastion_config.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.bastion.id
      size     = local.bastion_config.disk_size
      type     = local.bastion_config.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.pxc[local.bastion_config.subnet_key].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
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
    role       = "bastion"
    managed_by = "opentofu"
  }
}
