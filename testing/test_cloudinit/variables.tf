# ---------------------------------------------------------------------------------------------------------------------
# VMWARE NAMING DATA SOURCE VARIABLES
# These are used to put your vSphere configuration variable
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
  description = "vSphere cluster name"
  default = ""
}

variable template_linux_name {
  type = string
  description = "Linux template"
}

variable "networkAdm" {
  type = string
  description = "Adm network for VM"
}