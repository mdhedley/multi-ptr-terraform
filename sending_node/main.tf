resource "google_compute_address" "sending-address" {
  count        = "${var.vm_count}"
  name         = "${local.ip_name_prefix}${count.index}"
  address_type = "INTERNAL"
  subnetwork   = "${var.sending-subnet}"
  address      = "${local.network_address}.${local.starting_ip + count.index}"
}

resource "google_compute_instance" "sending-node" {
  count        = "${var.vm_count}"
  name         = "${local.vm_name_prefix}${count.index}"
  machine_type = "${var.vm-type}"

  boot_disk {
    auto_delete = true
    device_name = "boot"

    initialize_params {
      image = "${local.vm_image}"
    }
  }

  network_interface {
    subnetwork    = "${var.sending-subnet}"
    address       = "${google_compute_address.sending-address.*.address[count.index]}"
    access_config = {}
  }

  metadata_startup_script = <<EOF
#!/bin/bash
sudo ip link add vxlan0 type vxlan id 42 dev eth0 dstport 0
BASE_VXNETWORK=${var.vx_base_network}
VXNETWORK=${var.vx_ip_send_network}
VXIPSTART=${var.send_vx_ip_start}
EDGE_VX_START=${var.edge_vx_ip_start}
EDGE_VX_NETWORK=${var.vx_ip_edge_network}
EDGE_GIP_NETWORK=${local.edge_network_address}
EDGE_GIP_START=${local.edge_starting_ip}
VMID=${count.index}
NAT_COUNT=${var.edge_count}
SEND_COUNT=${var.vm_count}
SEND_NETWORK=${local.network_address}
SEND_START=${local.starting_ip}
VX_CIDR_BITS=${var.vx_cidr_bits}
for x in $(seq 0 $(expr $NAT_COUNT - 1))
do
    NAT_IP=$(expr $EDGE_GIP_START + $x)
            sudo bridge fdb append to 00:00:00:00:00:00 dst $EDGE_GIP_NETWORK.$NAT_IP dev vxlan0
done
for x in $(seq 0 $(expr $SEND_COUNT - 1 ))
do
    SEND_IP=$(expr $SEND_START + $x)
    if [ $x != $VMID ]
      then
        sudo bridge fdb append to 00:00:00:00:00:00 dst $SEND_NETWORK.$SEND_IP dev vxlan0
    fi
done
if [ ! -f /root/runonce ]
  then
      touch /root/runonce
      for x in $(seq 1 $NAT_COUNT)
        do
          echo $x edge$x>>/etc/iproute2/rt_tables
        done
fi

for NAT_POS in $(seq 0 $(expr $NAT_COUNT - 1))
do
  SOURCE_IP=$(expr $VXIPSTART + $(expr $VMID \* $NAT_COUNT ) + $NAT_POS)
  sudo ip addr add $VXNETWORK.$SOURCE_IP/$VX_CIDR_BITS dev vxlan0
  
  sudo ip rule add from $VXNETWORK.$SOURCE_IP table edge$(expr $NAT_POS + 1)
  sudo ip rule add to $VXNETWORK.$SOURCE_IP table edge$(expr $NAT_POS + 1)
done
sudo ip link set up dev vxlan0
sudo ip route add $BASE_VXNETWORK/$VX_CIDR_BITS dev vxlan0
for NAT_POS in $(seq 0 $(expr $NAT_COUNT - 1))
do
  SOURCE_IP=$(expr $VXIPSTART + $(expr $VMID \* $NAT_COUNT ) + $NAT_POS)
  sudo ip route add $BASE_VXNETWORK/$VX_CIDR_BITS dev vxlan0 table edge$(expr $NAT_POS + 1)
  sudo ip route add default via $EDGE_VX_NETWORK.$(expr $EDGE_VX_START + $NAT_POS) dev vxlan0 table edge$(expr $NAT_POS + 1)
done
EOF
}
