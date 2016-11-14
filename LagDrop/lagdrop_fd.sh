#!/bin/sh

##### 42Kmi LagDrop Force Drop Fools #####
#LagDrop MUST be running prior to use.
#Enter drop targets as arguments in command line. Execute without argument to drop most recent allowed peer.
#Use wisely! Use with discretion!#

MODE=2 # 0 for fixed source (enter destination only); 1 to enter source and destination, in that order; 2 to drop most recent allowed
SOURCE="YOUR_FIXED_IP_HERE"
RECENT=$(echo $(iptables -nL LDACCEPT| tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p))
RECENTSOURCE=$(echo $(iptables -nL LDACCEPT| tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 2p))

if [ "${MODE}" != 1 ] && [ "${MODE}" != 2 ]; then
DEST=$1
	if [ "${DEST}" = "" ] && [ "${MODE}" != 2 ]; then
	echo "Please enter a destination"
	else
		iptables -I LDREJECT -s "${SOURCE}" -d "${DEST}" -j DROP &> /dev/null
		echo "$DEST has been dropped"
	fi
else
SOURCE=$1
DEST=$2
if [ "${MODE}" != 2 ]; then
	if ( [ "${SOURCE}" = "" ] || [ "${SOURCE}" = "YOUR_FIXED_IP_HERE" ] ) || [ "${DEST}" = "" ]; then
	echo "Please enter both source AND destination"
	else
	iptables -I LDREJECT -s "${SOURCE}" -d "${DEST}" -j DROP &> /dev/null
	echo "$DEST has been dropped from $SOURCE"
	fi
fi
fi

##### Drop Recent IP #####
if [ "${MODE}" = 2 ] && [ "$1" = "" ]; then
iptables -I LDREJECT -s "${RECENTSOURCE}" -d "${RECENT}" -j DROP &> /dev/null
echo "Current peer has been dropped at $(date)"
fi
##### Drop Recent IP #####
##### 42Kmi LagDrop Force Drop Fools #####