#!/bin/bash

#Ensures lagdrop.sh is running.
#Add this script to the end of your router startup

ARGUMENT="$1" #Enter your identifier here

SCRIPTNAME=$(echo "${0##*/}")
kill -9 "$(ps -w | grep -F "$SCRIPTNAME" | grep -v $$)" &> /dev/null
DIR=$(echo "$0"|sed -E "s/\/"$SCRIPTNAME"//g")

whereargyou ()
{
if [ "${ARGUMENT}" = "$(echo -n "{ARGUMENT}"|grep -oEiF "")" ]; then

	echo "Where arg you?"
	whereargyou
else

	while : ; do if ! { ps|grep -qF  ""$DIR"/lagdrop.sh "${ARGUMENT}""; } ; then :; else eval ""$DIR"/lagdrop.sh "${ARGUMENT}" &> /dev/null"; fi; done &> /dev/null &
fi
}

while :; do
whereargyou
done

#LagDrop.com|42Kmi.com