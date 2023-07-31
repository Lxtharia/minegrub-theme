#!/bin/bash

# requires to be run as root, unless the user has access to the theme folder
if [[ `id -u` -ne 0 ]] ; then
	echo "Must be run as root!"
	exit
fi 

# this should be the directory of the clones repo
SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
# I accidentally deleted the above line once and it copied / into the theme folder, so lets prevent this
if [[ -z $SCRIPT_DIR ]] ; then echo "Something didn't work, exiting"; exit; fi

# check if the grub folder is called grub/ or grub2/
if [ -d /boot/grub ]    ; then
	grub_path="/boot/grub"
elif [ -d /boot/grub2 ] ; then
	grub_path="/boot/grub2"
else 
	echo "Can't find a /boot/grub or /boot/grub2 folder. Exiting."
	exit 
fi
theme_path="$grub_path/themes/minegrub"

# Choosing a background, comment this out if it's annoying
echo "First, lets choose a background, press Enter to skip this step."
$SCRIPT_DIR/choose_background.sh

# copy recursive, update, verbose
echo "=> Copying the theme to $theme_path"
cd $SCRIPT_DIR && cp -ruv ./minegrub $grub_path/themes/ | awk '$0 !~ /skipped/ { print "\t"$0 }'

echo -ne "=> Installing systemd service to update splash and package labels on boot\n\t"
cp -uv $SCRIPT_DIR/minegrub-update.service /etc/systemd/system/

echo
echo "== Done! Make sure to add/change this line in /etc/default/grub :"
echo -e "\tGRUB_THEME=$theme_path/theme.txt"

