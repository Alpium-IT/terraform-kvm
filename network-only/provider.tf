terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "=0.7.6"
    }
  }
}
# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

terraform {
  backend "local" {
    path = "state/terraform.tfstate"
  }
}
