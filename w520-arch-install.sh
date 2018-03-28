#!/bin/bash

#Erase the Disk
#shred --verbose --random-source=/dev/urandom --iterations=1 /dev/sda

#Partition the Disk
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
cryptsetup --verbose --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat /dev/sda2

#Unlock the partition (cryptroot will be the device mapper name)
cryptsetup open --type luks /dev/sda2 cryptroot

#Create and mount the file systems
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/mapper/cryptroot
mount -t ext4 /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount -t ext4 /dev/sda1 /mnt/boot

#Install the base and base-devel systems
pacstrap -i /mnt base base-devel

#Generate the fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

#Chroot to configure the base system
arch-chroot /mnt

#Uncomment the en_US locale
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

#Generate the locale
locale-gen

#Create configuration file that would instruct the system what language locale it should be using
echo LANG=en_US.UTF-8 > /etc/locale.conf

#Export the locale
export LANG=en_US.UTF-8

#Create a symbolic link with the desired time zone
ln -s /usr/share/zoneinfo/Canada/Eastern /etc/localtime

#Set the hardware clock to UTC
hwclock --systohc --utc

#Set the desired hostname
echo 'What is your desired hostname?'
read -p 'Hostname: ' newhostname
echo $newhostname > /etc/hostname

#Set the root password
echo 'Set the root Password'
passwd

#Add a system user
echo 'Adding a system user'
read -p 'Username: ' uservar
useradd -m -g users -G wheel,games,power,optical,storage,scanner,lp,audio,video -s /bin/bash $uservar
passwd $uservar

#Install sudo (base-devel) and the boot loader grub and os-prober
pacman --noconfirm --needed -S sudo grub-bios os-prober

#Allow the system user to use sudo and run commands (temporary) as root
sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /etc/sudoers

#kernel parameter to be able to unlock your LUKS encrypted root partition during system startup
sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=\/dev\/sda2:cryptroot\"/" /etc/default/grub 

#Add encrypt hook
sed -i 's/HOOKS=.*/HOOKS="base udev autodetect keyboard modconf block encrypt filesystems fsck"/' /etc/mkinitcpio.conf

#re-generate our initrams image (ramdisk)
mkinitcpio -p linux

#Install grub and save it's configuration file
grub-install --recheck /dev/sda
grub-mkconfig --output /boot/grub/grub.cfg

#Exit from chroot, unmount the partitions, close the device and reboot (remove the installation media)
exit
umount -R /mnt/boot
umount -R /mnt
cryptsetup close cryptroot
systemctl reboot


