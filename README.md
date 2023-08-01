# terraform4vSphere



Readme En Français
[![FR](https://img.shields.io/badge/lang-fr-red.svg)](https://github.com/shahwahed/terraform4vSphere/blob/master/Readme-FR.md)



# Cloud init template for terraform and other stuff

This repository is a collection of my cloud init template I am using with terraform.

Cloud init can be either in yaml or script. more information https://cloudinit.readthedocs.io/en/latest/

If you can do it by hand using bash you can do it with cloud-init!


In this repository you will also found :

- a testing folder called test_cloudinit with a cloud-init terraform test file, to test your if your linux template works with cloud-init
- a testing folder called test_Stage to test modules created using my cloud-init user-data files


## Spliting Cloud-init file or Mime Multi Part Archive


Cloud-init support mime multi part archive, one benefit of it is reuse and modularity!

When I starting to use cloud-init, I use to do one file by service (dns, ntp, netbox...) and time after time, each new service get some basic step different than the previous one. With multipart mime, you only code small step and then can reuse them, when you modify one step all other template can benefit from them!

I also use the basic templating from terraform to code generic cloud-init file, then using vault as config management and secret keeper.


more info about mime support in cloud-init : https://cloudinit.readthedocs.io/en/latest/topics/format.html#helper-subcommand-to-generate-mime-messages 

## Repository structures

```sh
├── homeLabDeploy               # home lab deployment script using terraform, packer, and cloud init
│
├── modules                     # Modules folder
│   ├── services                # services definition (dns, ntp, ...) base on a cloud-init installation, terraform modules
│   ├── srvTemplate             # cloud-init multi part (user-data and meta-data)
│   └── vsphere_infrastructure  # packer template for vSphere
│
└── testing                     # testing folder
    ├── test_cloudinit          # to test your template against a simple cloud-init script
    └── test_Stage              # to test services modules

```

## Terraform modules

In the modules folder, you will found all my terraform modules to create various services. 

all modules create a linux VM and then customize it using cloud-init, all cloud-init file, have been tested with ubuntu distribution (22.04 LTS and 22.10)

The cloud-init files are located in the srvTemplate folder

## Files structures of cloud-init multi part

In the folder srvTemplate, you will found two folder, metadata and userdata.split.

The userdata.split contains different cloud-init script, each one get a purpose, from settings a system configuration, firewalling or a services configuration.

Each file begin with a number, from 00 to 99.
00 for step should be done first
1X basic system configuration
2X network and firewall stuff
3X services
5X ngnix frontend
99 last step with final reboot

| File        | Description           |
| ------------- | ------------- |
| 00.disableAutoUpdate_cloud-init.tftpl  | disable autoupdate, to speed up VM creation |
| 11.systembase.IPFORCED.tftpl  | setup properly ip address in host file |
|10.systembase.tftpl    |   setup host file with dyn ip |
|20.firewall.tftpl  | basic firewall using ufw |
|20.firewallADV.tftpl| advance firewall using ufw |
|21.NAT.tftpl | nat configuration with dhcp dnsmasq|
|22.NATnodhcp.tftpl | nat configuration without dhcp|
|30.minio.core.tftpl | minio S3 storage server |
|30.powerdns.core.nopubwebsrv.tftpl | powerdns server without webserver|
|30.powerdns.core.tftpl| powerdns server |
|30.vaultConsul.core.tftpl| vault with consul backend|
|30.netbox.core.tftpl | netbox dcim |
|30.stepca.core.tftpl | stepca cool ACME server from smalstep|
|30.stepca.core.listenallint.tftpl | stepca cool ACME server from smalstep, listen on all interface|
|30.harbor.core.tftpl | harbor container registry dockerhub like |
|30.keycloak.core.tftpl| keycloak server |
|30.SSHCERTONLY.tftpl| setup ssh to use cert generate with STEPCA CA!!!
|50.SSL_NGNIX_With_ACME.tftpl | setup ngnix frontend with internal acme certificate
|51.SSL_NGNIX_With_ACME_With_BOOTSTRAP.tftpl| stepup ngnix frontend with autosigne certiicate|
|99.finalreboot.tftpl | final reboot with clearing of cloud init file for security purpose|

## Optimizations & Todo

review security hardening of all services
add some hardening script



## Usage/Examples

Using terraform for vsphere if you want to create your a dynamic cloud init:


```terraform
# cloud-init userdata dynamic for a nat gateway
data template_cloudinit_config "simpleNatGateway" {
  gzip          = true
  base64_encode = true


  part {
    content     = templatefile("../../srvTemplate/userdata.split/10.systembase.tftpl",
    {
      servicednsname="myVmDnsName"
    })
    content_type = "text/x-shellscript"
  }
  part {
    content_type = "text/x-shellscript"
    content  = templatefile("../../srvTemplate/userdata.split/20.firewall.tftpl",
    {
      firewall_ports_in="22/tcp,67/udp,68/udp"
      firewall_ports_out="22/tcp,53/udp,67/udp,68/udp,80/tcp,443/tcp"
    })
  }
  part {
    content_type = "text/x-shellscript"
    content  = templatefile("../../srvTemplate/userdata.split/21.NAT.tftpl",
    {
      dnsmasq_dhcp_clients="192.168.2.0/24",
      dnsmasq_range="192.168.2.100,192.168.2.150,255.255.255.0",
      dnsmasq_dns="1.1.1.1",
      out_interface="ens192",
      int_interface="ens224"
    })
  }
}

```

Consume it in terraform using extra_config tag
```terraform

resource vsphere_virtual_machine "natgateway" {
  name  = "natgateway"
  resource_pool_id = "myvspherepool"
  datastore_cluster_id     = "myDatastoreCluster"

  num_cpus = 2
  memory   = 512
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  cdrom {
    client_device = true
  }

  network_interface {
    network_id   = data.vsphere_network.network01.id
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
    "guestinfo.metadata"          = base64encode(templatefile("../../srvTemplate/metadata/metadata1nicStatic.tftpl",
                                    {
                                      hostname="gateway01",
                                      ipA="192.168.2.1/24",
                                      gw="192.168.1.1",
                                      dns="1.1.1.1",
                                    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata" = data.template_cloudinit_config.simpleNatGateway.rendered
    "guestinfo.userdata.encoding" = "gzip+base64"
  }
  
}
```

## Badges

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![Terraform vSphere Provider](https://img.shields.io/badge/terraform-vsphere__provider-green)](https://registry.terraform.io/providers/hashicorp/vsphere/latest)
[![vsphere version](https://img.shields.io/badge/vsphere-6.X%2C%207.X-green)](https://vmware.com)

