#!/bin/bash

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd "$SCRIPT_DIR/background_options/" || exit 1

# El autor original odia los vectores de bash y los bucles for con ls
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
declare -a backgrounds
for f in `ls -v *.png` ; do 
	backgrounds+=("$f")
done
IFS=$SAVEIFS

echo "¡Escoge el fondo de pantalla que te gustaría poner!":

ind=0
for f in "${backgrounds[@]}"; do 
	echo "[$ind]: $f"
	ind=`expr $ind + 1`
done;

echo -n '>> ' 
read chosen_ind


if ! [[ "$chosen_ind" =~ ^[0-9]+$ ]] ; then 
	echo "Sin cambios en el fondo de pantalla"
	exit 1
fi

chosen_backgound=${backgrounds[$chosen_ind]}
echo "Opción elegida $chosen_ind:  $chosen_backgound"

if [[ "$chosen_backgound" == "" ]]; then
	echo Sin cambios en el fondo de pantalla.
else
	cp "$chosen_backgound" "$SCRIPT_DIR/minegrub/background.png"
fi
