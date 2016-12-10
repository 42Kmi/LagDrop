#!/bin/sh
export LC_ALL=C
trap "$0" EXIT INT TERM
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
##### Ver 2.0.5
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
##### Don't Be Racist #####
##### Ban SLOW Peers #####

##### Prepare LagDrop's IPTABLES Chains #####
if { iptables -L LDACCEPT && iptables -L LDREJECT; } then :; else eval "iptables -F FORWARD"; fi &> /dev/null
if { iptables -L FORWARD|grep -Eoq "^LDACCEPT.*anywhere"; }; then eval "#LDACCEPT already exists"; else iptables -N LDACCEPT; iptables -P LDACCEPT ACCEPT; iptables -t filter -A FORWARD -j LDACCEPT; fi &> /dev/null
if { iptables -L FORWARD|grep -Eoq "^LDREJECT.*anywhere"; }; then eval "#LDREJECT already exists"; else iptables -N LDREJECT; iptables -P LDREJECT DROP; iptables -t filter -A FORWARD -j LDREJECT; fi &> /dev/null
##### Prepare LagDrop's IPTABLES Chains #####

##### Make Files #####
CONSOLENAME=CONSOLE_NAME_HERE
SCRIPTNAME=$(echo "${0##*/}")
kill -9 $(ps -w|grep -v $$|grep -F "$SCRIPTNAME") &> /dev/null
DIR=$(echo $0|sed -E "s/\/$SCRIPTNAME//g")
SETTINGS=$(tail +1 "$DIR"/42Kmi/options_"$CONSOLENAME".txt|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E 's/^.*=//g') #Settings stored here, called from memory
if "$DIR"/lagdrop_"$SUFFIX".sh; then :; else
SWITCH=$(echo "$SETTINGS"|tail -1) ### Enable (1)/Disable(0) LagDrop
if [ "${SWITCH}" = 0 ] || [ "${SWITCH}" = OFF ] || [ "${SWITCH}" = off ]; then :;
else
{
GETSTATIC=$(echo $(nvram get static_leases|sed -E 's/= /\n/g'|sed -E 's/((([a-z]|[A-Z]|[0-9]){2})\:?){6}=//g'|grep -i "$CONSOLENAME"|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p))
if [ ! -f "$DIR"/42Kmi ] ; then mkdir -p "$DIR"/42Kmi ; fi
if [ ! -f "$DIR"/42Kmi/options_$CONSOLENAME.txt ] ; then echo -e "$CONSOLENAME=$GETSTATIC\nPINGLIMIT=90\nCOUNT=5\nSIZE=1024\nMODE=1\nMAXTTL=10\nPROBES=5\nTRACELIMIT=30\nACTION=REJECT\nCHECKPACKETLOSS=OFF\nPACKETLOSSLIMIT=80\nSENTINEL=OFF\nCLEARALLOWED=OFF\nCLEARBLOCKED=OFF\nCLEARLIMIT=10\nCHECKPORTS=NO\nPORTS=\nSWITCH=ON\n;" > "$DIR"/42Kmi/options_$CONSOLENAME.txt; fi ### Makes options file if it doesn't exist
##### Make Files #####
CONSOLE=$(echo "$SETTINGS"|sed -n 1p) ### Your Wii U's IP address. Change this in the $CONSOLENAMEip.txt file
CHECKPORTS=$(echo "$SETTINGS"|sed -n 16p)
PORTS=$(echo "$SETTINGS"|sed -n 17p)
##### Check Ports #####
if [ "${CHECKPORTS}" = 1 ] || [ "${CHECKPORTS}" = ON ] || [ "${CHECKPORTS}" = on ] || [ "${CHECKPORTS}" = YES ] || [ "${CHECKPORTS}" = yes ]; then
IPCONNECT=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack|grep "$CONSOLE" |grep -E "dport\=${PORTS}\b"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d") ### IP connections stored here, called from memory
else
	IPCONNECT=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack|grep "$CONSOLE"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d") ### IP connections stored here, called from memory
fi
##### Check Ports #####
LIMIT=$(echo "$SETTINGS"|sed -n 2p) ### Your max average millisecond limit. Peers pinging higher than this value are blocked. Default is 3.
COUNT=$(echo "$SETTINGS"|sed -n 3p) ### How many packets to send. Default is 5
SIZE=$(echo "$SETTINGS"|sed -n 4p) ### Size of packets. Default is 1024
MODE=$(echo "$SETTINGS"|sed -n 5p) ### 0 or 1=Ping, 2=TraceRoute, 3=Ping or TraceRoute, 4=Ping & TraceRoute. Default is 1.
ROUTER=$(nvram get lan_ipaddr|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})")
ROUTERSHORT=$(nvram get lan_ipaddr|grep -Eo '(([0-9]{1,3}\.?){3})'|sed -E 's/\./\\./g'|sed -n 1p)
WANSHORT=$(nvram get wan_ipaddr|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|sed -E 's/\./\\./g'|sed -n 1p)
#FILTERIP=$(echo "")
FILTERIP=$(echo "^99999") #Debug, Add IPs to whitelist.txt file instead
RANDOM=$(echo $(dd bs=1 count=1 if=/dev/urandom 2>/dev/null)|hexdump -v -e '/1 "%02X"'|sed -e s/"0A$"//g) #Generates random value between 0-FF
IGNORE=$(echo $({ if { { iptables -nL LDACCEPT && iptables -nL LDREJECT ; }|grep -Eoq "([0-9]{1,3}\.?){4}"; } then echo "$({ iptables -nL LDACCEPT && iptables -nL LDREJECT ; }|grep -Eo "([0-9]{1,3}\.?){4}"|awk '!a[$0]++'|grep -v "${CONSOLE}"|grep -v "127.0.0.1"|sed -E 's/^/\^/g'|sed 's/\./\\\./g')"|sed -E 's/$/\|/g'; else echo "${ROUTER}"; fi; })|sed -E 's/\|$//g'|sed -E 's/\ //g')
if [ ! -f "$DIR"/42Kmi/whitelist.txt ] ; then
PEERIP=$(echo "$IPCONNECT"|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|grep -o '^.*\..*$'|grep -v "${CONSOLE}"|grep -v "${ROUTER}"|grep -Ev "${IGNORE}"|grep -Ev "^$ROUTERSHORT"|grep -Ev "^$WANSHORT"|egrep -Ev "$FILTERIP"|awk '!a[$0]++'|sed -n 1p) ### Get Wii U Peer's IP
else
WHITELIST=$(echo $(echo "$(tail +1 "${DIR}"/42Kmi/whitelist.txt|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E "s/^/\^/g"|sed -E "s/\^#|\^$//g"|sed -E "s/\^\^/^/g"|sed -E "s/$/|/g")")|sed -E 's/\|$//g'|sed -E "s/(\ *)//g"|sed -E 's/\b\.\b/\\./g') ### Additional IPs to filter out. Make whitelist.txt in 42Kmi folder, add IPs there. Can now support extra lines and titles. See README
PEERIP=$(echo "$IPCONNECT"|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|grep -o '^.*\..*$'|grep -v "${CONSOLE}"|grep -v "${ROUTER}"|grep -Ev "${IGNORE}"|grep -Ev "^$ROUTERSHORT"|grep -Ev "^$WANSHORT"|egrep -Ev "$FILTERIP"|egrep -Ev "$WHITELIST"|awk '!a[$0]++'|sed -n 1p) ### Get Wii U Peer's IP
fi
EXISTS=$({ iptables -nL LDACCEPT && iptables -nL LDREJECT ;}|grep -Foq "$PEERIP")
CONTRADICTION=$(if { iptables -L LDREJECT|grep "$PEERIP"; } && { iptables -L LDACCEPT|grep "$PEERIP"; }; then eval "iptables -D LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; fi
)
##### The Ping #####
if { "$EXISTS"; }; then :;
else
PING=$(ping -q -c "${COUNT}" -W 1 -s "${SIZE}" -p "${RANDOM}" "${PEERIP}" &) ### Ping time and Packet Loss info stored here, called from memory.
fi
##### The Ping #####
if [ "${MODE}" = 2 ]; then :;
else
PINGRESULT=$({ if { "$EXISTS"; }; then :; else echo "$PING"|grep -Eo "round-trip.*"|grep -Eo "\/([0-9]{1,})\.([0-9]{3})\/"|sed "s/\///g"|sed -E 's/\.([0-9]{3})//g'|sed -E "s/\..*ms//g"; &> /dev/null; fi; } &) ### Get PINGRESULT from ping
fi
MODE=$(echo "$SETTINGS"|sed -n 5p)
if [ "${MODE}" != 2 ] && [ "${MODE}" != 3 ] && [ "${MODE}" != 4 ]; then :;
else
##### TRACEROUTE #####
##### PARAMETERS #####
MAXTTL=$(echo "$SETTINGS"|sed -n 6p)
TTL=$(if [ "${MAXTTL}" -le 255 ] && [ "${MAXTTL}" -ge 1 ]; then echo "$MAXTTL"; else echo 10; fi)
PROBES=$(echo "$SETTINGS"|sed -n 7p)
TRACELIMIT=$(echo "$SETTINGS"|sed -n 8p)
##### PARAMETERS #####
MXP=$(echo $(( TTL * PROBES )))
TRGET=$(if { "$EXISTS"; }; then :; else echo $(traceroute -m "${TTL}" -q "${PROBES}" -w 1 "${PEERIP}" "${SIZE}"|grep -Eo "([0-9]{1,9}\.[0-9]{3}\ ms)"|sed -E 's/(time=|\..*$)//g'|sed -E 's/$/ +/g'); fi)
TRCOUNT=$(echo "$TRGET"|grep -o " +"|wc -l) #Counts for average
TRACEROUTESUM=$(echo "$TRGET"|sed -E 's/\+$//g') #TRACEROUTE values get
TR=$(echo $(( TRACEROUTESUM ))) #TRACEROURTE sum for math
##### TRAVG #####
if [ "${TRCOUNT}" != 0 ]; then
TRAVG=$(echo $(( TR / TRCOUNT ))) #AVERAGE, true average
else
TRAVG=$(echo $(( TR / MXP ))) #AVERAGE, if first fails
fi
##### TRAVG #####
DEV=$(echo $(( TR - TRAVG * TRCOUNT ))) #Difference of SUM minus AVERAGE times MXP
##### TRACEROUTE #####
fi
##### ACTION of IP Rule #####
ACTION=$(echo "$SETTINGS"|sed -n 9p) ### DROP (1)/REJECT(0) 
ACTION1=$(if [ "${ACTION}" = 1 ] || [ "${ACTION}" = drop ] || [ "${ACTION}" = DROP ]; then echo "DROP"; else echo "REJECT"; fi)
##### ACTION of IP Rule #####

##### BLACKLIST #####
if [ ! -f "$DIR"/42Kmi/blacklist.txt ] ; then :;
else
RECENT=$(iptables -nL LDACCEPT|tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
BLACKLIST=$(echo $(echo "$(tail +1 "${DIR}"/42Kmi/blacklist.txt|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E "s/^/\^/g"|sed -E "s/\^#|\^$//g"|sed -E "s/\^\^/^/g"|sed -E "s/$/|/g")")|sed -E 's/\|$//g'|sed -E "s/(\ *)//g"|sed -E 's/\b\.\b/\\./g') ### Permananent ban. If encountered, automatically blocked.

	if { echo "${PEERIP}" |grep -E "${BLACKLIST}"; }; then eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; fi
	if { echo "${RECENT}" |grep -E "${BLACKLIST}"; }; then eval "iptables -I LDREJECT -s $CONSOLE -d $RECENT -j $ACTION1;"; fi
fi
##### BLACKLIST #####

##### Ping Packet Loss Block #####
PACKETLOSSLIMIT=$(echo "$SETTINGS"|sed -n 11p)
CHECKPACKETLOSS=$(echo "$SETTINGS"|sed -n 10p)
if [ "${CHECKPACKETLOSS}" = 1 ] || [ "${CHECKPACKETLOSS}" = ON ] || [ "${CHECKPACKETLOSS}" = on ] || [ "${CHECKPACKETLOSS}" = YES ] || [ "${CHECKPACKETLOSS}" = yes ]; then
	if { "$EXISTS"; }; then :;
	else
	PINGPACKETLOSS=$({ if { "$EXISTS"; }; then :; else echo "$PING"|grep -Eo "[0-9]{1,3}\% packet loss"|sed -E "s/%.*$//g"; &> /dev/null; fi; } &) ### Packet Loss
	PACKETBLOCK=$({ if { "$EXISTS"; }; then :; else { if [ "${PINGPACKETLOSS}" -gt "${PACKETLOSSLIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; fi; } fi; } &)# Block if PacketLoss, Overrides other options only
	fi
fi
##### Ping Packet Loss Block #####
if [ "$(iptables -L LDREJECT|grep "${PEERIP}")" = 0 ]; then :;
else
##### BLOCK ##### // 0 or 1=Ping, 2=TraceRoute, 3=Ping or TraceRoute, 4=Ping & TraceRoute
if [ "${MODE}" != 2 ] && [ "${MODE}" != 3 ] && [ "${MODE}" != 4 ]; then
BLOCK=$({ if "$EXISTS"; then :; else { if [ "${PINGRESULT}" -gt "${LIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &)# Ping only
else
	if [ "${MODE}" = 2 ]; then
	BLOCK=$({ if "$EXISTS"; then :; else { if [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &)#TraceRoute only
	else
		if [ "${MODE}" = 3 ]; then
		BLOCK=$({ if "$EXISTS"; then :; else { if [ "${PINGRESULT}" -gt "${LIMIT}" ] || [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &) #Ping OR TraceRoute
		else
				if [ "${MODE}" = 4 ]; then
				BLOCK=$({ if "$EXISTS"; then :; else { if [ "${PINGRESULT}" -gt "${LIMIT}" ] && [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &) #Ping AND TraceRoute
				fi
		fi
	fi
fi
fi
##### Can't be in both #####
"$CONTRADICTION"
##### Can't be in both #####
##### BLOCK #####

##### SENTINEL Modulus #####
SENTINEL=$(echo "$SETTINGS"|sed -n 12p) #Testing of allowed peers for packet loss
if [ "${SENTINEL}" = 1 ] || [ "${SENTINEL}" = ON ] || [ "${SENTINEL}" = on ] || [ "${SENTINEL}" = YES ] || [ "${SENTINEL}" = yes ] || [ "${SENTINEL}" = ENABLE ] || [ "${SENTINEL}" = enable ];
then
	if [ "$(iptables -nL LDREJECT|grep -Eo "$RECENT")" ]; then :;
	else
	#Repeats pactketloss test of most recent allowed peer
	RECENT=$(iptables -nL LDACCEPT|tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
	RECENTSOURCE=$(iptables -nL LDACCEPT|tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 2p)
	LASTRULE=$(iptables --line-number -nL LDACCEPT|tail -1|grep -Eo "^[0-9]{1,}")
	CHECKUP=$(if echo "$IPCONNECT"|grep -o "$RECENT"; then ping -q -c 17 -W 1 -s 1 -p "${RANDOM}" "${RECENT}"|grep -Eo "[0-9]{1,3}\% packet loss"|sed -E "s/%.*$//g"; fi &)
		if echo "$IPCONNECT"|grep -o "$RECENT"
		then 
			if [ "${CHECKUP}" -gt "${PACKETLOSSLIMIT}" ]; then { eval "iptables -I LDREJECT -s $RECENTSOURCE -d $RECENT -j $ACTION1; iptables -D LDACCEPT $LASTRULE; iptables -D LDACCEPT -d $RECENTSOURCE -s $RECENT -j $ACTION1"; }; fi;
		else :;
		fi	
	fi
else :;

fi
##### SENTINEL Modulus #####

##### Clear Old #####
CLEARLIMIT=$(echo "$SETTINGS"|sed -n 15p)
#Allow
CLEARALLOWED=$(echo "$SETTINGS"|sed -n 13p)
if [ "${CLEARALLOWED}" = 1 ] || [ "${CLEARALLOWED}" = ON ] || [ "${CLEARALLOWED}" = on ] || [ "${CLEARALLOWED}" = YES ] || [ "${CLEARALLOWED}" = yes ] || [ "${CLEARALLOWED}" = ENABLE ] || [ "${CLEARALLOWED}" = enable ];
then
	COUNTALLOW=$(iptables -L LDACCEPT|grep -Ec "^ACCEPT")
	TOPALLOW=$(iptables -nL LDACCEPT|grep -E "^ACCEPT"|sed "s/${CONSOLE}//g"|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
	if [ "${COUNTALLOW}" -ge "${CLEARLIMIT}" ];
	then
		if echo "$IPCONNECT"|grep -q "${CONSOLE}"|grep -oq "$TOPALLOW"; then :;
		else eval "iptables -D LDACCEPT 1;"
		fi
	else :;
	fi
else :;
fi
#Blocked
CLEARBLOCKED=$(echo "$SETTINGS"|sed -n 14p)
if [ "${CLEARBLOCKED}" = 1 ] || [ "${CLEARBLOCKED}" = ON ] || [ "${CLEARBLOCKED}" = on ] || [ "${CLEARBLOCKED}" = YES ] || [ "${CLEARBLOCKED}" = yes ] || [ "${CLEARBLOCKED}" = ENABLE ] || [ "${CLEARBLOCKED}" = enable ];
then
	COUNTBLOCKED=$(iptables -L LDREJECT|grep -Ec "^(DROP|REJECT)")
	BOTTOMBLOCKED=$(iptables -nL LDREJECT|tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 2p)
	OLDBLOCK=$(iptables --line-number -nL LDREJECT|tail -1|grep -Eo "^[0-9]{1,}")
	if [ "${COUNTBLOCKED}" -ge "${CLEARLIMIT}" ];
	then
		if echo "$IPCONNECT"|grep -q "${CONSOLE}"|grep -oq "$BOTTOMBLOCKED"; then :;
		else eval "iptables -D LDREJECT $OLDBLOCK;"
		fi
	else :;	
	fi
else :;
fi
##### Clear Old #####
##### Can't be in both #####
"$CONTRADICTION" 
##### Can't be in both #####
}
fi
KILLOLD=$(kill -9 `ps -w | grep -F "$SCRIPTNAME" | grep -v $$` &> /dev/null)
LOOP=$(exec "$0")

{
##########
LOCKFILE=/tmp/lock.txt
if [ -e ${LOCKFILE} ] && kill -0 $(cat ${LOCKFILE}); then
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
if "$DIR"/lagdrop_"$SUFFIX".sh; then :; else
if [ "${SWITCH}" = 0 ] || [ "${SWITCH}" = OFF ] || [ "${SWITCH}" = off ]; then exit && $KILLOLD;
else {
lagdropexecute ()
{ #LagDrop loops within here. It's cool, yo.
{
if { ping -q -c 1 -W 1 -s 1 "${CONSOLE}"|grep -q -F -w "100% packet loss" ;} &> /dev/null; then :; else
lagdropexecute
{ while ping -q -c 1 -W 1 "${CONSOLE}"|grep -q -F -w "100% packet loss"; do :; done ;} &> /dev/null; wait
while sleep :; do 
if { "$EXISTS"; }; then :; else ${PACKETBLOCK} && ${BLOCK}; wait &> /dev/null; fi
 
 done
fi
$KILLOLD
lagdropexecute
} &> /dev/null
} &> /dev/null
} fi
fi
fi
##### Ban SLOW Peers #####
##### 42Kmi International Competitive Gaming #####
##### Visit 42Kmi.com #####
##### Shop @ 42Kmi.com/store #####
##### Shirts @ 42Kmi.com/swag.htm #####