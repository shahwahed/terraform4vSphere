Readme in English 
[![en](https://img.shields.io/badge/lang-fr-red.svg)](https://github.com/shahwahed/terraform4vSphere/blob/master/Readme.md)


# Cloud init template pour terraform

Ce dépôt contient des templates cloud-init que j'utilise avec terraform et son provider vSphere.

Vous devriez pouvoir utiliser la partie cloud-init avec n'importe quel systeme qui utilise cloud-init.


Cloud init support le yaml ou du langage script, pour plus d'informations https://cloudinit.readthedocs.io/en/latest/

Si vous pouvez le faire à la main en utilisant bash, vous pouvez le faire avec cloud-init!

Dans ce dépôt vous pouvez aussi trouver :

- un répertoire de test nommé test_cloudinit pour crée une VM et verifier que vos template soit bien compatible avec cloud-init
- un répertoire nommé test_Stage pour tester les modules en créant la VM correspondante


## Cloud-init Mime Multi Part Archive


Cloud-init support d’être séparé en plusieurs fichiers, l'avantage c'est plus modulaire et bien mieux réutilisable.

A force de faire des fichiers cloud-init pour chaque service (dns, ntp, netbox...), chaque fichier avait des parties identique, parfois avec de légère différence.
Avec le multipart mime, vous pouvez séparer votre code en plusieurs parties et lorsque vous faite une mise à jour, tous vos template le son d'un coup!


J'utilise aussi le système de template basic de terraform pour rendre encore plus générique mes fichiers cloud-init, couplé a vault pour la gestion des secrets et le config management c'est idéal pour l'automatisation de vos déploiements vSphere

pour plus d'info sur le multi part avec cloud-init : https://cloudinit.readthedocs.io/en/latest/topics/format.html#helper-subcommand-to-generate-mime-messages 

## Structure du dépôt

```sh
├── homeLabDeploy               # déploiement d'un homelab vsphere en utilisant terraform et packer
│
├── modules                     # répertoire des modules
│   ├── services                # sous repertoires services, chaque répertoire à l'intérieur est un module définissant un service (ntp, dns, ipxe...)
│   ├── srvTemplate             # répertoire contenant les script cloud-init multi part (user-data et meta-data)
│   └── vsphere_infrastructure  # template packer pour vSphere ubuntu 22.04 LTS et 22.10
│
└── testing                     # répertoire
    ├── test_cloudinit          # pour tester si vos templates fonctionne avec cloud-init
    └── test_Stage              # pour tester de maniere unitaire un module

```
## Modules Terraform

Dans le répertoire modules, vous aller voir tous mes modules pour créer différent services.

Tous les modules crée des VM Linux qui seront configurer en utilisant cloud-init. Tous les fichiers cloud-init ont été tester avec une distribution ubuntu (22.04 LTS, 22.10 et 23.04)

Les fichiers cloud-init sont situées dans le répertoire srvTemplate.

## Arborescence et structure des fichiers cloud-init

Dans le répertoire srvTemplate, vous avez deux répertoire metadata et userdata.split.

Le répertoire userdata.split contient différent script cloud-init, chacun étant soit pour de la configuration système (ex parefeu) ou une installation d'un services (ex dns, ntp ...).

Chaque fichier template commence par des chiffres de 00 a 99 pour mieux s’y retrouver.

00 etapes d'initialisation
1X système de configuration de base
2X réseau et parefeu
3X services
5X ngnix frontend
99 etape final pour reboot

| Fichier        | Description           |
| ------------- | ------------- |
| 00.disableAutoUpdate_cloud-init.tftpl  | désactivation de l'autoupdate, pour accélérer les déploiements |
| 11.systembase.IPFORCED.tftpl  | config du hostname avec une ip static fixe |
|10.systembase.tftpl    |   config du hostname  |
|20.firewall.tftpl  | configuration simple du parefeu ufw |
|20.firewallADV.tftpl| configuration avancé du parefeu ufw |
|21.NAT.tftpl | mise en place d'un nat avec dhcp|
|22.NATnodhcp.tftpl | mise en place d'un nat sans dhcp|
|30.minio.core.tftpl | serveur de stockage minio S3 |
|30.powerdns.core.nopubwebsrv.tftpl | serveur powerdns sans serveur web|
|30.powerdns.core.tftpl| serveur powerdns |
|30.vaultConsul.core.tftpl| vault avec backend consul|
|30.netbox.core.tftpl | netbox dcim |
|30.stepca.core.tftpl | stepca serveur ACME cool de smallstep|
|30.stepca.core.listenallint.tftpl | stepca serveur ACME cool de smallstep, ecoute sur toutes les interfaces|
|30.harbor.core.tftpl | harbor registry à la dockerhub |
|30.keycloak.core.tftpl| serveur keycloak |
|30.SSHCERTONLY.tftpl| configure le serveur ssh pour des certificats générés par STEPCA CA!!!
|50.SSL_NGNIX_With_ACME.tftpl | frontend NGNIX avec certificat ACME stepca
|51.SSL_NGNIX_With_ACME_With_BOOTSTRAP.tftpl| frontend NGNIX avec certificat autosigné|
|99.finalreboot.tftpl | reboot final avec effacement des fichiers cloud-init pour raison de sécurité
|
## Optimisations

durcissemments des services
ajout de script de durcissements système


## Usage/Exemples

Utiliser comme un module standard terraform, vous n'avez qu'a donner le minimum d'information au provider vSphere utilisé par le module
Vous pouvez utiliser des variables locale comme un "map" ou définir chaque variable unitairement.

```terraform
module "ntp" {
  source = "../modules/services/ntp" # chemin vers les modules
  count = "1" # optionnel vous pouvez utiliser la variable count pour faire plusieurs instance

    # variable requis par les modules
    # dans chaque module une liste des variables nécessaire est disponible dans le fichier variable.tf du module
    ntp_srv_config = {
        vfolder        = "/"
        vmname         = "ntp01"
        hostname       = "ntp01.mydomain.lan"
        servicednsname = "ntp01.mydomain.lan"
        ip             = "192.168.1.208/24"
        gw             = "192.168.1.1"
        dns            = "1.1.1.1"
        ntpsecserver   = "ntppool1.time.nl"
        timezone       = "Europe/Paris"
    }

    #variable nécessaire au provider vsphere du module
    datacenter_name = "dc_name"
    #cluster_name = "cluster_name"
    datastore_name = "datastore_name"
    pool_name = "pool_name"
    network01 = "networkAdm"
    template_linux_name = "template_linux_name"

}
```

utilisation uniquement de la partie cloud-init avec le provider terraform :


On crée d'abord le fichier cloud-init user-data

```terraform
# cloud-init userdata dynamic for a nat gateway
data template_cloudinit_config "simpleNatGateway" {
  gzip          = true
  base64_encode = true


  part {
    content     = templatefile("../../srvTemplate/userdata.split/10.systembase.tftpl",
    {
      servicednsname="myVmDnsName"
    })
    content_type = "text/x-shellscript"
  }
  part {
    content_type = "text/x-shellscript"
    content  = templatefile("../../srvTemplate/userdata.split/20.firewall.tftpl",
    {
      firewall_ports_in="22/tcp,67/udp,68/udp"
      firewall_ports_out="22/tcp,53/udp,67/udp,68/udp,80/tcp,443/tcp"
    })
  }
  part {
    content_type = "text/x-shellscript"
    content  = templatefile("../../srvTemplate/userdata.split/21.NAT.tftpl",
    {
      dnsmasq_dhcp_clients="192.168.2.0/24",
      dnsmasq_range="192.168.2.100,192.168.2.150,255.255.255.0",
      dnsmasq_dns="1.1.1.1",
      out_interface="ens192",
      int_interface="ens224"
    })
  }
}

```

Puis utilisation du template généré avec le provider vsphere pour terraform
```terraform

resource vsphere_virtual_machine "natgateway" {
  name  = "natgateway"
  resource_pool_id = "myvspherepool"
  datastore_cluster_id     = "myDatastoreCluster"

  num_cpus = 2
  memory   = 512
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  cdrom {
    client_device = true
  }

  network_interface {
    network_id   = data.vsphere_network.network01.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }


  wait_for_guest_net_timeout = 0

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    #eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(templatefile("../../srvTemplate/metadata/metadata1nicStatic.tftpl",
                                    {
                                      hostname="gateway01",
                                      ipA="192.168.2.1/24",
                                      gw="192.168.1.1",
                                      dns="1.1.1.1",
                                    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata" = data.template_cloudinit_config.simpleNatGateway.rendered
    "guestinfo.userdata.encoding" = "gzip+base64"
  }
  
}
```

## Badges

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![Terraform vSphere Provider](https://img.shields.io/badge/terraform-vsphere__provider-green)](https://registry.terraform.io/providers/hashicorp/vsphere/latest)
[![vsphere version](https://img.shields.io/badge/vsphere-6.X%2C%207.X-green)](https://vmware.com)

