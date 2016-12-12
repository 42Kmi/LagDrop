#!/bin/sh
#LagDrop Count
ALLOWED=$(iptables -nL LDACCEPT|grep -oE "^ACCEPT"| wc -l)
BLOCKED=$(iptables -nL LDREJECT|grep -oE "^(REJECT|DROP)"| wc -l)
while :; do (printf "\ec"; echo "---------------------------"; echo "42Kmi LagDrop Count";(echo "Allowed peers: $(iptables -nL LDACCEPT|grep -oE "^ACCEPT"| wc -l)" && echo "Blocked peers: $(iptables -nL LDREJECT|grep -oE "^(REJECT|DROP)"| wc -l)"; sleep 5)); done

#while :; do (printf "\ec"; echo "---------------------------"; echo "42Kmi LagDrop Count";(echo "Allowed peers: "${ALLOWED}" ($(( ALLOWED * 100/(ALLOWED + BLOCKED + 1) ))%)" && echo "Blocked peers: "${BLOCKED}" ($(( BLOCKED * 100/(ALLOWED + BLOCKED + 1) ))%)"; sleep 5)); done

#while :; do (printf "\ec"; echo "---------------------------"; echo "42Kmi LagDrop Count";(echo "Allowed peers: "${ALLOWED}" ($(( ( ALLOWED + 1) * 100/(ALLOWED + BLOCKED + 1) ))%)" && echo "Blocked peers: "${BLOCKED}" ($(( ( BLOCKED + 1 ) * 100/(ALLOWED + BLOCKED + 1) ))%)"; sleep 5)); done