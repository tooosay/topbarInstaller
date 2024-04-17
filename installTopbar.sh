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

function buildWorkspace() {
	if [ ! -e .git ] || [ ! -e installTopbar.sh ]; then
		mkdir -p ${Workspacename}
		cd ${Workspacename}
	fi
}

function clean() {
	info "cleaning up...."

	if [ -e .git ]; then
		git clean -xdff
	else
		cd ..
		rm -rf ${Workspacename}
	fi

	ok "done" 
}

function buildBar() {
	info "building top bar...."
	test ! -d lemonbar-xft && git clone --depth 1 https://gitlab.com/protesilaos/lemonbar-xft.git
	cd lemonbar-xft
	home_path=$(echo $HOME)
	sed -i "s@PREFIX?=/usr@PREFIX?=$home_path/.local@g" Makefile 
	make && make install
	cd ..
	ok "done"
}
function buildSuccade() {
	info "building helper...."
	test ! -d succade && git clone --depth 1 https://github.com/domsson/succade.git
	cd succade
	./build-inih 
	./install 
	cd ..
	ok "done"
}

function installFont() {
	if [ ! -d "${HOME}/.local/share/fonts" ]; then
	    mkdir -p "${HOME}/.local/share/fonts"
	fi

	if [ -d ${HOME}/.local/share/fonts/InconsolataLGC ]; then
		return 0
	fi

	info "downloading font..."
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/InconsolataLGC.zip
	info "extracting font..."
	unzip InconsolataLGC.zip -d ${HOME}/.local/share/fonts/InconsolataLGC
	info "installing font..."
	fc-cache -fv
}

function downloadHelperFile(){
	test ! -f ${1} && wget https://raw.githubusercontent.com/tooosay/topbarInstaller/master/${1} && chmod u+x ${1}
	cp ${1} ${2}
}

function configureLemonade(){
	info "configuring lemonade ..."
	downloadHelperFile lemonade.sh ${HOME}/.config/succade/
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
	if grep -q "if \[ \$(pgrep succade | wc -l ) -lt \"1\" \]; then" $customBashFile > /dev/null ; then
	    ok "startup is already configured"
	else
		info "configuring starup..."
		cat >> $customBashFile << EOL
if [ \$(pgrep succade | wc -l ) -lt "1" ]; then
	succade &
fi
EOL
fi
     ok "successfully configured startup"
}

function configureSuccade(){
	info "configuring succade"
	downloadHelperFile succaderc ${HOME}/.config/succade/
	ok "succade configured"
}

function main() {
	info "starting installation..."
	buildWorkspace

	### write instruction here
	installFont
	buildBar
	buildSuccade
	configureLemonade
	configureSuccade
	configureStartup
	###
	ok "successfully configured..."
	info "wait for a moment to cleanup the workspace..."
	clean
	ok "success... please reboot your machine :<>"
}

main
