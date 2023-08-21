provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables:
  #    - VAULT_ADDR
  #    - VAULT_TOKEN
  #    - VAULT_CACERT
  #    - VAULT_CAPATH
  #    - etc.
}

# Enable K/V v2 secrets engine to store your config and secret for your homelab
resource "vault_mount" "homelabKV" {
  path = "homelab"
  type = "kv-v2"
} 

# Create Policies to use vault 
# admins => can manage and create
# IaC ==> can just consume 

# Create admin policy in the root namespace
resource "vault_policy" "admin_policy" {
  name   = "admins"
  policy = file("policies/admin-policy.hcl")
}

# Create 'IaC' policy just to restrict IaC to the homelab realm/vault
# it is a best practice, if you don't care about security
# you could only use root token ...


resource "vault_policy" "iac-client" {
  name   = "iac-client"
  policy = file("policies/iac-client-policy.hcl")
}

# Enable user auth backend
resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

# Create a user, 'admin'
# Add it to admins group
# Remember that admin group is not allowed to add secret to homelab realm/vault
resource "vault_generic_endpoint" "adminuser" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/admin"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["admins"],
  "password": "adminchangeme"
}
EOT
}

resource "vault_generic_endpoint" "iacuser" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/iacuser"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["iac-client"],
  "password": "changemeagain"
}
EOT
}


