#!/bin/sh
SUFFIX=wiiu ###change this to match the ending of the lagdrop file you want to run
SCRIPTNAME=$(echo "${0##*/}")
DIR=$(echo $0 | sed -E "s/\/$SCRIPTNAME//g")
##### Run LagDrop On Startup #####

##### Add Lagdrop Scripts Here #####
#{{ until $DIR/lagdrop_wiiu.sh; do eval "$DIR/lagdrop_wiiu.sh"; done; } &> /dev/null LAGDROP1=$!; } &
#&& {{ until $DIR/lagdrop_3ds.sh; do eval "$DIR/lagdrop_3ds.sh"; done; } &> /dev/null LAGDROP2=$!; } &
#&& {{ until $DIR/lagdrop_xbox.sh; do eval "$DIR/lagdrop_xbox.sh"; done; } &> /dev/null LAGDROP3=$!; } &
{{ until $DIR/lagdrop_$SUFFIX.sh; do eval "$DIR/lagdrop_$SUFFIX.sh"; done; } &> /dev/null LAGDROP1=$!; }
##### Add Lagdrop Scripts Here #####
wait
##### Run LagDrop On Startup #####

#####This is the LagDrop auto-run/keep-alive script. Add this to cronjobs to run every minute. It will only run if lagdrop is not running.#####