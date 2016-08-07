#!/bin/sh
##### LagDrop iptables clear script. Clears LagDrop related iptables at the given interval. In Minutes.#####

#CLEARINTERVAL=60
##### Add this to cron to run at some interval. Execute this script to clear the LagDrop chains from iptables

#if { iptables -L| grep -Eoq "(LDREJECT|LDACCEPT).*anywhere"; }; then while sleep ( $((60 * ${CLEARINTERVAL})); do { iptables -F LDREJECT && iptables -F LDACCEPT && iptables -F LDREJECTOUT; } done; fi
iptables -F LDREJECT && iptables -F LDACCEPT && iptables -F LDREJECTOUT