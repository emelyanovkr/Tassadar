resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/templates/inventory.ini.tftpl", {
    bastion_public_ip   = digitalocean_droplet.bastion.ipv4_address
    flowerca_private_ip = digitalocean_droplet.flowerca.ipv4_address_private
    pxc_hosts = {
      for name, droplet in digitalocean_droplet.pxc : name => droplet.ipv4_address_private
    }
    ssh_private_key = trimsuffix(pathexpand(var.ssh_public_key_path), ".pub")
  })
}
