### 00.vSphere_fillVault


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

