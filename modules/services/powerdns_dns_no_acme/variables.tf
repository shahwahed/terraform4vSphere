variable "dns_srv_config" {
    type = map
    description = "DNS server configuration input"
    default = {
        "vfolder"        = "/"
        "vmname"         = "dns01"
        "hostname"       = "dns01.mydomain.lan"
        "servicednsname" = "dns01.mydomain.lan"
        "ip"             = "192.168.1.208/24"
        "gw"             = "192.168.1.1"
        "dns"            = "1.1.1.1"
        "dnszoneip"      = "192.168.1.208"
        "dbname"         = "pdnsdb"
        "dblogin"        = "pdnsusr"
        "dbpassword"     = "pdnsDBPASSWORDCHANGEME"
        "sysuser"        = "pdns"
        "sysgroup"       = "pdns"
        "apikey"         = "APIKEYCHANGEME"  
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

# variable cluster_name {
#   type        = string
#   description = "The vSphere Cluster into which resources will be created."
# }

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

variable template_linux_name {
  type = string
  description = "Linux template"
}