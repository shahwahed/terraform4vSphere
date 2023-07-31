# ---------------------------------------------------------------------------------------------------------------------
# This variables are for vault
# ---------------------------------------------------------------------------------------------------------------------

variable "esxVaultPath" {
  description = "vault path for the esx to deploy on"
  type        = string
  default     = ""
  #sensitive = true
}

variable "vcVaultPath" {
  description = "vault path for the vcenter creds to deploy on"
  type        = string
  default     = ""
  #sensitive = true
}

variable "newvSphereVaultPath" {
  description = "vault path for the new vcsa creds"
  type        = string
  default     = ""
  sensitive = true
}



# ---------------------------------------------------------------------------------------------------------------------
# This variables are for deploy vcsa 
# ---------------------------------------------------------------------------------------------------------------------

variable "esxi_hostname" {
  description = "ESXi hostname of the target host"
  type        = string
  default     = ""
}

variable "vc_hostname" {
  description = "vCenter hostname of the target vCenter where the appliance will be deployed in"
  type        = string
  default     = ""
}

variable "esxi_username" {
  description = "Username for the account on the target ESXi host"
  type        = string
  default     = ""
}

variable "vc_username" {
  description = "Username for the account on the target vCenter that will be used to deploy the appliance"
  type        = string
  default     = ""
}

variable "esxi_password" {
  description = "Password for the account on the target host"
  type        = string
  default     = ""
}

variable "vc_password" {
  description = "Password for the account on the target vCenter that will be used to deploy the appliance"
  type        = string
  default     = ""
}

variable "vc_datacenter" {
  description = "Datacenter where the appliance will be deployed"
  type        = string
  default     = ""
}

variable "vc_cluster" {
  description = "Cluster where the appliance will be deployed"
  type        = string
  default     = ""
}

variable "vcsa_network" {
  description = "Target vCenter appliance network"
  type        = string
}

variable "vcsa_datastore" {
  description = "Target datastore for the vCenter appliance"
  type        = string
}

variable "disk_mode" {
  default     = true
  description = "Thin provisioned disk mode"
  type        = bool
}

variable "deploy_type" {
  description = "Type of deployment that will be performed - esxi or vc "
  type        = string
  default     = "esxi"
  validation {
    condition     = var.deploy_type != "esxi" || var.deploy_type != "vc"
    error_message = "The variable type must be \"esxi\" or \"vc\"."
  }
}

variable "deployment_size" {
  default     = "tiny"
  description = "vCenter server deployment size"
  validation {
    condition     = var.deployment_size != "tiny" || var.deployment_size != "small" || var.deployment_size != "medium" || var.deployment_size != "large" || var.deployment_size != "x-large"
    error_message = "The variable deployment_size must be \"tiny\", \"small\", \"medium\", \"large\", or \"x-large\"."
  }
  type = string
}

variable "vcenter_prefix" {
  description = "vCenter server subnet prefix"
  default     = "24"
  type        = string
}

variable "ip_family" {
  default     = "ipv4"
  description = "Setting for ipv4 or ipv6"
  type        = string
}

variable "network_mode" {
  default     = "static"
  description = "Static or DHCP configuration for the network mode"
  type        = string
}

variable "vcenter_ip" {
  description = "vCenter server IP Address"
  type        = string
}

variable "vcenter_gateway" {
  description = "Default gateway for vCenter server"
  type        = string
}

variable "vcenter_dns" {
  description = "vCenter server upstream DNS servers"
  type        = list(string)
}

variable "vcenter_ntp_server" {
  description = "vCenter server NTP server"
  default     = null
  type        = string
}

variable "vcenter_ssh_enabled" {
  description = "vCenter SSH setting"
  type        = bool
  default     = true
}

variable "vcenter_system_name" {
  description = "vCenter server Primary network identity. Can be either an IP address or a fully qualified domain name (FQDN)"
  type        = string
}

variable "vcenter_appliance_name" {
  description = "vCenter name in esxi or another vCenter"
  type        = string
}


variable "binaries_path" {
  description = "Path for the vCenter server deployment binaries"
  type        = string
}