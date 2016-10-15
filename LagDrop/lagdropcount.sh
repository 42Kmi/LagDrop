#!/bin/sh
#LagDrop Count
while :; do (printf "\ec"; echo "---------------------------"; echo "42Kmi LagDrop Count";(echo "Allowed peers: $(iptables -nL LDACCEPT|grep -oE "^ACCEPT"| wc -l)" && echo "Blocked peers: $(iptables -nL LDREJECT|grep -oE "^(REJECT|DROP)"| wc -l)"; sleep 5)); done
