#!/bin/bash

# color
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
NC='\033[0m'

function main () {

function privelige(){
	if [ "$prev_elavator" = "1" ]
	then
		echo "Installing doas"
		sudo pacman -S opendoas --noconfirm
		sudo touch /etc/doas.conf
		echo "permit nopass :wheel" | sudo tee /etc/doas.conf
		doas pacman -Rns sudo --noconfirm
		doas ln -s /usr/bin/doas /usr/bin/sudo
    elif [ "$prev_elavator" = "2" ]
    then
		# Add pound symbol at the start of line 82
		# and remove pound symbol at start of line 85
		sudo bash -c "sed -i '82 s/^/#/' /etc/sudoers && sed -i '85 s/^#//' /etc/sudoers"
    else 
		echo -e "${RED}This postinstall script will not work if the privelige elavator is not choosen"
		sleep 3
		exit
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
	if [ "$aur" = "1" ]
	then
		git clone https://aur.archlinux.org/yay.git
		cd yay
		makepkg -si --noconfirm
		cd ..
		rm -rf yay
	elif [ "$aur" = "2" ]
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

		# dwm
	if [ "$wm" = "1" ]
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

		# spectrwm
	elif [ "$wm" = "2" ]
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
	if [ "$prev_elavator" = "1" ]
    then
		echo "permit persist :wheel" | sudo tee /etc/doas.conf
    elif [ "$prev_elavator" = "2" ]
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

function automation(){

    if [ "$action" = "1" ]
    then
		prev_elavator="1"
		aur="2"
		wm="1"
		drive="sda1"

		main
    elif [ "$action" = "2" ]
    then
		sleep 0
    else
		echo "Follow the instruction"
		exit
    fi
}

function not_root(){
   id=`whoami`
   if [ "$id" = "root" ]
   then
		echo -e "${RED}Please run the script as a normal user, not as root"
		echo -e "${NC}"
		sleep 3
		exit
   fi

}


not_root
echo -e "${PURPLE}Welcome To Arch Post Installation"
echo " "
echo "Choosing the Automatic option, the script will choose for you."
echo "Choosing the Manual way, you will have two options in every questons that follow."
echo " "
sleep 3
echo -e "${RED}TYPE ONLY THE NUMBER"
echo -e "${PURPLE}Choose one of the following"
echo -e "${NC}1. Automatic    2. Manual"
read action
automation
echo " "
echo -e "${PURPLE}Choose which privelige elavator program to use"
echo -e "${NC}1. Doas  2. Sudo"
read prev_elavator
echo " "
echo -e "${PURPLE}Which AUR helper"
echo -e "${NC}1. Yay   2. Paru"
read aur
echo " "
echo -e "${PURPLE}Choose which wm"
echo -e "${NC}1. dwm   2. spectrwm"
read wm
echo " "
echo -e "${PURPLE}Mounting point for additional drives"
echo -e "${NC}name of the drive e.g sda1"
read drive
echo " "
echo -e "${GREEN}Initiating post installation..."
echo -e "${NC} "
sleep 3
main


