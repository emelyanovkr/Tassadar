resource "digitalocean_firewall" "bastion" {
  name = "${var.name_prefix}-bastion-firewall"
  tags = [digitalocean_tag.bastion.name]

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

resource "digitalocean_firewall" "pxc" {
  name = "${var.name_prefix}-nodes-firewall"
  tags = [digitalocean_tag.pxc.name]

  inbound_rule {
    protocol    = "tcp"
    port_range  = "22"
    source_tags = [digitalocean_tag.bastion.name]
  }

  inbound_rule {
    protocol    = "tcp"
    port_range  = "3306"
    source_tags = [digitalocean_tag.bastion.name]
  }

  inbound_rule {
    protocol    = "tcp"
    port_range  = "4444"
    source_tags = [digitalocean_tag.pxc.name]
  }

  inbound_rule {
    protocol    = "tcp"
    port_range  = "4567-4568"
    source_tags = [digitalocean_tag.pxc.name]
  }

  inbound_rule {
    protocol    = "udp"
    port_range  = "4567"
    source_tags = [digitalocean_tag.pxc.name]
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
