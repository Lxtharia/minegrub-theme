#!/bin/bash

### BEGIN INIT INFO
# Provides:          minecraft-grub
# Required-Start:
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Minecraft-Grub theme updater..
#
### END INIT INFO

set -e

PATH="/usr/bin:/bin:/sbin"
NAME="minecraft-grub"
DESC="Update the minecraft-grub theme."

if [[ -d "/boot/grub2" ]] ; then
	THEME_DIR="/boot/grub2/themes/minegrub"
else
	THEME_DIR="/boot/grub/themes/minegrub"
fi

case "${1}" in
	"start"|"restart"|"reload"|"force-reload")
		if command -v "python3" &> /dev/null ; then
			python3 "${THEME_DIR}/update_theme.py" && exit 0 || exit 1
		fi
	;;
	"stop")
		echo "${0##*/}: done: nothing to do."
		exit 0
	;;
	*)
		echo "Usage: ${0##*/} start"
		exit 3
	;;
esac
