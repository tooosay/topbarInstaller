#!/bin/bash
set -aeo pipefail

RED="\e[31m"
GREEN="\e[32m"
ORANGE="\e[33m"
ENDCOLOR="\e[0m"
## log functions ##
function info(){
	echo -e "[${ORANGE}INFO${ENDCOLOR}] ${ORANGE}$1${ENDCOLOR}"
}
function err(){
	echo -e "[${RED}ERROR${ENDCOLOR}] ${RED}$1${ENDCOLOR}"
}
function ok(){
	echo -e "[${GREEN}OK${ENDCOLOR}] ${GREEN}$1${ENDCOLOR}"
}
###################

Workspacename="topbarInstallWorkspaceAndThisShouldBeRemovedAfterInstallation"
lemonadeFile="/home/$USER/.local/bin/lemonade.sh"
customBashFile="/home/$USER/.bashrc.custom"
sucConfigDir="/home/$USER/.config/succade"
sucFile="$sucConfigDir/succaderc"
function buildWorkspace(){
	if [ ! -d $Workspacename ]; then
		mkdir $Workspacename
	fi
	cd $Workspacename
}
function clean(){
	info "cleaning up...."
	if [ ! -d $Workspacename ]; then
                cd ..
		clean
    fi

	rm -rf $Workspacename
	ok "done" 
}

function buildbins(){
	info "building executables..."
	buildBar
	buildSuccade
}
function buildBar(){
	info "building top bar...."
	git clone --depth 1 https://gitlab.com/protesilaos/lemonbar-xft.git xft
	cd xft
	make target PREFIX="$HOME/.local" && make install
	cd ..
	ok "done"
}
function buildSuccade(){
	info "building helper...."
	git clone --depth 1 https://github.com/domsson/succade.git sca
	cd sca
	./build-inih 
	./install 
	cd ..
	ok "done"
}

function installFont(){
	if [ ! -d "$HOME/.local/share/fonts" ]; then
	    mkdir "$HOME/.local/share/fonts"
	fi
	info "downloading font..."
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/InconsolataLGC.zip
	info "extracting font..."
	unzip InconsolataLGC.zip -d $HOME/.local/share/fonts/InconsolataLGC
	info "instlling font..."
	fc-cache -fv
}

function configureLemonade(){
	info "configuring Lemonade ..."
	if [ ! -f $lemonadeFile ]; then
	    info "no config file so creating file"
		touch $lemonadeFile
		ok "file created" 
	fi
		info "overwriting config file ..."
        cat > $lemonadeFile << EOL
#!/usr/bin/bash

Clock(){
	TIME=$(date "+%H:%M:%S")
	echo -e -n " \uf017 ${TIME}" 
}

Cal() {
    DATE=$(date "+%a, %m %B %Y")
    echo -e -n "\uf073 ${DATE}"
ndowname | cut -c 1-$max_len)..."
	else
		echo -n "$(xdotool getwindowfocus getwindowname)"
	fi
}

Battery() {
	BATTACPI=$(acpi --battery)
	BATPERC=$(echo $BATTACPI | cut -d, -f2 | tr -d '[:space:]')

	if [[ $BATTACPI == *"100%"* ]]
	then
		echo -e -n "\uf0e7 $BATPERC"
	elif [[ $BATTACPI == *"Discharging"* ]]
	then
		BATPERC=${BATPERC::-1}
		if [ $BATPERC -le "10" ]
		then
			echo -e -n "\uf244"
		elif [ $BATPERC -le "25" ]
		then
			echo -e -n "\uf243"
		elif [ $BATPERC -le "50" ]
		then
			echo -e -n "\uf242"
		elif [ $BATPERC -le "75" ]
		then
			echo -e -n "\uf241"
		elif [ $BATPERC -le "100" ]
		then
			echo -e -n "\uf240"
		fi
		echo -e " $BATPERC%"
	elif [[ $BATTACPI == *"Charging"* && $BATTACPI != *"100%"* ]]
	then
		echo -e "\uf0e7 $BATPERC"
	elif [[ $BATTACPI == *"Unknown"* ]]
	then
		echo -e "$BATPERC"
	fi
}

# Wifi(){
# 	WIFISTR=$( iwconfig wlp1s0 | grep "Link" | sed 's/ //g' | sed 's/LinkQuality=//g' | sed 's/\/.*//g')
# 	if [ ! -z $WIFISTR ] ; then
# 		WIFISTR=$(( ${WIFISTR} * 100 / 70))
# 		ESSID=$(iwconfig wlp1s0 | grep ESSID | sed 's/ //g' | sed 's/.*://' | cut -d "\"" -f 2)
# 		if [ $WIFISTR -ge 1 ] ; then
# 			echo -e "\uf1eb ${ESSID} ${WIFISTR}%"
# 		fi
# 	fi
# }

Sound(){
	NOTMUTED=$( amixer sget Master | grep "\[on\]" )
	if [[ ! -z $NOTMUTED ]] ; then
		VOL=$(amixer get Master | grep -oP '\d+%' | head -n 1 | tr -d '%')
		if [ -z "$VOL" ]; then
		     VOL=0
		fi
			if [ $VOL -ge 85 ] ; then
				echo -e "\uf028 ${VOL}%"
			elif [ $VOL -ge 50 ] ; then
				echo -e "\uf027 ${VOL}%"
			else
				echo -e "\uf026 ${VOL}%"
			fi
	else
		echo -e "\ueb24 Muted"
	fi
}

Language(){
	CURRENTLANG=$(head -n 1 /tmp/uim-state)
	if [[ $CURRENTLANG == *"English"* ]] ; then
		echo -e " \uf0ac ENG"
	elif [[ $CURRENTLANG == *"Katakana"* ]] ; then
		echo -e " \uf0ac カタカナ"
	elif [[ $CURRENTLANG == *"Hiragana"* ]] ; then
		echo -e " \uf0ac ひらがな"
	else
		echo -e " \uf0ac \uf128"
	fi
}

Spotify(){
	echo -e -n "\uf1bc"
}

Slack(){
	echo -e -n "\uf198"
}
# Check if a function name is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <function_name>"
    exit 1
fi

# Call the specified function
"$@"

EOL
ok "lemonade configured"
}

function configureStartup(){
	info "configuring startup"
	if [ ! -f $customBashFile ]; then
	    info "${customBashFile} not found so creating...."
		touch $customBashFile
		ok "file created"
	fi
	info "checking previous configuration.."
	if [ $(grep -q "if \[ \$(pgrep succade | wc -l ) -lt \"1\" \]; then" $customBashFile) ]; then
	info "configuring starup..."
	cat >> $customBashFile << EOL
	if [ $(pgrep succade | wc -l ) -lt "1" ]; then
	 succade &
    fi
EOL
else
     ok "startup is already configured"
fi
     ok "successfully configured startup"
}

function configureSuccade(){
	info "configuring succade"
	if [ ! -f $sucFile ]; then
	   info "no conifg file found so creating...."
	   mkdir $sucConfigDir
		touch $sucFile
	fi
	info "overwriting config file ... "
	cat > $sucFile << EOL
[bar]
name = "toppbar"
blocks = " | time | sound battery"
height = 24
underline = true
font = "Inconsolata LGC Nerd Font Mono"
label-font = "-wuncon-siji-medium-r-normal--10-100-75-75-c-80-iso10646-1"

[default]
margin = 4
padding = 2
foreground = "#c6d0f5"
; background = "#303446"
; label-foreground = "#838ba7"

[date]
command = "date +'%Y-%m-%d'"
interval = 1
; label = "  "
; label-background = "#a6d189"

[time]
command = "date +'%Y-%m-%d  %H:%M:%S'"
interval = 1
; label = "  "
; label-background = "#ca9ee6"
mouse-left = "xdg-open https://calendar.google.com"
mouse-right = "xdg-open https://liferay.atlassian.net/jira/your-work"
mouse-middle = "slack"
margin-right = 8

[battery]
command = "lemonbar.sh Battery"
interval = 3
; label = "  "
; label-background = "#ef9f76"
margin-right = 8

[spotify]
command = 'lemonbar.sh Spotify'
mouse-left = "xdg-open https://spotify.com"

[sound]
command = "lemonbar.sh Sound"
interval = 0.1
mouse-left = "amixer -D default set Master toggle"
mouse-right = "pavucontrol"
scroll-up = "amixer -D default sset Master 5%+"
scroll-down = "amixer -D default sset Master 5%-"
EOL
ok "succade configured"
}

function main(){
	info "starting installation..."
	buildWorkspace
	### write instruction here
	installFont
	buildbins
	configureLemonade
	configureSuccade
	configureStartup
	###
	ok "successfully configured..."
	info "wait for a moment to cleanup the workspace..."
	clean
	ok "sucess... please reboot your machine :<>"
}

main
