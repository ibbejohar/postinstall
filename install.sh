#!/bin/bash

# color

RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
NC='\033[0m'

function options(){
	clear

	check_root
	packages

	echo -e "${PURPLE}Welcome To Post Installation"
	echo " "
	echo -e "${PURPLE}Choose the distro"
	echo -e "${NC}1. Arch   2. Void"
	read option_distro

	check_distro

	echo " "
	echo -e "${PURPLE}Choose one of the following"
	echo -e "${NC}1. Automatic    2. Manual"
	read option_auto

	auto

	echo " "
	echo -e "${PURPLE}Choose which privelige elavator program to use"
	echo -e "${NC}1. Doas   2. Sudo"
	read option_priv
	echo " "

	prompt_src_helper

	echo -e "${PURPLE}Choose which wm"
	echo -e "${NC}1. Dwm   2. Spectrwm"
	read option_wm
	echo " "
	echo -e "${PURPLE}Mounting point for additional drive i.g sda1${NC}"
	read  option_drive
	echo " "
	echo -e "${GREEN}Initiating Post Installation..."
	echo -e "${NC}"
	sleep 2
	head
	body
	foot
	exit
}

function check_root(){
	if [ "$(whoami)" = "root" ]
	then
		echo -e "${RED}MUST BE A NORMAL USER FOR THE SCRIPT TO RUN"
		echo -e "${NC}"
		sleep 1
		exit
	fi

}

function check_distro(){
	# Arch
	if [ "$option_distro" = "1" ]
	then
		end_credit_distro="Arch"
		pkg_install="pacman -S --noconfirm"
		pkg_remove="pacman -Rns --noconfirm"
		pkg="$arch_pkg $gen_pkg"
		pkg_dep="$arch_dep"
		src_pkg="$aur_pkg"
	# Void
	elif [ "$option_distro" = "2" ]
	then
		end_credit_distro="Void"
		pkg_install="xbps-install -Sy"
		pkg_remove="xbps-remove -R"
		pkg="$void_pkg $gen_pkg"
		pkg_dep="$void_dep"
		src_pkg="$xbps_src_pkg"
	else
		echo  -e "${RED}Choose a distro"
		sleep 1
		exit
	fi

}

function auto(){
	# Automatic
	if [ "$option_auto" = "1" ]
	then
		option_priv="1"
		option_aur_helper="2"
		option_wm="1"
		option_drive="sda1"
		head
		body
		foot
		exit
	fi

}

function prompt_src_helper(){
	# Arch
	if [ "$option_distro" = "1" ]
	then
		echo -e "${PURPLE}Choose which AUR helper"
		echo " "
		echo -e "${NC}1. Yay   2. Paru"
		read option_aur_helper
	# Void
	elif [ "$option_distro" = "2" ]
	then
		echo -e "${PURPLE}xbps-src is not added yet"
		echo -e "${NC}"
	fi

}

function packages(){
		
		gen_pkg="
		alacritty
		aria2
		curl
		exa
		feh
		firefox
		fuse
		git
		mpv
		nemo
		neofetch
		nodejs
		ntfs-3g
		pulseaudio
		pulsemixer
		rofi
		sxiv
		unrar
		unzip
		zathura
		zip
		"
		arch_pkg="
		bitwarden
		"
		arch_dep="
		zathura-pdf-mupdf
		"

		aur_pkg="
		ani-cli
		devour
		ly
		mangodl
		nerd-fonts-complete
		"

		void_repo="
		void-repo-nonfree
		void-repo-multilib
		void-repo-multilib-nonfree
		"
		void_pkg="
		nerd-fonts-ttf
		"

		void_dep="
		zathura-pdf-mupdf
		base-devel
		libX11-devel
		libXft-devel
		libXinerama-devel
		make
		"

	}

function head(){

	function priv(){
		# Doas
		if [ "$option_priv" = "1" ]
		then
			clear
			sudo $pkg_install opendoas
			sudo touch /etc/doas.conf
			echo "permit nopass :wheel" | sudo tee /etc/doas.conf
				# Arch
				if [ "$option_distro" = "1" ]
				then
					doas $pkg_remove sudo
				elif [ "$option_distro" = "2" ]
				then
					sudo touch /etc/xbps.d/ignorefile
					echo "ignorepkg=sudo" | sudo tee /etc/xbps.d/ignorefile
					doas xbps-install -Su
					doas $pkg_remove sudo

					# Adding repo
					sudo $pkg_install $void_repo
					sudo xbps-install -Su
				fi
			doas ln -s /usr/bin/doas /usr/bin/sudo
			end_credit_priv="Doas"
		elif [ "$option_priv" = "2" ]
		then
			clear
		 	# Add pound symbol at the start of line 82
			# adn remove pound symbol at start of line 85
			sudo bash -c "sed -i '82 s/^/#/' /etc/sudoers && sed -i '85 s/^#//' /etc/sudoers"
			end_credit_priv="Sudo"
		fi
	}

	function xdg(){
		sudo $pkg_install xdg-user-dirs
		xdg-user-dirs-update
	}

	function dotfile(){
		cd $HOME
		rm .bashrc
		rm .bash_profile
		git clone https://github.com/ibbejohar/.dotfile.git
		cd .dotfile
		./config.sh
	}

	function hardware_disable(){
		sudo touch /etc/modprobe.d/nobeep.conf
		echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf
	}

	function mounting_point(){
		sudo mkdir -p /media/"$option_drive"

	}

priv
xdg
dotfile
hardware_disable
mounting_point
}

function body(){
	
	
	function src_helper_install(){
		# Yay
		if [ "$option_aur_helper" = "1" ]
		then
			git clone https://aur.archlinux.org/yay.git
			cd yay
			makepkg -si --noconfirm
			cd ..
			rm -rf yay
			src_install="yay -S --noconfirm"
		elif [ "$option_aur_helper" = "2" ]
		then
			git clone https://aur.archlinux.org/paru.git
			cd paru
			makepkg -si --noconfirm
			cd ..
			rm -rf paru
			src_install="paru -S --noconfirm"
		fi

	}

	function install_pkg(){
		sudo $pkg_install $pkg $pkg_dep
		$src_install $src_pkg
	}		
src_helper_install
install_pkg
}

function foot(){

	function install_wm(){
		# Dwm
		if [ "$option_wm" = "1" ]
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
			end_credit_wm="Dwm"
		# Spectrwm
		elif [ "option_wm" = "2"  ]
		then
		sudo $pkg_install spectrwm
		cd $HOME/.config
		git clone https://github.com/ibbejohar/spectrwm.git
		cd $HOME
		end_credit_wm="Spectrwm"
		else 
		end_credit_wm="Did not choose WM"
		fi
	}

	function clean_up(){
		# Doas
		if [ "$option_priv" = "1" ]
		then
			echo "permit persist :wheel" | sudo tee /etc/doas.conf
		elif [ "$option_priv" = "2" ]
		then
			# Add pound symbol at the start of line 85
			# and remove pound symbol at the start of line 82
			sudo bash -c "sed -i '85 s/^/#/' /etc/sudoers && sed -i '82 s/^#//' /etc/sudoers"
		fi
	}

	function end_credit(){
		clear
		echo -e "${PURPLE}---------- $end_credit_distro ----------"
		echo " "
		echo -e "${PURPLE}---------- Privelige Elavator ----------"
		echo " "
		echo -e "${NC}$end_credit_priv"
		echo " "
		echo -e "${PURPLE}---------- Packages ----------"
		echo " "
		echo -e "${NC}$pkg"
		echo " "
		echo -e "${PURPLE}---------- Dependicies ----------"
		echo " "
		echo -e "${NC}$pkg_dep"
		echo " "
		echo -e "${PURPLE}---------- Window Manager ----------"
		echo " "
		echo -e "${NC}$end_credit_wm"
		echo " "
		echo -e "${PURPLE}---------- Mounting Point ----------"
		echo " "
		echo -e "${NC}$option_drive"
		echo " "
		echo -e "${PURPLE}--------------------------"
		echo -e "${NC}"
		sleep 1
	}

install_wm
clean_up
end_credit
}


options

