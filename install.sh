#!/bin/bash

function main(){

echo "Welcome To Arch Post Installation"
echo " "
echo "Choose which privelige elavator program to use: "
echo "Sudo or Doas"
read prev_elavator
echo "Which AUR helper"
echo "Yay or Paru"
read aur
echo "Choose which wm"
echo "dwm or spectrwm"
read wm
echo "Mounting point for additional drives"
read drive
echo "Initiating post installation..."
sleep 3

function privelige(){
	if [ "$prev_elavator" = "doas" ]
	then
		echo "Installing doas"
		sudo pacman -S opendoas --noconfirm
		sudo touch /etc/doas.conf
		echo "permit nopass :wheel" | sudo tee /etc/doas.conf
		doas pacman -Rns sudo --noconfirm
		doas ln -s /usr/bin/doas /usr/bin/sudo
	else
		# Add pound symbol at the start of line 82
		# and remove pound symbol at start of line 85
		sudo bash -c "sed -i '82 s/^/#/' /etc/sudoers && sed -i '85 s/^#//' /etc/sudoers"
	fi
}

function xdg(){
	sudo pacman -S xdg-user-dirs --noconfirm
	xdg-user-dirs-update
}

function Dotfiles(){
	cd $HOME
	rm .bashrc
	rm .bash_profile
	git clone https://github.com/ibbejohar/.dotfile.git
	cd .dotfile
	./config.sh
}

function packages(){

	program="
	alacritty
	aria2
	bitwarden
	curl
	exa
	feh
	firefox
	fuse
	git
	mpv
	nemo
	neofetch
	neovim
	nodejs
	ntfs-3g
	pulseaudio
	pulsemixer
	rofi
	sxiv
	unclutter
	unrar
	unzip
	zathura
	zathura-pdf-mupdf
	zip
	"
	sudo pacman -S $program --noconfirm
}

function aur_helper(){

	aur_packages="
	ani-cli
	devour
	ly
	mangodl
	nerd-fonts-complete
	"
	if [ "$aur" = "yay" ]
	then
		git clone https://aur.archlinux.org/yay.git
		cd yay
		makepkg -si --noconfirm
		cd ..
		rm -rf yay
	elif [ "$aur" = "paru" ]
	then
		git clone https://aur.archlinux.org/paru.git
		cd paru
		makepkg -si --noconfirm
		cd ..
		rm -rf paru
	else
		echo "No AUR helper was selected"
	fi

	$aur -S $aur_packages --noconfirm

}

function add_packages(){
	git clone https://github.com/CoolnsX/dra-cla
	cd dra-cla
	sudo cp dra-cla /usr/local/bin/dra-cla
	cd ..
	rm -rf dra-cla
}

function install_wm(){
	if [ "$wm" = "dwm" ]
	then
		mkdir -p $HOME/.config/suckless
		cd $HOME/.config/suckless
		git clone https://github.com/ibbejohar/dwm.git
		git clone https://github.com/ibbejohar/blocks.git

		cd dwm
		sudo make clean install
		cd ..
		cd blocks
		sudo make clean install
		./install.sh
		cd $HOME	
	elif [ "$wm" = "spectrwm" ]
	then
		sudo pacman -S spectrwm
		cd $HOME/.config
		git clone https://github.com/ibbejohar/spectrwm.git
		cd $HOME
	else
		echo "No window manager was selected"
	fi

}


function services(){
	sudo systemctl enable ly.service

}

function hardware_disable(){
	sudo touch /etc/modprobe.d/nobeep.conf
	echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf
}

function mounting_point(){
	sudo mkdir -p /media/"$drive"

}

function clean_up(){
	if [ "$prev_elavator" = "doas" ]
    then
		echo "permit persist :wheel" | sudo tee /etc/doas.conf
    elif [ "$prev_elavator" = "sudo" ]
    then
		# Add pound symbol at the start of line 85
		# and remove pound symbol at the start of line 82
		sudo bash -c "sed -i '85 s/^/#/' /etc/sudoers && sed -i '82 s/^#//' /etc/sudoers"
    else
		echo "NULL"
    fi

}

### Executing funtions ###

privelige
xdg
Dotfiles
packages
aur_helper
add_packages
install_wm
services
hardware_disable
mounting_point
clean_up

}

main
