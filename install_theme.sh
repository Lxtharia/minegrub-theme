#!/bin/bash

# requires to be run as root, unless the user has access to the theme folder
if [[ `id -u` -ne 0 ]] ; then
	echo "Must be run as root!"
	exit
fi 

# get the path of the cloned repository 
SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
# I accidentally deleted the above line once and it copied / into the theme folder, so lets prevent this
if [[ -z $SCRIPT_DIR ]] ; then echo "Something didn't work, so to not copy the entirety of root to your efi partition, this script is gonna exit"; exit; fi

# check if the grub folder is called grub/ or grub2/
if [ -d /boot/grub ]    ; then
	grub_path="/boot/grub"
elif [ -d /boot/grub2 ] ; then
	grub_path="/boot/grub2"
else 
	echo "Can't find a /boot/grub or /boot/grub2 folder. Exiting."
	exit 
fi


theme_path="$grub_path/themes/minegrub-theme"
# Create theme folder if it does not exist yet
mkdir -p $theme_path


echo "=> Copying the theme to $theme_path"
# copy recursive, update, verbose
cp -ruv $SCRIPT_DIR/* $theme_path | awk '$0 !~ /skipped/ { print "\t"$0 }'

echo -ne "=> Installing splash and package label update service\n\t"
cp -uv $SCRIPT_DIR/assets/minegrub-update.service /etc/systemd/system/

echo "== Done! Make sure to add/change this line in /etc/default/grub /!\\"
echo -e "\tGRUB_THEME=$grub_path/themes/minegrub-theme/theme.txt"

