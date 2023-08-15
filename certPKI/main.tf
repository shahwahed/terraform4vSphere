provider "tls" {
  # Configuration options
}

resource "tls_private_key" "cm_ca_private_key" {
  #algorithm = "ED25519"
  algorithm = "RSA"
  rsa_bits  = 4096 
}


resource "local_file" "cm_ca_key" {
  content  = tls_private_key.cm_ca_private_key.private_key_pem
  filename = "${path.module}/certs/cloudcornerCA.key"
}


resource "tls_self_signed_cert" "cm_ca_cert" {
  private_key_pem = tls_private_key.cm_ca_private_key.private_key_pem

  is_ca_certificate = true

  subject {
    country             = "FR"
    province            = "Fantasy Island"
    locality            = "Southern Masleonebax Wanrated"
    common_name         = "Cloud Corner Root CA"
    organization        = "Cloud Corner Cyber Team"
    organizational_unit = "Cloud Corner Root Certification Auhtority"
  }

  validity_period_hours = 43800 //  1825 days or 5 years

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "local_file" "cm_ca_cert" {
  content  = tls_self_signed_cert.cm_ca_cert.cert_pem
  filename = "${path.module}/certs/cloudcornerCA.cert"
}

# Create private key for server certificate 
resource "tls_private_key" "cm_internal" {
  #algorithm = "ED25519"
  algorithm = "RSA"
  rsa_bits  = 4096 
}

resource "local_file" "cm_internal_key" {
  content  = tls_private_key.cm_internal.private_key_pem
  filename = "${path.module}/certs/vault.cloudcorner.key"
}


# Create CSR for for server certificate 
resource "tls_cert_request" "cm_internal_csr" {

  private_key_pem = tls_private_key.cm_internal.private_key_pem

  dns_names = ["vault.cloudcorner.internal","vault.local"]
  ip_addresses = ["127.0.0.1","172.16.0.2"]

  subject {
    country             = "FR"
    province            = "Fantasy Island"
    locality            = "Southern Masleonebax Wanrated"
    common_name         = "Cloud Corner Internal Vault"
    organization        = "Cloud Corner"
    organizational_unit = "Vault Cloud Corner"
  }
}

# Sign Seerver Certificate by Private CA 
resource "tls_locally_signed_cert" "cm_internal" {
  // CSR by the development servers
  cert_request_pem = tls_cert_request.cm_internal_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = tls_private_key.cm_ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = tls_self_signed_cert.cm_ca_cert.cert_pem

  validity_period_hours = 43800

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "cm_internal_cert" {
  content  = tls_locally_signed_cert.cm_internal.cert_pem
  filename = "${path.module}/certs/vault.cloudcorner.cert"
}
