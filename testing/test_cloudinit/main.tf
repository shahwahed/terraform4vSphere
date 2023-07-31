locals {
  vfolder = "/yourFolder"

  cloudInitTest_map_server = {
    "0" = ["vmCloudInit", "vmCloudInit.local.lan", "vmCloudInit.local.lan","192.168.254.208/24", "192.168.254.1", "192.168.254.253"]
  }
}


provider "vault" {
skip_tls_verify = true
}

data "vault_generic_secret" "vsphere_creds" {
  path = var.vsphere_creds_vault_path
}


provider "vsphere" {
  user                  = data.vault_generic_secret.vsphere_creds.data["login"]
  password              = data.vault_generic_secret.vsphere_creds.data["password"]
  vsphere_server        = var.vsphere_server
  #allow_unverified_ssl  = true
}


module "cloudInitTest" {
  source = "../modules/services/test_cloud_init"
  count = "${length(local.cloudInitTest_map_server)}"

    #module internal services vars
      cloudInitTest_srv_config = {
        vfolder             = "${local.vfolder}"
        vmname              = "${element(local.cloudInitTest_map_server[count.index], 0)}"
        hostname            = "${element(local.cloudInitTest_map_server[count.index], 1)}"
        servicednsname      = "${element(local.cloudInitTest_map_server[count.index], 2)}"
        ip                  = "${element(local.cloudInitTest_map_server[count.index], 3)}"
        gw                  = "${element(local.cloudInitTest_map_server[count.index], 4)}"
        dns                 = "${element(local.cloudInitTest_map_server[count.index], 5)}"
    }

    #vsphere provider need vars
    datacenter_name = var.datacenter_name
    cluster_name = var.cluster_name
    datastore_name = var.datastore_name
    pool_name = var.pool_name
    network01 = var.networkAdm
    template_linux_name = var.template_linux_name

}
