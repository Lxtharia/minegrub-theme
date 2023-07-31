#!/bin/bash 

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPT_DIR/backgrounds

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
	exit
fi 

chosen_backgound=${backgrounds[$chosen_ind]}
echo "Chose option $chosen_ind:  $chosen_backgound"

if [[ "$chosen_backgound" == "" ]]; then
	echo Not changing background.
else 
	cp "$chosen_backgound" $SCRIPT_DIR/minegrub/background.png
fi 
