locals {
  vfolder = "/yourFolder"

  keycloak_map_server = {
    "0" = ["keycloak01", "keycloak01.local.lan", "keycloak01.local.lan","192.168.254.207/24", "192.168.254.1", "192.168.254.253", "keycloakdb", "keycloakusr", "keycloakpasswd","keycloak","keycloak", "admin", "admin"]
  }
  ntp_map_server = {
    "0" = ["ntp01", "ntp01.local.lan", "ntp01.local.lan","192.168.254.207/24", "192.168.254.1", "192.168.254.253", "ntppool1.time.nl ntppool2.time.nl"]
    "1" = ["ntp02", "ntp02.local.lan", "ntp02.local.lan","dhcp", "ntppool1.time.nl ntppool2.time.nl"]
  }

    ipxe_map_server = {
    "0" = ["ipxe01", "ipxe01.local.lan", "ipxe01.local.lan","192.168.254.207/24", "192.168.2.1/24", "192.168.254.1", "192.168.254.253","192.168.2.1/24","192.168.2.10,192.168.2.100,255.255.255.0","1.1.1.1","ens192","ens224"]
  }
}


provider "vault" {
skip_tls_verify = true
}

data "vault_generic_secret" "vsphere_creds" {
  path = var.vsphere_server
}


provider "vsphere" {
  user                  = data.vault_generic_secret.vsphere_creds.data["login"]
  password              = data.vault_generic_secret.vsphere_creds.data["password"]
  vsphere_server        = var.vsphere_server
  #allow_unverified_ssl  = true
}


module "ipxe_server" {
  source = "../modules/services/ipxe"
  count = "${length(local.ipxe_map_server)}"

    #module internal services vars
      ipxe_srv_config = {
        vfolder             = "${local.vfolder}"
        vmname              = "${element(local.ipxe_map_server[count.index], 0)}"
        hostname            = "${element(local.ipxe_map_server[count.index], 1)}"
        servicednsname      = "${element(local.ipxe_map_server[count.index], 2)}"
        ip                  = "${element(local.ipxe_map_server[count.index], 3)}"
        ip2                 = "${element(local.ipxe_map_server[count.index], 4)}"
        gw                  = "${element(local.ipxe_map_server[count.index], 5)}"
        dns                 = "${element(local.ipxe_map_server[count.index], 6)}"
        dhcp_clients_netmask = "${element(local.ipxe_map_server[count.index], 7)}"
        dhcp_clients_range  = "${element(local.ipxe_map_server[count.index], 8)}"
        dhcp_dns            = "${element(local.ipxe_map_server[count.index], 9)}"
        nat_out             = "${element(local.ipxe_map_server[count.index], 10)}"
        nat_in              = "${element(local.ipxe_map_server[count.index], 11)}"
    }

    #vsphere provider need vars
    datacenter_name = var.datacenter_name
    cluster_name = var.cluster_name
    datastore_name = var.datastore_name
    pool_name = var.pool_name
    network01 = var.networkAdm
    network02 = var.network01
    template_linux_name = var.template_linux_name

}

