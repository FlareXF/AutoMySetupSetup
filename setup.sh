#!/bin/bash
help(){
	echo -e "Usage: setup [OPTIONS]
Install and configures programmes i need for work

OPTIONS:


Posix:		GNU:
	-h,	--help
			displays this text and exit
	-s,	--small
			sets small amount of programmes
	-m,	--medium
			sets medium amount of programmes
	-l,	--large
			sets large amount of programmes

	"
}

hell(){
	echo -e "Usage: setup [OPTIONS]
Try 'setup -h' or 'setup --help' for getting more information"
}

small_install(){
	echo "da"
	if [ `lsb_release -d | awk '{print $2}'` = "Debian" ];then
		
		if [ `lsb_release -r | awk '{print $2}'` = "11" ]; then
			rm /etc/apt/sources.list
			echo "# See https://wiki.debian.org/SourcesList for more information.
deb http://deb.debian.org/debian bullseye main contrib non-free
deb-src http://deb.debian.org/debian bullseye main contrib non-free

deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb-src http://deb.debian.org/debian bullseye-updates main contrib non-free

deb http://security.debian.org/debian-security/ bullseye-security main contrib non-free
deb-src http://security.debian.org/debian-security/ bullseye-security main contrib non-free

deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb-src http://deb.debian.org/debian bullseye-backports main contrib non-free" > /etc/apt/sources.list
		fi
		if [ `lsb_release -r | awk '{print $2}'` = "10" ]; then
			rm /etc/apt/sources.list
			echo "###### Debian Main Repos
deb http://deb.debian.org/debian/ buster main contrib non-free
deb-src http://deb.debian.org/debian/ buster main contrib non-free

deb http://deb.debian.org/debian/ buster-updates main contrib non-free
deb-src http://deb.debian.org/debian/ buster-updates main contrib non-free

deb http://deb.debian.org/debian-security buster/updates main contrib non-free
deb-src http://deb.debian.org/debian-security buster/updates main contrib non-free

deb http://ftp.debian.org/debian buster-backports main contrib non-free
deb-src http://ftp.debian.org/debian buster-backports main contrib non-free" > /etc/apt/sources.list
		fi
	else
		echo "Your distribution is not Debian!"
	fi
	apt-get update
	apt-get -y install vim ranger neovim bash-completion 
	cd /usr/share/vim/vim8*
	sudo -u $MAINUSER sh -c "cp defaults.vim ~/.vimrc"
	apt-get purge -y vim
	sudo -u $MAINUSER sh -c "echo '
alias q='exit'
alias r='ranger'
alias v='vim'
set -o vi' >> ~/.bashrc"
	mv /root/.bashrc /root/.bashrc.bak
	cp "`eval echo ~$MAINUSER`/.bashrc" /root/.bashrc 
	echo 'PATH="$PATH:/usr/bin:/usr/sbin"' >> ~/.bashrc

}

medium_install(){
	echo "da"
	small_intsall 
	apt-get install -y wget curl git build-essential python3-pip cmake python3-dev nodejs npm
	sudo -u $MAINUSER sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	sudo -u $MAINUSER sh -c "echo \"
call plug#begin('~/.vim/plugged')
Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }
Plug 'ycm-core/YouCompleteMe'
Plug 'jiangmiao/auto-pairs'
call plug#end()

let g:ycm_global_ycm_extra_conf = '~/.vim/plugged/YouCompleteMe/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_key_list_select_completion = [ '<Enter>' ]
let g:ycm_key_list_stop_completion = [ '<Tab>' ]
let g:ycm_add_preview_to_completeopt = 0


set tabstop=4
set shiftwidth=4
set clipboard+=unnamedplus\" >> ~/.vimrc"
	sudo -u $MAINUSER sh -c "mkdir ~/.config/nvim ~/.vim ~/.vim/plugged ~/.config/ranger"
	sudo -u $MAINUSER sh -c "echo '
set runtimepath+=~/.vim,~/.vim/after
set packpath+=~/.vim
source ~/.vimrc' > ~/.config/nvim/init.vim"
	sudo -u $MAINUSER sh -c 'echo "Now, please press ":" key and type PlugInstall, then wait about 1-2 minutes. After everything is installed, press <ESC>, to enter normal mod, and press <ZQ> to exit Vim" | nvim'
	cd "`eval echo ~$MAINUSER`/.vim/plugged/YouCompleteMe"
	python3 install.py --clang-completer --ts-completer
	sudo -u $MAINUSER sh -c 'echo "
set preview_images true
set preview_images_method w3m" > ~/.config/ranger/rc.conf'
}


large_install(){
	echo "da"
	medium_install
	apt-get install gparted audacious simple-scan orcfreeder qalcualte thunderbird syncthing mupdf gimp handbrake vlc freecad kicad krita telegram-desktop

}

if [ $EUID = 0 ]; then
	MAINUSER="`who am i | awk '{print $1}'`"
	if [ $# -ne 0 ]; then
		echo "$#"
		echo "$@"

		for i in "$@"; do 
			case $i in
				-h|--help|-help) help ;;
				-s|--small|-small) small_install ;;
				-m|--medium|-medium) medium_install ;;
				-l|--large|-large) large_install ;;
				*) hell ;;
			esac
		done
	else
		hell
		exit
	fi
	
else
	echo "This program is designed to run as root. Please run script as root."
	exit 1 
fi

