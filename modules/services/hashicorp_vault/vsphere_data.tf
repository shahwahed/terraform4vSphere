data vsphere_datacenter "dc" {
  name = "DC01"
}

data vsphere_compute_cluster "cluster01" {
  name          = "Niflheim"
  datacenter_id = data.vsphere_datacenter.dc.id
}

#data vsphere_datastore "datastore" {
# data vsphere_datastore_cluster "datastore" {
#   name          = "DSDAT01"
#   #name          = "ssd-000098"
#   datacenter_id = data.vsphere_datacenter.dc.id
#   #sdrs_enabled  = true
# }

data vsphere_datastore "datastore" {
  name          = "vsanDatastore"
  datacenter_id = data.vsphere_datacenter.dc.id
  #sdrs_enabled  = true
}

data vsphere_resource_pool "pool01" {
  name          = "Compute"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

/*
data vsphere_datastore_cluster "this" {
  name          = "datastoreclustername"
  datacenter_id = data.vsphere_datacenter.this.id
}
*/

# data vsphere_network "networkInternet" {
#   name          = "*InternetBox"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

data vsphere_network "vmnetwork" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# data vsphere_network "network01" {
#   name          = "*SMW_01"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

# data vsphere_network "network02" {
#   name          = "*SMW_02"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

# data vsphere_network "network03" {
#   name          = "*SMW_03"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

# data vsphere_network "network04" {
#   name          = "*SMW_04"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

# data vsphere_network "network05" {
#   name          = "*SMW_05"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

data vsphere_virtual_machine "template" {
  name          = "ubuntu-2210-amd64-v1-beta"
  #name          = "ubuntu-2104-amd64-v2"
  datacenter_id = data.vsphere_datacenter.dc.id
}
