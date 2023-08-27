### 00.vSphere_fillVault

## If you don't have a vault server

If you don't have a vault, you can use the docker compose file in ./vault.docker to create one.

You will need to create a certificate using openssl or the terraform file in CertPKI.

Pull them in volumes/config/certs folder: 

```sh
volumes/
└── config
    └── certs
        ├── vault-certificate.pem
        └── vault-key.pem
```

## Fill vault with value
Quick Terraform to fill your vault with minimum information for your IaC home lab deployment.

the data model could be improve but for now :

```sh
$ vault kv list -mount=homelab
Keys
----
esx01
ssh_multipass01
vsphere
```

with :
* esx01 ==> creds for esxi
* ssh_multipass01 ==> creds for linux boxes user/password
* vsphere ==> root password, administrator password and domain for VCSA appliance

Two policies have been created :
* admins : for admins (can configure vault)
* iac-client : for group allowed create and delete secret in the homelab kv realm

Thow users have been created :
* admin just to don't use root :)
* iacuser to be use by your terraform script, security best practice

To fill your vault you will need the root token.

## Grab a token with your freshly created user

After that you could login to grab a token for iacuser for all the deployment.

```sh
$ vault login -method=userpass username=iacuser
Password (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                    Value
---                    -----
token                  xxx.zdazjdjifjvnzjdé23232Sefezf2323Def88953GgtuUYDcfgrtyrETfgrthscXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
token_accessor         sdsdsfdEZDFCFe32XXXXXXXX
token_duration         768h
token_renewable        true
token_policies         ["default" "iac-client"]
identity_policies      []
policies               ["default" "iac-client"]
token_meta_username    iacuser

```

