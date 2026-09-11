#!/bin/bash

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd "$SCRIPT_DIR/background_options/" || exit 1

# I hate bash arrays and for loops with ls
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
declare -a backgrounds
for f in `ls -v *.png` ; do 
	backgrounds+=("$f")
done
IFS=$SAVEIFS

echo "Choose which background you'd like!":

ind=0
for f in "${backgrounds[@]}"; do 
	echo "[$ind]: $f"
	ind=`expr $ind + 1`
done;

echo -n '>> ' 
read chosen_ind


if ! [[ "$chosen_ind" =~ ^[0-9]+$ ]] ; then 
	echo "Not changing background" 
	exit 1
fi

chosen_backgound=${backgrounds[$chosen_ind]}
echo "Chose option $chosen_ind:  $chosen_backgound"

if [[ "$chosen_backgound" == "" ]]; then
	echo Not changing background.
else
	cp "$chosen_backgound" "$SCRIPT_DIR/minegrub/background.png"
	# button style update - both resources and theme.txt
	style=classic
	text_color="#ffffa0"
	shadow_color="#3f3f28"
	if [[ "$chosen_backgound" =~ ^([0-9]+)\.([0-9]+) ]]; then
		major="${BASH_REMATCH[1]}"
		minor="${BASH_REMATCH[2]}"
		if (( 10#$major > 1 || (10#$major == 1 && 10#$minor >= 15) )); then
			style=modern
			text_color="#ffffff"
			shadow_color="#383838"
		fi
	fi
	cp "$SCRIPT_DIR/button_options/$style"/selected_item_*.png "$SCRIPT_DIR/minegrub/"
	sed -i \
		-e "/item_color = \"#ffffff\"/{n;s/selected_item_color = .*/selected_item_color = \"$text_color\"/;}" \
		-e "/item_color = \"#383838\"/{n;s/selected_item_color = .*/selected_item_color = \"$shadow_color\"/;}" \
		"$SCRIPT_DIR/minegrub/theme.txt"
fi
