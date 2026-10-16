variable "digitalocean_token" {
  description = "DigitalOcean API token supplied by the caller."
  type        = string
  sensitive   = true
}
variable "ssh_key_id" {
  description = "ID of an existing DigitalOcean SSH key installed on the manager."
  type        = string
  validation {
    condition     = can(regex("^[0-9]+$", var.ssh_key_id))
    error_message = "ssh_key_id must be the numeric ID of an existing DigitalOcean SSH key."
  }
}
variable "admin_cidr" {
  description = "IPv4 CIDR allowed to access the manager over SSH; defaults to public key-only SSH."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.admin_cidr))
    error_message = "admin_cidr must be a valid IPv4 CIDR."
  }
}

variable "region" {
  description = "DigitalOcean region containing the manager and existing Tassadar VPC."
  type        = string
  default     = "fra1"
}
variable "manager_name" {
  description = "Name of the standalone management Droplet."
  type        = string
  default     = "tassadar-manager"
}
variable "manager_size" {
  description = "DigitalOcean size slug for the manager."
  type        = string
  default     = "s-1vcpu-1gb"
}
variable "opentofu_version" {
  description = "OpenTofu package version installed during initial cloud-init."
  type        = string
  default     = "1.12.3"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.opentofu_version))
    error_message = "opentofu_version must have the form major.minor.patch."
  }
}
variable "ansible_core_version" {
  description = "Ansible core version installed in an isolated Python virtual environment."
  type        = string
  default     = "2.18.6"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.ansible_core_version))
    error_message = "ansible_core_version must have the form major.minor.patch."
  }
}
