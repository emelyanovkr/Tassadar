output "network_id" {
  description = "ID of the region's default VPC network."
  value       = data.digitalocean_vpc.pxc.id
}

output "firewall_ids" {
  description = "IDs of the bastion and PXC Cloud Firewalls."
  value = {
    bastion  = digitalocean_firewall.bastion.id
    pxc      = digitalocean_firewall.pxc.id
    flowerca = digitalocean_firewall.flowerca.id
  }
}

output "bastion_public_ip" {
  description = "Public IPv4 address of the bastion host."
  value       = digitalocean_droplet.bastion.ipv4_address
}

output "flowerca_instance_id" {
  description = "ID of the FlowerCA Droplet."
  value       = digitalocean_droplet.flowerca.id
}

output "flowerca_public_ip" {
  description = "Public IPv4 address of the FlowerCA Droplet."
  value       = digitalocean_droplet.flowerca.ipv4_address
}

output "flowerca_private_ip" {
  description = "Private IPv4 address of the FlowerCA Droplet."
  value       = digitalocean_droplet.flowerca.ipv4_address_private
}

output "pxc_private_ips" {
  description = "Private IPv4 addresses of the PXC nodes."
  value = {
    for name, droplet in digitalocean_droplet.pxc : name => droplet.ipv4_address_private
  }
}

output "pxc_instance_ids" {
  description = "IDs of the PXC Droplets."
  value = {
    for name, droplet in digitalocean_droplet.pxc : name => droplet.id
  }
}

output "pxc_data_volume_ids" {
  description = "IDs of the PXC data volumes."
  value = {
    for name, volume in digitalocean_volume.pxc_data : name => volume.id
  }
}
