locals {
  vfolder = "/infra"

  dns_map_server = {
    "0" = ["dns01", "dns01.darkabyss.lan", "dns01.darkabyss.lan","192.168.1.201/24", "192.168.1.1", "1.1.1.1", "192.168.1.201", "pdnsdb", "pdnsdbusr", "fohYuhi4tee7wieWaeyeayac","pdns","pdns", "Maix3chuxieyo3yoo7aidaekieghena3"],
    "1" = ["dns02", "dns02.darkabyss.lan", "dns02.darkabyss.lan","192.168.1.202/24", "192.168.1.1", "1.1.1.1", "192.168.1.202", "pdnsdb", "pdnsdbusr", "fohYuhi4tee7wieWaeyeayac","pdns","pdns", "Maix3chuxieyo3yoo7aidaekieghena3"]
  }


  keycloak_map_server = {
    "0" = ["keycloak01", "keycloak01.cloudcorner.lan", "keycloak01.cloudcorner.lan","192.168.254.207/24", "192.168.254.1", "192.168.254.253", "keycloakdb", "keycloakusr", "keycloakpasswd","keycloak","keycloak", "admin", "admin"]
  }
  ntp_map_server = {
    "0" = ["ntp01", "ntp01.darkabyss.lan", "ntp01.darkabyss.lan","192.168.1.203/24", "192.168.1.1", "192.168.1.201,192.168.1.202", "ntppool1.time.nl ntppool2.time.nl","Europe/Paris"]
  }

    ipxe_map_server = {
    "0" = ["ipxe01", "ipxe01.darkabyss.lan", "ipxe01.darkabyss.lan","192.168.254.207/24", "192.168.2.1/24", "192.168.254.1", "192.168.254.253","192.168.2.1/24","192.168.2.10,192.168.2.100,255.255.255.0","1.1.1.1","ens192","ens224"]
  }

  templatesFolder = "infra"
  linuxSSHPassVaultPath = "ice/ssh_multipass01"
  vNetwork01 = "*VM*"
  vSphereSRV = "192.168.1.100"
  vSphereVaultPath = "Darkabyss/vsphere"
  vSphereDC = "dc"
  vSphereCluster = "cluster1"
  

  esx01 = "192.168.1.101"
  esx01VaultPath = "Darkabyss/esx01"
  esx01Datastore = "datastore_esx01"

}


provider "vault" {
skip_tls_verify = true
}


data "vault_generic_secret" "darkabyss_esx01" {
  path = local.esx01VaultPath
}

data "vault_generic_secret" "darkabyss_vsphere" {
  path = local.vSphereVaultPath
}

provider "vsphere" {
  user                  = join("@",[data.vault_generic_secret.darkabyss_vsphere.data["login"],data.vault_generic_secret.darkabyss_vsphere.data["domain"]])
  password              = data.vault_generic_secret.darkabyss_vsphere.data["admpassword"]
  vsphere_server        = local.vSphereSRV
  allow_unverified_ssl  = true
}


module "powerdns_dns_no_acme" {
  source = "../../modules/services/powerdns_dns_no_acme"
  count = "${length(local.dns_map_server)}"

    #module internal services vars
      dns_srv_config = {
        vfolder             = "${local.vfolder}"
        vmname              = "${element(local.dns_map_server[count.index], 0)}"
        hostname            = "${element(local.dns_map_server[count.index], 1)}"
        servicednsname      = "${element(local.dns_map_server[count.index], 2)}"
        ip                  = "${element(local.dns_map_server[count.index], 3)}"
        gw                  = "${element(local.dns_map_server[count.index], 4)}"
        dns                 = "${element(local.dns_map_server[count.index], 5)}"
        dnszoneip           = "${element(local.dns_map_server[count.index], 6)}"
        dbname              = "${element(local.dns_map_server[count.index], 7)}"
        dblogin             = "${element(local.dns_map_server[count.index], 8)}"
        dbpassword          = "${element(local.dns_map_server[count.index], 9)}"
        sysuser             = "${element(local.dns_map_server[count.index], 10)}"
        sysgroup            = "${element(local.dns_map_server[count.index], 11)}"
        apikey              = "${element(local.dns_map_server[count.index], 12)}"
    }

    #vsphere provider need vars
    datacenter_name = var.datacenter_name
    #cluster_name = var.cluster_name
    datastore_name = var.datastore_name
    pool_name = var.pool_name
    network01 = var.networkAdm
    template_linux_name = var.template_linux_name

}

module "ntp" {
  source = "../modules/services/ntp"
  count = "${length(local.ntp_map_server)}"

    #module internal services vars
      ntp_srv_config = {
        vfolder        = "${local.vfolder}"
        vmname         = "${element(local.ntp_map_server[count.index], 0)}"
        hostname       = "${element(local.ntp_map_server[count.index], 1)}"
        servicednsname = "${element(local.ntp_map_server[count.index], 2)}"
        ip             = "${element(local.ntp_map_server[count.index], 3)}"
        gw             = "${element(local.ntp_map_server[count.index], 4)}"
        dns            = "${element(local.ntp_map_server[count.index], 5)}"
        ntpsecserver   = "${element(local.ntp_map_server[count.index], 6)}"
        timezone       = "${element(local.ntp_map_server[count.index], 7)}"
    }

    #vsphere provider need vars
    datacenter_name = var.datacenter_name
    #cluster_name = var.cluster_name
    datastore_name = var.datastore_name
    pool_name = var.pool_name
    network01 = var.networkAdm
    template_linux_name = var.template_linux_name

}