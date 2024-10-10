
# resource "libvirt_pool" "images" {
#   name = "images"
#   type = "dir"
#   path = "/var/lib/libvirt/images"
# }

variable "worker" {
    type = list(string)
    default = ["storage0","storage1","storage2" ]  // , "cp4-storage1", "cp4-storage2"]
  }

// DISK VOLUMES  ===================================================

# resource "libvirt_volume" "fatdisk-workers" {
#   # name           = "fatdisk-${element(var.worker, count.index)}"
#   name           = "fatdisk-${element(var.worker, count.index)}"
#   pool           = "images"
#   size           = 130000000000
#   count = "${length(var.worker)}"
# }

resource "libvirt_volume" "volume-mon-workers" {
  name   = "epyc-${element(var.worker, count.index)}-volume-mon"
  pool   = "default"
  size   = "20000000000"  # 20Gi
  format = "qcow2"
  count = "${length(var.worker)}"
}
resource "libvirt_volume" "volume-osd1-workers" {
  name   = "epyc-${element(var.worker, count.index)}-volume-osd1"
  pool   = "default"
  size   = "20000000000"  # 20Gi
  format = "qcow2"
  count = "${length(var.worker)}"
}
resource "libvirt_volume" "volume-osd2-workers" {
  name   = "epyc-${element(var.worker, count.index)}-volume-osd2"
  pool   = "default"
  size   = "20000000000"  # 20Gi
  format = "qcow2"
  count = "${length(var.worker)}"
}

// NODES  ===================================================

resource "libvirt_domain" "ocp_storage_nodes" {
  name   = "${element(var.worker, count.index)}"
  count = "${length(var.worker)}"

  memory = "8000"
  vcpu   = 1
  cpu   {
    mode = "host-passthrough"
  }
  running = false
  boot_device {
      dev = ["hd","cdrom"]
    }
  network_interface {
    network_name = "epyc"
    mac = "AA:BB:CC:11:42:2${count.index}"
  }
  network_interface {
    network_name = "storage_net_99"
    mac = "AA:BB:CC:11:42:5${count.index}"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"

  }

  disk { volume_id = "${element(libvirt_volume.volume-mon-workers.*.id,  count.index)}" }
  disk { volume_id = "${element(libvirt_volume.volume-osd1-workers.*.id, count.index)}" }
  disk { volume_id = "${element(libvirt_volume.volume-osd2-workers.*.id, count.index)}" }
  # disk { volume_id = "${element(libvirt_volume.fatdisk-workers.*.id, count.index)}" }
  # disk { file = "/var/lib/libvirt/images/discovery_image_ocpd.iso" }


  depends_on = [
    libvirt_network.ocp_network_99,
  ]
}