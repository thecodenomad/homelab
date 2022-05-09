#!/bin/bash
set -e 

username="root"
node_ip="${1}"
gpg_sum="7fb03ec8a1675723d2853b84aa4fdb49a46a3bb72b9951361488bfd19b29aab0a789a4f8c7406e71a69aabbc727c936d3549731c4659ffa1a08f44db8fdcebfa"
ssh_identity="${HOME}/.ssh/home_rsa"

if [[ -z "${node_ip}" ]]; then
    echo "This script requries a node ip!"
    exit 1
fi


# Setup installs cript
cat << EOF > /tmp/proxmox_install.sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "Setting up repo"
echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
sha512sum /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg | grep "7fb03ec8a1675723d2853b84aa4fdb49a46a3bb72b9951361488bfd19b29aab0a789a4f8c7406e71a69aabbc727c936d3549731c4659ffa1a08f44db8fdcebfa" 

echo "Making sure hostname is working..."
sed -i 's/127.0.1.1/${node_ip}/g' /etc/hosts

apt-get update
apt-get upgrade -y
echo "Starting install..."
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Local Only'"
DEBIAN_FRONTEND=noninteractive apt install -y proxmox-ve postfix open-iscsi 

echo "Formatting SD Card"
mkfs.ext4 /dev/mmcblk1p1 

echo "Setting up fstab for SD Card"
if ! grep "/mnt/sd_card" /etc/fstab; then
  mkdir -p /mnt/sd_card
  /usr/sbin/blkid /dev/mmcblk1p1 | awk '{printf "%s    /mnt/sd_card ext4 discard,noatime,errors=remount-ro 0 1", \$2}' >> /etc/fstab 
  echo "" >> /etc/fstab
  echo "Updated fstab:"
  cat /etc/fstab 
  echo 

  if ! mount | grep mmcblk1p1; then
      echo "Mounting sd card..."
      mount /mnt/sd_card &> /dev/null && echo "Successfully mounted sd card, moving on..."
  fi
fi

echo "Removing root login capabilities over ssh"
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

echo "All done, rebooting in 5 seconds..."
sleep 5 && reboot
EOF

echo "Setting up ssh key"
ssh-copy-id -i ${ssh_identity} ${username}@${node_ip}

echo "Copying install script."
scp /tmp/proxmox_install.sh ${username}@${node_ip}:/tmp/proxmox_install.sh

echo "Starting install..."
ssh -i ${ssh_identity} ${username}@${node_ip} chmod +x /tmp/proxmox_install.sh
ssh -i ${ssh_identity} ${username}@${node_ip} /tmp/proxmox_install.sh 

