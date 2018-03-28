#!/bin/bash

#Erase the Disk
#echo 'Erasing /dev/sda'
#shred --verbose --random-source=/dev/urandom --iterations=1 /dev/sda

#Partition the Disk
echo 'Partitioning the Disk sda1-boot sda2-root'
(
echo o # Create a new empty DOS partition table
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (Accept default: 1)
echo +100M # 100 MB boot parttion
echo n # Add a new partition
echo p # Primary partition
echo 2 # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector (Accept default: End of Disk)
echo a # make a partition bootable
echo 1 # bootable partition is partition 1 -- /dev/sda1
echo p # print the in-memory partition table
echo w # Write changes
echo q # and we're done
) | sudo fdisk /dev/sda

#Create cryptographic device mapper device in LUKS encryption mode
echo 'Setting up Full Disk Encryption'
cryptsetup --verbose --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat /dev/sda2

#Unlock the partition (cryptroot will be the device mapper name)
cryptsetup open --type luks /dev/sda2 cryptroot

#Create and mount the file systems
echo 'Creating and mounting the file system'
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/mapper/cryptroot
mount -t ext4 /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount -t ext4 /dev/sda1 /mnt/boot

#Install the base and base-devel systems
echo 'Installing the base system'
pacstrap -i /mnt base base-devel

#Download the chroot script to be executed in the base System
echo 'Downloading the chroot scripts'
wget https://raw.githubusercontent.com/digimatt10/archsetup/master/w520-arch-install-chroot.sh -P /mnt/root
chmod +x /mnt/root/w520-arch-install-chroot.sh

#Generate the fstab
echo 'Generating the fstab'
genfstab -U -p /mnt >> /mnt/etc/fstab

#Chroot to configure the base system
echo 'chrooting into the base system'
arch-chroot /mnt /root/w520-arch-install-chroot.sh

#Unmount and reboot
echo 'Unmounting and rebooting'
umount -R /mnt/boot
umount -R /mnt
cryptsetup close cryptroot
systemctl reboot


