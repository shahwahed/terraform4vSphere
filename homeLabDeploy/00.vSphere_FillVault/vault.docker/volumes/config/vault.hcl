ui	= true
disable_mlock = false
api_addr = "https://0.0.0.0:8200"
disable_clustering = true

listener "tcp" {
	address = "0.0.0.0:8200"
	tls_disable = false
	tls_cert_file = "/vault/config/certs/vault-certificate.pem"
  	tls_key_file  = "/vault/config/certs/vault-key.pem"
}

storage "file" {
	path = "/vault/data"
}
