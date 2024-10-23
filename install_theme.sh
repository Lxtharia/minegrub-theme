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

## Prompts

# Choosing a background, comment this out if it's annoying
read -p "[?] Do you want to choose a specific background? [y/N] " -en 1 choose_bg 
if [[ "$choose_bg" =~ y|Y ]]; then
    echo "[INFO] Choosing a background from ./background_options/"
    $SCRIPT_DIR/choose_background.sh
else
    echo "[INFO] [Skipping] Choosing a background"
fi

echo
read -p "[?] Copy/Update the theme to '$theme_path'? [Y/n] " -en 1 copy_theme
if [[ "$copy_theme" =~ y|Y || -z "$copy_theme" ]]; then
    echo "[INFO] => Copying the theme files to boot partition:"
    # copy recursive, update, verbose
    cd $SCRIPT_DIR && cp -ruv ./minegrub $grub_path/themes/ | awk '$0 !~ /skipped/ { print "\t"$0 }'
else
    echo "[INFO] [Skipping] Copying the theme files to boot partition"
fi


echo 
read -p "[?] Do you want to install a systemd service to automatically update the splash texts and backgrounds after every boot? [y/N] " -en 1 skip_service_installation
if [[ "$skip_service_installation" =~ y|Y ]]; then
    echo -ne "[INFO] Installing systemd service to update splash and package labels on boot\n\t"
    cp -uv $SCRIPT_DIR/minegrub-update.service /etc/systemd/system/
else
    echo "[INFO] [Skipping] Systemd service installation"
fi


echo
read -p "[?] Do you want a grub drop-in-config file to be edited so setting GRUB_BACKGROUND will set a background for the grub console? [y/N] " -en 1 skip_patch
if [[ "$skip_patch" =~ y|Y ]]; then
    echo "[INFO] Editing /etc/grub.d/00_header"
    # Backing up that file, just in case
    cp --no-clobber /etc/grub.d/00_header ./00_header.bak
    # sed'ing that one line
    sed --in-place -E 's/(.*)elif(.*"x\$GRUB_BACKGROUND" != x ] && [ -f "\$GRUB_BACKGROUND" ].*)/\1fi; if\2/' /etc/grub.d/00_header
else
    echo "[INFO] [Skipping] Editing grub drop-in-config file"
fi


echo
echo "======= Done! ======="
echo "[YEAH] Make sure to add/change this line in /etc/default/grub :"
echo
echo -e "    GRUB_THEME=$theme_path/theme.txt"
echo
echo "[YEAH] And optionally this line. This won't have any effect unless you have applied the patch"
echo
echo -e "    GRUB_BACKGROUND=$theme_path/dirt.png"
echo

