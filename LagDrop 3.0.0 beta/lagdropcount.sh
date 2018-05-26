#!/bin/sh
#LagDrop Count

##### Find Shell #####
SHELLIS=$(if [ -f "/usr/bin/lua" ]; then echo "ash"; else echo "no"; fi)
WAITLOCK=$(if [ "${SHELLIS}" = "ash" ]; then "-w"; else :; fi)
##### Find Shell #####

ALLOWED=$(iptables -nL LDACCEPT "${WAITLOCK}"|grep -oE "^ACCEPT"| wc -l)
BLOCKED=$(iptables -nL LDREJECT "${WAITLOCK}"|grep -oE "^(REJECT|DROP)"| wc -l)
while :; do (printf "\ec"; echo "---------------------------"; echo "42Kmi LagDrop Count";(echo "Allowed peers: $(iptables -nL LDACCEPT "${WAITLOCK}"|grep -oE "^ACCEPT"| wc -l)" && echo "Blocked peers: $(iptables -nL LDREJECT "${WAITLOCK}"|grep -oE "^(REJECT|DROP)"| wc -l)"; sleep 5)); done

#while :; do (printf "\ec"; echo "---------------------------"; echo "42Kmi LagDrop Count";(echo "Allowed peers: "${ALLOWED}" ($(( ALLOWED * 100/(ALLOWED + BLOCKED + 1) ))%)" && echo "Blocked peers: "${BLOCKED}" ($(( BLOCKED * 100/(ALLOWED + BLOCKED + 1) ))%)"; sleep 5)); done

#while :; do (printf "\ec"; echo "---------------------------"; echo "42Kmi LagDrop Count";(echo "Allowed peers: "${ALLOWED}" ($(( ( ALLOWED + 1) * 100/(ALLOWED + BLOCKED + 1) ))%)" && echo "Blocked peers: "${BLOCKED}" ($(( ( BLOCKED + 1 ) * 100/(ALLOWED + BLOCKED + 1) ))%)"; sleep 5)); done