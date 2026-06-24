resource "yandex_vpc_security_group" "bastion" {
  name       = "${var.name_prefix}-bastion-sg"
  network_id = yandex_vpc_network.pxc.id

  ingress {
    description    = "SSH with public key authentication"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "pxc" {
  name       = "${var.name_prefix}-nodes-sg"
  network_id = yandex_vpc_network.pxc.id

  ingress {
    description       = "SSH from the bastion host"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  ingress {
    description       = "MySQL access from the bastion host"
    protocol          = "TCP"
    port              = 3306
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  ingress {
    description       = "PXC state snapshot transfer"
    protocol          = "TCP"
    port              = 4444
    predefined_target = "self_security_group"
  }

  ingress {
    description       = "PXC replication and incremental state transfer"
    protocol          = "TCP"
    from_port         = 4567
    to_port           = 4568
    predefined_target = "self_security_group"
  }

  ingress {
    description       = "PXC multicast replication"
    protocol          = "UDP"
    port              = 4567
    predefined_target = "self_security_group"
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
