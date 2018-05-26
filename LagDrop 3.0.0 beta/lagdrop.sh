#!/bin/sh
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
VERSION=$(echo "Ver 3.0.0, #OneForAll")
export LC_ALL=C
trap "$0" EXIT INT TERM
##### Kill if no argument #####
if [ "$1" = "$(echo -n "$1" | grep -oEi "((\ ?){1,}|)")" ]; then
echo "Enter an Argument!! Eg: WIIU, XBOX, PS4, PC, etc."
echo -e "### 42Kmi LagDrop "${VERSION}\ ###"\nRouter-based Anti-Lag Solution for P2P online games.\nSupported arguments load the appropriate filters for the console.\nRunning LagDrop without argument will terminate all instances of the script.\n42Kmi.com | LagDrop.com"
exec $(`ps -w | grep -E ".*lagdrop.*" | grep -vF "ps" |sed -E "s/root.*//g"| grep -oE "[0-9]{1,}"|sed -E "s/^/kill -9 /g"`  &> /dev/null) &> /dev/null
exec $(`ps -w | grep -E ".*lagdrop.*" | grep -vF "ps" |sed -E "s/root.*//g"| grep -oE "[0-9]{1,}"|sed -E "s/^/killall -9 /g"`  &> /dev/null) &> /dev/null
exit
fi
##### Kill if no argument #####

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

##### Demo Mode #####
ENABLEDEMO=0 #If enabled, will activate demo mode, which will delete LagDrop from your router after the set number of days.
if [ "$ENABLEDEMO" = "$(echo -n "$ENABLEDEMO" | grep -oEi "(yes|1|on|enable(d?))")" ]; then
DEMOLIMIT=7
CURRENTDATE=$(date +%s)
#Time Scales, in seconds
#DEMOMINUTE=60
#DEMOHOUR=360
DEMODAY=86400

if [ ! -f "$DIR"/42Kmi/options_"$CONSOLENAME".txt ] ; then echo -e "${CURRENTDATE}" > "$DIR"/42Kmi/lddemo.txt; fi ### Makes demo limit reference file if it doesn't exist
GETLDDEMO=$(tail +1 "$DIR"/42Kmi/lddemo.txt|sed -E "s/#.*$//g"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E 's/^.*=//g'|sed -n 1p) #Settings stored here, called from memory
DEMODIFF=$(( (( GETLDDEMO - CURRENTDATE )) / DEMOMINUTE ))

if [ "${DEMODIFF}" -gt "${DEMOLIMIT}" ] ; then rm -f "$0"; rm -f "$DIR"/"42Kmi/lddemo.txt"; echo "It is done." > "$DIR"/42Kmi/lddemodone.txt; fi
fi
##### Demo Mode ##### 

##### Find Shell #####
SHELLIS=$(if [ -f "/usr/bin/lua" ]; then echo "ash"; else echo "no"; fi)
WAITLOCK=$(if [ "${SHELLIS}" = "ash" ]; then "-w"; else :; fi)
##### Find Shell #####

##### Prepare LagDrop's IPTABLES Chains #####
#if { iptables -L LDACCEPT && iptables -L LDREJECT; } then :; else eval "iptables -F FORWARD"; fi &> /dev/null
#if { iptables -L FORWARD|grep -Eoq "^LDACCEPT.*anywhere"; }; then eval "#LDACCEPT already exists"; else iptables -N LDACCEPT; iptables -P LDACCEPT ACCEPT; iptables -t filter -A FORWARD -j LDACCEPT; fi &> /dev/null
#if { iptables -L FORWARD|grep -Eoq "^LDREJECT.*anywhere"; }; then eval "#LDREJECT already exists"; else iptables -N LDREJECT; iptables -P LDREJECT DROP; iptables -t filter -A FORWARD -j LDREJECT; fi &> /dev/null
#if { iptables -L FORWARD|grep -Eoq "^LDBAN.*anywhere"; }; then eval "#LDBAN already exists"; else iptables -N LDBAN; iptables -P LDBAN DROP; iptables -t filter -A FORWARD -j LDBAN; fi &> /dev/null
if { iptables -L LDACCEPT "${WAITLOCK}" && iptables -L LDREJECT "${WAITLOCK}"; } then :; else eval "iptables -F FORWARD "${WAITLOCK}""; fi &> /dev/null
if { iptables -L FORWARD "${WAITLOCK}"|grep -Eoq "^LDACCEPT.*anywhere"; }; then eval "#LDACCEPT already exists"; else iptables -N LDACCEPT; iptables -P LDACCEPT ACCEPT; iptables -t filter -A FORWARD -j LDACCEPT; fi &> /dev/null
if { iptables -L FORWARD "${WAITLOCK}"|grep -Eoq "^LDREJECT.*anywhere"; }; then eval "#LDREJECT already exists"; else iptables -N LDREJECT; iptables -P LDREJECT DROP; iptables -t filter -A FORWARD -j LDREJECT; fi &> /dev/null
if { iptables -L FORWARD "${WAITLOCK}"|grep -Eoq "^LDBAN.*anywhere"; }; then eval "#LDBAN already exists"; else iptables -N LDBAN; iptables -P LDBAN DROP; iptables -t filter -A FORWARD -j LDBAN; fi &> /dev/null
##### Prepare LagDrop's IPTABLES Chains #####

##### Make Files #####
CONSOLENAME=$(echo "$1")

##### Get Static IP #####
if [ "${SHELLIS}" = "ash" ]; then
#GETSTATIC=$(echo $(uci -P/var/state show |grep -i -A 2 "$CONSOLENAME")|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|sed -n 1p)# for OpenWRT
GETSTATIC=$(echo $(tail +1 "/var/etc/dnsmasq.conf"|grep -i "$CONSOLENAME"|grep -Eo "([0-9]{1,3}\.){3}([0-9]{1,3})")|sed -n 1p)# for OpenWRT
else
GETSTATIC=$(echo $(nvram get static_leases|sed -E 's/= /\n/g'|sed -E 's/((([a-z]|[A-Z]|[0-9]){2})\:?){6}=//g'|grep -i "$CONSOLENAME"|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)) # for DD-WRT
fi
##### Get Static IP #####

SCRIPTNAME=$(echo "${0##*/}")
kill -9 $(ps -w|grep -v $$|grep -F "$SCRIPTNAME") &> /dev/null
DIR=$(echo $0|sed -E "s/\/"$SCRIPTNAME"//g")
if [ ! -d "$DIR"/42Kmi ] ; then mkdir -p "$DIR"/42Kmi ; fi
if [ ! -f "$DIR"/42Kmi/options_"$CONSOLENAME".txt ] ; then echo -e "$CONSOLENAME=$GETSTATIC\nPINGLIMIT=20\nCOUNT=20\nSIZE=2048\nMODE=1\nMAXTTL=20\nPROBES=5\nTRACELIMIT=30\nACTION=REJECT\nCHECKPACKETLOSS=OFF\nPACKETLOSSLIMIT=10\nSENTINEL=OFF\nCLEARALLOWED=OFF\nCLEARBLOCKED=OFF\nCLEARLIMIT=10\nCHECKPORTS=NO\nPORTS=\nRESTONMULTIPLAYER=NO\nNUMBEROFPEERS=\nDECONGEST=OFF\nSWITCH=ON\n;" > "$DIR"/42Kmi/options_"$CONSOLENAME".txt; fi ### Makes options file if it doesn't exist
SETTINGS=$(tail +1 "$DIR"/42Kmi/options_"$CONSOLENAME".txt|sed -E "s/#.*$//g"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E 's/^.*=//g') #Settings stored here, called from memory
##### TWEAKS #####
# create 42Kmi/tweak.txt to edit these values
if [ -f "$DIR"/42Kmi/tweak.txt ] ; then
TWEAKSETTINGS=$(tail +1 "$DIR"/42Kmi/tweak.txt|sed -E "s/#.*$//g"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E 's/^.*=//g') #Settings stored here, called from memory
TWEAKPINGRESOLUTION=$(echo "$TWEAKSETTINGS"|sed -n 1p)
TWEAKTRGETCOUNT=$(echo "$TWEAKSETTINGS"|sed -n 2p)
TWEAKPACKETMODE=$(echo "$TWEAKSETTINGS"|sed -n 3p)
TWEAKPACKETINTERVAL=$(echo "$TWEAKSETTINGS"|sed -n 4p)
TWEAKSENTMODE=$(echo "$TWEAKSETTINGS"|sed -n 5p)
TWEAKSENTLIMIT=$(echo "$TWEAKSETTINGS"|sed -n 6p)
TWEAKSENTRUN=$(echo "$TWEAKSETTINGS"|sed -n 7p)
TWEAKSENTRES=$(echo "$TWEAKSETTINGS"|sed -n 8p)
TWEAKSENTINTERVAL=$(echo "$TWEAKSETTINGS"|sed -n 9p)
TWEAKSENTINELXSQMODE=$(echo "$TWEAKSETTINGS"|sed -n 10p)
fi 
##### TWEAKS #####
SWITCH=$(echo "$SETTINGS"|tail -1) ### Enable (1)/Disable(0) LagDrop
RESTONMULTIPLAYER=$(echo "$SETTINGS"|sed -n 18p)
if [ "$SWITCH" = "$(echo -n "$SWITCH" | grep -oEi "(off|0|disable(d?))")" ]; then :; 
else
{
##### Make Files #####
CONSOLE=$(echo "$SETTINGS"|sed -n 1p) ### Your console's IP address. Change this in the options.txt file
CHECKPORTS=$(echo "$SETTINGS"|sed -n 16p)
PORTS=$(echo "$SETTINGS"|sed -n 17p)
##### Check Ports #####
{
IPCON=$(if [ "${SHELLIS}" = "ash" ]; then echo "nf"; else echo "ip"; fi)
if [ "$CHECKPORTS" = "$(echo -n "$CHECKPORTS" | grep -oEi "(yes|1|on|enable(d?))")" ]; then
#IPCONNECT=$(while read -r i; do echo "${i%}"; done < "/proc/net/"$IPCON"_conntrack"|grep "$CONSOLE" |grep -E "dport\=(${PORTS})\b"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d") ### IP connections stored here, called from memory
IPCONNECT=$(tail +1 "/proc/net/"$IPCON"_conntrack"|grep "$CONSOLE" |grep -E "dport\=(${PORTS})\b"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d") ### IP connections stored here, called from memory
else
	#IPCONNECT=$(while read -r i; do echo "${i%}"; done < "/proc/net/"$IPCON"_conntrack"|grep "$CONSOLE"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d") ### IP connections stored here, called from memory
	IPCONNECT=$(tail +1 "/proc/net/"$IPCON"_conntrack"|grep "$CONSOLE"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d") ### IP connections stored here, called from memory
fi
if [ "${IPCONNECT}" != "" ]; then :;
else
	IPCONNECT=$(while read -r i; do echo "${i%}"; done < "/proc/net/"$IPCON"_conntrack"|grep "$CONSOLE" |grep -E "dport\=(${PORTS})\b"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d") ### IP connections stored here, called from memory
fi
}
##### Check Ports #####

LIMIT=$(echo "$SETTINGS"|sed -n 2p) ### Your max average millisecond limit. Peers pinging higher than this value are blocked. Default is 3.
COUNT=$(echo "$SETTINGS"|sed -n 3p) ### How many packets to send. Default is 5
SIZE=$(echo "$SETTINGS"|sed -n 4p) ### Size of packets. Default is 1024
MODE=$(echo "$SETTINGS"|sed -n 5p) ### 0 or 1=Ping, 2=TraceRoute, 3=Ping or TraceRoute, 4=Ping & TraceRoute. Default is 1.
DECONGEST=$(echo "$SETTINGS"|sed -n 20p)
##### Get ROUTER'S IPs #####
if [ "${SHELLIS}" = "ash" ]; then
ROUTER=$(uci -P/var/state get network.lan.ipaddr) # For OpenWRT
WANSHORT=$( if uci -P/var/state get network.wan.ipaddr|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})" ; then uci -P/var/state get network.wan.ipaddr|sed -E 's/\./\\./g'|sed -n 1p; else echo $ROUTER; fi)# For Open-WRT
else
ROUTER=$(nvram get lan_ipaddr|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})") # For DD-WRT
WANSHORT=$(nvram get wan_ipaddr|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|sed -E 's/\./\\./g'|sed -n 1p) #DD-WRT
fi
ROUTERSHORT=$(echo $ROUTER|grep -Eo '(([0-9]{1,3}\.?){2})'|sed -E 's/\./\\./g'|sed -n 1p)
##### Get ROUTER'S WAN IP #####
##### Filter #####
{
if [ "$1" = "$(echo -n "$1" | grep -oEi "(nintendo|wiiu|wii|switch|[0-9]?ds)")" ]; then
#Nintendo
FILTERIP=$(echo "^38\.112\.28\.9[6-9]|^60\.32\.179\.(1[6-9]|2[0-3])|^60\.36\.183\.15[2-9]|^64\.124\.44\.(4[8-9]|5[0-5])|^64\.125\.103\.|^65\.166\.10\.(10[4-9]|11[0-1])|^84\.37\.20\.(20[8-9]|21[0-5])|^84\.233\.128\.(6[4-9]|[7-9][0-9]|1[0-1][0-9]|12[0-7)|^84\.233\.202\.([0-2][0-9]|3[0-1])|^89\.202\.218([0-9]|1[0-5])|^125\.196\.255\.(19[6-9]|20[0-7])|^125\.199\.254\.(4[8-9]|5[0-9]|6[0-7])|^125\.206\.241\.(17[6-9]|18[0-9]|19[0-1])|^133\.205\.103\.(192[2-9]|20[0-7])|^192\.195\.204\.|^194\.121\.124\.(22[4-9]|23[0-1])|^194\.176\.154\.(16[8-9]|17[0-5])|^195\.10\.13\.(1[6-9]|[2-5][0-9]|6[0-3])|^195\.10\.13\.7[2-5]|^195\.27\.92\.(9[6-9]|1[0-1][0-9]|12[0-7])|^195\.27\.92\.(19[2-9]|20[0-7])|^195\.27\.195\.([0-9]|1[0-5])|^195\.73\.250\.(22[4-9]|23[0-1])|^195\.243\.236\.(13[6-9]|14[0-3])|^202\.232\.234\.(12[8-9]|13[0-9]|14[0-3])|^205\.166\.76\.|^206\.19\.110\.|^208\.186\.152\.|^210\.88\.88\.(17[6-9]|18[0-9]|19[0-1])|^210\.138\.40\.(2[4-9]|3[0-1])|^210\.151\.57\.(8[0-9]|9[0-5])|^210\.169\.213\.(3[2-9]|[4-5][0-9]|6[0-3])|^210\.172\.105\.(1[6-8][0-9]|19[0-1])|^210\.233\.54\.(3[2-9]|4[0-7])|^211\.8\.190\.(19[2-9]|2[0-1][0-9]|22[0-3])|^212\.100\.231\.6[0-1]|^213\.69\.144\.(1[6-8][0-9]|19[0-1])|^217\.161\.8\.2[4-7]|^219\.96\.82\.(17[6-9]|18[0-9]|19[0-1])|^220\.109\.217\.16[0-7]|^125\.199\.254\.50|^192\.195\.204\.40|^192\.195\.204\.176|^205\.166\.76\.176|^207\.38\.8\.15|^207\.38\.11\.1[2-4]|^207\.38\.11\.34|^207\.38\.11\.49|^209\.67\.106\.141|^207\.38\.(8|9|1[0-5])\.|^13\.32\.|^13\.54\.|^23\.20\.|^27\.0\.([0-3])\.|^34\.(19[2-9]|20[0-7])\.|^35\.154\.|^35\.(15[6-9])\.|^35\.(16[0-7])\.|^43\.250\.(19[2-3])\.|^46\.51\.(1[0-9][0-9]|20[0-7])\.|^46\.51\.(21[6-9]|2[2-9][0-9])\.|^46\.137\.|^50\.(1[6-9])\.|^50\.112\.|^52\.([0-9][0-9]|1[0-9][0-9]|2[0-1][0-9]|22[0-2])\.|^54\.([6-9][0-9]|14[4-9]|1[5-9][0-9]|2[0-5][0-9])\.|^67\.202\.([0-5][0-9]|6[0-3])\.|^72\.31\.(19[2-9]|2[0-1][0-9]|22[0-3])\.|^72\.44\.(3[2-9]|[4-5][0-9]|6[0-3])\.|^75\.101\.(12[8-9]|1[3-9]|2[0-9][0-9])\.|^79\.125\.([0-9][0-9]|1[0-1][0-9]|2[0-5][0-9])\.|^87\.238\.(8[0-7])\.|^96\.127\.([0-9][0-9]|1[0-1][0-9]|12[0-7])\.|^103\.4\.([8-9]|1[0-5])\.|^103\.8\.(17[2-5])\.|^103\.246\.(14[8-9]|15[0-1])\.|^107\.(2[0-3])\.|^122\.248\.(19[2-9]|2[0-5][0-9])\.|^172\.96\.97\.|^174\.129\.|^175\.41\.(1[2-8][0-9]|19[0-9]|2[0-5][0-9])|^176\.32\.([6-8][0-9]|9[0-9]|1[0-1][0-9]|12[0-5])|^176\.34\.|^177\.71\.|^177\.72\.(24[0-7])\.|^178\.236\.([0-9]|1[0-5])\.|^184\.7([2-3])\.|^184\.169\.(12[8-9]|1[3-9][0-9]|2[0-5]|[0-9])\.|^185\.48\.(12[0-3])\.|^185\.143\.16\.|^203\.83\.(22[0-3])\.|^204\.236\.(12[8-9]|1[3-9][0-9]|2[[0-5]|[0-9])\.|^204\.246\.(16[0-9]|17[0-1]|17[4-9]|1[8-9][0-9]|2[0-3][0-9]|24[0-5])\.|^205\.251\.(24[7-9]|25[0-5])\.|^207\.171\.(1[6-8][0-9]|19[0-1])\.|^216\.137\.(3[2-9]|[4-5][0-9]|6[0-3])\.|^216\.182\.(22[4-9]|23[0-9])\.|^202\.(3[2-5])\.|^198\.62\.122\.|^69\.25\.139\.(12[8-9]|1[3-9][0-9]|[1-2][0-9]{2})|^34\.(19[2-9]|2[0-9]{2})|^23\.2[0-3]\.|^13\.112\.35\.82")

else
	if [ "$1" = "$(echo -n "$1" | grep -oEi "(playstation|ps[2-9]|sony|psx)")" ]; then
	#Sony
	FILTERIP=$(echo "^63\.241\.6\.(4[8-9]|5[0-5])|^63\.241\.60\.4[0-4]|^64\.37\.(12[8-9]|1[3-9][0-9])\.|^69\.153\.161\.(1[6-9]|2[0-9]|3[0-1])|^199\.107\.70\.7[2-9]|^199\.108\.([0-9]|1[0-5])\.|^199\.108\.(19[2-9]|20[0-7])\.")

	else
		if [ "$1" = "$(echo -n "$1" | grep -oEi "(microsoft|x[boxne1360]{1,})")" ]; then
		#Microsoft
		FILTERIP=$(echo "^104\.((6[4-9]{1})|(7[0-9]{1})|(8[0-9]{1})|(9[0-9]{1})|(10[0-9]{1})|(11[0-9]{1})|(12[0-7]{1}))|^13\.((6[4-9]{1})|(7[0-9]{1})|(8[0-9]{1})|(9[0-9]{1})|(10[0-7]{1}))|^131\.253\.(([2-4]{1}[1-9]{1}))|^134\.170\.|^137\.117\.|^137\.135\.|^138\.91\.|^152\.163\.|^157\.((5[4-9]{1})|60)\.|^168\.((6[1-3]{1}))\.|^191\.239\.160\.97|^23\.((3[2-9]{1})|(6[0-7]{1}))\.|^23\.((9[6-9]{1})|(10[0-3]{1}))\.|^2((2[4-9]{1})|(3[0-9]{1}))\.|^40\.((7[4-9]{1})|([8-9]{1}[0-9]{1})|(10[0-9]{1})|(11[0-9]{1})|(12[0-5]{1}))\.|^52\.((8[4-9]{1})|(9[0-5]{1}))\.|^54\.((22[4-9]{1})|(23[0-9]{1}))\.|^54\.((23[0-1]{1}))\.|^64\.86\.|^65\.((5[2-5]{1}))\.|^69\.164.\(([0-9]{1})|([1-5]{1}[0-9]{1})|((6[0-3]{1}))\.|^40.(7[4-9]|[8-9][0-9]|1[0-1][0-9]|12[0-7]).|^138.91.|^13.64.|^157.54.|^157\.(5[4-9]|60)\.")

		else
				if [ "$1" != "$(echo -n "$1" | grep -oEi "(microsoft|x[boxne1360]{1,})|(playstation|ps[2-9]|sony|psx)|(nintendo|wiiu|wii|3ds|2ds|ds)")" ]; then
				#PC/Debug/Custom
				FILTERIP=$(echo "^99999") #Debug, Add IPs to whitelist.txt file instead

				fi
		fi
	fi
fi
}
##### Filter #####
if [ "${SHELLIS}" = "ash" ]; then :; 
else
RANDOMGET=$(echo $(dd bs=1 count=1 if=/dev/urandom 2>/dev/null)|hexdump -v -e '/1 "%02X"'|sed -e s/"0A$"//g) #Generates random value between 0-FF
RANDOM=$(echo " -p $RANDOMGET")
fi
IGNORE=$(echo $({ if { { iptables -nL LDACCEPT && iptables -nL LDREJECT && iptables -nL LDBAN ; }|grep -Eoq "([0-9]{1,3}\.?){4}"; } then echo "$({ iptables -nL LDACCEPT && iptables -nL LDREJECT ; }|grep -Eo "([0-9]{1,3}\.?){4}"|awk '!a[$0]++'|grep -v "${CONSOLE}"|grep -v "127.0.0.1"|sed -E 's/^/\^/g'|sed 's/\./\\\./g')"|sed -E 's/$/\|/g'; else echo "${ROUTER}"; fi; })|sed -E 's/\|$//g'|sed -E 's/\ //g')
if [ ! -f "$DIR"/42Kmi/whitelist.txt ] ; then
PEERIP=$(echo "$IPCONNECT"|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|grep -o '^.*\..*$'|grep -v "${CONSOLE}"|grep -v "${ROUTER}"|grep -Ev "${IGNORE}"|grep -Ev "^$ROUTERSHORT"|grep -Ev "^$WANSHORT"|grep -Ev "$FILTERIP"|awk '!a[$0]++'|sed -n 1p) ### Get console Peer's IP
else
WHITELIST=$(echo $(echo "$(tail +1 "${DIR}"/42Kmi/whitelist.txt|sed -E "/(#.*$|^$|\;|#^[ \t]*$)|#/d"|sed -E "s/^/\^/g"|sed -E "s/\^#|\^$//g"|sed -E "s/\^\^/^/g"|sed -E "s/$/|/g")")|sed -E 's/\|$//g'|sed -E "s/(\ *)//g"|sed -E 's/\b\.\b/\\./g') ### Additional IPs to filter out. Make whitelist.txt in 42Kmi folder, add IPs there. Can now support extra lines and titles. See README
PEERIP=$(echo "$IPCONNECT"|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|grep -o '^.*\..*$'|grep -v "${CONSOLE}"|grep -v "${ROUTER}"|grep -Ev "${IGNORE}"|grep -Ev "^$ROUTERSHORT"|grep -Ev "^$WANSHORT"|grep -Ev "$FILTERIP"|grep -Ev "$WHITELIST"|awk '!a[$0]++'|sed -n 1p) ### Get console Peer's IP
fi
RECENT=$(iptables -nL LDACCEPT|tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
EXISTS=$({ iptables -nL LDACCEPT && iptables -nL LDREJECT && iptables -nL LDBAN ;}|grep -Fo "$PEERIP")
LASTRULE=$(iptables --line-number -nL LDACCEPT|grep -F "${RECENT}"|grep -Eo "^[0-9]{1,}")

##### The Ping #####
#Rapid Ping, New Ping Method
if [ "${MODE}" = 2 ]; then :;
else

if [ -f "$DIR"/42Kmi/tweak.txt ] ; then PINGRESOLUTION="${TWEAKPINGRESOLUTION}"; else PINGRESOLUTION=5; fi
#PINGGET=$(echo "$(n=0; while [[ $n -lt "${COUNT}" ]]; do ( ping -q -c "${PINGRESOLUTION}" -W 1 -s "${SIZE}""${RANDOM}" "${PEERIP}" & ) ; n=$((n+1)); done )"|grep -Eo "\/([0-9]{1,}\.[0-9]{1,})\/"|sed -E 's/(\/|\.)//g'|sed -E 's/$/+/g')
PINGGET=$(echo "$(n=0; while [[ $n -lt "${COUNT}" ]]; do ( ping -q -c "${PINGRESOLUTION}" -W 1 -s "${SIZE}""${RANDOM}" "${PEERIP}" & ) ; n=$((n+1)); done )"|grep -Eo "\/([0-9]{1,}\.[0-9]{1,})\/"|sed -E 's/(\/|\.)//g'|sed -E 's/(^|\b)(0){1,}//g'|sed -E 's/$/+/g'|sed -E 's/\+$//g') &> /dev/nul
PINGCOUNT=$(echo "$PINGGET"|wc -w)
#PINGSUM=$(( $(echo "$PINGGET"|sed -E 's/\+$//g') ))
PINGSUM=$(( $PINGGET ))
#PINGFULL=$(echo $(( PINGSUM / PINGCOUNT ))|sed -E 's/\[0-9]{3}$//g' )
PINGFULL=$(echo $(( PINGSUM / PINGCOUNT )))
PING=$(echo $"$PINGFULL"|sed 's/.\{3\}$//' )
if [ "${PING}" = "$(echo -n "$PING" | grep -oEi "(0|)")" ] && [ "${PINGFULL}" -lt "1000" ];then PING=0;else ( if [ "${PING}" = "$(echo -n "$PING" | grep -oEi "(0|)")" ];then PING="$PINGFULL";fi ); fi #Fallback

fi
##### The Ping #####

MODE=$(echo "$SETTINGS"|sed -n 5p)
if [ "$MODE" != "$(echo -n "$MODE" | grep -oEi "([2-4]{1})")" ]; then :;
else
##### TRACEROUTE #####
##### PARAMETERS #####
MAXTTL=$(echo "$SETTINGS"|sed -n 6p)
TTL=$(if [ "${MAXTTL}" -le 255 ] && [ "${MAXTTL}" -ge 1 ]; then echo "$MAXTTL"; else echo 10; fi)
PROBES=$(echo "$SETTINGS"|sed -n 7p)
TRACELIMIT=$(echo "$SETTINGS"|sed -n 8p)
##### PARAMETERS #####
##### New TraceRoute #####

if [ -f "$DIR"/42Kmi/tweak.txt ] ; then TRGETCOUNT="${TWEAKTRGETCOUNT}"; else TRGETCOUNT=1; fi
MXP=$(echo $(( TTL * PROBES * TRGETCOUNT )))
#New TraceRoute
#TRGET=$(if { "$EXISTS"; }; then :; else echo $(echo "$(n=0; while [[ $n -lt "${TRGETCOUNT}" ]]; do ( traceroute -m "${TTL}" -q "${PROBES}" -w 1 "${PEERIP}" "${SIZE}" & ) ; n=$((n+1)); done )"|grep -Eo "([0-9]{1,}\.[0-9]{3}\ ms)"|sed -E 's/(\/|\.|\ ms)//g'|sed -E 's/$/+/g'); fi)
#TRGET=$(if { "$EXISTS"; }; then :; else echo $(echo "$(n=0; while [[ $n -lt "${TTL}" ]]; do ( traceroute -F -m 1 -q "${PROBES}" -w 1 "${PEERIP}" 32768 & ) ; n=$((n+1)); done )"|grep -Eo "([0-9]{1,}\.[0-9]{3}\ ms)"|sed -E 's/(\/|\.|\ ms)//g'|sed -E 's/$/+/g'); fi)
TRGET=$(echo $(echo "$(n=0; while [[ $n -lt "${TTL}" ]]; do ( traceroute -F -m "${TRGETCOUNT}" -q "${PROBES}" -w 1 "${PEERIP}" "${SIZE}" & ) ; n=$((n+1)); done )"|grep -Eo "([0-9]{1,}\.[0-9]{3}\ ms)"|sed -E 's/(\/|\.|\ ms)//g'|sed -E 's/(^|\b)(0){1,}//g'|sed -E 's/$/+/g')|sed -E 's/\+$//g') &> /dev/nul
TRCOUNT=$(echo "$TRGET"|wc -w) #Counts for average
TRSUM=$(( $TRGET ))
if [ "${TRCOUNT}" != 0 ]; then
TRAVGFULL=$(echo $(( TRSUM / TRCOUNT ))) #TRACEROURTE sum for math
TRAVG=$(echo $TRAVGFULL | sed 's/.\{3\}$//')
else
TRAVGFULL=$(echo "$(( TRSUM / MXP ))") #TRACEROURTE sum for math
TRAVG=$(echo $TRAVGFULL | sed 's/.\{3\}$//')
fi
if [ "${TRAVG}" = "$(echo -n "$TRAVG" | grep -oEi "(0|)")" ] && [ "${TRAVGFULL}" -lt "1000" ];then TRAVG=0;else ( if [ "${TRAVG}" = "$(echo -n "$TRAVG" | grep -oEi "(0|)")" ];then TRAVG="$TRAVGFULL";fi ) ; fi #Fallback
##### New TraceRoute #####
##### TRACEROUTE #####
fi
##### ACTION of IP Rule #####
ACTION=$(echo "$SETTINGS"|sed -n 9p) ### DROP (1)/REJECT(0) 
ACTION1=$(if [ "$ACTION" = "$(echo -n "$ACTION" | grep -oEi "(drop|1)")" ]; then echo "DROP"; else echo "REJECT"; fi)
##### ACTION of IP Rule #####

##### BLACKLIST #####
if [ ! -f "$DIR"/42Kmi/blacklist.txt ] ; then :;
else
#RECENT=$(iptables -nL LDACCEPT|tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
BLACKLIST=$(echo $(echo "$(tail +1 "${DIR}"/42Kmi/blacklist.txt|sed -E "/(#.*$|^$|\;|#^[ \t]*$)|#/d"|sed -E "s/^/\^/g"|sed -E "s/\^#|\^$//g"|sed -E "s/\^\^/^/g"|sed -E "s/$/|/g")")|sed -E 's/\|$//g'|sed -E "s/(\ *)//g"|sed -E 's/\b\.\b/\\./g') ### Permananent ban. If encountered, automatically blocked.

	#if { echo "${PEERIP}" |grep -E "${BLACKLIST}"; }; then eval "iptables -I LDBAN -s $CONSOLE -d $PEERIP -j $ACTION1 "${WAITLOCK}";"; fi
	#if { echo "${RECENT}" |grep -E "${BLACKLIST}"; }; then eval "iptables -I LDBAN -s $CONSOLE -d $RECENT -j $ACTION1 "${WAITLOCK}";"; fi
	if { echo "${BLACKLIST}" |grep -E "${PEERIP}"; }; then eval "iptables -I LDBAN -s $CONSOLE -d $PEERIP -j $ACTION1 "${WAITLOCK}";"; fi
	if { echo "${BLACKLIST}" |grep -E "${RECENT}"; }; then eval "iptables -I LDBAN -s $CONSOLE -d $RECENT -j $ACTION1 "${WAITLOCK}";"; fi
fi
##### BLACKLIST #####

##### Count Connected IPs #####
NUMBEROFPEERS=$(echo "$SETTINGS"|sed -n 19p)
OMIT=$("$WHITELIST" && "$BLACKLIST" && "$FILTER"|sed -E 's/\^//g')
IPCONNECTCOUNT=$(echo -ne "$IPCONNECT"| grep -Ev "$OMIT"|grep -Ec "^")

##### Count Connected IPs #####
if [ "$RESTONMULTIPLAYER" = "$(echo -n "$RESTONMULTIPLAYER" | grep -oEi "(yes|1|on|enable(d?))")" ] && [ "${IPCONNECTCOUNT}" -ge "${NUMBEROFPEERS}" ]; then :; else

if { iptables -nL LDREJECT && iptables -nL LDBAN|grep "${PEERIP}"; } then :;
else
##### BLOCK ##### // 0 or 1=Ping, 2=TraceRoute, 3=Ping or TraceRoute, 4=Ping & TraceRoute
if [ "${MODE}" != "$(echo -n "${MODE}" | grep -oEi "([234])")" ]; then
BLOCK=$({ if "$EXISTS"; then :; else { if [ "${PING}" -gt "${LIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1 "${WAITLOCK}";"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT "${WAITLOCK}""; } fi; } fi; } &)# Ping only
else
	if [ "${MODE}" = 2 ]; then
	BLOCK=$({ if "$EXISTS"; then :; else { if [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1 "${WAITLOCK}";"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT "${WAITLOCK}""; } fi; } fi; } &)#TraceRoute only
	else
		if [ "${MODE}" = 3 ]; then
		BLOCK=$({ if "$EXISTS"; then :; else { if [ "${PING}" -gt "${LIMIT}" ] || [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1 "${WAITLOCK}";"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT "${WAITLOCK}""; } fi; } fi; } &) #Ping OR TraceRoute
		else
				if [ "${MODE}" = 4 ]; then
				BLOCK=$({ if "$EXISTS"; then :; else { if [ "${PING}" -gt "${LIMIT}" ] && [ "${TRAVG}" -gt "${TRACELIMIT}" ]; then { eval "iptables -I LDREJECT -s $CONSOLE -d $PEERIP -j $ACTION1 "${WAITLOCK}";"; }; else { eval "iptables -A LDACCEPT -p all -s $PEERIP -d $CONSOLE -j ACCEPT "${WAITLOCK}""; } fi; } fi; } &) #Ping AND TraceRoute
				fi
		fi
	fi
fi

##### Packet Sentinel #####
(
CHECKPACKETLOSS=$(echo "$SETTINGS"|sed -n 10p)
if [ "$CHECKPACKETLOSS" = "$(echo -n "$CHECKPACKETLOSS" | grep -oEi "(yes|1|on|enable(d?))")" ]; then
#Packet Diff Compare
packetsentinel ()
{
PACKETLOSSLIMIT=$(echo "$SETTINGS"|sed -n 11p)
#PACKETMODE=3 #0 or 1=Difference, 2=X^2, 3=Difference or X^2, 4=Difference & X^2
if [ -f "$DIR"/42Kmi/tweak.txt ] ; then PACKETMODE="${TWEAKPACKETMODE}"; else PACKETMODE=3; fi

if [ -f "$DIR"/42Kmi/tweak.txt ] ; then PACKETINTERVAL="${TWEAKPACKETINTERVAL}"; else PACKETINTERVAL=1; fi
PACKETGET1=$(echo "$(iptables -xnvL LDACCEPT| grep -F "$RECENT"|awk '{print $1}'|grep -E "[0-9]{1,}")")
sleep "${PACKETINTERVAL}"
PACKETGET2=$(echo "$(iptables -xnvL LDACCEPT| grep -F "$RECENT"|awk '{print $1}'|grep -E "[0-9]{1,}")")
PACKETDIFF=$(echo $(( PACKETGET2 - PACKETGET1 )))
PACKETCOUNT=$(echo "$PACKETGET1 $PACKETGET2"|wc -w)
PACKETAVG=$(echo $(( (( PACKETGET2 - PACKETGET1 )) / PACKETCOUNT )) / )
PACKETDIFFSQ=$(echo $(( PACKETDIFF * PACKETDIFF )))
PACKETXSQ=$(echo $(( (( PACKETDIFFSQ / PACKETAVG )) )))

#if [ "$RECENT" = "$(echo -n "$IPCONNECT" | grep -o "$RECENT")" ]; then

##### BLOCK ##### // 0 or 1=Difference, 2=X^2, 3=Difference or X^2, 4=Difference & X^2

if [ "${PACKETMODE}" != "$(echo -n "${PACKETMODE}" | grep -oEi "([234])")" ]; then
PACKETBLOCK=$({ if [ "${PACKETDIFF}" -gt "${PACKETLOSSLIMIT}" ]; then { eval "iptables -I LDREJECT -s $RECENTSOURCE -d $RECENT -j $ACTION1 "${WAITLOCK}"; iptables -D LDACCEPT $LASTRULE; iptables -D LDACCEPT -d $RECENTSOURCE -s $RECENT -j $ACTION1 "${WAITLOCK}""; } fi; } &)# Difference only
else
	if [ "${PACKETMODE}" = 2 ]; then
	PACKETBLOCK=$({ if [ "${PACKETXSQ}" -gt "${PACKETLOSSLIMIT}" ]; then { eval "iptables -I LDREJECT -s $RECENTSOURCE -d $RECENT -j $ACTION1 "${WAITLOCK}"; iptables -D LDACCEPT $LASTRULE; iptables -D LDACCEPT -d $RECENTSOURCE -s $RECENT -j $ACTION1 "${WAITLOCK}""; } fi; } &)#X^2 only
	else
		if [ "${PACKETMODE}" = 3 ]; then
		PACKETBLOCK=$({ if [ "${PACKETDIFF}" -gt "${PACKETLOSSLIMIT}" ] || [ "${PACKETXSQ}" -gt "${PACKETLOSSLIMIT}" ]; then { eval "iptables -I LDREJECT -s $RECENTSOURCE -d $RECENT -j $ACTION1 "${WAITLOCK}"; iptables -D LDACCEPT $LASTRULE; iptables -D LDACCEPT -d $RECENTSOURCE -s $RECENT -j $ACTION1 "${WAITLOCK}""; } fi; } &) #Difference or X^2
		else
				if [ "${PACKETMODE}" = 4 ]; then
				PACKETBLOCK=$({ if [ "${PACKETDIFF}" -gt "${PACKETLOSSLIMIT}" ] && [ "${PACKETXSQ}" -gt "${PACKETLOSSLIMIT}" ]; then { eval "iptables -I LDREJECT -s $RECENTSOURCE -d $RECENT -j $ACTION1 "${WAITLOCK}"; iptables -D LDACCEPT $LASTRULE; iptables -D LDACCEPT -d $RECENTSOURCE -s $RECENT -j $ACTION1 "${WAITLOCK}""; } fi; } &) #Difference AND X^2
				fi
		fi
	fi
fi
#fi
${PACKETBLOCK}
##### BLOCK #####
#wait
sleep "${PACKETINTERVAL}"
packetsentinel
}
else :;
fi
)
##### Packet Sentinel #####

fi
##### BLOCK #####
fi

##### New SENTINEL Modulus #####
(
if [ "$RESTONMULTIPLAYER" = "$(echo -n "$RESTONMULTIPLAYER" | grep -oEi "(yes|1|on|enable(d?))")" ]; then :;#RestOnMultiplayer Overrides Sentinel
else
SENTINEL=$(echo "$SETTINGS"|sed -n 12p) #Testing of allowed peers for packet loss
sentinel ()
{
if [ "$SENTINEL" = "$(echo -n "$SENTINEL" | grep -oEi "(yes|1|on|enable(d?))")" ]; then
#RECENT=$(iptables -nL LDACCEPT|tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
RECENTSOURCE=$(iptables -nL LDACCEPT|tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 2p)
#LASTRULE=$(iptables --line-number -nL LDACCEPT|tail -1|grep -Eo "^[0-9]{1,}")
LASTRULE=$(iptables --line-number -nL LDACCEPT|grep -F "${RECENT}"|grep -Eo "^[0-9]{1,}")
if [ -f "$DIR"/42Kmi/tweak.txt ] ; then SENTMODE="${TWEAKSENTMODE}"; else SENTMODE=3; fi # // 0 or 1=Difference, 2=X^2, 3=Difference or X^2, 4=Difference and X^2
#New Sentinel, Compares averages taken at two time points. Difference and ChiSquared
if [ -f "$DIR"/42Kmi/tweak.txt ] ; then SENTLIMIT="${TWEAKSENTLIMIT}"; else SENTLIMIT=0; fi
if [ -f "$DIR"/42Kmi/tweak.txt ] ; then SENTRUN="${TWEAKSENTRUN}"; else SENTRUN=100; fi
if [ -f "$DIR"/42Kmi/tweak.txt ] ; then SENTRES="${TWEAKSENTINTERVAL}"; else SENTINTERVAL=4; fi
SENTSIZE=$(echo "${SIZE}") #1024
if [ -f "$DIR"/42Kmi/tweak.txt ] ; then SENTRES="${TWEAKSENTRES}"; else SENTRES=4; fi
#SENTINELXSQMODE=Standard #Standard or HIGH
if [ -f "$DIR"/42Kmi/tweak.txt ] ; then SENTINELXSQMODE="${TWEAKSENTINELXSQMODE}"; else SENTINELXSQMODE=Standard; fi
#Sentinal Values 1
#SENTGET=$(echo $(echo "$(n=0; while [[ $n -lt "${SENTRUN}" ]]; do ( ping -q -c "${SENTRES}" -W 1 -s "${SENTSIZE}" "${RECENT}" & ) ; n=$((n+1)); done )"|grep -Eo "\/([0-9]{1,}\.[0-9]{1,})\/"|sed -E 's/(\/|\.)//g'|sed -E 's/$/+/g')|sed -E 's/\+$//g')
SENTGET=$(echo $(echo "$(n=0; while [[ $n -lt "${SENTRUN}" ]]; do ( ping -q -c "${SENTRES}" -W 1 -s "${SENTSIZE}" "${RECENT}" & ) ; n=$((n+1)); done )"|grep -Eo "\/([0-9]{1,}\.[0-9]{1,})\/"|sed -E 's/(\/|\.)//g'|sed -E 's/(^|\b)(0){1,}//g'|sed -E 's/$/+/g')|sed -E 's/\+$//g'|sed -E 's/\+$//g') &> /dev/nul
SENTCOUNT=$(echo "$SENTGET"|wc -w)
#SENTSUM=$(( $(echo "$SENTGET"|sed -E 's/\+$//g') ))
SENTSUM=$(( $SENTGET ))
SENTAVG=$(echo $(( SENTSUM / SENTCOUNT ))|sed -E 's/[0-9]{3}$//g' )
#Sentinal Values 2
sleep "${SENTINTERVAL}"
SENTGET2=$(echo $(echo "$(n=0; while [[ $n -lt "${SENTRUN}" ]]; do ( ping -q -c "${SENTRES}" -W 1 -s "${SENTSIZE}" "${RECENT}" & ) ; n=$((n+1)); done )"|grep -Eo "\/([0-9]{1,}\.[0-9]{1,})\/"|sed -E 's/(\/|\.)//g'|sed -E 's/(^|\b)(0){1,}//g'|sed -E 's/$/+/g')|sed -E 's/\+$//g') &> /dev/nul
SENTCOUNT2=$(echo "$SENTGET2"|wc -w)
SENTSUM2=$(( $(echo "$SENTGET2"|sed -E 's/\+$//g') ))
SENTAVG2=$(echo $(( SENTSUM2 / SENTCOUNT2 ))|sed -E 's/[0-9]{3}$//g' )
#SENTDIFF=$(echo $(( SENTAVG2 - SENTAVG ))|sed -E 's/\-//g')
SENTDIFF=$(echo $(( SENTAVG2 - SENTAVG )))
SENTAVGBOTH=$(echo $(( (( SENTAVG + SENTAVG2 )) / 2 )) )
if [ "${SENTCOUNT}" = "$(echo -n "$SENTCOUNT" | grep -oEi "(0|)")" ];then SENTCOUNT=1;fi #Fallback
if [ "${SENTCOUNT2}" = "$(echo -n "$SENTCOUNT2" | grep -oEi "(0|)")" ];then SENTCOUNT2=1;fi #Fallback
if [ "${SENTAVGBOTH}" = "$(echo -n "$SENTAVGBOTH" | grep -oEi "(0|)")" ];then SENTAVGBOTH=1;fi #Fallback

#####High#####
SENTHIGH=$(echo "${SENTGET}"|sed -E 's/\+\ /\n/g'|sort -dur|sed -n 1p|sed -E 's/\+$//g')
SENTHIGH2=$(echo "${SENTGET2}"|sed -E 's/\+\ /\n/g'|sort -dur|sed -n 1p|sed -E 's/\+$//g')
SENTHIGHAVG=$(echo $(( (( SENTHIGH + SENTHIGH2 )) / 2 ))|sed -E 's/[0-9]{3}$//g' )
if [ "$SENTINELXSQMODE" = "$(echo -n "$SENTINELXSQMODE" | grep -oEi "(high)")" ]; then
SENTXSQ=$(echo $(( (( (( (( SENTHIGHAVG - SENTAVGBOTH )) * (( SENTHIGHAVG - SENTAVGBOTH )) )) / SENTAVGBOTH )) )) ) # Chi-Squared of the 2 averages
#####High#####
else
SENTXSQ=$(echo $(( (( (( (( SENTAVG2 - SENTAVG )) * (( SENTAVG2 - SENTAVG )) )) / SENTAVGBOTH )) ))) # Chi-Squared of the 2 averages
fi

#if echo "$IPCONNECT"|grep -o "$RECENT"; then 
if [ "$RECENT" = "$(echo -n "$IPCONNECT" | grep -o "$RECENT")" ]; then
##### BLOCK ##### // 0 or 1=Difference, 2=X^2, 3=Difference or X^2, 4=Difference and X^2
if [ "${SENTMODE}" != "$(echo -n "${SENTMODE}" | grep -oEi "(2|3|4)")" ]; then
SENTBLOCK=$({ if [ "${SENTDIFF}" -gt "${SENTLIMIT}" ]; then { eval "iptables -I LDREJECT -s $RECENTSOURCE -d $RECENT -j $ACTION1 "${WAITLOCK}"; iptables -D LDACCEPT $LASTRULE; iptables -D LDACCEPT -d $RECENTSOURCE -s $RECENT -j $ACTION1 "${WAITLOCK}""; } fi; } &)# Difference only
else
	if [ "${SENTMODE}" = 2 ]; then
	SENTBLOCK=$({ if [ "${SENTXSQ}" -gt "${SENTLIMIT}" ]; then { eval "iptables -I LDREJECT -s $RECENTSOURCE -d $RECENT -j $ACTION1 "${WAITLOCK}"; iptables -D LDACCEPT $LASTRULE; iptables -D LDACCEPT -d $RECENTSOURCE -s $RECENT -j $ACTION1 "${WAITLOCK}""; } fi; } &)#X^2 only
	else
		if [ "${SENTMODE}" = 3 ]; then
		SENTBLOCK=$({ if [ "${SENTDIFF}" -gt "${SENTLIMIT}" ] || [ "${SENTXSQ}" -gt "${SENTLIMIT}" ]; then { eval "iptables -I LDREJECT -s $RECENTSOURCE -d $RECENT -j $ACTION1 "${WAITLOCK}"; iptables -D LDACCEPT $LASTRULE; iptables -D LDACCEPT -d $RECENTSOURCE -s $RECENT -j $ACTION1 "${WAITLOCK}""; } fi; } &) #Difference or X^2
		else
				if [ "${SENTMODE}" = 4 ]; then
				SENTBLOCK=$({ if [ "${SENTDIFF}" -gt "${SENTLIMIT}" ] && [ "${SENTXSQ}" -gt "${SENTLIMIT}" ]; then { eval "iptables -I LDREJECT -s $RECENTSOURCE -d $RECENT -j $ACTION1 "${WAITLOCK}"; iptables -D LDACCEPT $LASTRULE; iptables -D LDACCEPT -d $RECENTSOURCE -s $RECENT -j $ACTION1 "${WAITLOCK}""; } fi; } &) #Difference AND X^2
				fi
		fi
	fi
fi
fi
eval "${SENTBLOCK}"
##### BLOCK #####
fi
wait
sleep "${SENTINTERVAL}"
sentinel
} &
fi
)
##### New SENTINEL Modulus #####
sentinel
##### Clear Old #####
{
CLEARLIMIT=$(echo "$SETTINGS"|sed -n 15p)
#Allow
CLEARALLOWED=$(echo "$SETTINGS"|sed -n 13p)
if [ "$CLEARALLOWED" = "$(echo -n "$CLEARALLOWED" | grep -oEi "(yes|1|on|enable(d?))")" ];
then
	COUNTALLOW=$(iptables -nL LDACCEPT|grep -Ec "^ACCEPT")
	TOPALLOW=$(iptables -nL LDACCEPT|grep -E "^ACCEPT"|sed "s/${CONSOLE}//g"|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
	if [ "${COUNTALLOW}" -gt "${CLEARLIMIT}" ];
	then
		if echo "$IPCONNECT"|grep -q "${CONSOLE}"|grep -oq "$TOPALLOW"; then :;
		else eval "iptables -D LDACCEPT 1 "${WAITLOCK}";"
		fi
	else :;
	fi
else :;
fi
#Blocked
CLEARBLOCKED=$(echo "$SETTINGS"|sed -n 14p)
if [ "$CLEARBLOCKED" = "$(echo -n "$CLEARBLOCKED" | grep -oEi "(yes|1|on|enable(d?))")" ];
then
	COUNTBLOCKED=$(iptables -nL LDREJECT|grep -Ec "^(DROP|REJECT)")
	BOTTOMBLOCKED=$(iptables -nL LDREJECT|tail -1|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 2p)
	OLDBLOCK=$(iptables --line-number -nL LDREJECT|tail -1|grep -Eo "^[0-9]{1,}")
	if [ "${COUNTBLOCKED}" -gt "${CLEARLIMIT}" ];
	then
		if echo "$IPCONNECT"|grep -q "${CONSOLE}"|grep -oq "$BOTTOMBLOCKED"; then :;
		else eval "iptables -D LDREJECT $OLDBLOCK "${WAITLOCK}";"
		fi
	else :;	
	fi
else :;
fi
}

##### Clear Old #####

KILLOLD=$(kill -9 `ps -w | grep -F "$SCRIPTNAME" | grep -v $$` &> /dev/null)
LOOP=$(eval $(echo "$0 $1"))

#####Decongest - Block all other connections#####

if { iptables -L FORWARD "${WAITLOCK}"|grep -Eoq "^LDKTA.*anywhere"; }; then eval "#LDKTA already exists"; else iptables -N LDKTA; iptables -P LDKTA DROP; iptables -t filter -A FORWARD -j LDKTA; fi &> /dev/null


if { ping -q -c 1 -W 1 "${CONSOLE}"|grep -q -F -w "100% packet loss" ;} &> /dev/null; then iptables -F LDKTA "${WAITLOCK}"; else
	if [ "$CHECKPORTS" = "$(echo -n "$CHECKPORTS" | grep -oEi "(yes|1|on|enable(d?))")" ]; then
	eval echo $(while read -r i; do echo "${i%}"; done < /proc/net/"$IPCON"_conntrack|grep -v "${CONSOLE}"|grep -Ev "$WHITELIST"|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|awk '!a[$0]++'|grep -Ev "^$ROUTERSHORT"|awk '!a[$0]++'|sed -E "s/^/iptables -I LDKTA -d /g"|sed -E "s/$/ -j DROP "${WAITLOCK}";/") &> /dev/null
	fi
fi
#####Decongest - Block all other connections#####

##### CULL CLEAR PEERS #####
cullold()
{
OLDESTALLOW=$(iptables -nL LDACCEPT|grep -E "^ACCEPT"|grep -Eo "([0-9]{1,3}\.?){4}"|sed -n 1p)
#CULLEXIST=$(echo "${IPCONNECT}"|grep -Eo "${OLDESTALLOW}")
OLDESTPEERLINE=$(iptables --line-number -nL LDACCEPT| grep -F "${OLDESTALLOW}"|awk '{print $1}'|grep -E "[0-9]{1,}"|sed -n 1p)
if echo "${IPCONNECT}"|grep -F "${OLDESTALLOW}"; then :;
else eval "iptables -D LDACCEPT $OLDESTPEERLINE "${WAITLOCK}";"
fi
cullold
}
cullold
##### CULL CLEAR PEERS #####

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
if "$DIR"/lagdrop.sh; then :; else
if [ "$RESTONMULTIPLAYER" = "$(echo -n "$RESTONMULTIPLAYER" | grep -oEi "(yes|1|on|enable(d?))")" ] && [ "${IPCONNECTCOUNT}" -ge "${NUMBEROFPEERS}" ]; then :; else
if [ "$SWITCH" = "$(echo -n "$SWITCH" | grep -oEi "(off|0|disable(d?))")" ]; then exit && $KILLOLD;
else {
lagdropexecute ()
{ #LagDrop loops within here. It's cool, yo.
{
if { ping -q -c 1 -W 1 -s 1 "${CONSOLE}"|grep -q -F -w "100% packet loss" ;} &> /dev/null; then :; else
lagdropexecute && sentinel && packetsentinel
{ while ping -q -c 1 -W 1 "${CONSOLE}"|grep -q -F -w "100% packet loss"; do :; done ;} &> /dev/null; wait
while sleep :; do 
if { "$EXISTS"; }; then :; else ${PACKETBLOCK} && ${SENTBLOCK} && ${BLOCK}; wait &> /dev/null & fi
 
 done
fi
$KILLOLD
lagdropexecute && packetsentinel && sentinel
} &> /dev/null
} &> /dev/null
} fi
fi
fi
}
fi
##### Ban SLOW Peers #####
##### 42Kmi International Competitive Gaming #####
##### Visit 42Kmi.com #####
##### Shop @ 42Kmi.com/store #####
##### Shirts @ 42Kmi.com/swag.htm #####