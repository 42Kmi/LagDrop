#!/bin/sh
SUFFIX=wiiu ###change this to match the ending of the lagdrop file you want to run
SCRIPTNAME=$(echo "${0##*/}")
DIR=$(echo $0 | sed -E "s/\/$SCRIPTNAME//g")
##### Run LagDrop On Startup #####

##### Add Lagdrop Scripts Here #####
{ until "$DIR"/lagdrop_"$SUFFIX".sh; do eval "$DIR/lagdrop_$SUFFIX.sh"; &> /dev/null LAGDROP1=$!; done } &
##### Add Lagdrop Scripts Here #####
#wait
##### Run LagDrop On Startup #####

#####This is the LagDrop auto-run/keep-alive script. Add this to cronjobs to run every minute. It will only run if lagdrop is not running.#####