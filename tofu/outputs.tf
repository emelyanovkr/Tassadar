output "network_id" {
  description = "ID of the VPC network."
  value       = yandex_vpc_network.pxc.id
}

output "nat_gateway_id" {
  description = "ID of the shared egress NAT gateway."
  value       = yandex_vpc_gateway.nat.id
}

output "subnets" {
  description = "Created subnet IDs, zones, and CIDR blocks."
  value = {
    for key, subnet in yandex_vpc_subnet.pxc : key => {
      id   = subnet.id
      zone = subnet.zone
      cidr = subnet.v4_cidr_blocks[0]
    }
  }
}

output "security_group_ids" {
  description = "IDs of the bastion and PXC node security groups."
  value = {
    bastion = yandex_vpc_security_group.bastion.id
    pxc     = yandex_vpc_security_group.pxc.id
  }
}

output "bastion_public_ip" {
  description = "Dynamic public IPv4 address of the bastion host."
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}
