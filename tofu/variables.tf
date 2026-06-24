variable "name_prefix" {
  description = "Prefix used for Yandex Cloud resource names."
  type        = string
  default     = "pxc"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key installed on the bastion host."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "subnets" {
  description = "Subnets used by the PXC nodes and bastion host."
  type = map(object({
    zone = string
    cidr = string
  }))

  default = {
    a = {
      zone = "ru-central1-a"
      cidr = "10.10.1.0/24"
    }
    b = {
      zone = "ru-central1-b"
      cidr = "10.10.2.0/24"
    }
    d = {
      zone = "ru-central1-d"
      cidr = "10.10.3.0/24"
    }
  }
}
