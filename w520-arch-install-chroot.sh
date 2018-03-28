#!/bin/bash

#Uncomment the en_US locale
echo 'setting the language and locale'
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
