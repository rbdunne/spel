#!/bin/bash

# Bail if we are not running inside VirtualBox.
if [[ "$(virt-what | head -1)" != "virtualbox" ]]; then
    exit 0
fi

# Install deps
echo "installing virtualbox guest addition dependencies"
VBOX_GUEST_DEPS="kernel-devel kernel-headers gcc perl"
bash /tmp/retry.sh 5 yum -y install ${VBOX_GUEST_DEPS}
bash /tmp/retry.sh 5 yum -y install dkms make
KERN_DIR=/usr/src/kernels/$(uname -r)
export KERN_DIR

# Install VirtualBox Guest Additions
echo "installing virtualbox guest additions"
mkdir -p /mnt/virtualbox
mount -o loop /home/vagrant/VBoxGuest*.iso /mnt/virtualbox
sh /mnt/virtualbox/VBoxLinuxAdditions.run || true
ln -s /opt/VBoxGuestAdditions-*/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
umount /mnt/virtualbox
rm -rf /home/vagrant/VBoxGuest*.iso

# Remove deps
echo "removing virtualbox guest addition dependencies"
yum -y remove --setopt=clean_requirements_on_remove=1 ${VBOX_GUEST_DEPS}
