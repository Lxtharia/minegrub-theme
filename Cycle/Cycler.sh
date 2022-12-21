#!/bin/bash
# Set working directory to script's location
cd "${0%/*}"
count=0

# Linus' Birthday logic
# If birthday file is present, check the date, and use it as the logo if it's Linus's birthday. End the script early.
if [[ -f "birthday.png" ]]; then
	if [[ $(date +%d%m) -eq 2812 ]]; then
		echo Happy Birthday Linus! Placing birthday logo in location.
		mv ../logo.png ./logo.png
		mv ./birthday.png ../logo.png
		exit
	fi
else
# If file isn't present, check it isn't still Linus' birthday. If it isn't, put the files back as they're meant to be and continue the script as normal.
	if [[ $(date +%d%m) -ne 2812 ]]; then
		echo Party time is over, restoring old logo.
		mv ../logo.png ./birthday.png
		mv ./logo.png ../logo.png
	else
		exit
	fi
fi


#Logo cycling
# Iterate through files and decrease their filename by 1. Also track how many total logos are available.
for f in *.png; do
	echo Renaming $f to $(printf %02d $((10#${f%.*}-1)))
	mv $f $(printf %02d $((10#${f%.*}-1))).png
	count=$((++count))
done

# Remove logo from main folder and rename it to sit at bottom of the rotation, put the lowest value image back in its place.
echo Swapping logo with $(printf %02d $(($count)))
mv ../logo.png $(printf %02d $(($count))).png
mv ./00.png ../logo.png
