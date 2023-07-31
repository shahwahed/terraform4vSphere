variable "keycloak_srv_config" {
    type = map
    description = "KEYCLOAK configuration input"
    default = {
        "vfolder"           = "/"
        "vmname"            = "keycloak01"
        "hostname"          = "keycloak01.mydomain.lan"
        "servicednsname"    = "keycloak01.mydomain.lan"
        "ip"                = "192.168.1.201/24"
        "gw"                = "192.168.1.1"
        "dns"               = "192.168.1.208"
        "dbname"            = "keycloakdb"
        "dblogin"           = "keycloakusr"
        "dbpassword"        = "CHANGEME"
        "sysuser"           = "keycloak"
        "sysgroup"          = "keycloak"
        "kcadmin"           = "admin"
        "kcadminpassword"   = "CHANGEMETOO"
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

variable template_linux_name {
  type = string
  description = "Linux template"
}