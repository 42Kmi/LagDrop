#!/bin/sh
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
##### Ver 1.7.4
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
if { iptables -L| grep -Eoq "(LDREJECT|LDACCEPT).*anywhere"; }; then :; else iptables -N LDREJECT; iptables -P LDREJECT DROP; iptables -N LDACCEPT; iptables -P LDACCEPT ACCEPT; iptables -t filter -A FORWARD -j LDACCEPT; iptables -t filter -A FORWARD -j LDREJECT; fi
##### Prepare LagDrop's IPTABLES Chains #####

##### Make Files #####
CONSOLENAME=3ds
SCRIPTNAME=$(echo "${0##*/}")
kill -9 `ps -w | grep -v $$ | grep -F "$SCRIPTNAME"` &> /dev/null
DIR=$(echo $0 | sed -E "s/\/$SCRIPTNAME//g")
SWITCH=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 10p | sed -E 's/^.*=//g') ### Enable (1)/Disable(0) LagDrop
if [ "${SWITCH}" = 0 ] || [ "${SWITCH}" = OFF ] || [ "${SWITCH}" = off ]; then exit;
else {
GETSTATIC=$(echo `nvram get static_leases | grep -Ei -o "$CONSOLENAME.*=([0-9]{1,3}\.?){4}" | sed -E 's/=? .*//g' | grep -Eo "([0-9]{1,3}\.?){4}"| sed -E 's/\=$//g'`)
if [ ! -f $DIR/42Kmi ] ; then mkdir -p $DIR/42Kmi ; fi
if [ ! -f $DIR/42Kmi/options_$CONSOLENAME.txt ] ; then echo -e "$CONSOLENAME=$GETSTATIC\nPINGLIMIT=90\nCOUNT=5\nSIZE=54\nMODE=1\nMAXTTL=10\nPROBES=5\nTRACELIMIT=20\nACTION=REJECT\nSWITCH=ON\n;" > $DIR/42Kmi/options_$CONSOLENAME.txt; fi ### Makes options file if it doesn't exist
##### Make Files #####
CONSOLE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 1p | sed -E 's/^.*=//g') ### Your Wii U's IP address. Change this in the $CONSOLENAMEip.txt file
LIMIT=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 2p | sed -E 's/^.*=//g') ### Your max average millisecond limit. Peers pinging higher than this value are blocked. Default is 3.
COUNT=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 3p | sed -E 's/^.*=//g') ### How many packets to send. Default is 5
SIZE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 4p | sed -E 's/^.*=//g') ### Size of packets. Default is 1024
MODE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 5p | sed -E 's/^.*=//g')
ROUTER=$(nvram get lan_ipaddr | grep -Eo '(([0-9]{1,3}\.?){4})')
ROUTERSHORT=$(nvram get lan_ipaddr | grep -Eo '(([0-9]{1,3}\.?){3})' | sed -E 's/\./\\./g' | sed -n 1p)
WANSHORT=$(nvram get wan_ipaddr | grep -Eo '(([0-9]{1,3}\.?){4})' | sed -E 's/\./\\./g' | sed -n 1p)
FILTERIP=$(echo "^202\.|^10\.248|^52\.|^203\.180|^64\.228|^54\.|^104\.|^198\.62|^23\.((19[2-9])|(2[0-9]{1,2})|(3[2-9])|(4[0-9])|(5[0-9])|(6[0-7]))|^192\.195\.204|^10\.([0-9]{1,3})|^203\.(17[8-9]|18[0-3])|^52\.(6[4-9]|7[0-9])|(^107\.2[0-3])|^23\.(([0-9]{1})|1([0-9]{1}))\.|^23\.7([2-9]{1})\.|^172\.(2(2([4-9]{1}))|(3[0-9]{1}))\.|^69\.25\.139\.(1(2([8-9]{1}))|(3([0-9]{1})))|^38\.112\.28\.9([6-9]{1})|^60\.32\.179\.1(([6-9]{1})|(2[0-3]{1}))|^60\.36\.183\.15([2-9]{1})|^64\.124\.44\.((4([8-9]{1}))|(5([0-5]{1})))|^64\.125\.103\.|^65\.166\.10\.(10([4-9]{1})|(11([0-1]{1})))|^84\.37\.20\.((20([8-9]{1}))|(21([0-5]{1})))|^84\.233\.128\.((6([4-9]{1}))|(([5-9]{1})([0-9]{1}))|(1([0-1]{1})([0-9]{1}))|(12([0-7]{1})))|^84\.233\.202((([0-2]{1})([0-9]{1}))|(3([0-1]{1})))^89\.202\.218\.(([0-9]{1})|(1([0-5]{1})))|^125\.196\.255\.((19([6-9]{1}))|(20([0-7]{1})))|^125\.199\.254\.((4([8-9]{1}))|(5([0-9]{1}))|(6([0-7]{1})))|^125\.206\.241\.((17([6-9]{1}))|(18([0-9]{1}))|(19([0-1]{1})))|^133\.205\.103\.((19([2-9]{1}))|(20([0-7]{1})))|^192\.195\.204\.^194\.121\.124\.((22([4-9]{1}))|(23([0-1]{1})))|^194\.176\.154\.((16([8-9]{1}))|(17([0-5]{1})))|^195\.10\.13\.((1([6-9]{1}))|(([2-5]{1})([0-9]{1}))|(6([0-3]{1})))|^195\.10\.13\.(7([2-5]{1}))|^195\.27\.92\.((9([6-9]{1}))|(1([0-1]{1})([0-9]{1}))|(12([0-7]{1})))|^195\.27\.92\.((19([2-9]{1}))|(20([0-7]{1})))|^195\.27\.196(([0-9]{1})|(1([0-5]{1})))|^195\.73\.250\.((22([4-9]{1}))|(23([0-1]{1})))|^195\.243\.236\.((13([6-9]{1}))|(14([0-3]{1})))|^202\.232\.234\.((12([8-9]{1}))|(13([0-9]{1}))|(14([0-3]{1})))|^205\.166\.76\.^206\.19\.110\.^208\.186\.152\.^210\.88\.88\.((17([6-9]{1}))|(18([0-9]{1}))|(19([0-1]{1})))|^210\.168\.40\.((2([4-9]{1}))|(3([0-9]{1})))|^210\.151\.57\.((8([0-9]{1}))|(9([0-5]{1})))|^210\.169\.213\.((3([2-9]{1}))|(([4-5]{1})([0-9]{1}))|(6([0-3]{1})))|^210\.172\.105\.((16([0-9]{1}))|(1([7-8]{1})([0-9]{1}))|(19([0-1]{1})))|^210\.233\.54\.((3([2-9]{1}))|(4([0-7]{1})))|^211\.8\.190\.((19([2-9]{1}))|(2([0-1]{1})([0-9]{1}))|(22([0-3]{1})))|^212\.100\.231\.(6([0-1]{1}))|^213\.69\.144\.((1([6-8]{1})([0-9]{1}))|(19([0-1]{1})))|^217\.161\.8\.(2([2-7]{1}))|^219\.96\.82\.((17([6-9]{1}))|(18([0-9]{1}))|(19([0-1]{1})))|^220\.109\.217\.(16([0-7]{1}))|^125\.199\.254\.50|^192\.195\.204\.40|^192\.195\.204\.176|^205\.166\.76\.176|^207\.38\.8\.15|^207\.38\.11\.12|^207\.38\.11\.34|^207\.38\.11\.49|^209\.67\.106\.141|^207\.38\.8\.0|^69\.25\.139\.|^69\.192\.|^184\.(2[4-9]|3[0-1])\.|^96\.1[6-7]\.")
IGNORE=$(echo $({ if { { iptables -nL LDACCEPT && iptables -nL LDREJECT; } | grep -Eoq "([0-9]{1,3}\.?){4}"; } then echo "$({ iptables -nL LDACCEPT && iptables -nL LDREJECT; } | grep -Eo "([0-9]{1,3}\.?){4}" | awk '!a[$0]++' |grep -v "${CONSOLE}"| sed -E 's/^/\^/g' | sed 's/\./\\\./g')"|sed -E 's/$/\|/g'; else echo "${ROUTER}"; fi; })|sed -E 's/\|$//g'|sed -E 's/\ //g')
if [ ! -f $DIR/42Kmi/extraip.txt ] ; then
PEERIP=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack | grep "${CONSOLE}" | grep -Eo '(([0-9]{1,3}\.?){4})' | grep -o '^.*\..*$' | grep -v "${CONSOLE}" | grep -v "${ROUTER}" |grep -Ev "${IGNORE}"| grep -Ev "^192\.168\.(([0-9]{1,3}\.?){2})" | grep -Ev "^$ROUTERSHORT" | grep -Ev "^$WANSHORT" | egrep -Ev "$FILTERIP" | awk '!a[$0]++' | sed -n 1p ) ### Get Wii U Peer's IP
else
EXTRAIP=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/extraip.txt | sed -n 1p ) ### Additional IPs to filter out. Make extraip.txt in 42Kmi folder, add IPs there. See README
PEERIP=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack | grep "${CONSOLE}" | grep -Eo '(([0-9]{1,3}\.?){4})' | grep -o '^.*\..*$' | grep -v "${CONSOLE}" | grep -v "${ROUTER}" |grep -Ev "${IGNORE}"| grep -Ev "^192\.168\.(([0-9]{1,3}\.?){2})" | grep -Ev "^$ROUTERSHORT" | grep -Ev "^$WANSHORT" | egrep -Ev "$FILTERIP" | egrep -Ev "$EXTRAIP" | awk '!a[$0]++' | sed -n 1p ) ### Get Wii U Peer's IP
fi
if [ "${MODE}" = 2 ]; then :;
else
PINGRESULT=$({ if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else ping -q -c "${COUNT}" -W 1 -s "${SIZE}" "${PEERIP}" | grep -F "round-trip" | sed -E 's/^.*([0-9]{1,9}\.[0-9]{3}\/){1}//g' | sed -E "s/\..*ms//g"; &> /dev/null; fi; } &) ### Get PINGRESULT from ping
fi
MODE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 5p | sed -E 's/^.*=//g')

if [ "${MODE}" != 2 ] && [ "${MODE}" != 3 ] && [ "${MODE}" != 4 ]; then :;
else
##### TRACEROUTE #####
##### PARAMETERS #####
MAXTTL=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 6p | sed -E 's/^.*=//g')
TTL=$(if [ "${MAXTTL}" -le 255 ] && [ "${MAXTTL}" -ge 1 ]; then echo "$MAXTTL"; else echo 10; fi)
PROBES=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 7p | sed -E 's/^.*=//g')
TRACELIMIT=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 8p | sed -E 's/^.*=//g')
##### PARAMETERS #####
MXP=$(echo $(( $TTL * $PROBES )))
TRGET=$(if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else echo $(traceroute -m "${TTL}" -q "${PROBES}" -w 1 "${PEERIP}"|grep -Eo "([0-9]{1,9}\.[0-9]{3}\ ms)"|sed -E 's/(time=|\..*$)//g'|sed -E 's/$/ +/g'); fi)
TRCOUNT=$(echo "$TRGET" | grep -o " +" | wc -l) #Counts for average
TRACEROUTESUM=$(echo "$TRGET"|sed -E 's/\+$//g') #TRACEROUTE values get
TR=$(echo $(( $TRACEROUTESUM ))) #TRACEROURTE sum for math
##### TRAVG #####
if [ "${TRCOUNT}" != 0 ]; then
TRAVG=$(echo $(( $TR / $TRCOUNT ))) #AVERAGE, true average
else
TRAVG=$(echo $(( $TR / $MXP ))) #AVERAGE, if first fails
fi
##### TRAVG #####
DEV=$(echo $(( $TR - $TRAVG*$TRCOUNT ))) #Difference of SUM minus AVERAGE times MXP
##### TRACEROUTE #####
fi
##### ACTION of IP Rule #####
ACTION=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 9p | sed -E 's/^.*=//g') ### DROP (1)/REJECT(0) 
ACTION1=$(if [ "${ACTION}" = 1 ] || [ "${ACTION}" = drop ] || [ "${ACTION}" = DROP ]; then echo "DROP"; else echo "REJECT"; fi)
##### ACTION of IP Rule #####
##### BLOCK ##### // 1=Ping, 2=TraceRoute, 3=Ping or TraceRoute, 4=Ping & TraceRoute
if [ "${MODE}" != 2 ] && [ "${MODE}" != 3 ] && [ "${MODE}" != 4 ]; then
BLOCK=$({ if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else { if [ "${PINGRESULT}" -gt "${LIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &)# Ping only
else
	if [ "${MODE}" = 2 ]; then
	BLOCK=$({ if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else { if [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &)#TraceRoute only
	else
		if [ "${MODE}" = 3 ]; then
		BLOCK=$({ if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else { if [ "${PINGRESULT}" -gt "${LIMIT}" ] || [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &) #Ping OR TraceRoute
		else
				if [ "${MODE}" = 4 ]; then
				BLOCK=$({ if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else { if [ "${PINGRESULT}" -gt "${LIMIT}" ] && [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &) #Ping AND TraceRoute
				fi
		fi
	fi
fi
##### BLOCK #####

#LOOP=$(exec "$0" && kill $$)
LOOP=$(exec "$0")

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
$LOOP

rm -f ${LOCKFILE}
##########
} &

{
if { ping -q -c 1 -W 1 -s 1 "${CONSOLE}" | grep -q -F -w "100% packet loss" ;} &> /dev/null; then :; else
$LOOP
{ while ping -q -c 1 -W 1 "${CONSOLE}" | grep -q -F -w "100% packet loss"; do :; done ;} &> /dev/null; wait
#while sleep 60; do 
while sleep :; do 
 if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else ${BLOCK}; wait &> /dev/null; fi

 done
fi

$LOOP
} &> /dev/null
}
fi
##### Ban SLOW Peers #####
##### 42Kmi International Competitive Gaming #####
##### Visit 42Kmi.com #####
##### Shop @ 42Kmi.com/store #####
##### Shirts @ 42Kmi.com/swag.htm #####