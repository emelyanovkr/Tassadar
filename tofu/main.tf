# Root module for production infrastructure.

resource "digitalocean_ssh_key" "admin" {
  name       = "${var.name_prefix}-admin"
  public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

resource "digitalocean_tag" "bastion" {
  name = "${var.name_prefix}-bastion"
}

resource "digitalocean_tag" "pxc" {
  name = "${var.name_prefix}-pxc"
}

resource "digitalocean_project_resources" "tassadar" {
  count = var.project_id == null ? 0 : 1

  project = var.project_id
  resources = concat(
    [digitalocean_droplet.bastion.urn],
    [for droplet in digitalocean_droplet.pxc : droplet.urn],
    [for volume in digitalocean_volume.pxc_data : volume.urn],
  )
}
