# ubuntu 22.10 template, by default use password store in vault
# uncomment none vaut password to with standard password
# to use vault export your VAULT_TOKEN and VAULT_ADDR as bash variable before run packer

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

#source bloc
source "vsphere-iso" "u2210_autoinstall" {
  #VM definition
  vm_name              = "ubuntu-2210-amd64-v6"
  notes                = "build template v06 ubuntu 2210 via autoinstall"  
  #iso ubuntu 22.10 autoinstall
  iso_checksum         = "sha256:874452797430a94ca240c95d8503035aa145bd03ef7d84f9b23b78f3c5099aed"
  iso_urls             = ["iso/ubuntu-22.10-live-server-amd64.iso", "https://releases.ubuntu.com/kinetic/ubuntu-22.10-live-server-amd64.iso"]

  convert_to_template  = "true"
  vm_version           = "17"
  CPUs                 = "1"
  RAM                  = "4096"
  RAM_reserve_all      = "false"
  firmware             = "efi-secure"
  guest_os_type        = "ubuntu64Guest"
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = "32768"
    disk_thin_provisioned = "true"
  }
  network_adapters {
    network      = "${var.network}"
    network_card = "vmxnet3"
  }
  
  #Boot command we use CDROM for autoinstall
  boot_command = [
   "<tab><tab><tab><tab><tab><c><wait><bs><bs>",
    "set gfxpayload=keep", "<enter>",
    "linux /casper/vmlinuz quiet autoinstall ---", "<enter>",
    "initrd /casper/initrd", "<enter>",
    "boot",  "<enter>"
     ]
  #boot_command           = ["<esc><esc><esc>","<enter><wait>","/casper/vmlinuz ","initrd=/casper/initrd ","autoinstall autoinstall ","<enter>"]
  boot_order             = "cdrom,disk,floppy"
  boot_wait              = "5s"
  cd_files               = ["./cdrom/meta-data","./cdrom/user-data"]
  cd_label               = "cidata"
  #if uncommented http server is on
  #http_directory         = "http-dir"

  #vsphere definition
  vcenter_server         = "${var.vcenter_server}"
  #username               = "${var.vcenter_user}"
  username               = join("@",[vault("${var.vault-vsphere-key}", "login"),vault("${var.vault-vsphere-key}", "domain")])
  #password               = "${var.vcenter_password}"
  password               = vault("${var.vault-vsphere-key}", "admpassword")
  insecure_connection    = "${var.insecure_connection}"
  datacenter             = "${var.datacenter}"
  #cluster                = "${var.cluster}"
  host                   = "${var.host}"
  datastore              = "${var.datastore}"
  folder                 = "${var.folder}"
 
  #Communicator part for doing stuff after installation before convert to template
  communicator           = "ssh"
  #communicator           = "none"
  shutdown_timeout       = "120m"
  
  ssh_handshake_attempts = "300"
  ssh_pty                = true
  ssh_timeout            = "120m"
  #ssh_username           = "${var.ssh_username}"
  ssh_username           = vault("${var.vault-ssh}", "username")
  #ssh_password           = "${var.ssh_password}"
  ssh_password           = vault("${var.vault-ssh}", "password")
  ip_settle_timeout      = "8m"
  #uncomment if you have trouble with shutdown as standard user
  #choose between with vault password or not
  #shutdown_command       = "echo ${vault("${var.vault-ssh}", "password")} | shutdown -P now"
  #shutdown_command       = "echo ${var.ssh_password} | shutdown -P now"

}

build {
  sources = ["source.vsphere-iso.u2210_autoinstall"]

  provisioner "file"{
   source = "scripts/cleanup_script.sh"
   destination = "/tmp/cleanup_script.sh"
   }
  
  provisioner "shell"{
   remote_folder = "/tmp"
   #inline = [
   #  "echo ${var.ssh_password} |sudo -S bash /tmp/cleanup_script.sh"
   #  ]
   inline = [
     "echo ${vault("${var.vault-ssh}", "password")} |sudo -S bash /tmp/cleanup_script.sh"
     ]
   }

}
