# just wait few second to make sure vault is correctly created
resource "time_sleep" "wait_5_seconds" {
  create_duration = "5s"
}

#--Resource Groups
variable "vsphere_secrets" {
    description = "vSphere Secrets"
    type        = list(string)
    default     = ["rootpassword",
                 "admpassword",
                 "domain"]
}

variable "esxi_secrets" {
    description = "ESXi Secrets"
    type        = list(string)
    default     = ["login",
                 "password"]
}

variable "ssh_multipass01" {
    description = "Linux Secrets"
    type        = list(string)
    default     = ["username",
                 "password"]
}

# set random passwords!!!
#

resource "random_password" "homelabSecrets" {
    length = 16
    special = false
    count   = "4"
}

resource "vault_generic_secret" "vsphereSecrets" {
    depends_on = [time_sleep.wait_5_seconds]
    path      = "homelab/vsphere"
    count     = "${length(var.vsphere_secrets)}"
    data_json = <<EOT
    {
    "${var.vsphere_secrets[0]}": "${random_password.homelabSecrets.0.result}",
    "${var.vsphere_secrets[1]}": "${random_password.homelabSecrets.1.result}",
    "${var.vsphere_secrets[2]}": "mondomain.tld"
    }
    EOT
}

resource "vault_generic_secret" "linuxSecrets" {
    depends_on = [time_sleep.wait_5_seconds]
    path      = "homelab/ssh_multipass01"
    count     = "${length(var.ssh_multipass01)}"
    data_json = <<EOT
    {
    "${var.ssh_multipass01[0]}": "osadmin",
    "${var.ssh_multipass01[1]}": "${random_password.homelabSecrets.2.result}"
    }
    EOT
}

# if you want to get up random password for your ESXi
# replace "VMware123" by "${random_password.homelabSecrets.3.result}"
# don't forget to modify your actual ESXi password with this one
# if you want to use deploy your homelab 

resource "vault_generic_secret" "esxiSecrets" {
    depends_on = [time_sleep.wait_5_seconds]
    path      = "homelab/esx01"
    count     = "${length(var.esxi_secrets)}"
    data_json = <<EOT
    {
    "${var.esxi_secrets[0]}": "root",
    "${var.esxi_secrets[1]}": "VMware123"
    }
    EOT
}


