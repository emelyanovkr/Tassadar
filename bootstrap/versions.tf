terraform {
  required_version = ">= 1.12.0, < 1.13.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "= 2.99.1"
    }
  }
}
provider "digitalocean" {
  token = var.digitalocean_token
}
