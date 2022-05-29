#!/usr/bin/env bash

# Reference material
# https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134
# https://linuxhint.com/install-nix-os/

set -e

# Location of the configuration.nix that will be used
NIX_CONFIG="/tmp/configuration.nix"

# Installation Drive configuration
ROOT_DEVICE=/dev/nvme0n1
EFI_PARTITION="${ROOT_DEVICE}p1"
LUKS_PARTITION="${ROOT_DEVICE}p2"

# Partition size configuration
# System has 64GB of RAM, create swap to handle hibernation and use the rest for /root
SWAP_SIZE="64G"
ROOT_SIZE="100%FREE"

# Luks configurations (1GB EFI partition with rest of the drive being LUKs)
EFI_SIZE="1GiB"
LUKS_SIZE="100%"

# Advanced/Misc
PV_NAME="enc-pv"
ROOT_MKFS="mkfs.ext4"

banner()
{
  echo "==========================================================="
  echo "${@}"
  echo "==========================================================="
  echo ""
}

#==============#
# Partitioning #
#==============#

banner "Partitioning ${ROOT_DEVICE}"

# NOTE: It is up to the user to make sure this is a 'fresh' drive
# dd if=/dev/zero of="{ROOT_DEVICE}"  bs=512  count=1

# TODO: This is NOT resilient. If it fails the first time around you can't just
#       rerun the script due to the kernel not being able to see the new partitions.
#       Is this an issue with out parted is being used?

# Set Partition Map
parted "${ROOT_DEVICE}" --script mklabel gpt

# Setup EFI partition
parted "${ROOT_DEVICE}" --script mkpart ESP fat32 1MiB "${EFI_SIZE}"

# Setup LUKs partition
parted "${ROOT_DEVICE}" --script mkpart primary "${EFI_SIZE}" "${LUKS_SIZE}"

# Finalize by setting partition types
parted "${ROOT_DEVICE}" --script set 1 esp on
parted "${ROOT_DEVICE}" --script set 2 LVM

#=====================#
# Creating PV and LVs #
#=====================#

banner "Setting up LUKs for encryption"
cryptsetup luksFormat "${LUKS_PARTITION}"

banner "Your password is needed to unlock the newly encrypted drive"
cryptsetup luksOpen "${LUKS_PARTITION}" "${PV_NAME}"

banner "Creating volume groups and formatting partitions."

# Create the physical volume and volume group
pvcreate /dev/mapper/"${PV_NAME}"
vgcreate vg /dev/mapper/"${PV_NAME}"

# Create swap logical volume
lvcreate -L "${SWAP_SIZE}" -n swap vg

# Create root logical volume
lvcreate -l "${ROOT_SIZE}" -n root vg

# Format the partitions
mkfs.fat "${EFI_PARTITION}"
"${ROOT_MKFS}" -L root /dev/vg/root
mkswap -L swap /dev/vg/swap

#===================#
# Mount Filesystems #
#===================#

banner "Mounting all filesystems into /mnt for NixOS next steps."
mount /dev/vg/root /mnt
mkdir /mnt/boot
mount "${EFI_PARTITION}" /mnt/boot
swapon /dev/vg/swap

banner "Generating the hardware config"
# NOTE: This is required for Nix to setup the appropriate hardware.nix which
#       is then used to provide the /etc/fstab with partition UUIDs
#       (TODO: Is there another way to generate JUST the hardware config?)
nixos-generate-config --root /mnt

echo "Copying over the provided Nix configuration..."
cp "${NIX_CONFIG}" /mnt/etc/nixos/configuration.nix

banner "Do the install!"
nixos-install

echo "Everything should be peachy now, time to reboot!"

