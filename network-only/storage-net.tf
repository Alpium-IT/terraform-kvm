
# resource "libvirt_pool" "images" {
#   name = "images"
#   type = "dir"
#   path = "/var/lib/libvirt/images"
# }

resource "libvirt_network" "ocp_network_99" {
  name = "storage_net_99"
  mode = "none"
  autostart = true
  domain = "storage1.local"
  addresses = ["10.99.0.0/24"]
  bridge = "virbr99"
  dhcp {
        enabled = true
        }
}