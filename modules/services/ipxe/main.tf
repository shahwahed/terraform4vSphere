
resource vsphere_virtual_machine "ipxe_01" {
  name             = "${var.ipxe_srv_config["vmname"]}"
  folder           = "${var.ipxe_srv_config["vfolder"]}"
  resource_pool_id = "${data.vsphere_resource_pool.pool01.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 2
  memory   = 1024
  firmware = "${data.vsphere_virtual_machine.template.firmware}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  cdrom {
    client_device = true
  }

  network_interface {
    network_id   = data.vsphere_network.network01.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  network_interface {
    network_id   = data.vsphere_network.network02.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  wait_for_guest_net_timeout = 0

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    #eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(templatefile("${path.module}/../srvTemplate/metadata/metadata2nicDyn.tftpl",
                                    {
                                      hostname="${var.ipxe_srv_config["hostname"]}",
                                      ipA="${var.ipxe_srv_config["ip"]}",
                                      ipB="${var.ipxe_srv_config["ip2"]}",
                                      gw="${var.ipxe_srv_config["gw"]}",
                                      dns= "${split(",", var.ipxe_srv_config["dns"])}"
                                    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata" = data.template_cloudinit_config.ipxe_01.rendered
    "guestinfo.userdata.encoding" = "gzip+base64"
  }
  
}

data template_cloudinit_config "ipxe_01" {
  gzip          = true
  base64_encode = true

  part {
    content     = templatefile("${path.module}/../srvTemplate/userdata.split/10.systembase.tftpl",
    {
      servicednsname="${var.ipxe_srv_config["servicednsname"]}",
    })
    content_type = "text/x-shellscript"
  }
  part {
    content_type = "text/x-shellscript"
    content  = templatefile("${path.module}/../srvTemplate/userdata.split/20.firewall.tftpl",
    {
      firewall_ports_in="22/tcp,67/udp,69/udp,80/tcp"
      firewall_ports_out="22/tcp,80/tcp,443/tcp,53/udp,68/udp"
    })
  }
  part {
    content_type = "text/x-shellscript"
    content  = templatefile("${path.module}/../srvTemplate/userdata.split/21.NAT.tftpl",
    {
      dnsmasq_dhcp_clients="${var.ipxe_srv_config["dhcp_clients_netmask"]}",
      dnsmasq_range="${var.ipxe_srv_config["dhcp_clients_range"]}",
      dnsmasq_dns="${var.ipxe_srv_config["dhcp_dns"]}",
      out_interface="${var.ipxe_srv_config["nat_out"]}",
      int_interface="${var.ipxe_srv_config["nat_in"]}"
    }
    )
  }
  part {
    content_type = "text/x-shellscript"
    content  = templatefile("${path.module}/../srvTemplate/userdata.split/30.ipxe.core.tftpl",
    {
      ipxesecserver="${var.ipxe_srv_config["servicednsname"]}",
    }
    )
  }
  part {
    content_type = "text/x-shellscript"
    content  = templatefile("${path.module}/../srvTemplate/userdata.split/99.finalreboot.tftpl", {})
  }
}

