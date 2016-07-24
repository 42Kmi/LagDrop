#!/bin/sh
#SCRIPTNAME=$(echo "${0##*/}")
#DIR=$(echo $0 | sed -E "s/\/$SCRIPTNAME//g")
#CONSOLENAME=wiiu
#CLEARINTERVAL=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 5p | sed -E 's/^.*=//g') ### Clear time in seconds. 
CLEARINTERVAL=300

{
#while $DIR/lagdrop_$CONSOLENAME.sh; do { while sleep ${CLEARINTERVAL}; do { iptables -F LDREJECT; iptables -F LDACCEPT;}; done; } done
if { iptables -L| grep -Eoq "(LDREJECT|LDACCEPT).*anywhere"; }; then while sleep ${CLEARINTERVAL}; do { iptables -F LDREJECT && iptables -F LDACCEPT; } done; fi
} &