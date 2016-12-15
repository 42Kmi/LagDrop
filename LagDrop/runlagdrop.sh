#!/bin/sh
#Version 2.0.6
SUFFIX=$1 ###change this to match the ending of the lagdrop file you want to run
SCRIPTNAME=$(echo "${0##*/}")
DIR=$(echo $0 | sed -E "s/\/$SCRIPTNAME//g")
SETTINGS=$(tail +1 "$DIR"/42Kmi/options_"$SUFFIX".txt|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E 's/^.*=//g') #Settings stored here, called from memory
if "$DIR"/lagdrop_"$SUFFIX".sh; then :; else
SWITCH=$(echo "$SETTINGS"|tail -1) ### Enable (1)/Disable(0) LagDrop
if [ "${SWITCH}" = 0 ] || [ "${SWITCH}" = OFF ] || [ "${SWITCH}" = off ]; then : && $(`ps -w | grep -E "lagdrop_$SUFFIX" | grep -vF "ps" |sed -E "s/root.*//g"| grep -oE "[0-9]{1,}"|sed -E "s/^/kill -9 /g"`) && $(`ps -w | grep -E "lagdrop_$SUFFIX" | grep -vF "ps" |sed -E "s/root.*//g"| grep -oE "[0-9]{1,}"|sed -E "s/^/killall -9 /g"`);
else
{
##### Run LagDrop On Startup #####
{
##########
LOCKFILE=/tmp/lock.txt
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit
fi

# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

# do stuff
#sleep 1000

rm -f ${LOCKFILE}
##########
} &
##### Add Lagdrop Scripts Here #####

if "$DIR"/lagdrop_"$SUFFIX".sh; then :; else
persist()
{
if "$DIR"/lagdrop_"$SUFFIX".sh; then :; else
	eval "$DIR/lagdrop_$SUFFIX.sh" &> /dev/null &
fi
persist
}
fi
##### Add Lagdrop Scripts Here #####
exit
##### Run LagDrop On Startup #####
}
fi
fi
#####This is the LagDrop auto-run/keep-alive script. Add this to cronjobs to run every minute. It will only run if lagdrop is not running.#####
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
