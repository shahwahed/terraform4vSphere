data vsphere_datacenter "dc" {
  name = var.datacenter_name
}

data vsphere_compute_cluster "cluster01" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data vsphere_datastore "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
  #sdrs_enabled  = true
}

# if you use cluster datastore uncomment this and make use of it in main.tf inside this modules
/* data vsphere_datastore_cluster "clusterdatastore" {
  name          = var.clusterdatastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
  #sdrs_enabled  = true
} */

data vsphere_resource_pool "pool01" {
  name          = var.pool_name
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data vsphere_network "network01" {
  name          = var.network01
  datacenter_id = data.vsphere_datacenter.dc.id
}

data vsphere_network "network02" {
  name          = var.network02
  datacenter_id = data.vsphere_datacenter.dc.id
}


data vsphere_virtual_machine "template" {
  name          = var.template_linux_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
