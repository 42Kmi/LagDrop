#!/bin/sh
SUFFIX=$1 ###change this to match the ending of the lagdrop file you want to run
SCRIPTNAME=$(echo "${0##*/}")
DIR=$(echo $0 | sed -E "s/\/$SCRIPTNAME//g")
##### Run LagDrop On Startup #####
#{
###########
#LOCKFILE=/tmp/lockldrun.txt
#if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
#    echo "already running"
#    exit
#fi
#
## make sure the lockfile is removed when we exit and then claim it
#trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
#echo $$ > ${LOCKFILE}
#
## do stuff
##sleep 1000
#
#rm -f ${LOCKFILE}
###########
#} &
##### Add Lagdrop Scripts Here #####
#{ until "$DIR"/lagdrop_"$SUFFIX".sh; do eval "$DIR/lagdrop_$SUFFIX.sh"; &> /dev/null LAGDROP1=$!; done } &

if "$DIR"/lagdrop_"$SUFFIX".sh; then :; else
{ until "$DIR"/lagdrop_"$SUFFIX".sh; do eval "$DIR/lagdrop_$SUFFIX.sh"; done }; &> /dev/null &
fi
##### Add Lagdrop Scripts Here #####
exit
##### Run LagDrop On Startup #####

#####This is the LagDrop auto-run/keep-alive script. Add this to cronjobs to run every minute. It will only run if lagdrop is not running.#####
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
