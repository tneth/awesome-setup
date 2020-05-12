#!/bin/bash
#################################################
#
#		0.	Meta
#
#################################################
#
#		Script for reinstalling debian configs
#		Definitely not perfect, but should help
#
#		Requires:
#			-	Run as primary user
#			-	Primary user has sudo
#					-	su root
#					-	apt install sudo -y
#					-	usermod -aG sudo <primary user>
#
dudw4r3z_splash=$(cat <<-END
▓█████▄  █    ██ ▓█████▄  █     █░ ▄▄▄       ██▀███  ▓█████ ▒███████▒
▒██▀ ██▌ ██  ▓██▒▒██▀ ██▌▓█░ █ ░█░▒████▄    ▓██ ▒ ██▒▓█   ▀ ▒ ▒ ▒ ▄▀░
░██   █▌▓██  ▒██░░██   █▌▒█░ █ ░█ ▒██  ▀█▄  ▓██ ░▄█ ▒▒███   ░ ▒ ▄▀▒░
░▓█▄   ▌▓▓█  ░██░░▓█▄   ▌░█░ █ ░█ ░██▄▄▄▄██ ▒██▀▀█▄  ▒▓█  ▄   ▄▀▒   ░
░▒████▓ ▒▒█████▓ ░▒████▓ ░░██▒██▓  ▓█   ▓██▒░██▓ ▒██▒░▒████▒▒███████▒
 ▒▒▓  ▒ ░▒▓▒ ▒ ▒  ▒▒▓  ▒ ░ ▓░▒ ▒   ▒▒   ▓▒█░░ ▒▓ ░▒▓░░░ ▒░ ░░▒▒ ▓░▒░▒
  ░ ▒  ▒ ░░▒░ ░ ░  ░ ▒  ▒   ▒ ░ ░    ▒   ▒▒ ░  ░▒ ░ ▒░ ░ ░  ░░░▒ ▒ ░ ▒
   ░ ░  ░  ░░░ ░ ░  ░ ░  ░   ░   ░    ░   ▒     ░░   ░    ░   ░ ░ ░ ░ ░
	       ░       ░        ░        ░          ░  ░   ░        ░  ░  ░ ░
END
)

echo "$dudw4r3z_splash"
echo -e "Fresh-debian setup script\n"


#################################################
#
#		1.	Check user rights
#
#################################################
groups="$(groups $USER)"
if [[ ! $groups =~ .*sudo.* ]]
then
	echo "ERROR: User $USER does not have sudo rights. To fix, run:"
	echo -e "  su root\n  apt install sudo -y\n  usermod -aG sudo $USER"
	exit
fi


#################################################
#
#		2.	Get machine type
#
#################################################
echo "Select computer:"
options=("X220 Thinkpad" "Dual-monitor PC" "Bedtop Toshiba")
select opt in "${options[@]}"
do
	case $opt in
	"X220 Thinkpad" )
		choice=0
		break
		;;
	"Dual-monitor PC" )
		choice=1
		sudo cp data/misc/sources.list.debian_testing /etc/apt/sources.list
		break
		;;
	"Bedtop Toshiba" )
		choice=2
		sudo cp data/misc/sources.list.debian_testing /etc/apt/sources.list
		break
		;;
	esac
done


#################################################
#
#		2.	APT installations
#
#################################################
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get upgrade -y
sudo apt-get autoremove -y
#		2.2		debian required
sudo apt-get install -y --ignore-missing build-essential gcc
#		2.3		basics
sudo apt-get install -y --ignore-missing git vim zip unzip p7zip-full p7zip-rar tmux imagemagick xorg x-window-system xinit compton nautilus
#		2.4		network
sudo apt-get install -y --ignore-missing pulseaudio keepassxc firefox-esr youtube-dl ncat nmap net-tools rsync
#		2.5		sensors
sudo apt-get install -y --ignore-missing htop arandr lm-sensors pavucontrol locate
#		2.6		other
sudo apt-get install -y --ignore-missing kpcli cmatrix mupdf feh eog gimp
#		2.7		media
sudo apt-get install -y --ignore-missing mpv vlc obs-studio

#		2.1		dudw4r3z /tmp data
mkdir -p ~/.dudw4r3z/tmp
mkdir -p ~/.dudw4r3z/media
mkdir -p ~/.dudw4r3z/tmp/data
rsync -r data ~/.dudw4r3z/tmp/
cd ~/.dudw4r3z/tmp

# xorg permissions for non-root user to use startx
## see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=802769#26
sudo cp data/misc/Xwrapper.config /etc/X11
sudo chmod 644 /etc/X11/Xrwapper.config
sudo chown root:root /etc/X11/Xwrapper.config

#
#		2.2		awesome
#
## lua-sec required for grabbing https urls
sudo apt-get install -y --ignore-missing awesome lua-sec

mkdir ~/.config
rsync -r data/awesome ~/.config/
# ps1 startup noise
cp ~/.dudw4r3z/tmp/data/media/ps1.mp3 ~/.dudw4r3z/media/ps1.mp3 
case $choice in
		0)
			cp ~/.config/awesome/themes/rc.lua.dudw4r3z-poké ~/.config/awesome/rc.lua 
			;;
		1)
			cp ~/.config/awesome/themes/rc.lua.dudw4r3z-2mon-eva-fotns ~/.config/awesome/rc.lua 
			;;
		2)
			cp ~/.config/awesome/themes/rc.lua.dudw4r3z-bedtop-green ~/.config/awesome/rc.lua 
			;;
		*)
esac


#################################################
#
#		3.	rc
#
#################################################
##	vim
cp -f data/misc/vimrc ~/.vimrc

##	terminator
sudo apt-get install -y --ignore-missing terminator python-keybinder python-vte
mkdir ~/.config/terminator
cp -f data/misc/terminator_config ~/.config/terminator/config

##	xinitrc
cp -f data/misc/xinitrc ~/.xinitrc
case $choice in
		1)
			sudo apt-get install -y --ignore-missing nvidia-driver
			sudo cp data/misc/xorg.conf /etc/X11/
			;;
		*)
esac

##	tmux
cp -f data/misc/tmux.conf ~/.tmux.conf
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

##	bash
cp -f data/misc/bashrc ~/.bashrc


#################################################
#
#		4.	Misc
#
#################################################
# 	4.1		update-motd.d (missingo ASCII-esque art)
sudo rm -Rf /etc/update-motd.d
case $choice in
		0)
			sudo mv data/motds/poke2gen/update-motd.d /etc
			;;
		1)
			sudo mv data/motds/kabu-skele/update-motd.d /etc
			;;
		2)
			sudo mv data/motds/toriel/update-motd.d /etc
			;;
		*)
esac
sudo chown root:root -R /etc/update-motd.d
sudo chmod 755 -R /etc/update-motd.d

# 	4.2		default dirs	(not ~/Desktop, ~/Documents, etc)
cp -f data/misc/user-dirs.dirs ~/.config/user-dirs.dirs

#		4.3		fonts
sudo mkdir /usr/share/fonts/manual
sudo cp -f data/fonts/* /usr/share/fonts/manual
sudo chown root:root /usr/share/fonts/manual/*

#		4.4		cool screenlock
sudo apt-get install -y --ignore-missing i3lock scrot imagemagick xautolock
cp -f ~/.dudw4r3z/tmp/data/media/lock.png ~/.dudw4r3z/media/lock.png
sudo mv ~/.dudw4r3z/tmp/data/misc/lock /bin
sudo chmod 755 /bin/lock
sudo chown root:root /bin/lock

#		4.5		host based adblocking
curl http://winhelp2002.mvps.org/hosts.txt >> /tmp/hosts
sudo mv /tmp/hosts /etc/hosts


#################################################
#
#		5.	Blab
#
#################################################
## sick greetz (improve this to look fancier)
echo "WHAT YOU NEED TO DO!"
echo "1: run tmux, ctrl+A, shift+I, in order to install continuum and res"
echo "sudo reboot 0"
echo "log in, run: startx"
