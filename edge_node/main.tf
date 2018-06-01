resource "google_compute_address" "edge-address" {
  count        = "${var.vm_count}"
  name         = "${local.ip_name_prefix}${count.index}"
  address_type = "INTERNAL"
  subnetwork   = "${var.edge-subnet}"
  address      = "${local.network_address}.${local.starting_ip + count.index}"
}

resource "google_compute_address" "edge-external" {
  count        = "${var.vm_count}"
  name         = "${local.ex_name_prefix}${count.index}"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "edge-node" {
  count          = "${var.vm_count}"
  name           = "${local.vm_name_prefix}${count.index}"
  machine_type   = "${var.vm-type}"
  can_ip_forward = true

  boot_disk {
    auto_delete = true
    device_name = "boot"

    initialize_params {
      image = "${local.vm_image}"
    }
  }

  network_interface {
    subnetwork = "${var.edge-subnet}"
    address    = "${google_compute_address.edge-address.*.address[count.index]}"

    access_config = {
      nat_ip = "${google_compute_address.edge-external.*.address[count.index]}"
    }
  }

  metadata_startup_script = <<EOF
#!/bin/bash
sudo ip link add vxlan0 type vxlan id 42 dev eth0 dstport 0
BASE_VXNETWORK=${var.vx_base_network}
VXNETWORK=${var.vx_ip_edge_network}
VXIPSTART=${var.nat_vx_ip_start}
EDGE_GIP_NETWORK=${local.network_address}
EDGE_GIP_START=${local.starting_ip}
VMID=${count.index}
NAT_COUNT=${var.vm_count}
SEND_COUNT=${var.send-count}
SEND_NETWORK=${local.send_network_address}
SEND_START=${local.send_starting_ip}
VX_CIDR_BITS=${var.vx_cidr_bits}
for x in $(seq 0 $(expr $NAT_COUNT - 1))
do
    NAT_IP=$(expr $EDGE_GIP_START + $x)
    if [ $x != $VMID ]
        then
            sudo bridge fdb append to 00:00:00:00:00:00 dst $EDGE_GIP_NETWORK.$NAT_IP dev vxlan0
    fi
done
for x in $(seq 0 $(expr $SEND_COUNT - 1 ))
do
    SEND_IP=$(expr $SEND_START + $x)
    sudo bridge fdb append to 00:00:00:00:00:00 dst $SEND_NETWORK.$SEND_IP dev vxlan0
done
sudo ip addr add $VXNETWORK.$(expr $VXIPSTART + $VMID)/$VX_CIDR_BITS dev vxlan0
sudo ip link set up dev vxlan0
sudo ip route add $BASE_VXNETWORK/$VX_CIDR_BITS dev vxlan0
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE


EOF
}
