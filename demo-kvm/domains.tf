
# resource "libvirt_pool" "images" {
#   name = "images"
#   type = "dir"
#   path = "/var/lib/libvirt/images"
# }

variable "workerList" {
    type = list(string)
    default = ["bm0" ,"bm1"]   # ,"bm1","bm2" ]
  }

// DISK VOLUMES  ===================================================

resource "libvirt_volume" "volume-workers" {
  name   = "demo-${element(var.workerList, count.index)}-volume.qcow2"
  pool   = "default"
  size   = "100000000000"  # 100Gi
  format = "qcow2"
  count = "${length(var.workerList)}"
}

// NODES  ===================================================

resource "libvirt_domain" "demo_nodes" {
  name   = "${element(var.workerList, count.index)}"
  count = "${length(var.workerList)}"

  memory = "8000"
  vcpu   = 2
  cpu   {
    mode = "host-passthrough"
  }
  running = true
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

  disk { volume_id = "${element(libvirt_volume.volume-workers.*.id,  count.index)}" }
  disk { file = "/var/lib/libvirt/images/rhcos-4.16.3-x86_64-live.x86_64.iso" }


  # depends_on = [
  #   libvirt_network.ocp_network_99,
  # ]
}