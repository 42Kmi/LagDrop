#!/bin/sh
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
##### Ver 1.7.8
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

##### Prep iptables #####
if  [ `iptables -L FORWARD|grep -E "^ACCEPT"|wc -l` -gt 5 ]; then eval "iptables -F FORWARD"; fi
##### Prep iptables #####

##### Prepare LagDrop's IPTABLES Chains #####
if { iptables -L FORWARD| grep -Eoq "^LDACCEPT.*anywhere"; }; then echo "LDACCEPT already exists"; else iptables -N LDACCEPT; iptables -P LDACCEPT ACCEPT; iptables -t filter -A FORWARD -j LDACCEPT; fi
if { iptables -L FORWARD| grep -Eoq "^LDREJECT.*anywhere"; }; then echo "LDREJECT already exists"; else iptables -N LDREJECT; iptables -P LDREJECT DROP; iptables -t filter -A FORWARD -j LDREJECT; fi
##### Prepare LagDrop's IPTABLES Chains #####

##### Make Files #####
CONSOLENAME=xbox
SCRIPTNAME=$(echo "${0##*/}")
kill -9 `ps -w | grep -v $$ | grep -F "$SCRIPTNAME"` &> /dev/null
DIR=$(echo $0 | sed -E "s/\/$SCRIPTNAME//g")
##### Add to CronJobs #####
#if (while read -r i; do echo "${i%}"; done < /tmp/cron.d/cron_jobs)| grep -E "\*\/[0-9]{1,} \* \* \* \* root \/bin\/sh ${DIR}/runlagdrop\.sh$"; then echo "exists"; else echo "Adding runlagdrop.sh to cronjobs"; echo -e "\n*/1 * * * * root /bin/sh ${DIR}/runlagdrop.sh" >> /tmp/cron.d/cron_jobs; stopservice cron && startservice cron; stopservice crond && startservice crond; fi
#if (while read -r i; do echo "${i%}"; done < /tmp/cron.d/cron_jobs)| grep -E "root /bin/sh ${DIR}/lagdropclear\.sh$"; then echo "exists"; else echo "Adding lagdropclear.sh to cronjobs"; echo -e "\n? */6 * * * root /bin/sh ${DIR}/lagdropclear.sh" >> /tmp/cron.d/cron_jobs; stopservice cron && startservice cron; stopservice crond && startservice crond; sleep 3; fi
##### Add to CronJobs #####
SWITCH=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 12p | sed -E 's/^.*=//g') ### Enable (1)/Disable(0) LagDrop
GETSTATIC=$(echo `nvram get static_leases | grep -Ei -o "$CONSOLENAME.*=([0-9]{1,3}\.?){4}" | sed -E 's/=? .*//g' | grep -Eo "([0-9]{1,3}\.?){4}"| sed -E 's/\=$//g'`)
if [ ! -f $DIR/42Kmi ] ; then mkdir -p $DIR/42Kmi ; fi
if [ ! -f $DIR/42Kmi/options_$CONSOLENAME.txt ] ; then echo -e "$CONSOLENAME=$GETSTATIC\nPINGLIMIT=90\nCOUNT=5\nSIZE=1024\nMODE=1\nMAXTTL=10\nPROBES=5\nTRACELIMIT=30\nACTION=REJECT\nCHECKPACKETLOSS=OFF\nPACKETLOSSLIMIT=80\nSWITCH=ON\n;" > $DIR/42Kmi/options_$CONSOLENAME.txt; fi ### Makes options file if it doesn't exist
##### Make Files #####
CONSOLE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 1p | sed -E 's/^.*=//g') ### Your Wii U's IP address. Change this in the $CONSOLENAMEip.txt file
LIMIT=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 2p | sed -E 's/^.*=//g') ### Your max average millisecond limit. Peers pinging higher than this value are blocked. Default is 3.
COUNT=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 3p | sed -E 's/^.*=//g') ### How many packets to send. Default is 5
SIZE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 4p | sed -E 's/^.*=//g') ### Size of packets. Default is 1024
MODE=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 5p | sed -E 's/^.*=//g')
ROUTER=$(nvram get lan_ipaddr | grep -Eo '(([0-9]{1,3}\.?){4})')
ROUTERSHORT=$(nvram get lan_ipaddr | grep -Eo '(([0-9]{1,3}\.?){3})' | sed -E 's/\./\\./g' | sed -n 1p)
WANSHORT=$(nvram get wan_ipaddr | grep -Eo '(([0-9]{1,3}\.?){4})' | sed -E 's/\./\\./g' | sed -n 1p)
FILTERIP=$(echo "^104\.((6[4-9]{1})|(7[0-9]{1})|(8[0-9]{1})|(9[0-9]{1})|(10[0-9]{1})|(11[0-9]{1})|(12[0-7]{1}))| ^13\.((6[4-9]{1})|(7[0-9]{1})|(8[0-9]{1})|(9[0-9]{1})|(10[0-7]{1}))| ^131\.253\.(([2-4]{1}[1-9]{1}))| ^134\.170\.| ^137\.117\.| ^137\.135\.| ^138\.91\.| ^152\.163\.|^157\.((5[4-9]{1})|60)\.|^168\.((6[1-3]{1}))\.|^191\.239\.160\.97|^23\.((3[2-9]{1})|(6[0-7]{1}))\.|^23\.((9[6-9]{1})|(10[0-3]{1}))\.|^2((2[4-9]{1})|(3[0-9]{1}))\.|^40\.((7[4-9]{1})|([8-9]{1}[0-9]{1})|(10[0-9]{1})|(11[0-9]{1})|(12[0-5]{1}))\.|^52\.((8[4-9]{1})|(9[0-5]{1}))\.|^54\.((22[4-9]{1})|(23[0-9]{1}))\.|^54\.((23[0-1]{1}))\.|^64\.86\.|^65\.((5[2-5]{1}))\.|^69\.164.\(([0-9]{1})|([1-5]{1}[0-9]{1})|((6[0-3]{1}))\.
")
RANDOM=$(echo $(echo `dd bs=1 count=1 if=/dev/urandom 2>/dev/null`|hexdump -v -e '/1 "%02X"'|sed -e s/"0A$"//g)) #Generates random interger between 0-FF
IGNORE=$(echo $({ if { { iptables -nL LDACCEPT && iptables -nL LDREJECT; } | grep -Eoq "([0-9]{1,3}\.?){4}"; } then echo "$({ iptables -nL LDACCEPT && iptables -nL LDREJECT; } | grep -Eo "([0-9]{1,3}\.?){4}" | awk '!a[$0]++' |grep -v "${CONSOLE}"| sed -E 's/^/\^/g' | sed 's/\./\\\./g')"|sed -E 's/$/\|/g'; else echo "${ROUTER}"; fi; })|sed -E 's/\|$//g'|sed -E 's/\ //g')
if [ ! -f $DIR/42Kmi/extraip.txt ] ; then
PEERIP=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack | grep "${CONSOLE}" | grep -Eo '(([0-9]{1,3}\.?){4})' | grep -o '^.*\..*$' | grep -v "${CONSOLE}" | grep -v "${ROUTER}" |grep -Ev "${IGNORE}"| grep -Ev "^192\.168\.(([0-9]{1,3}\.?){2})" | grep -Ev "^$ROUTERSHORT" | grep -Ev "^$WANSHORT" | egrep -Ev "$FILTERIP" | awk '!a[$0]++' | sed -n 1p ) ### Get Wii U Peer's IP
else
EXTRAIP=$(echo $(while read -r i; do echo "${i%}"; done < /jffs/42Kmi/extraip.txt|sed -E "s/^/\^/g"|sed -E "s/\^#|\^$//g"|sed -E "s/\^\^/^/g"|sed -E "/(^#.*#$|^$|^\;$|#^[ \t]*$)|#/d"|sed -E "s/$/|/g")|sed -E 's/\|$//g'|sed -E "s/(\ *)//g"|sed -E 's/\b\.\b/\\./g') ### Additional IPs to filter out. Make extraip.txt in 42Kmi folder, add IPs there. Can now support extra lines and titles. See README
PEERIP=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack | grep "${CONSOLE}" | grep -Eo '(([0-9]{1,3}\.?){4})' | grep -o '^.*\..*$' | grep -v "${CONSOLE}" | grep -v "${ROUTER}" |grep -Ev "${IGNORE}"| grep -Ev "^192\.168\.(([0-9]{1,3}\.?){2})" | grep -Ev "^$ROUTERSHORT" | grep -Ev "^$WANSHORT" | egrep -Ev "$FILTERIP" | egrep -Ev "$EXTRAIP" | awk '!a[$0]++' | sed -n 1p ) ### Get Wii U Peer's IP
fi
if [ "${MODE}" = 2 ]; then :;
else
PINGRESULT=$({ if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else ping -q -c "${COUNT}" -W 1 -s "${SIZE}" -p "${RANDOM}" "${PEERIP}" | grep -F "round-trip" | sed -E 's/^.*([0-9]{1,9}\.[0-9]{3}\/){1}//g' | sed -E "s/\..*ms//g"; &> /dev/null; fi; } &) ### Get PINGRESULT from ping
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
TRGET=$(if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else echo $(traceroute -m "${TTL}" -q "${PROBES}" -w 1 "${PEERIP}" "${SIZE}"|grep -Eo "([0-9]{1,9}\.[0-9]{3}\ ms)"|sed -E 's/(time=|\..*$)//g'|sed -E 's/$/ +/g'); fi)
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

##### Ping Packet Loss Block #####
CHECKPACKETLOSS=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 10p | sed -E 's/^.*=//g')
if [ "${CHECKPACKETLOSS}" = 1 ] || [ "${CHECKPACKETLOSS}" = ON ] || [ "${CHECKPACKETLOSS}" = on ] || [ "${CHECKPACKETLOSS}" = YES ] || [ "${CHECKPACKETLOSS}" = yes ]; then
PACKETLOSSLIMIT=$(while read -r i; do echo "${i%}"; done < /$DIR/42Kmi/options_$CONSOLENAME.txt | sed -n 11p | sed -E 's/^.*=//g')
PINGPACKETLOSS=$({ if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else ping -q -c "${COUNT}" -W 1 -s "${SIZE}" -p "${RANDOM}" "${PEERIP}" | grep -Eo "[0-9]{1,3}\% packet loss" | sed -E "s/%.*$//g"; &> /dev/null; fi; } &) ### Packet Loss
PACKETBLOCK=$({ if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else { if [ "${PINGPACKETLOSS}" -gt "${PACKETLOSSLIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; fi; } fi; } &)# Block if PacketLoss, Overrides other options only
else :; # Packet Loss Check is disabled for the else condition.
fi
##### Ping Packet Loss Block #####

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

rm -f ${LOCKFILE}
##########
} &

if [ "${SWITCH}" = 0 ] || [ "${SWITCH}" = OFF ] || [ "${SWITCH}" = off ]; then exit && $LOOP;
else {
lagdropexecute ()
{ #LagDrop loops within here. It's cool, yo.
{
if { ping -q -c 1 -W 1 -s 1 "${CONSOLE}" | grep -q -F -w "100% packet loss" ;} &> /dev/null; then :; else
lagdropexecute
{ while ping -q -c 1 -W 1 "${CONSOLE}" | grep -q -F -w "100% packet loss"; do :; done ;} &> /dev/null; wait
while sleep :; do 
#if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else ${BLOCK}; wait &> /dev/null; fi
if { iptables -nL| grep -Foq "$PEERIP"; }; then :; else ${PACKETBLOCK} && ${BLOCK}; wait &> /dev/null; fi
 
 done
fi

lagdropexecute
} &> /dev/null
} &> /dev/null
} fi
##### Ban SLOW Peers #####
##### 42Kmi International Competitive Gaming #####
##### Visit 42Kmi.com #####
##### Shop @ 42Kmi.com/store #####
##### Shirts @ 42Kmi.com/swag.htm #####