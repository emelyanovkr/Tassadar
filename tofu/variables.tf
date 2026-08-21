variable "digitalocean_token" {
  description = "DigitalOcean API token used by the provider."
  type        = string
  sensitive   = true
}

variable "name_prefix" {
  description = "Prefix used for DigitalOcean resource names."
  type        = string
  default     = "pxc"
}

variable "region" {
  description = "DigitalOcean region slug used for all Tassadar resources."
  type        = string
  default     = "fra1"
}

variable "admin_cidr" {
  description = "IPv4 CIDR allowed to connect to the bastion over SSH."
  type        = string
}

variable "project_id" {
  description = "Optional DigitalOcean project ID. Resources stay in the default project when null."
  type        = string
  default     = null
  nullable    = true
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key installed on the Droplets."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
