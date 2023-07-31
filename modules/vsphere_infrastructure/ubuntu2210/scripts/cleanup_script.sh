#!/bin/bash
# if you doesn't want cloud init
#purge cloud-init
#apt-get remove cloud-init -y && apt-get autoremove -y
#apt-get purge cloud-init -y
#rm -rf /etc/cloud


# removes files leftover from the cloud-config install

FILE=/etc/cloud/cloud.cfg.d/50-curtin-networking.cfg
if test -f "$FILE"; then
  rm $FILE
  echo "cleanup ${FILE}"
fi

FILE=/etc/cloud/cloud.cfg.d/curtin-preserve-sources.cfg
if test -f "$FILE"; then
  rm $FILE
  echo "cleanup ${FILE}"
fi

# add support for for using user-data & meta-data from cloud-init via extra-guest info
#curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -
# next lines is for cloud-init to work with vsphere 6.7 and up

grep "disable_vmware_customization: false" /etc/cloud/cloud.cfg > /dev/null 2>&1
if [ $? -eq 1 ]; then
    echo "disable_vmware_customization: false" >> /etc/cloud/cloud.cfg
fi

# Allows VMware customization of the VM using cloud-init
# check kb for more information
# https://kb.vmware.com/s/article/54986
# https://kb.vmware.com/s/article/59557
# enable cloud-init guest customization using ospsec
FILE=/etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
if test -f "$FILE"; then
  rm $FILE
  echo "cleanup ${FILE}"
fi

FILE=/etc/cloud/cloud.cfg.d/99-installer.cfg
if test -f "$FILE"; then
  rm $FILE
  echo "cleanup ${FILE}"
fi

# Cleanup cloud init logs files
cloud-init clean --logs

#cleanup apt cache
apt-get autoremove -y

#Stop services for cleanup
sudo service rsyslog stop

#clear audit logs
if [ -f /var/log/wtmp ]; then
    truncate -s0 /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    truncate -s0 /var/log/lastlog
fi

#cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

#cleanup current ssh keys
rm -f /etc/ssh/ssh_host_*

# add check for ssh keys on reboot...regenerate if neccessary
# cloud init will do it but in case you don't have cloud-init or don't want to trust it
cat << 'EOL' | sudo tee /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
# dynamically create hostname (optional)
#if hostname | grep localhost; then
#    hostnamectl set-hostname "$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')"
#fi
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL

# make sure the script is executable
chmod +x /etc/rc.local

#enable systemd rc.local
cat << 'EOL' | sudo tee /etc/systemd/system/rc-local.service
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target
EOL

sudo systemctl enable rc-local

#reset hostname
truncate -s0 /etc/hostname
hostnamectl set-hostname utemplate

#cleanup apt
apt-get clean -y

# cleanup machine id for dhcp
cat /dev/null > /etc/machine-id

# this will be done by cloud-init but just in case
# force a new random seed to be generated
rm -f /var/lib/systemd/random-seed

#cleanup shell history
cat /dev/null > ~/.bash_history && history -c
history -w

echo "Cleanup finish"

#shutdown -h now


exit 0 