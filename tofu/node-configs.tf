locals {
  bastion_config = {
    subnet_key    = "a"
    image_family  = "ubuntu-2404-lts"
    platform_id   = "standard-v3"
    cores         = 2
    memory        = 2
    core_fraction = 20
    disk_type     = "network-hdd"
    disk_size     = 10
  }

  pxc_config = {
    image_family        = "ubuntu-2404-lts"
    platform_id         = "standard-v3"
    cores               = 2
    memory              = 4
    core_fraction       = 20
    boot_disk_type      = "network-hdd"
    boot_disk_size      = 20
    data_disk_type      = "network-ssd"
    data_disk_size      = 30
    data_disk_blocksize = 4096
  }

  pxc_nodes = {
    pxc-1 = {
      subnet_key = "a"
    }
    pxc-2 = {
      subnet_key = "b"
    }
    pxc-3 = {
      subnet_key = "d"
    }
  }
}
