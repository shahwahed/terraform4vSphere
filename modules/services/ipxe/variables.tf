variable "ipxe_srv_config" {
    type = map
    description = "ipxe configuration input"
    default = {
        "vfolder"           = "/"
        "vmname"            = "ipxe01"
        "hostname"          = "ipxe01.mydomain.lan"
        "servicednsname"    = "ipxe01.mydomain.lan"
        "ip"             = "192.168.1.1/24"
        "ip2"             = "192.168.2.1/24"
        "gw"             = "192.168.1.1"
        "dns"            = "1.1.1.1"
        "dhcp_clients_netmask" = "192.168.2.1/24"
        "dhcp_clients_range" = "192.168.2.10,192.168.2.100,255.255.255.0"
        "dhcp_dns" = "1.1.1.1"
        "nat_out" = "ens192"
        "nat_in" = "ens224"
    }
}



# ---------------------------------------------------------------------------------------------------------------------
# VMWARE DATA SOURCE VARIABLES
# These are used to discover unmanaged resources used during deployment.
# ---------------------------------------------------------------------------------------------------------------------

variable datacenter_name {
  type        = string
  description = "The name of the vSphere Datacenter into which resources will be created."
}

variable cluster_name {
  type        = string
  description = "The vSphere Cluster into which resources will be created."
}

variable datastore_name {
  type        = string
  description = "The vSphere Datastore into which resources will be created."
}

variable pool_name {
  type        = string
  description = "The vSphere Pool Resource into which resources will be created."
}


variable datastore_cluster_name {
  type    = string
  default = ""
}

variable "network01" {
  type = string
  description = "VM FirstNic attached Portgroup"
}

variable "network02" {
  type = string
  description = "VM SecondNic attached Portgroup"
}

variable template_linux_name {
  type = string
  description = "Linux template"
}