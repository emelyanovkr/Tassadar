terraform {
  required_version = ">= 1.8"

  required_providers {
    local = {
      source = "hashicorp/local"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
