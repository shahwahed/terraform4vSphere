locals {
  vfolder = "/infra"

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

resource "vsphere_datacenter" "dc" {
  name = local.vSphereDC
}

resource "vsphere_folder" "folder" {
  depends_on = [ vsphere_datacenter.dc ]
  path          = local.vfolder
  type          = "vm"
  datacenter_id = vsphere_datacenter.dc.moid
}

data "vsphere_host_thumbprint" "thumbprint" {
  address = local.esx01
  insecure = true
}

resource "vsphere_host" "esx01" {
  depends_on = [ vsphere_datacenter.dc ]
  hostname = local.esx01
  username   = data.vault_generic_secret.darkabyss_esx01.data["login"]
  password   = data.vault_generic_secret.darkabyss_esx01.data["password"]
  #license    = "00000-00000-00000-00000-00000"
  thumbprint = data.vsphere_host_thumbprint.thumbprint.id
  datacenter = vsphere_datacenter.dc.moid
}

resource "null_resource" "packer" {
  depends_on = [ vsphere_host.esx01 ]

  provisioner "local-exec" {
    working_dir = "../../modules/vsphere_infrastructure/ubuntu2204-LTS/"
    command = <<EOF
packer build \
  -force \
  -var vcenter_server="${local.vSphereSRV}" \
  -var insecure_connection="true" \
  -var datacenter="${local.vSphereDC}" \
  -var datastore="${local.esx01Datastore}" \
  -var folder="${local.templatesFolder}" \
  -var network="${local.vNetwork01}" \
  -var host="${local.esx01}" \
  -var vault-vsphere-key="${replace(local.vSphereVaultPath,"/","/data/")}" \
  -var vault-ssh="${replace(local.linuxSSHPassVaultPath,"/","/data/")}" \
  .
EOF
  }

}

