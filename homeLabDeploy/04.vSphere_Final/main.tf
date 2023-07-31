
provider "vault" {
skip_tls_verify = true
}

data "vault_generic_secret" "esx_creds" {
  path = var.esxVaultPath
}

data "vault_generic_secret" "new_vsca_creds" {
  path = var.newvSphereVaultPath
}


module "vcenter" {
  source = "../../modules/services/vcenter"
  deploy_type           = var.deploy_type 
  esxi_username           = data.vault_generic_secret.esx_creds.data["login"]
  esxi_hostname           = var.esxi_hostname
  esxi_password           = data.vault_generic_secret.esx_creds.data["password"]
  # if you want to deploy on VC uncomment and fill thoses vc_* variables
  # comment esxi_* variables and set deploy type to vc
  #vc_username = var.vc_username
  #vc_hostname = var.vc_hostname
  #vc_password = var.vc_password 
  #vc_datacenter = var.vc_datacenter 
  #vc_cluster = var.vc_cluster
  vcsa_network          = var.vcsa_network 
  vcsa_datastore        = var.vcsa_datastore
  deployment_size       = var.deployment_size
  vcenter_appliance_name = var.vcenter_appliance_name
  vcenter_system_name         = var.vcenter_system_name
  vcenter_ip            = var.vcenter_ip
  vcenter_prefix        = var.vcenter_prefix
  vcenter_gateway       = var.vcenter_gateway
  vcenter_dns           = var.vcenter_dns
  vcenter_root_password = data.vault_generic_secret.new_vsca_creds.data["rootpassword"]
  vcenter_sso_password = data.vault_generic_secret.new_vsca_creds.data["admpassword"]
  vcenter_sso_domain = data.vault_generic_secret.new_vsca_creds.data["domain"]
  vcenter_ntp_server    = var.vcenter_ntp_server
  binaries_path         = var.binaries_path
  #settings for vcsa deployement
  disk_mode = true
  network_mode = "static"
  ip_family = "ipv4"
  vcenter_ssh_enabled = true
}
