resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/templates/inventory.ini.tftpl", {
    bastion_public_ip = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
    pxc_hosts = {
      for name, instance in yandex_compute_instance.pxc : name => instance.network_interface[0].ip_address
    }
    ssh_private_key = trimsuffix(pathexpand(var.ssh_public_key_path), ".pub")
  })
}
