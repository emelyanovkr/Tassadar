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
}
