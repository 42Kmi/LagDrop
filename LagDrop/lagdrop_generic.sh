#!/bin/sh
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
##### Ver 1.4.1
######################################################################################################
#               .////////////   -+osyyys+-   `////////////////////-                      `//////////`#
#              /Ny++++++++hM+/hNho/----:+hNo hN++++++oMMm++++++mMy`                      hMhhhhhhdMh #
#            `yN/        .NNmd/           :MmM/      hMy`    `hN/```````.--.`   `---.   oMy+++++omN` #
#           :Nd.        `mMM+     ods      NMs      oN+     /NMmdddddmMNhyshNhymdysydNo:MmhhhhhhNM:  #
#          sMo   `      yMM+     yMM:     /Md      -d.    `yMMd      :-     `s+`     :MMd      :Mo   #
#        -mm-   o`     /MMh.....+Md-     /MN.     `o`    -mdNN`     -o.      /+      /MN.     .Nh    #
#       +Ms`  .d-     .NmhhhhhNMm/     `sMM/      `     oMosM:     :Mm      sMs     `mM/      dN`    #
#     .hN:   :No      mm`   -hN+      +NNMs            yM-:Ms     `NM-     /Md      hMs      oM:     #
#    /Nh`   +Mh      sM-  -hNo`     /md/md             mm`Nd      hM+     .NN.     +Md      :Mo      #
#   yN+    yNm`     :NMm+yNo`     +md: hN.     `-      MhhN.     oMy      dM/     -MN.     `Nd       #
#  oM:               -MMNo`    `+md:  +M/      h.     .MNM:     -Mm`     sMs     `mM/      dN.       #
# :Ms               `mNo`    `oNMdssssMy      +m      :MMs     `NM-     /Md      yMy      oM:        #
#`NMmdddddds      sdms`      -::::::NMm`     -My      +Md      hM+     .NN.     +Mm`     :Ms         #
#        dN`     /MMy              yMN.     `mM/      oN.     oMh      dM/     -MN.     `Nd          #
#       sMhooooooNMMsoooooooooooooyMMdoooooodMMyoooooomdooooosMMsooooohMNoooooomMdoooooodN.          #
#       :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.           #
######################################################################################################

##### 42Kmi International Competitive Gaming #####
##### Please visit and join 42Kmi.com #####
##### Be Glorious #####
##### Ban SLOW Peers #####



##### Make Files #####
CONSOLENAME=CONSOLE_NAME_HERE
SCRIPTNAME=$(echo "${0##*/}")
kill -9 `ps -w | grep -v $$ | grep -F "$SCRIPTNAME"` &> /dev/null
DIR=$(echo $0 | sed -E "s/\/$SCRIPTNAME//g")
GETSTATIC=$(echo `nvram get static_leases | grep -E -i -o "$CONSOLENAME.*=([0-9]{1,3}.?){4}" | sed -E 's/=? .*//g' | grep -E -o "([0-9]{1,3}.?){4}"| sed -E 's/\=$//g'`)
if [ ! -f $DIR/42Kmi ] ; then mkdir -p $DIR/42Kmi ; fi
if [ ! -f $DIR/42Kmi/options_$CONSOLENAME.txt ] ; then echo -e "$CONSOLENAME=$GETSTATIC\nLIMIT=3\nCOUNT=5\nSIZE=1024\nCLEARINTERVAL=300\n;" > $DIR/42Kmi/options_$CONSOLENAME.txt; fi ### Makes options file if it doesn't exist
#if [ ! -f $DIR/42Kmi/peerip_$CONSOLENAME.txt ]; then echo "0.0.0.0" > $DIR/42Kmi/peerip_$CONSOLENAME.txt; fi
##### Make Files #####
CONSOLE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 1p | sed -E 's/^.*=//g') ### Your Wii U's IP address. Change this in the $CONSOLENAMEip.txt file
LIMIT=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 2p | sed -E 's/^.*=//g') ### Your max average millisecond limit. Peers pinging higher than this value are blocked. Default is 3.
COUNT=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 3p | sed -E 's/^.*=//g') ### How many packets to send. Default is 5
SIZE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 4p | sed -E 's/^.*=//g') ### Size of packets. Default is 1024
CLEARINTERVAL=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -5 4p | sed -E 's/^.*=//g') ### Size of packets. Default is 1024
ROUTER=$(nvram get lan_ipaddr | grep -E -o '(([0-9]{1,3}\.?){4})')
ROUTERSHORT=$(nvram get lan_ipaddr | grep -E -o '(([0-9]{1,3}\.?){2})' | sed -n 1p)
WANSHORT=$(nvram get wan_ipaddr | grep -E -o '(([0-9]{1,3}\.?){2})' | sed -n 1p)
FILTERIP=$(echo "FORMATTED_IPs_HERE")

if [ ! -f $DIR/42Kmi/extraip.txt ] ; then
PEERIP=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack | grep "${CONSOLE}" | grep -E -o '(([0-9]{1,3}\.?){4})' | grep -o '^.*\..*$' | grep -v "${CONSOLE}" | grep -v "${ROUTER}" | grep -E -v "^192\.168\.(([0-9]{1,3}\.?){2})" | grep -E -v "^$ROUTERSHORT" | grep -E -v "^$WANSHORT" | egrep -E -v "$FILTERIP" | awk '!a[$0]++' | sed -n 1p ) ### Get Wii U Peer's IP
else
EXTRAIP=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/extraip.txt | sed -n 1p ) ### Additional IPs to filter out. Make extraip.txt in 42Kmi folder, add IPs there. See README
PEERIP=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack | grep "${CONSOLE}" | grep -E -o '(([0-9]{1,3}\.?){4})' | grep -o '^.*\..*$' | grep -v "${CONSOLE}" | grep -v "${ROUTER}" | grep -E -v "^192\.168\.(([0-9]{1,3}\.?){2})" | grep -E -v "^$ROUTERSHORT" | grep -E -v "^$WANSHORT" | egrep -E -v "$FILTERIP" | egrep -E -v "$FILTERIP" | awk '!a[$0]++' | sed -n 1p ) ### Get Wii U Peer's IP
fi
RESOLVE=$(nslookup $PEERIP | grep -Fq "Address 1: $PEERIP" | sed -E "s/^.*$PEERIP\ //g")
mdev=$(ping -q -c "${COUNT}" -W 1 -s "${SIZE}" "${PEERIP}" | grep -F "round-trip" | sed -E 's/^.*([0-9]{1,9}\.[0-9]{3}\/){2}//g' | sed -E "s/\..*ms//g"; &> /dev/null) ### Get mdev from ping
BLOCK=$({ if [ "${mdev}" -gt "${LIMIT}" ]; then if { iptables -L | grep -Fq "$PEERIP" ;} || { iptables -L | grep -q `echo "$PEERIP" | sed -E 's/\./-/g'`; } || { iptables -L | grep -Fq "$RESOLVE" ;} || { iptables -nL|sort -u|grep -Fq "$PEERIP"|sed 's/$PEERIP//g'|sed -E 's/^.*--//g'|grep -Eo "(([0-9]{0,3})\.?){4}"|sort -u|grep -Fq "$RESOLVE" ; }; then :; else { eval "iptables -A INPUT -p all -s $CONSOLE -d $PEERIP -j REJECT" && eval "iptables -A INPUT -p all -s $PEERIP -d $CONSOLE -j REJECT" && eval "iptables -A OUTPUT -p all -s $CONSOLE -d $PEERIP -j REJECT" && eval "iptables -A OUTPUT -p all -s $PEERIP -d $CONSOLE -j REJECT"; } fi; else { eval "iptables -A INPUT -p all -s $CONSOLE -d $PEERIP -j ACCEPT" && eval "iptables -A INPUT -p all -s $PEERIP -d $CONSOLE -j ACCEPT" && eval "iptables -A OUTPUT -p all -s $CONSOLE -d $PEERIP -j ACCEPT" && eval "iptables -A OUTPUT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; }&) 
KILLOLD=$(kill -9 `ps -w | grep -F "$SCRIPTNAME" | grep -v $$` &> /dev/null)
LOOP=$(exec "$0" && $KILLOLD && kill $$)

{
##########
LOCKFILE=/tmp/lock.txt
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit
fi

# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

# do stuff
#sleep 1000
$KILLOLD

rm -f ${LOCKFILE}
##########
} &

### Clear iptables ###
{ { while sleep "$CLEARINTERVAL"; do { { eval "echo $(iptables -L --line-numbers | grep -i "$CONSOLENAME" | grep "ACCEPT" | grep -oE "(([0-9]{1,9})).*ACCEPT" | grep -oE "(([0-9]{1,9}))" | sort -u | sed -E 's/^/iptables -D INPUT /g' | sed -E 's/$/\n/g')"; } ; { eval "echo $(iptables -L --line-numbers | grep -i "$CONSOLENAME" | grep "ACCEPT" | grep -oE "(([0-9]{1,9})).*ACCEPT" | grep -oE "(([0-9]{1,9}))" | sort -u | sed -E 's/^/iptables -D OUTPUT /g' | sed -E 's/$/\n/g')"; } ; { eval "echo $(iptables -L --line-numbers | grep -i "$CONSOLENAME" | grep "REJECT" | grep -oE "(([0-9]{1,9})).*REJECT" | grep -oE "(([0-9]{1,9}))" | sort -u | sed -E 's/^/iptables -D INPUT /g' | sed -E 's/$/\n/g')"; } ; { eval "echo $(iptables -L --line-numbers | grep -i "$CONSOLENAME" | grep "REJECT" | grep -oE "(([0-9]{1,9})).*REJECT" | grep -oE "(([0-9]{1,9}))" | sort -u | sed -E 's/^/iptables -D OUTPUT /g' | sed -E 's/$/\n/g')"; }; }; done; } &> /dev/null; } &
### Clear iptables ###

{
if { ping -q -c 1 -W 1 -s 1 "${CONSOLE}" | grep -q -F -w "100% packet loss" ;} &> /dev/null; then :; else
$KILLOLD
{ while ping -q -c 1 -W 1 "${CONSOLE}" | grep -q -F -w "100% packet loss"; do :; done ;} &> /dev/null; wait
#while sleep 60; do 
while sleep :; do 
 if { iptables -L | grep -Fq "$PEERIP" ;} || { iptables -L | grep -q `echo "$PEERIP" | sed -E 's/\./-/g'`; } || { iptables -L | grep -Fq "$RESOLVE" ;}; then :; else ${BLOCK}; sleep $((2 * COUNT)); wait &> /dev/null; fi
done
fi

$KILLOLD
$LOOP
} &> /dev/null
##### Ban SLOW Peers #####
##### 42Kmi International Competitive Gaming #####
##### Visit 42Kmi.com #####
##### Shop @ 42Kmi.com/store #####
##### Shirts @ 42Kmi.com/swag.htm #####