#!/bin/sh
SCRIPTNAME=$(echo "${0##*/}")
kill -15 $(ps|grep lagdrop.sh|grep -Eo "^(\s*)?[0-9]{1,}")

##### Find Shell #####
SHELLIS=$(if [ -f "/usr/bin/lua" ]; then echo "ash"; else echo "no"; fi)
WAITLOCK=$(if [ "${SHELLIS}" = "ash" ]; then echo "-w"; else echo ""; fi)
##### Find Shell #####
##### LagDrop iptables clear script. Clears LagDrop related iptables#####
##### Add this to cron to run at some interval. Execute this script to clear the LagDrop chains from iptables

### Edit to adjust function ###
MODE=0 #0 = clears LDACCEPT and LDREJECT; 1 = clears LDREJECT only.
### Edit to adjust function ###

### Magic happens here ###
if [ "${MODE}" != 1 ]; then
iptables -F LDREJECT && iptables -F LDACCEPT && iptables -F LDIGNORE && iptables -F LDTEMPHOLD && iptables -F LDBAN && iptables -F LDSENTSTRIKE
else
iptables -F LDACCEPT 
fi
rm -f /tmp/ldpass.txt
rm -f /tmp/ldfail.txt
rm -f /tmp/ldlog.txt
rm -f /tmp/ldmonit.txt
#rm -f /jffs/42Kmi/filterignore.txt

if  { ls /tmp|grep -Ei "[0-9a-f]{38,}"; } &> /dev/null;  then
	for i in $(ls /tmp|grep -Ei "[0-9a-f]{38,}"); do
		rm -f /tmp/"$i"
	done
fi
exit
### Magic happens here ###
wait $!
kill -15 $(ps -w | grep -F "$SCRIPTNAME" | grep -v $$) &> /dev/null
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
