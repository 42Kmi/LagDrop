#!/bin/sh
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
##### Ver 1.5.0
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

##### Prepare LagDrop's IPTABLES Chains #####
if { iptables -L| grep -Eoq "(LDREJECT|LDACCEPT).*anywhere"; }; then :; else iptables -N LDREJECT; iptables -P LDREJECT REJECT; iptables -N LDACCEPT; iptables -P LDACCEPT ACCEPT; iptables -t filter -A INPUT -j LDACCEPT; iptables -t filter -A INPUT -j LDREJECT; fi
##### Prepare LagDrop's IPTABLES Chains #####

##### Make Files #####
CONSOLENAME=3ds
SCRIPTNAME=$(echo "${0##*/}")
kill -9 `ps -w | grep -v $$ | grep -F "$SCRIPTNAME"` &> /dev/null
DIR=$(echo $0 | sed -E "s/\/$SCRIPTNAME//g")
GETSTATIC=$(echo `nvram get static_leases | grep -E -i -o "$CONSOLENAME.*=([0-9]{1,3}\.?){4}" | sed -E 's/=? .*//g' | grep -E -o "([0-9]{1,3}\.?){4}"| sed -E 's/\=$//g'`)
if [ ! -f $DIR/42Kmi ] ; then mkdir -p $DIR/42Kmi ; fi
if [ ! -f $DIR/42Kmi/options_$CONSOLENAME.txt ] ; then echo -e "$CONSOLENAME=$GETSTATIC\nLIMIT=3\nCOUNT=5\nSIZE=4\nCLEARINTERVAL=300\n;" > $DIR/42Kmi/options_$CONSOLENAME.txt; fi ### Makes options file if it doesn't exist
##### Make Files #####
CONSOLE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 1p | sed -E 's/^.*=//g') ### Your 3DS's IP address. Change this in the $CONSOLENAMEip.txt file
LIMIT=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 2p | sed -E 's/^.*=//g') ### Your max average millisecond limit. Peers pinging higher than this value are blocked. Default is 3.
COUNT=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 3p | sed -E 's/^.*=//g') ### How many packets to send. Default is 5
SIZE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 4p | sed -E 's/^.*=//g') ### Size of packets. Default is 4
CLEARINTERVAL=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -5 4p | sed -E 's/^.*=//g') ### Clear time in seconds. Default is 300
ROUTER=$(nvram get lan_ipaddr | grep -E -o '(([0-9]{1,3}\.?){4})')
ROUTERSHORT=$(nvram get lan_ipaddr | grep -E -o '(([0-9]{1,3}\.?){2})' | sed -n 1p)
WANSHORT=$(nvram get wan_ipaddr | grep -E -o '(([0-9]{1,3}\.?){2})' | sed -n 1p)
FILTERIP=$(echo "^202\.|^10\.248|^52\.|^203\.180|^64\.228|^54\.|^104\.|^198\.62|^23\.((19[2-9])|(2[0-9]{1,2})|(3[2-9])|(4[0-9])|(5[0-9])|(6[0-7]))|^192\.195\.204|^10\.([0-9]{1,3})|^203\.(17[8-9]|18[0-3])|^52\.(6[4-9]|7[0-9])|(^107\.2[0-3])|^23\.(([0-9]{1})|1([0-9]{1}))\.|^23\.7([2-9]{1})\.|^172\.(2(2([4-9]{1}))|(3[0-9]{1}))\.|^69\.25\.139\.(1(2([8-9]{1}))|(3([0-9]{1})))|^38\.112\.28\.9([6-9]{1})|^60\.32\.179\.1(([6-9]{1})|(2[0-3]{1}))|^60\.36\.183\.15([2-9]{1})|^64\.124\.44\.((4([8-9]{1}))|(5([0-5]{1})))|^64\.125\.103\.|^65\.166\.10\.(10([4-9]{1})|(11([0-1]{1})))|^84\.37\.20\.((20([8-9]{1}))|(21([0-5]{1})))|^84\.233\.128\.((6([4-9]{1}))|(([5-9]{1})([0-9]{1}))|(1([0-1]{1})([0-9]{1}))|(12([0-7]{1})))|^84\.233\.202((([0-2]{1})([0-9]{1}))|(3([0-1]{1})))^89\.202\.218\.(([0-9]{1})|(1([0-5]{1})))|^125\.196\.255\.((19([6-9]{1}))|(20([0-7]{1})))|^125\.199\.254\.((4([8-9]{1}))|(5([0-9]{1}))|(6([0-7]{1})))|^125\.206\.241\.((17([6-9]{1}))|(18([0-9]{1}))|(19([0-1]{1})))|^133\.205\.103\.((19([2-9]{1}))|(20([0-7]{1})))|^192\.195\.204\.^194\.121\.124\.((22([4-9]{1}))|(23([0-1]{1})))|^194\.176\.154\.((16([8-9]{1}))|(17([0-5]{1})))|^195\.10\.13\.((1([6-9]{1}))|(([2-5]{1})([0-9]{1}))|(6([0-3]{1})))|^195\.10\.13\.(7([2-5]{1}))|^195\.27\.92\.((9([6-9]{1}))|(1([0-1]{1})([0-9]{1}))|(12([0-7]{1})))|^195\.27\.92\.((19([2-9]{1}))|(20([0-7]{1})))|^195\.27\.196(([0-9]{1})|(1([0-5]{1})))|^195\.73\.250\.((22([4-9]{1}))|(23([0-1]{1})))|^195\.243\.236\.((13([6-9]{1}))|(14([0-3]{1})))|^202\.232\.234\.((12([8-9]{1}))|(13([0-9]{1}))|(14([0-3]{1})))|^205\.166\.76\.^206\.19\.110\.^208\.186\.152\.^210\.88\.88\.((17([6-9]{1}))|(18([0-9]{1}))|(19([0-1]{1})))|^210\.168\.40\.((2([4-9]{1}))|(3([0-9]{1})))|^210\.151\.57\.((8([0-9]{1}))|(9([0-5]{1})))|^210\.169\.213\.((3([2-9]{1}))|(([4-5]{1})([0-9]{1}))|(6([0-3]{1})))|^210\.172\.105\.((16([0-9]{1}))|(1([7-8]{1})([0-9]{1}))|(19([0-1]{1})))|^210\.233\.54\.((3([2-9]{1}))|(4([0-7]{1})))|^211\.8\.190\.((19([2-9]{1}))|(2([0-1]{1})([0-9]{1}))|(22([0-3]{1})))|^212\.100\.231\.(6([0-1]{1}))|^213\.69\.144\.((1([6-8]{1})([0-9]{1}))|(19([0-1]{1})))|^217\.161\.8\.(2([2-7]{1}))|^219\.96\.82\.((17([6-9]{1}))|(18([0-9]{1}))|(19([0-1]{1})))|^220\.109\.217\.(16([0-7]{1}))|^125\.199\.254\.50|^192\.195\.204\.40|^192\.195\.204\.176|^205\.166\.76\.176|^207\.38\.8\.15|^207\.38\.11\.12|^207\.38\.11\.34|^207\.38\.11\.49|^209\.67\.106\.141|^207\.38\.8\.0|^69\.25\.139\.")

if [ ! -f $DIR/42Kmi/extraip.txt ] ; then
PEERIP=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack | grep "${CONSOLE}" | grep -E -o '(([0-9]{1,3}\.?){4})' | grep -o '^.*\..*$' | grep -v "${CONSOLE}" | grep -v "${ROUTER}" | grep -E -v "^192\.168\.(([0-9]{1,3}\.?){2})" | grep -E -v "^$ROUTERSHORT" | grep -E -v "^$WANSHORT" | egrep -E -v "$FILTERIP" | awk '!a[$0]++' | sed -n 1p ) ### Get Wii U Peer's IP
else
EXTRAIP=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/extraip.txt | sed -n 1p ) ### Additional IPs to filter out. Make extraip.txt in 42Kmi folder, add IPs there. See README
PEERIP=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack | grep "${CONSOLE}" | grep -E -o '(([0-9]{1,3}\.?){4})' | grep -o '^.*\..*$' | grep -v "${CONSOLE}" | grep -v "${ROUTER}" | grep -E -v "^192\.168\.(([0-9]{1,3}\.?){2})" | grep -E -v "^$ROUTERSHORT" | grep -E -v "^$WANSHORT" | egrep -E -v "$FILTERIP" | egrep -E -v "$EXTRAIP" | awk '!a[$0]++' | sed -n 1p ) ### Get Wii U Peer's IP
fi
mdev=$({ if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else ping -q -c "${COUNT}" -W 1 -s "${SIZE}" "${PEERIP}" | grep -F "round-trip" | sed -E 's/^.*([0-9]{1,9}\.[0-9]{3}\/){2}//g' | sed -E "s/\..*ms//g"; &> /dev/null; fi; } &) ### Get mdev from ping
BLOCK=$({ if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else { if [ "${mdev}" -gt "${LIMIT}" ]; then { eval "iptables -A LDREJECT -p all -s $PEERIP -d $CONSOLE -j REJECT"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &)
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
{ { while sleep "$CLEARINTERVAL"; do { { eval "echo $(iptables -nL --line-numbers | grep -i "$CONSOLE" | grep "ACCEPT" | grep -oE "(([0-9]{1,9})).*ACCEPT" | grep -oE "(([0-9]{1,9}))" | awk '!x[$0]++' | sed -E 's/^/iptables -D INPUT /g' | sed -E 's/$/\n/g')"; } ; { eval "echo $(iptables -L --line-numbers | grep -i "$CONSOLE" | grep "ACCEPT" | grep -oE "(([0-9]{1,9})).*ACCEPT" | grep -oE "(([0-9]{1,9}))" | awk '!x[$0]++' | sed -E 's/^/iptables -D OUTPUT /g' | sed -E 's/$/\n/g')"; } ; { eval "echo $(iptables -L --line-numbers | grep -i "$CONSOLE" | grep "REJECT" | grep -oE "(([0-9]{1,9})).*REJECT" | grep -oE "(([0-9]{1,9}))" | awk '!x[$0]++' | sed -E 's/^/iptables -D INPUT /g' | sed -E 's/$/\n/g')"; } ; { eval "echo $(iptables -L --line-numbers | grep -i "$CONSOLE" | grep "REJECT" | grep -oE "(([0-9]{1,9})).*REJECT" | grep -oE "(([0-9]{1,9}))" | awk '!x[$0]++' | sed -E 's/^/iptables -D OUTPUT /g' | sed -E 's/$/\n/g')"; }; }; done; } &> /dev/null; } &

{ { while sleep "$CLEARINTERVAL"; do { iptables -F LDREJECT; iptables -F LDACCEPT;}; done; } &> /dev/null; } & 
### Clear iptables ###

{
if { ping -q -c 1 -W 1 -s 1 "${CONSOLE}" | grep -q -F -w "100% packet loss" ;} &> /dev/null; then :; else
$KILLOLD
{ while ping -q -c 1 -W 1 "${CONSOLE}" | grep -q -F -w "100% packet loss"; do :; done ;} &> /dev/null; wait
#while sleep 60; do 
while sleep :; do 
 if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else ${BLOCK}; sleep $((2 * $COUNT)); wait &> /dev/null; fi
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