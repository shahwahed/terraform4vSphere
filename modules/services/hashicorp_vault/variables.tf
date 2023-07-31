variable "dns_srv_config" {
    type = map
    description = "DNS server configuration input"
    default = {
        "vfolder"        = "/"
        "vmname"         = "dns01"
        "hostname"       = "dns01.mydomain.lan"
        "servicednsname" = "dns01.mydomain.lan"
        "ip"             = "192.168.1.208/24"
        "gw"             = "192.168.1.1"
        "dns"            = "1.1.1.1"
        "dnszoneip"      = "192.168.1.208"
        "dbname"         = "pdnsdb"
        "dblogin"        = "pdnsusr"
        "dbpassword"     = "pdnsDBPASSWORDCHANGEME"
        "sysuser"        = "pdns"
        "sysgroup"       = "pdns"
        "apikey"         = "APIKEYCHANGEME"  
    }
}
