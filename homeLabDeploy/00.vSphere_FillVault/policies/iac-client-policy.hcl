# Permits CRUD operation on kv-v2
path "homelab/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}


# List enabled secrets engines
path "secret/metadata/*" {
   capabilities = ["list"]
}
