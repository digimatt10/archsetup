#!/bin/bash


pacman --noconfirm --needed -S xorg-server
pacman --noconfirm --needed -S xorg-xinit
pacman --noconfirm --needed -S i3-gaps
pacman --noconfirm --needed -S i3lock
pacman --noconfirm --needed -S arandr
pacman --noconfirm --needed -S rofi
pacman --noconfirm --needed -S arc-gtk-theme
pacman --noconfirm --needed -S arc-icon-theme
pacman --noconfirm --needed -S networkmanager
pacman --noconfirm --needed -S gnome-keyring
pacman --noconfirm --needed -S network-manager-applet
pacman --noconfirm --needed -S networkmanager-openvpn
pacman --noconfirm --needed -S wireless_tools
pacman --noconfirm --needed -S ufw
pacman --noconfirm --needed -S ntfs-3g
pacman --noconfirm --needed -S exfat-utils
pacman --noconfirm --needed -S dosfstools
pacman --noconfirm --needed -S ranger
pacmna --noconfirm --needed -S thunar
pacman --noconfirm --needed -S vim
pacman --noconfirm --needed -S zsh
pacman --noconfirm --needed -S rxvt-unicode
pacman --noconfirm --needed -S feh
pacman --noconfirm --needed -S htop
pacman --noconfirm --needed -S wget
pacman --noconfirm --needed -S cmatrix
pacman --noconfirm --needed -S git
pacman --noconfirm --needed -S youtube-viewer
pacman --noconfirm --needed -S scrot
pacman --noconfirm --needed -S pulseaudio
pacman --noconfirm --needed -S pulseaudio-alsa
pacman --noconfirm --needed -S pamixer
pacman --noconfirm --needed -S mpd
pacman --noconfitm --needed -S ncmpcpp
pacman --noconfirm --needed -S ffmpeg
pacman --noconfirm --needed -S mpv
pacman --noconfirm --needed -S firefox
pacman --noconfirm --needed -S thunderbird
pacman --noconfirm --needed -S youtube-dl
pacman --noconfirm --needed -S libreoffice-fresh
pacman --noconfirm --needed -S mupdf
pacman --noconfirm --needed -S gimp
pacman --noconfirm --needed -S blender
pacman --noconfirm --needed -S audacity

### INSTALLING AUR PACKAGE MANAGER ###
git clone https://aur.archlinux.org/pikaur.git
cd pikaur
makepkg -fsri

### INSTALLING AUR PACKAGES ###
pikaur --noconfirm --needed -S nerd-fonts-complete
pikaur --noconfirm --needed -S polybar
pikaur --noconfirm --needed -S cli-visualizer
pikaur --noconfirm --needed -S urlview
pikaur --noconfirm --needed -S aur oh-my-zsh-git
pikaur --noconfirm --needed -S vim-plug
pikaur --noconfirm --needed -S speedometer

systemctl enable NetworkManager
systemctl start NetworkManager


