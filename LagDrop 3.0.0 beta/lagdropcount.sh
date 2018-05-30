#!/bin/sh
#LagDrop Count
SCRIPTNAME=$(echo "${0##*/}")
kill -9 $(ps -w | grep -F "$SCRIPTNAME" | grep -v $$) &> /dev/null

##### Find Shell #####
SHELLIS=$(if [ -f "/usr/bin/lua" ]; then echo "ash"; else echo "no"; fi)
WAITLOCK=$(if [ "${SHELLIS}" = "ash" ]; then echo "-w"; fi)
##### Find Shell #####

#ALLOWED=$(iptables -nL LDACCEPT "${WAITLOCK}"|grep -oE "^ACCEPT"| wc -l)
#BLOCKED=$(iptables -nL LDREJECT "${WAITLOCK}"|grep -oE "^(REJECT|DROP)"| wc -l)

ALLOWED=$(iptables -nL LDACCEPT |grep -oE "^ACCEPT"| wc -l)
BLOCKED=$(iptables -nL LDREJECT |grep -oE "^(REJECT|DROP)"| wc -l)
while :;
do (printf "\ec"; echo "---------------------------";
echo -e "42Kmi LagDrop Count\nAllowed peers: "$ALLOWED" \nBlocked peers: "$BLOCKED"";
sleep 5);
done
