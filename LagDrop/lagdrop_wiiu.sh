#!/bin/sh
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
##### Ver 2.0.2
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
if iptables -L LDACCEPT && iptables -L LDREJECT; then :; else eval "iptables -F FORWARD"; fi
if { iptables -L FORWARD| grep -Eoq "^LDACCEPT.*anywhere"; }; then eval "#LDACCEPT already exists"; else iptables -N LDACCEPT; iptables -P LDACCEPT ACCEPT; iptables -t filter -A FORWARD -j LDACCEPT; fi
if { iptables -L FORWARD| grep -Eoq "^LDREJECT.*anywhere"; }; then eval "#LDREJECT already exists"; else iptables -N LDREJECT; iptables -P LDREJECT DROP; iptables -t filter -A FORWARD -j LDREJECT; fi
##### Prepare LagDrop's IPTABLES Chains #####

##### Make Files #####
CONSOLENAME=wiiu
SCRIPTNAME=$(echo "${0##*/}")
kill -9 $(ps -w | grep -v $$ | grep -F "$SCRIPTNAME") &> /dev/null
DIR=$(echo $0 | sed -E "s/\/$SCRIPTNAME//g")
SETTINGS=$(while read -r i; do echo "${i%}"; done < "$DIR"/42Kmi/options_$CONSOLENAME.txt) #Settings stored here, called from memory

##### Fix whitelist.txt & blacklist.txt #####
if [ -f $"{DIR}"/42Kmi/whitelist.txt ]
then
	if (tail -n 1 $"{DIR}"/42Kmi/whitelist.txt | grep -E "^;?$") ;
	then :; 
	else echo -en "\n;" >> $"{DIR}"/42Kmi/whitelist.txt;
	fi; &> /dev/null
else :;
fi

if [ -f $"{DIR}"/42Kmi/blacklist.txt ]
then
	if (tail -n 1 $"{DIR}"/42Kmi/blacklist.txt | grep -E "^;?$") ;
	then :; 
	else echo -en "\n;" >> $"{DIR}"/42Kmi/blacklist.txt;
	fi; &> /dev/null
else :;
fi
##### Fix whitelist.txt & blacklist.txt #####
SWITCH=$(echo "$SETTINGS"| tail -1 | sed -E 's/^.*=//g') ### Enable (1)/Disable(0) LagDrop
if [ "${SWITCH}" = 0 ] || [ "${SWITCH}" = OFF ] || [ "${SWITCH}" = off ]; then :;
else
{
GETSTATIC=$(echo $(nvram get static_leases|sed -E 's/= /\n/g'|sed -E 's/((([a-z]|[A-Z]|[0-9]){2})\:?){6}=//g' | grep -i "$CONSOLENAME" | grep -Eo "([0-9]{1,3}\.?){4}"))
if [ ! -f "$DIR"/42Kmi ] ; then mkdir -p "$DIR"/42Kmi ; fi
if [ ! -f "$DIR"/42Kmi/options_$CONSOLENAME.txt ] ; then echo -e "$CONSOLENAME=$GETSTATIC\nPINGLIMIT=90\nCOUNT=5\nSIZE=1024\nMODE=1\nMAXTTL=10\nPROBES=5\nTRACELIMIT=30\nACTION=REJECT\nCHECKPACKETLOSS=OFF\nPACKETLOSSLIMIT=80\nSENTINEL=OFF\nCLEARALLOWED=OFF\nCLEARBLOCKED=OFF\nCLEARLIMIT=10\nSWITCH=ON\n;" > "$DIR"/42Kmi/options_$CONSOLENAME.txt; fi ### Makes options file if it doesn't exist
##### Make Files #####
CONSOLE=$(echo "$SETTINGS"| sed -n 1p | sed -E 's/^.*=//g') ### Your Wii U's IP address. Change this in the $CONSOLENAMEip.txt file
IPCONNECT=$(while read -r i; do echo "${i%}"; done < /proc/net/ip_conntrack|grep "$CONSOLE") ### IP connections stored here, called from memory
LIMIT=$(echo "$SETTINGS"| sed -n 2p | sed -E 's/^.*=//g') ### Your max average millisecond limit. Peers pinging higher than this value are blocked. Default is 3.
COUNT=$(echo "$SETTINGS"| sed -n 3p | sed -E 's/^.*=//g') ### How many packets to send. Default is 5
SIZE=$(echo "$SETTINGS"| sed -n 4p | sed -E 's/^.*=//g') ### Size of packets. Default is 1024
MODE=$(echo "$SETTINGS"| sed -n 5p | sed -E 's/^.*=//g') ### 0 or 1=Ping, 2=TraceRoute, 3=Ping or TraceRoute, 4=Ping & TraceRoute. Default is 1.
ROUTER=$(nvram get lan_ipaddr | grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})")
ROUTERSHORT=$(nvram get lan_ipaddr | grep -Eo '(([0-9]{1,3}\.?){3})' | sed -E 's/\./\\./g' | sed -n 1p)
WANSHORT=$(nvram get wan_ipaddr | grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})" | sed -E 's/\./\\./g' | sed -n 1p)
FILTERIP=$(echo "^7\.211\.140\.65|^10\.^23\.47\.27\.27|^23\.52\.155\.27|^23\.54\.216\.193|^23\.66\.165\.91|^23\.66\.176\.43|^23\.67\.251\.26|^23\.76\.127\.188|^23\.196\.120\.223|^23\.203\.39\.241|^23\.203\.139\.135|^23\.208\.59\.171|^23\.208\.106\.4|^23\.218\.43\.42|^23\.218\.127\.182|^23\.222\.72\.202|^50\.16\.222\.244|^52\.4\.150\.153|^52\.6\.111\.246|^52\.7\.215\.194|^52\.10\.208\.5|^52\.10\.214\.117|^52\.11\.87\.11|^52\.23\.114\.119|^52\.23\.140\.61|^52\.27\.43\.90|^52\.34\.243\.80|^52\.69\.129\.190|^52\.69\.208\.20|^52\.71\.185\.4|^52\.193\.76\.83|^52\.193\.78\.159|^52\.193\.88\.72|^52\.193\.92\.33|^52\.193\.114\.246|^52\.196\.253\.128|^52\.197\.113\.56|^52\.197\.152\.173|^54\.68\.210\.71|^54\.69\.205\.82|^54\.149\.91\.11|^54\.174\.216\.110|^54\.174\.217\.31|^54\.200\.128\.254|^54\.221\.210\.227|^54\.231\.17\.161|^54\.231\.98\.112|^54\.240\.160\.(40|133)|^54\.240\.190\.100|^72\.21\.91\.(29|82)|^104\.15\.41\.223|^104\.64\.18\.174|^104\.68\.140\.25|^104\.70\.53\.133|^104\.85\.97\.161|^104\.85\.154\.179|^107\.21\.32\.93|^173\.194\.206\.(95|156|157)|^173\.223\.239\.182|^174\.103\.130\.105|^184\.73\.207\.189|^185\.53\.179\.29|^187\.190\.152\.252|^202\.32\.117\.14(2|3)|^202\.232\.239\.25|^203\.180\.85\.([7-8][0-9])|^209\.15\.13\.141|^209\.67\.106\.141|^216\.58\.195\.(13[1-2]|142)|^216\.146\.46\.10|^38\.112\.28\.9[6-9]|^60\.32\.179\.(1[6-9]|2[0-3])|^60\.36\.183\.15[2-9]|^64\.124\.44\.(4[8-9]|5[0-5])|^64\.125\.103\.|^65\.166\.10\.(10[4-9]|11[0-1])|^84\.37\.20\.(20[8-9]|21[0-5)|^84\.233\.128\.(6[4-9]|[7-9][0-9]|1[0-1][0-9]|12[0-7])|^84\.233\.202\.([0-9]|[1-2][0-9]|3[0-1])|^89\.202\.218\.([0-9]|1[0-5])|^125\.196\.255\.(19[6-9]|20[0-7])|^125\.199\.254\.(4[8-9]|5[0-9]|6[0-7])|^125\.206\.241\.(17[6-9]|18[0-9]|19[0-1])|^133\.205\.103\.(19[2-9]|20[0-7])|^192\.195\.204\.|^194\.121\.124\.(22[4-9]|23[0-1])|^194\.176\.154\.(16[8-9]|17[0-5])|^195\.10\.13\.(1[6-9]|[2-5][0-9]|6[0-3]|7[2-5])|^195\.27\.92\.(9[6-9]|1[0-1][0-9]|12[0-7]|19[2-9]|20[0-7])|^195\.27\.195\.([0-9]|1[0-5])|^195\.73\.250\.(22[4-9]|23[0-1])|^195\.243\.236\.(13[6-9]|14[0-3])|^202\.232\.234\.(12[8-9]|13[0-9]|14[0-3])|^205\.166\.76\.|^206\.19\.110\.|^207\.38\.([8-9]|1[0-5])|^208\.186\.152\.|^210\.88\.88\.(17[6-9]|18[0-9]|19[0-1])|^210\.138\.40\.(2[4-9]|3[0-1])|^210\.151\.57\.(8[0-9]|9[0-5])|^210\.169\.213\.(3[2-9]|[4-5][0-9]|6[0-3])|^210\.172\.105\.(1[6-8][0-9]|19[0-1])|^210\.233\.54\.(3[2-9]|4[0-7])|^211\.8\.190\.(19[2-9]|2[0-1][0-9]|22[0-3])|^212\.100\.231\.6[0-1]|^213\.69\.144\.(1[6-8][0-9]|19[0-1])|^217\.161\.8\.(2[4-7])|^219\.96\.82\.(17[6-9]|18[0-9]|19[0-1])|^220\.109\.217\.(16[0-7])|^104\.112\.251\.170|^104\.94\.217\.78|^198\.62\.122\.|^23\.43\.162\.5|^52\.193\.60\.252|^52\.196\.212\.20|^52\.196\.253\.128|^52\.197\.113\.56|^52\.197\.152\.173|^52\.23\.140\.61|^52\.36\.149\.192|^54\.209\.134\.35|^54\.225\.175\.227|^54\.230\.204\.(161|199)|^54\.243\.240\.77|^54\.86\.140\.46|^174\.129\.219\.182|^52\.219\.4\.17|^69\.25\.139\.(12[8-9]|1[3-9][0-9]|2[0-4][0-9]|22[0-5])|^209\.67\.106\.(12[8-9]|1[3-9][0-9]|2[0-4][0-9]|22[0-5])|^107\.211\.140\.65")
#FILTERIP=$(echo "^99999") #Debug
RANDOM=$(echo $(echo $(dd bs=1 count=1 if=/dev/urandom 2>/dev/null)|hexdump -v -e '/1 "%02X"'|sed -e s/"0A$"//g)) #Generates random value between 0-FF
IGNORE=$(echo $({ if { { iptables -nL LDACCEPT && iptables -nL LDREJECT ; } | grep -Eoq "([0-9]{1,3}\.?){4}"; } then echo "$({ iptables -nL LDACCEPT && iptables -nL LDREJECT ; } | grep -Eo "([0-9]{1,3}\.?){4}" | awk '!a[$0]++' |grep -v "${CONSOLE}"|grep -v "127.0.0.1"| sed -E 's/^/\^/g' | sed 's/\./\\\./g')"|sed -E 's/$/\|/g'; else echo "${ROUTER}"; fi; })|sed -E 's/\|$//g'|sed -E 's/\ //g')
if [ ! -f "$DIR"/42Kmi/whitelist.txt ] ; then
PEERIP=$(echo "$IPCONNECT"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d" | grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})" | grep -o '^.*\..*$' | grep -v "${CONSOLE}" | grep -v "${ROUTER}" |grep -Ev "${IGNORE}"| grep -Ev "^192\.168\.(([0-9]{1,3}\.?){2})" | grep -Ev "^$ROUTERSHORT" | grep -Ev "^$WANSHORT" | egrep -Ev "$FILTERIP" | awk '!a[$0]++' | sed -n 1p ) ### Get Wii U Peer's IP
else
WHITELIST=$(echo "$(while read -r i; do echo "${i%}"; done < "${DIR}"/42Kmi/whitelist.txt|sed -E "s/^/\^/g"|sed -E "s/\^#|\^$//g"|sed -E "s/\^\^/^/g"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E "s/$/|/g")"|sed -E 's/\|$//g'|sed -E "s/(\ *)//g"|sed -E 's/\b\.\b/\\./g') ### Additional IPs to filter out. Make whitelist.txt in 42Kmi folder, add IPs there. Can now support extra lines and titles. See README
PEERIP=$(echo "$IPCONNECT"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d" | grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})" | grep -o '^.*\..*$' | grep -v "${CONSOLE}" | grep -v "${ROUTER}" |grep -Ev "${IGNORE}"| grep -Ev "^192\.168\.(([0-9]{1,3}\.?){2})" | grep -Ev "^$ROUTERSHORT" | grep -Ev "^$WANSHORT" | egrep -Ev "$FILTERIP" | egrep -Ev "$WHITELIST" | awk '!a[$0]++' | sed -n 1p ) ### Get Wii U Peer's IP
fi
EXISTS=$({ iptables -nL LDACCEPT && iptables -nL LDREJECT ;}| grep -Foq "$PEERIP")
##### The Ping #####
if { "$EXISTS"; }; then :;
else
PING=$(ping -q -c "${COUNT}" -W 1 -s "${SIZE}" -p "${RANDOM}" "${PEERIP}" &) ### Ping time and Packet Loss info stored here, called from memory.
fi
##### The Ping #####
if [ "${MODE}" = 2 ]; then :;
else
PINGRESULT=$({ if { "$EXISTS"; }; then :; else echo "$PING" | grep -Eo "round-trip.*" |grep -Eo "\/([0-9]{1,})\.([0-9]{3})\/"|sed "s/\///g"|sed -E 's/\.([0-9]{3})//g'| sed -E "s/\..*ms//g"; &> /dev/null; fi; } &) ### Get PINGRESULT from ping
fi
MODE=$(echo "$SETTINGS"| sed -n 5p | sed -E 's/^.*=//g')
if [ "${MODE}" != 2 ] && [ "${MODE}" != 3 ] && [ "${MODE}" != 4 ]; then :;
else
##### TRACEROUTE #####
##### PARAMETERS #####
MAXTTL=$(echo "$SETTINGS"| sed -n 6p | sed -E 's/^.*=//g')
TTL=$(if [ "${MAXTTL}" -le 255 ] && [ "${MAXTTL}" -ge 1 ]; then echo "$MAXTTL"; else echo 10; fi)
PROBES=$(echo "$SETTINGS"| sed -n 7p | sed -E 's/^.*=//g')
TRACELIMIT=$(echo "$SETTINGS"| sed -n 8p | sed -E 's/^.*=//g')
##### PARAMETERS #####
MXP=$(echo $(( TTL * PROBES )))
TRGET=$(if { "$EXISTS"; }; then :; else echo $(traceroute -m "${TTL}" -q "${PROBES}" -w 1 "${PEERIP}" "${SIZE}"|grep -Eo "([0-9]{1,9}\.[0-9]{3}\ ms)"|sed -E 's/(time=|\..*$)//g'|sed -E 's/$/ +/g'); fi)
TRCOUNT=$(echo "$TRGET" | grep -o " +" | wc -l) #Counts for average
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
ACTION=$(echo "$SETTINGS"| sed -n 9p | sed -E 's/^.*=//g') ### DROP (1)/REJECT(0) 
ACTION1=$(if [ "${ACTION}" = 1 ] || [ "${ACTION}" = drop ] || [ "${ACTION}" = DROP ]; then echo "DROP"; else echo "REJECT"; fi)
##### ACTION of IP Rule #####

##### BLACKLIST #####
if [ ! -f "$DIR"/42Kmi/whitelist.txt ] ; then :;
else
RECENT=$(iptables -nL LDACCEPT| tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
BLACKLIST=$(echo "$(while read -r i; do echo "${i%}"; done < "${DIR}"/42Kmi/blacklist.txt|sed -E "s/^/\^/g"|sed -E "s/\^#|\^$//g"|sed -E "s/\^\^/^/g"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E "s/$/|/g")"|sed -E 's/\|$//g'|sed -E "s/(\ *)//g"|sed -E 's/\b\.\b/\\./g') ### Permananent ban. If encountered, automatically blocked.
	if { echo "${PEERIP}"  | grep -E "${BLACKLIST}"; }; then eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; fi
	if { echo "${RECENT}"  | grep -E "${BLACKLIST}"; }; then eval "iptables -I LDREJECT -s $CONSOLE -d $RECENT -j $ACTION1;"; fi
fi
##### BLACKLIST #####

##### Ping Packet Loss Block #####
PACKETLOSSLIMIT=$(echo "$SETTINGS"| sed -n 11p | sed -E 's/^.*=//g')
CHECKPACKETLOSS=$(echo "$SETTINGS"| sed -n 10p | sed -E 's/^.*=//g')
if [ "${CHECKPACKETLOSS}" = 1 ] || [ "${CHECKPACKETLOSS}" = ON ] || [ "${CHECKPACKETLOSS}" = on ] || [ "${CHECKPACKETLOSS}" = YES ] || [ "${CHECKPACKETLOSS}" = yes ]; then
	if { "$EXISTS"; }; then :;
	else
	PINGPACKETLOSS=$({ if { "$EXISTS"; }; then :; else echo "$PING" | grep -Eo "[0-9]{1,3}\% packet loss" | sed -E "s/%.*$//g"; &> /dev/null; fi; } &) ### Packet Loss
	PACKETBLOCK=$({ if { "$EXISTS"; }; then :; else { if [ "${PINGPACKETLOSS}" -gt "${PACKETLOSSLIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; fi; } fi; } &)# Block if PacketLoss, Overrides other options only
	fi
fi
##### Ping Packet Loss Block #####
if [ "$(iptables -L LDREJECT| grep "${PEERIP}")" = 0 ]; then :;
else
##### BLOCK ##### // 0 or 1=Ping, 2=TraceRoute, 3=Ping or TraceRoute, 4=Ping & TraceRoute
if [ "${MODE}" != 2 ] && [ "${MODE}" != 3 ] && [ "${MODE}" != 4 ]; then
BLOCK=$({ if { { iptables -nL LDACCEPT && iptables -nL LDREJECT ;}| grep -Foq "$PEERIP"; }; then :; else { if [ "${PINGRESULT}" -gt "${LIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &)# Ping only
else
	if [ "${MODE}" = 2 ]; then
	BLOCK=$({ if { { iptables -nL LDACCEPT && iptables -nL LDREJECT ;}| grep -Foq "$PEERIP"; }; then :; else { if [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &)#TraceRoute only
	else
		if [ "${MODE}" = 3 ]; then
		BLOCK=$({ if { { iptables -nL LDACCEPT && iptables -nL LDREJECT ;}| grep -Foq "$PEERIP"; }; then :; else { if [ "${PINGRESULT}" -gt "${LIMIT}" ] || [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &) #Ping OR TraceRoute
		else
				if [ "${MODE}" = 4 ]; then
				BLOCK=$({ if { { iptables -nL LDACCEPT && iptables -nL LDREJECT ;}| grep -Foq "$PEERIP"; }; then :; else { if [ "${PINGRESULT}" -gt "${LIMIT}" ] && [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1;"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; } fi; } fi; } &) #Ping AND TraceRoute
				fi
		fi
	fi
fi
fi
##### Can't be in both #####
if { iptables -L LDREJECT|grep "$PEERIP"; } && { iptables -L LDACCEPT|grep "$PEERIP"; }; then eval "iptables -D LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; fi
##### Can't be in both #####
##### BLOCK #####

##### SENTINEL Modulus #####
SENTINEL=$(echo "$SETTINGS"| sed -n 12p | sed -E 's/^.*=//g') #Testing of allowed peers for packet loss
if [ "${SENTINEL}" = 1 ] || [ "${SENTINEL}" = ON ] || [ "${SENTINEL}" = on ] || [ "${SENTINEL}" = YES ] || [ "${SENTINEL}" = yes ] || [ "${SENTINEL}" = ENABLE ] || [ "${SENTINEL}" = enable ];
then
	if [ "$(iptables -nL LDREJECT|grep -Eo "$RECENT")" ]; then :;
	else
	#Repeats pactketloss test of most recent allowed peer
	RECENT=$(iptables -nL LDACCEPT| tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
	RECENTSOURCE=$(iptables -nL LDACCEPT| tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 2p)
	LASTRULE=$(iptables --line-number -nL LDACCEPT|tail -1|grep -Eo "^[0-9]{1,}")
	CHECKUP=$(ping -q -c 30 -W 1 -s 1 -p "${RANDOM}" "${RECENT}"|grep -Eo "[0-9]{1,3}\% packet loss" | sed -E "s/%.*$//g" &)
		if echo "$IPCONNECT"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d" |grep -o "$RECENT"|grep -Eo "([0-9]{1,3}\.?){4}"
		then 
			if [ "${CHECKUP}" -gt "${PACKETLOSSLIMIT}" ]; then { eval "iptables -I LDREJECT -s $RECENTSOURCE -d $RECENT -j $ACTION1; iptables -D LDACCEPT $LASTRULE; iptables -D LDACCEPT -d $RECENTSOURCE -s $RECENT -j $ACTION1"; }; fi;
		else :;
		fi	
	fi
else :;

fi
##### SENTINEL Modulus #####

##### Clear Old #####
CLEARLIMIT=$(echo "$SETTINGS"| sed -n 15p | sed -E 's/^.*=//g')
#Allow
CLEARALLOWED=$(echo "$SETTINGS"| sed -n 13p | sed -E 's/^.*=//g')
if [ "${CLEARALLOWED}" = 1 ] || [ "${CLEARALLOWED}" = ON ] || [ "${CLEARALLOWED}" = on ] || [ "${CLEARALLOWED}" = YES ] || [ "${CLEARALLOWED}" = yes ] || [ "${CLEARALLOWED}" = ENABLE ] || [ "${CLEARALLOWED}" = enable ];
then
	COUNTALLOW=$(iptables -L LDACCEPT|grep -Ec "^ACCEPT")
	TOPALLOW=$(iptables -nL LDACCEPT|grep -E "^ACCEPT"|sed "s/${CONSOLE}//g"|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
	if [ "${COUNTALLOW}" -ge "${CLEARLIMIT}" ];
	then
		if echo "$IPCONNECT"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d" | grep -q "${CONSOLE}"| grep -oq "$TOPALLOW"; then :;
		else eval "iptables -D LDACCEPT 1;"
		fi
	else :;
	fi
else :;
fi
#Blocked
CLEARBLOCKED=$(echo "$SETTINGS"| sed -n 14p | sed -E 's/^.*=//g')
if [ "${CLEARBLOCKED}" = 1 ] || [ "${CLEARBLOCKED}" = ON ] || [ "${CLEARBLOCKED}" = on ] || [ "${CLEARBLOCKED}" = YES ] || [ "${CLEARBLOCKED}" = yes ] || [ "${CLEARBLOCKED}" = ENABLE ] || [ "${CLEARBLOCKED}" = enable ];
then
	COUNTBLOCKED=$(iptables -L LDREJECT|grep -Ec "^(DROP|REJECT)")
	BOTTOMBLOCKED=$(iptables -nL LDREJECT|tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 2p)
	OLDBLOCK=$(iptables --line-number -nL LDREJECT|tail -1|grep -Eo "^[0-9]{1,}")
	if [ "${COUNTBLOCKED}" -ge "${CLEARLIMIT}" ];
	then
		if echo "$IPCONNECT"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d" | grep -q "${CONSOLE}"| grep -oq "$BOTTOMBLOCKED"; then :;
		else eval "iptables -D LDREJECT $OLDBLOCK;"
		fi
	else :;	
	fi
else :;
fi
##### Clear Old #####
##### Can't be in both #####
if { iptables -L LDREJECT|grep "$PEERIP"; } && { iptables -L LDACCEPT|grep "$PEERIP"; }; then eval "iptables -D LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT"; fi
##### Can't be in both #####
}
fi
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
if { "$EXISTS"; }; then :; else ${PACKETBLOCK} && ${BLOCK}; wait &> /dev/null; fi
 
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