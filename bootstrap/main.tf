data "digitalocean_vpc" "tassadar" {
  region = var.region
}
resource "digitalocean_tag" "manager" {
  name = var.manager_name
}
resource "digitalocean_droplet" "manager" {
  name       = var.manager_name
  image      = "ubuntu-24-04-x64"
  region     = var.region
  size       = var.manager_size
  vpc_uuid   = data.digitalocean_vpc.tassadar.id
  ssh_keys   = [var.ssh_key_id]
  monitoring = true
  tags       = [digitalocean_tag.manager.name]

  # Never pass credentials through user_data: it is stored in OpenTofu state.
  user_data = "#cloud-config\n${yamlencode({
    ssh_pwauth     = false
    disable_root   = false
    package_update = true
    packages       = ["ca-certificates", "curl", "gnupg", "git", "python3-venv"]
    write_files = [{
      path        = "/usr/local/sbin/tassadar-install-tools"
      owner       = "root:root"
      permissions = "0755"
      content = templatefile("${path.module}/templates/install-tools.sh.tftpl", {
        opentofu_version     = var.opentofu_version
        ansible_core_version = var.ansible_core_version
      })
    }]
    runcmd = [["/usr/local/sbin/tassadar-install-tools"]]
  })}"
}
resource "digitalocean_firewall" "manager" {
  name        = "${var.manager_name}-firewall"
  droplet_ids = [digitalocean_droplet.manager.id]
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.admin_cidr]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
