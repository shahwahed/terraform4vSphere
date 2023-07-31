variable "acme_srv_config" {
    type = map
    description = "DNS configuration input"
    default = {
        "vfolder"           = "/"
        "vmname"            = "pki01"
        "hostname"          = "pki01.mydomain.lan"
        "servicednsname"    = "pki01.mydomain.lan"
        "ip"                = "192.168.1.201/24"
        "gw"                = "192.168.1.1"
        "dns"               = "192.168.1.208"
        "password"          = "CHANGEME"
        "provisionerpass"   = "CHANGEME"
        "provisionername"   = "mydomain.pki"
        "sysuser"           = "stepca"
        "sysgroup"          = "stepca"
        "pkiname"           = "pki01.mydomain.lan"
    }
}

