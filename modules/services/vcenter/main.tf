locals {
  binaries_path = var.binaries_path
  vcsa_template = templatefile("${path.module}/vcTemplates/vcsa-${var.deploy_type}.json.tmpl", {
    esxi_hostname         = var.esxi_hostname
    vc_hostname           = var.vc_hostname
    esxi_username         = var.esxi_username
    vc_username           = var.vc_username
    esxi_password         = var.esxi_password
    vc_password           = var.vc_password
    vcsa_network          = var.vcsa_network
    vc_datacenter         = var.vc_datacenter
    vc_cluster            = var.vc_cluster
    vcsa_datastore        = var.vcsa_datastore
    disk_mode             = var.disk_mode
    deployment_size       = var.deployment_size
    vcenter_appliance_name      = var.vcenter_appliance_name
    ip_family             = var.ip_family
    network_mode          = var.network_mode
    vcenter_system_name          = var.vcenter_system_name
    vcenter_ip            = var.vcenter_ip
    vcenter_prefix        = var.vcenter_prefix
    vcenter_gateway       = var.vcenter_gateway
    vcenter_dns           = "${jsonencode(var.vcenter_dns)}"
    vcenter_root_password = var.vcenter_root_password
    vcenter_ntp_server    = var.vcenter_ntp_server
    vcenter_ssh_enabled   = var.vcenter_ssh_enabled
    vcenter_sso_password  = var.vcenter_sso_password
    vcenter_sso_domain    = var.vcenter_sso_domain
    vcenter_ceip_status   = var.vcenter_ceip_status
  })
}

resource "local_file" "vcsa_template_to_json" {
  filename = "/tmp/vcsa/vcsa-${var.deploy_type}.json"
  content  = local.vcsa_template
}

# hack for windows/linux support
# if windows variable is not set, linux deploy command
resource "null_resource" "vcsa_linux_deploy" {
  count = var.windows == false ? 1 : 0
  provisioner "local-exec" {
    command = "${local.binaries_path}/vcsa-cli-installer/lin64/vcsa-deploy install --accept-eula --acknowledge-ceip --no-ssl-certificate-verification /tmp/vcsa/vcsa-${var.deploy_type}.json"
  }
}

#hack for windows/linux support
# if windows variable is set, so go for windows deploy command
resource "null_resource" "vcsa_windows_deploy" {
  count = var.windows == true ? 1 : 0
  provisioner "local-exec" {
    command = "${local.binaries_path}/vcsa-cli-installer/win32/vcsa-deploy.exe install --accept-eula --acknowledge-ceip --no-ssl-certificate-verification /tmp/vcsa/vcsa-${var.deploy_type}.json"
  }
}
