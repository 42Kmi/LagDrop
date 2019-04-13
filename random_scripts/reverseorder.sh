#!/bin/sh
#42Kmi
#Reverse order of input text.

if [ "$1" = "" ]; then
	read -p "Type something: " userenter
else
	userenter="$1"
fi

IP=$(echo "$userenter")

echo $(echo -n "$(echo -n "$IP"|sed -E "s/\s/###SPACE_ECAPS###/g"|grep -Eo ".")"|grep -En "."|sort -nr|sed -E "s/^[0-9]{1,}\://g")|sed -E "s/\s//g"|sed -E "s/###SPACE_ECAPS###/ /g"

