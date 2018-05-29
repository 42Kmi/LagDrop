#!/bin/sh
SCRIPTNAME=$(echo "${0##*/}")
kill -9 $(ps -w | grep -F "$SCRIPTNAME" | grep -v $$) &> /dev/null

##### Find Shell #####
SHELLIS=$(if [ -f "/usr/bin/lua" ]; then echo "ash"; else echo "no"; fi)
WAITLOCK=$(if [ "${SHELLIS}" = "ash" ]; then "-w"; else :; fi)
##### Find Shell #####
##### LagDrop iptables clear script. Clears LagDrop related iptables#####
##### Add this to cron to run at some interval. Execute this script to clear the LagDrop chains from iptables

### Edit to adjust function ###
MODE=0 #0 = clears LDACCEPT and LDREJECT; 1 = clears LDREJECT only.
### Edit to adjust function ###

### Magic happens here ###
if [ "${MODE}" != 1 ]; then
iptables -F LDREJECT "${WAITLOCK}" && iptables -F LDACCEPT "${WAITLOCK}"
else
iptables -F LDACCEPT "${WAITLOCK}"
fi
### Magic happens here ###
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
