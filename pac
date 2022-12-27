#!/bin/bash

_ScriptVersion="1.0.0"
_fzf_flags="--ansi --multi --bind=space:toggle-preview --preview "

function install() {
	# search for, selecct and install official packages
	programs=$(pacman --color always -Sl | fzf ${_fzf_flags} "pacman -Si {2}" | cut -f 2 -d " " | tr '\n' ' ' | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
	echo -e "selected: \n${programs}"

	if [ -n "$programs" ]; then
		sudo pacman --needed -S $programs
	fi
}

function uninstall() {
	# select and uninstall packages
	programs=$(pacman --color always -Q | cut -f 1 -d ' ' | fzf ${_fzf_flags} 'pacman -Qi {1}')
	echo -e "selected: \n${programs}"

	if [ -n "$programs" ]; then
		sudo pacman -Rns $programs
	fi

}

function info() {
	# search for an installed package and display its info
	program=$(pacman -Qq | fzf ${_fzf_flags} "pacman -Qi {}")

	if [ -n "$program" ]; then
		pacman -Qi "$program"
	fi
}

function usage() {
	echo "Usage :  $0 [options] [--]

    Options:
    -h|help       Display this message
    -v|version    Display script version"

}

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
while getopts ":hvsrq" opt; do
	case $opt in

	h | help)
		usage
		exit 0
		;;

	v | version)
		echo "$0 -- Version $_ScriptVersion"
		exit 0
		;;

	s | install) # uses repo sync and search like pacman -S
		install
		exit 0
		;;

	r | uninstall) # uses removal like pacman -R
		uninstall
		exit 0
		;;

	q | info) # uses local database query like pacman -Q
		info
		exit 0
		;;

	*)
		echo -e "\n  Option does not exist : $OPTARG\n"
		usage
		exit 1
		;;

	esac # --- end of case ---
done
shift $(($OPTIND - 1))
