locals {
  bastion_config = {
    image = "ubuntu-24-04-x64"
    size  = "s-1vcpu-1gb"
  }

  pxc_config = {
    image          = "ubuntu-24-04-x64"
    size           = "s-2vcpu-4gb"
    data_disk_size = 30
  }

  pxc_nodes = toset(["pxc-1", "pxc-2", "pxc-3"])
}