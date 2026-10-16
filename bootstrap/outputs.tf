output "manager_instance_id" {
  description = "DigitalOcean ID of the management Droplet."
  value       = digitalocean_droplet.manager.id
}
output "manager_public_ip" {
  description = "Public IPv4 address used for administrator SSH access."
  value       = digitalocean_droplet.manager.ipv4_address
}
output "manager_private_ip" {
  description = "Private IPv4 address in the existing Tassadar VPC."
  value       = digitalocean_droplet.manager.ipv4_address_private
}
