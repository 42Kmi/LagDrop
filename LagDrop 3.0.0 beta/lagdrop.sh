#!/bin/sh
{
POPULATE=""
cleanall(){
PROC="$(ps|grep -E "$(echo $(ps|grep "${0##*/}"|grep -v $$|grep -Ev "(\[("kthreadd"|"ksoftirqd"|"kworker"|"khelper"|"writeback"|"bioset"|"crypto"|"kblockd"|"khubd"|"kswapd"|"fsnotify_mark"|"deferwq"|"scsi_eh_"|"usb-storage"|"cfg80211"|"jffs2_gcd_mtd3").*\])"|grep -Ev "SW(.?)"|awk '{printf $3" "$4"|\n"}'|sort -u)|sed -E 's/.$//')"|grep -v $$|grep -v "rm"|grep -Eo "^(\s*)?[0-9]{1,}")"
	misterclean(){
	iptables -F LDKTA
	sed -i -E "/#(.*)#(.*)$/d" ""$DIR"/42Kmi/${GEOMEMFILE}"
	sed -i -E "/#(.*)#(.*)#$/d" ""$DIR"/42Kmi/${PINGMEM}"
	kill -9 $(ps|grep "${0##*/}"|grep -Eo "^(\s*)?[0-9]{1,}"|grep -v $$)
	for process in $PROC; do
		{ rm -rf "/proc/$process" 2>&1 >/dev/null 2> /dev/null; } &
	#rm "/tmp/$RANDOMGET"; iptables -nL LDACCEPT; iptables -nL LDREJECT; iptables -nL LDIGNORE; iptables -nL LDKTA #; iptables -nL LDBAN
	done &
	}
n=0; while [[ $n -lt 10 ]]; do { misterclean; } ; n=$((n+1)); done
wait $!
echo 100 > /proc/sys/vm/vfs_cache_pressure
exit
} &> /dev/null
trap cleanall 0 1 2 3 6 9 15

PROCESS="$$"
##### LINE OPTIONS #####
for i in "$@"
do
case $i in
	-c|--clear) #Cleans old LagDrop records, but directories and options remain. Terminates
	if  { ls -1 /tmp|grep -Ei "[0-9a-f]{38,}"; } &> /dev/null;  then
	iptables -F LDREJECT && iptables -F LDACCEPT && iptables -F LDIGNORE &> /dev/null
	for i in $(ls -1 /tmp|grep -Ei "[0-9a-f]{38,}"); do
		rm -f /tmp/"$i" &> /dev/null
	done &> /dev/null
fi; break
	{ exit 0; } &> /dev/null
	;;
    -s|--smart) # Enable Smart Mode, after 5 passed results, average of passed pings becomes the new ping limit. Successively decreases to best pings
    SMARTMODE=1
    SHOWSMART=1
    ;;
    -b) # Block null ping results
	;;
	-l|--location) #Show peer location, via ipapi
	SHOWLOCATION=1
    ;;
	-p|--populate) #with location enabled, fills caches for ping approximation. LagDrop doesn't filter
	POPULATE=1
    ;;
esac
done
##### LINE OPTIONS #####

#Header
VERSION="Ver 3.0.0 beta, #OneForAll"
#export LC_ALL=C
##### Kill if no argument #####
if [ "$1" = "$(echo -n "$1" | grep -oEi "((\ ?){1,}|)")" ]; then
echo "Enter an Argument!! Eg: WIIU, XBOX, PS4, PC, etc."
echo -e "### 42Kmi LagDrop "${VERSION}\ ###"
Router-based Anti-Lag Solution for P2P online games.
Supported arguments load the appropriate filters for the console.
Running LagDrop without argument will terminate all instances of the script.
42Kmi.com | LagDrop.com"
cleanall
exit
else
kill -9 $(echo $(ps|grep "${0##*/}"|grep -v "$$"|grep -Eo "^(\s*)?[0-9]{1,}"))|: #Kill previous instances. Can't run in two places at same time.
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
##### Be Glorious, Be Best #####
##### Don't Be Racist, Homophobic, Islamophobic, Misogynistic, Bigoted, Sexist, etc. #####
##### Ban SLOW Peers #####

##### Special thanks to CharcoalBurst, robus9one, Deniz, Driphter #####

######Items only needed to initialize
##### Colors & Escapes##### 
NC="\033[0m"; RED="\033[1;31m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; MARK="\033[1;37m"; GRAY="\033[1;30m"; BLUE="\033[1;34m"; MAGENTA="\033[1;35m"; DEFAULT="\033[1;39m"; BLACK="\033[1;30m"; CYAN="\033[1;36m"; LIGHTGRAY="\033[1;37m"; DARKGRAY="\033[1;90m"; LIGHTRED="\033[1;91m"; LIGHTGREEN="\033[1;92m"; LIGHTYELLOW="\033[1;93m"; LIGHTBLUE="\033[1;94m"; LIGHTMAGENTA="\033[1;95m"; LIGHTCYAN="\033[1;96m"; WHITE="\033[1;97m";HIDE="\033[8m";BOLD="\033[1m"
SAVECURSOR="\033[s" #Save Cursor Position
RESTORECURSOR="\033[u" #Restore Cursor Position
REFRESHALL="\033[H\033[2J" # From Top and Left of screen
REFRESH="\033[H\033[2J" # From cursor
CLEARLINE="\033[K" #Clears line at cursor position and beyond
CLEARSCROLLBACK="\033[H\033[3J" # Clears scrollback
##### BG COLORS #####
BG_BLACK="\033[1;40m"; BG_RED="\033[1;41m"; BG_GREEN="\033[1;42m"; BG_YELLOW="\033[1;43m"; BG_BLUE="\033[1;44m"; BG_MAGENTA="\033[1;45m"; BG_CYAN="\033[1;46m"; BG_WHITE="\033[1;47m"
##### BG COLORS #####
##### Colors & Escapes##### 

##### Find Shell #####
SHELLIS=$(if [ -f "/usr/bin/lua" ]; then echo "ash"; else echo "no"; fi)
WAITLOCK=$(if [ "${SHELLIS}" = "ash" ]; then echo "-w"; else echo ""; fi)
if [ "${SHELLIS}" = "ash" ]; then
	#Remove xtables.lock because it interferes with LagDrop
	while :;do { rm -f /var/run/xtables.lock &> /dev/null & }; done &
	while [ -f /var/run/xtables.lock ]; do { rm -f /var/run/xtables.lock &> /dev/null & }; done &
	while :; do sleep 5; curl -sk "http://example.com" &> /dev/null; done & #Keep OpenWRT Connection alive
	while :; do sleep 5; ping -q -c 1 -W 1 "example.com" &> /dev/null; done & #Keep OpenWRT Connection alive
fi &> /dev/null &
IPTABLESVER=$(iptables -V|grep -Eo "([0-9]{1,}\.?){3}")
SUBFOLDER="cache"
##### Memory Dir #####
PINGMEM="cache/pingmem"
GEOMEMFILE="cache/geomem"
FILTERIGNORE="cache/filterignore"
##### Memory Dir #####
gogetem(){
if ! [ -f ""$DIR"/42Kmi/${FILTERIGNORE}" ]; then touch ""$DIR"/42Kmi/${FILTERIGNORE}"; fi
if ! [ -f ""$DIR"/42Kmi/${GEOMEMFILE}" ]; then touch ""$DIR"/42Kmi/${GEOMEMFILE}"; fi
if  { ls -1 /tmp|grep -Eio "[0-9a-f]{38,42}"; } &> /dev/null;  then
RANDOMGET="$(ls -1 /tmp|grep -Eio "[0-9a-f]{42}"|sed -n 1p)"
else
RANDOMGET="$(echo $(dd bs=1 count=21 if=/dev/urandom 2>/dev/null)|hexdump -v -e '/1 "%02X"'|sed -e s/"0A$"//g)"
touch "/tmp/$RANDOMGET" #; chmod 000 "/tmp/$RANDOMGET"
fi
LTIME=$(date +%s -r "/tmp/$RANDOMGET")
LSIZE=$(tail +1 "/tmp/$RANDOMGET"|wc -c)
}; gogetem
##### Get ROUTER'S IPs #####
if [ "${SHELLIS}" = "ash" ]; then
ROUTER=$(ubus call network.interface.lan status|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|sed -n 1p) # For OpenWRT
#WAN_Address=$(ubus call network.interface.wan status|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|sed -n 1p)# For OpenWRT
else
ROUTER=$(nvram get lan_ipaddr|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})") # For DD-WRT
#WAN_Address=$(nvram get wan_ipaddr|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})") #DD-WRT
fi
ROUTERSHORT=$(echo "$ROUTER"|grep -Eo '(([0-9]{1,3}\.?){2})'|sed -E 's/\./\\./g'|sed -n 1p)
ROUTERSHORT_POP=$(echo "$ROUTER"|grep -Eo '(([0-9]{1,3}\.?){2})'|sed -n 1p)
##### Get ROUTER'S IPs #####

##### Find Shell #####
SCRIPTNAME="${0##*/}"
DIR="${0%\/*.*}"
if [ -f ""$DIR"/42Kmi/${GEOMEMFILE}" ]; then sed -E -i "/#$/d" ""$DIR"/42Kmi/${GEOMEMFILE}"; fi #Housekeeping
##### Make Files #####
CONSOLENAME="$1"
##### Get Static IP #####
if [ "${SHELLIS}" = "ash" ]; then
GETSTATIC=$"$(tail +1 "/var/dhcp.leases"|grep -i "$CONSOLENAME"|grep -Eo "\b([0-9]{1,3}\.){3}([0-9]{1,3})\b"|sed -n 1p)" # for OpenWRT
else
GETSTATIC="$(tail +1 "/tmp/dnsmasq.leases"|grep -i "$CONSOLENAME"|grep -Eo "\b([0-9]{1,3}\.){3}([0-9]{1,3})\b"|sed -n 1p)" # for DD-WRT
fi
##### Get Static IP #####
##### Prepare LagDrop's IPTABLES Chains #####
maketables(){
if ! { iptables -nL LDACCEPT|grep -E "([1-9])([0-9]{1,})? references" 2>&1 >/dev/null; }; then
until { iptables -nL LDACCEPT|grep -E "([1-9])([0-9]{1,})? references"; }; do iptables -N LDACCEPT|iptables -P LDACCEPT ACCEPT|iptables -t filter -A FORWARD -j LDACCEPT; done &> /dev/null & break
else break; fi &> /dev/null &

if ! { iptables -nL LDREJECT|grep -E "([1-9])([0-9]{1,})? references" 2>&1 >/dev/null; }; then
until { iptables -nL LDREJECT|grep -E "([1-9])([0-9]{1,})? references"; }; do iptables -N LDREJECT|iptables -P LDREJECT REJECT |iptables -t filter -A FORWARD -j LDREJECT; done &> /dev/null & break
else break; fi &> /dev/null &

if ! { iptables -nL LDBAN|grep -E "([1-9])([0-9]{1,})? references" 2>&1 >/dev/null; }; then
until { iptables -nL LDBAN|grep -E "([1-9])([0-9]{1,})? references"; }; do iptables -N LDBAN|iptables -P LDBAN REJECT --reject-with icmp-host-prohibited|iptables -t filter -A FORWARD -j LDBAN; done &> /dev/null & break
else break; fi &> /dev/null &

if ! { iptables -nL LDIGNORE|grep -E "([1-9])([0-9]{1,})? references" 2>&1 >/dev/null; }; then
until { iptables -nL LDIGNORE|grep -E "([1-9])([0-9]{1,})? references"; }; do iptables -N LDIGNORE|iptables -P LDIGNORE ACCEPT|iptables -t filter -A FORWARD -j LDIGNORE; done &> /dev/null & break
else break; fi &> /dev/null &

if ! { iptables -nL LDTEMPHOLD|grep -E "([1-9])([0-9]{1,})? references" 2>&1 >/dev/null; }; then
until { iptables -nL LDTEMPHOLD|grep -E "([1-9])([0-9]{1,})? references"; }; do iptables -N LDTEMPHOLD|iptables -t filter -I FORWARD -j LDTEMPHOLD; done &> /dev/null & break
else break; fi &> /dev/null & #Hold for clear

if ! { iptables -nL LDKTA|grep -E "([1-9])([0-9]{1,})? references" 2>&1 >/dev/null; }; then
until { iptables -nL LDKTA|grep -E "([1-9])([0-9]{1,})? references"; }; do iptables -N LDKTA|iptables -P LDKTA REJECT|iptables -t filter -A FORWARD -j LDKTA; done &> /dev/null & break
else break; fi &> /dev/null & 
#
if ! { iptables -nL LDSENTSTRIKE|grep -E "([1-9])([0-9]{1,})? references" 2>&1 >/dev/null; }; then
until { iptables -nL LDSENTSTRIKE|grep -E "([1-9])([0-9]{1,})? references"; }; do iptables -N LDSENTSTRIKE|iptables -P LDSENTSTRIKE ACCEPT|iptables -t filter -A FORWARD -j LDSENTSTRIKE; done &> /dev/null & break
else break; fi &> /dev/null & #Hold for clear
}
maketables &> /dev/null &
##### Prepare LagDrop's IPTABLES Chains #####
##### Make Options #####
if [ ! -d "$DIR"/42Kmi ] ; then mkdir -p "$DIR"/42Kmi ; fi
if [ ! -d "$DIR"/42Kmi/$SUBFOLDER ] ; then mkdir -p "$DIR"/42Kmi/$SUBFOLDER ; fi
if [ ! -f "$DIR"/42Kmi/options_"$CONSOLENAME".txt ] ; then echo -en "$CONSOLENAME=$GETSTATIC
PINGLIMIT=150
COUNT=15
SIZE=1365
MODE=5
MAXTTL=5
PROBES=3
TRACELIMIT=25
ACTION=REJECT
SENTINEL=OFF
CLEARALLOWED=ON
CLEARBLOCKED=ON
CLEARLIMIT=10
CHECKPORTS=NO
PORTS=
RESTONMULTIPLAYER=NO
NUMBEROFPEERS=
DECONGEST=OFF
SWITCH=ON
;"> "$DIR"/42Kmi/options_"$CONSOLENAME".txt; fi ### Makes options file if it doesn't exist
##### Make Options #####
##### Filter #####
{
case "$1" in
     "$(echo -n "$1" | grep -oEi "(nintendo|wiiu|wii|switch|[0-9]?ds|NSW)")") #Nintendo   
		NINTENDO_SERVERS="(45\.55\.142\.122)|(45\.55)"
        FILTERIP="^38\.112\.28\.9[6-9]|^60\.32\.179\.(1[6-9]|2[0-3])|^60\.36\.183\.15[2-9]|^64\.124\.44\.(4[8-9]|5[0-5])|^64\.125\.103\.|^65\.166\.10\.(10[4-9]|11[0-1])|^84\.37\.20\.(20[8-9]|21[0-5])|^84\.233\.128\.(6[4-9]|[7-9][0-9]|1[0-1][0-9]|12[0-7)|^84\.233\.202\.([0-2][0-9]|3[0-1])|^89\.202\.218([0-9]|1[0-5])|^125\.196\.255\.(19[6-9]|20[0-7])|^125\.199\.254\.(4[8-9]|5[0-9]|6[0-7])|^125\.206\.241\.(17[6-9]|18[0-9]|19[0-1])|^133\.205\.103\.(192[2-9]|20[0-7])|^192\.195\.204\.|^194\.121\.124\.(22[4-9]|23[0-1])|^194\.176\.154\.(16[8-9]|17[0-5])|^195\.10\.13\.(1[6-9]|[2-5][0-9]|6[0-3])|^195\.10\.13\.7[2-5]|^195\.27\.92\.(9[6-9]|1[0-1][0-9]|12[0-7])|^195\.27\.92\.(19[2-9]|20[0-7])|^195\.27\.195\.([0-9]|1[0-5])|^195\.73\.250\.(22[4-9]|23[0-1])|^195\.243\.236\.(13[6-9]|14[0-3])|^202\.232\.234\.(12[8-9]|13[0-9]|14[0-3])|^205\.166\.76\.|^206\.19\.110\.|^208\.186\.152\.|^210\.88\.88\.(17[6-9]|18[0-9]|19[0-1])|^210\.138\.40\.(2[4-9]|3[0-1])|^210\.151\.57\.(8[0-9]|9[0-5])|^210\.169\.213\.(3[2-9]|[4-5][0-9]|6[0-3])|^210\.172\.105\.(1[6-8][0-9]|19[0-1])|^210\.233\.54\.(3[2-9]|4[0-7])|^211\.8\.190\.(19[2-9]|2[0-1][0-9]|22[0-3])|^212\.100\.231\.6[0-1]|^213\.69\.144\.(1[6-8][0-9]|19[0-1])|^217\.161\.8\.2[4-7]|^219\.96\.82\.(17[6-9]|18[0-9]|19[0-1])|^220\.109\.217\.16[0-7]|^125\.199\.254\.50|^192\.195\.204\.40|^192\.195\.204\.176|^205\.166\.76\.176|^207\.38\.8\.15|^207\.38\.11\.1[2-4]|^207\.38\.11\.34|^207\.38\.11\.49|^209\.67\.106\.141|^207\.38\.(8|9|1[0-5])\.|^13\.32\.|^13\.54\.|^23\.20\.|^27\.0\.([0-3])\.|^34\.(19[2-9]|20[0-7])\.|^35\.154\.|^35\.(15[6-9])\.|^35\.(16[0-7])\.|^43\.250\.(19[2-3])\.|^46\.51\.(1[0-9][0-9]|20[0-7])\.|^46\.51\.(21[6-9]|2[2-9][0-9])\.|^46\.137\.|^50\.(1[6-9])\.|^50\.112\.|^52\.([0-9][0-9]|1[0-9][0-9]|2[0-1][0-9]|22[0-2])\.|^54\.([6-9][0-9]|14[4-9]|1[5-9][0-9]|2[0-5][0-9])\.|^67\.202\.([0-5][0-9]|6[0-3])\.|^72\.31\.(19[2-9]|2[0-1][0-9]|22[0-3])\.|^72\.44\.(3[2-9]|[4-5][0-9]|6[0-3])\.|^75\.101\.(12[8-9]|1[3-9]|2[0-9][0-9])\.|^79\.125\.([0-9][0-9]|1[0-1][0-9]|2[0-5][0-9])\.|^87\.238\.(8[0-7])\.|^96\.127\.([0-9][0-9]|1[0-1][0-9]|12[0-7])\.|^103\.4\.([8-9]|1[0-5])\.|^103\.8\.(17[2-5])\.|^103\.246\.(14[8-9]|15[0-1])\.|^107\.(2[0-3])\.|^122\.248\.(19[2-9]|2[0-5][0-9])\.|^172\.96\.97\.|^174\.129\.|^175\.41\.(1[2-8][0-9]|19[0-9]|2[0-5][0-9])|^176\.32\.([6-8][0-9]|9[0-9]|1[0-1][0-9]|12[0-5])|^176\.34\.|^177\.71\.|^177\.72\.(24[0-7])\.|^178\.236\.([0-9]|1[0-5])\.|^184\.7([2-3])\.|^184\.169\.(12[8-9]|1[3-9][0-9]|2[0-5]|[0-9])\.|^185\.48\.(12[0-3])\.|^185\.143\.16\.|^203\.83\.(22[0-3])\.|^204\.236\.(12[8-9]|1[3-9][0-9]|2[[0-5]|[0-9])\.|^204\.246\.(16[0-9]|17[0-1]|17[4-9]|1[8-9][0-9]|2[0-3][0-9]|24[0-5])\.|^205\.251\.(24[7-9]|25[0-5])\.|^207\.171\.(1[6-8][0-9]|19[0-1])\.|^216\.137\.(3[2-9]|[4-5][0-9]|6[0-3])\.|^216\.182\.(22[4-9]|23[0-9])\.|^202\.(3[2-5])\.|^198\.62\.122\.|^69\.25\.139\.(12[8-9]|1[3-9][0-9]|[1-2][0-9]{2})|^34\.(19[2-9]|2[0-9]{2})|^23\.2[0-3]\.|^13\.112\.35\.82|^163\.172\.141\.219|^45\.248\.48\.62|^(${NINTENDO_SERVERS})"
		LOADEDFILTER="${RED}Nintendo${NC}"

          ;;
     "$(echo -n "$1" | grep -oEi "(playstation|ps[2-9]|sony|psx)")") #Sony      
        FILTERIP="^63\.241\.6\.(4[8-9]|5[0-5])|^63\.241\.60\.4[0-4]|^64\.37\.(12[8-9]|1[3-9][0-9])\.|^69\.153\.161\.(1[6-9]|2[0-9]|3[0-1])|^199\.107\.70\.7[2-9]|^199\.108\.([0-9]|1[0-5])\.|^199\.108\.(19[2-9]|20[0-7])\."
		LOADEDFILTER="${BLUE}PlayStation${NC}"

          ;;
     "$(echo -n "$1" | grep -oEi "(microsoft|x[boxne1360]{1,})")") #Microsoft
        FILTERIP="^104\.((6[4-9]{1})|(7[0-9]{1})|(8[0-9]{1})|(9[0-9]{1})|(10[0-9]{1})|(11[0-9]{1})|(12[0-7]{1}))|^13\.((6[4-9]{1})|(7[0-9]{1})|(8[0-9]{1})|(9[0-9]{1})|(10[0-7]{1}))|^131\.253\.(([2-4]{1}[1-9]{1}))|^134\.170\.|^137\.117\.|^137\.135\.|^138\.91\.|^152\.163\.|^157\.((5[4-9]{1})|60)\.|^168\.((6[1-3]{1}))\.|^191\.239\.160\.97|^23\.((3[2-9]{1})|(6[0-7]{1}))\.|^23\.((9[6-9]{1})|(10[0-3]{1}))\.|^2((2[4-9]{1})|(3[0-9]{1}))\.|^40\.((7[4-9]{1})|([8-9]{1}[0-9]{1})|(10[0-9]{1})|(11[0-9]{1})|(12[0-5]{1}))\.|^52\.((8[4-9]{1})|(9[0-5]{1}))\.|^54\.((22[4-9]{1})|(23[0-9]{1}))\.|^54\.((23[0-1]{1}))\.|^64\.86\.|^65\.((5[2-5]{1}))\.|^69\.164.\(([0-9]{1})|([1-5]{1}[0-9]{1})|((6[0-3]{1}))\.|^40.(7[4-9]|[8-9][0-9]|1[0-1][0-9]|12[0-7]).|^138.91.|^13.64.|^157.54.|^157\.(5[4-9]|60)\."
		LOADEDFILTER="${GREEN}Xbox${NC}"

          ;; 
     *) #PC/Debug/Custom
        FILTERIP="^99999" #Debug, Add IPs to whitelist.txt file instead
		LOADEDFILTER="${YELLOW}"$1"${NC}"

esac
}
ONTHEFLYFILTER="amazonaws|amazon|akamaitechnologies|AKAMAI|Akamai|twitter|nintendowifi\.net|(nintendo|xboxlive|sony|playstation)\.net|ps[2-9]|nflxvideo|netflix|easo\.ea\.com|\.ea\.com|\.1e100\.net|.GOGL|goog|Sony Online Entertainment|cloudfront\.net|facebook|fb-net|IANA|Cloudflare|BAD REQUEST|blizzard|NC Interactive|ncsoft|NCINT|RIOT(\s)?GAMES|RIOT|SQUARE ENIX|Valve Corporation|Ubisoft|not found|IANA-RESERVED|\b(dns|ns|NS|DNS)([0-9]{1,)?(\.|\-)\b|google\.com" # Ignores if these words are found in whois requests
#ONTHEFLYFILTER="klhjgdfshjvckxrsjrfkctyjztyflkutyjsrehxcvhjyutresdxfcgh"
MSFT_SERVERS="(52\.(1((4[5-9])|([5-8][0-9])|(9[0-1]))))|(52\.(2(2[4-9]|[3-5][0-9])))|(52\.(9[6-9]|10[0-9]|11[1-5]))"
IANA_IPs="(239\.255\.255\.250)|(10(\.[0-9]{1,3}){3})|(2(2[4-9]|3[0-9])(\.[0-9]{1,3}){3})|(255(\.([0-9]){1,3}){3})|(0\.)|(100\.((6[4-9])|[7-9][0-9]|1(([0-1][0-9])|(2[0-7]))))|(172\.((1[6-9])|(2[0-9])|(3[0-1])))"
ONTHEFLYFILTER_IPs="${IANA_IPs}|${MSFT_SERVERS}|1\.0\.0\.1|1\.1\.1\.1|127\.0\.0\.1|8\.8\.8\.8|8\.8\.4\.4" #Ignores these IPs, usually IANA reserved or something 
##### Filter #####
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
##### Get Country via ipapi.co #####
#ipapi.co, © 2018 Kloudend, Inc.
if [ $SHOWLOCATION = 1 ]; then
getcountry(){
	LDCOUNTRY="" #Reinitialize
	checkcountry(){
	GEOMEM="$(tail +1 ""$DIR"/42Kmi/${GEOMEMFILE}")"
	if echo "$GEOMEM"|grep -E "^("$peer"|"$peerenc")#"; then 
	LDCOUNTRY=$(echo "$GEOMEM"|grep -E "^("$peer"|"$peerenc")#"|sed -n 1p|sed -E "s/^($peer|$peerenc)#//g")
	else
	#LDCOUNTRY="$(echo $(curl --no-keepalive --no-buffer --connect-timeout ${CURL_TIMEOUT} -sk -A "$(echo $(dd bs=1 count=21 if=/dev/urandom 2>/dev/null)|hexdump -v -e '/1 "%02X"'|sed -e s/"0A$"//g)" "https://ipapi.co/"$peer"/json/"|grep -E "(city|region_code|\"country\"|continent_code)"|sed -E "s/^\s*?.*:\s*?//g"|sed -E "s/(\")//g")|sed -E "s/(,$|,?\s?(null))//g")"
	LOCATION_DATA_STORE="$(curl --no-keepalive --no-buffer --connect-timeout ${CURL_TIMEOUT} -sk -A "$(echo $(dd bs=1 count=21 if=/dev/urandom 2>/dev/null)|hexdump -v -e '/1 "%02X"'|sed -e s/"0A$"//g)" "https://ipapi.co/"$peer"/json/")"
	LDCOUNTRY="$(echo $(echo "$LOCATION_DATA_STORE"|grep -E "(city|region_code|\"country\"|continent_code)"|sed -E "s/^\s*?.*:\s*?//g"|sed -E "s/(\")//g")|sed "s/null/$(echo "$LOCATION_DATA_STORE"|grep "\"region\""|sed "s/.*://"|sed -E "s/(\"|,$|,?\s?(null))//g")/"|sed -E "s/(,$|,?\s?(null))//g")"

	wait $!
	if [ -f "$DIR"/42Kmi/ipstack.txt ] ; then
		if [ $LDCOUNTRY = "" ]; then
		#Backup IP Locate by ipstack.com. Visit to get your API key.
		IPStackKEY="$(tail +1 "$DIR"/42Kmi/ipstack.txt|sed -n 1p)"
			LDCOUNTRY="$(echo $(curl --no-keepalive --no-buffer --connect-timeout ${CURL_TIMEOUT} -sk -A "$(echo $(dd bs=1 count=21 if=/dev/urandom 2>/dev/null)|hexdump -v -e '/1 "%02X"'|sed -e s/"0A$"//g)" "http://api.ipstack.com/"$peer"?access_key=$IPStackKEY&format=1"|grep -E "(\"city\"|\"region_code\"|\"country_code\"|\"continent_code\")"|grep -nE ".*"|sort -r|sed -E "s/^[0-9](\s*)?.*:(\s*)?//g"|sed -E "s/(\")//g")|sed -E "s/(,$|,?\s?(null(,\s)?))//g")" #sed -E "s/(,\s.{2}$)//g"
		fi
	fi
	location_corrections(){
		#Add corrections for formatting.
		case "${LDCOUNTRY}" in
		#AF
		#AS
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Taipei\, TPE\, TW\, AS\, Peicity Digital Cable Television\.\, LTD")")
				LDCOUNTRY="Taipei, TPE, TW, AS"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "^水果湖街道\, CN\, AS")")
				LDCOUNTRY="Wuhan, HB, CN, AS" #Shuiguo Lake, HB, CN, AS
				;;
		#AT
		#EU
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Moscow\, MOW\, RU\, EU\, OJS Moscow city telephone network")")
				LDCOUNTRY="Moscow, MOW, RU, EU"
				;;
		#NA
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Emigrant Gap\, US\, NA")")
				LDCOUNTRY="Emigrant Gap, CA, US, NA"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Research Triangle Park, US, NA")")
				LDCOUNTRY="Research Triangle Park, NC, US, NA"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Newcastle\, US\, NA")")
				LDCOUNTRY="Newcastle, WA, US, NA"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Maplewood\, US\, NA")")
				LDCOUNTRY="Maplewood, MN, US, NA"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Northlake\, US\, NA")")
				LDCOUNTRY="Northlake, Il, US, NA"
				;;
		#SA
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Manguinhos\, BR\, SA")")
				LDCOUNTRY="Manguinhos, RJ, BR, SA"
				;;
		#OC
		#General null region
			"$(echo "${LDCOUNTRY}"|grep -Eo "^([a-zA-Z -]{1,})\, ([A-Z]{2})\, ([A-Z]{2})$")")
				LDCOUNTRY="$(echo "${LDCOUNTRY}"|sed -E "s/([a-zA-Z -]{1,})\, ([A-Z]{2})\, ([A-Z]{2})/\1, 0null0, \2, \3/g")"
				;;
		esac
	}
	location_corrections
	if ! { tail +1 ""$DIR"/42Kmi/${GEOMEMFILE}"| grep -E "^("$peer"|"$peerenc")#"; }; then echo ""$peerenc"#"$LDCOUNTRY"" >> ""$DIR"/42Kmi/${GEOMEMFILE}"; fi
	LDCOUNTRYCHECK="$(echo $LDCOUNTRY|sed -E "s/.{4}$//g")"
	CONTINENT="$(echo $LDCOUNTRY|sed -E "s/.{4}$//g")"
	fi
	if echo "$LDCOUNTRY"|grep -E "AF$"; then
		LDCOUNTRY_toLog="${GREEN}$(echo "$LDCOUNTRY"|sed -E "s/.{4}$//g")${NC}"
		elif echo "$LDCOUNTRY"|grep -E "AN$"; then
		LDCOUNTRY_toLog="${WHITE}$(echo "$LDCOUNTRY"|sed -E "s/.{4}$//g")${NC}"
		elif echo "$LDCOUNTRY"|grep -E "AS$"; then
		LDCOUNTRY_toLog="${LIGHTRED}$(echo "$LDCOUNTRY"|sed -E "s/.{4}$//g")${NC}"
		elif echo "$LDCOUNTRY"|grep -E "EU$"; then
		LDCOUNTRY_toLog="${LIGHTBLUE}$(echo "$LDCOUNTRY"|sed -E "s/.{4}$//g")${NC}"
		elif echo "$LDCOUNTRY"|grep -E "NA$"; then
		LDCOUNTRY_toLog="${MAGENTA}$(echo "$LDCOUNTRY"|sed -E "s/.{4}$//g")${NC}"
		elif echo "$LDCOUNTRY"|grep -E "OC$"; then
		LDCOUNTRY_toLog="${CYAN}$(echo "$LDCOUNTRY"|sed -E "s/.{4}$//g")${NC}"
		elif echo "$LDCOUNTRY"|grep -E "SA$"; then
		LDCOUNTRY_toLog="${YELLOW}$(echo "$LDCOUNTRY"|sed -E "s/.{4}$//g")${NC}"
	fi
	}

##### Regional & Country Bans #####
	bancountry(){
	BANCOUNTRY="" #Reinitialize
		if [ -f "$DIR"/42Kmi/bancountry.txt ] ; then
		#Country
		BANCOUNTRY="$(echo $(echo "$(tail +1 ""${DIR}"/42Kmi/bancountry.txt"|sed -E "s/$/|/g")")|sed -E "s/\|$//g"|sed -E "s/\| /|/g"|sed 's/,/\\,/g'|sed -E "s/\|$//")" # "CC" format for Country only; "RR, CC" format for Region by Country; "(RR|GG), CC" format for multiple regions by country
			if { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"| grep -Ei "($BANCOUNTRY)"; }; then
			BANCOUNTRYIP=$(tail +1 "/tmp/$RANDOMGET"| grep -Ei "($BANCOUNTRY).\[.*$"|grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}""${ADDWHITELIST}")
			for ip in $BANCOUNTRYIP; do
				if ! { iptables -nL LDBAN|grep -E "\b${ip}\b"; }; then
				eval "iptables -A LDBAN -s $ip -d $CONSOLE -j REJECT --reject-with icmp-host-prohibited "${WAITLOCK}""; wait $!
				fi
				TABLENAMES=$(echo -e "LDACCEPT|LDREJECT|LDTEMPHOLD"|tr "|" "\\n")
				for tablename in $TABLENAMES; do
					TABLELINENUMBER=$(iptables --line-number -nL $tablename|grep -E "\b${ip}\b"|grep -Eo "^\s?[0-9]{1,}")
					if iptables -nL $tablename; then 
						eval "iptables -D $tablename "$TABLELINENUMBER""
					fi
				done
				sed -i -E "s/(${ip}.*$)/$(echo -e "${BG_RED}")&/g" "/tmp/$RANDOMGET"; sleep 5 #Background color notification for banned country/region
				wait $!; sed -i -E "/(m)?${ip}#/d" "/tmp/$RANDOMGET"
				eval "wait $!; sed -i -E "/\b${ip}\b#/d" "/tmp/$RANDOMGET""
			done &
			fi &
		fi
	}
##### Regional & Country Bans #####
checkcountry; bancountry
}
fi
##### Get Country via ipapi.co #####
timestamps(){ EPOCH="$(date +%s)" && DATETIME="$(date +"%Y-%m-%d#%X")"; }
cleanliness(){
	#Check tables, delete from tables if not in log.
	cleantable(){
	TABLENAMES=$(echo -e "LDACCEPT|LDREJECT|LDTEMPHOLD"|tr "|" "\\n")
	for tablename in $TABLENAMES; do
		IPLIST=$(iptables -nL $tablename|tail +3|grep -E "\b${CONSOLE}\b"|grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}"|grep -Ev "\b(${CONSOLE}|0.0.0.0)\b")
			for ip in $IPLIST; do
			if ! { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E "\b${ip}#"; }; then 
				case $tablename in
				LDACCEPT)
					TABLELINENUMBER=$(iptables --line-number -nL $tablename|grep -E "\b${ip}\b"|grep -Eo "^\s?[0-9]{1,}")
					eval "iptables -D LDACCEPT $TABLELINENUMBER"
					;;
				LDREJECT)
					TABLELINENUMBER=$(iptables --line-number -nL $tablename|grep -E "\b${ip}\b"|grep -Eo "^\s?[0-9]{1,}")
					eval "iptables -D LDREJECT $TABLELINENUMBER"
				;;
				LDTEMPHOLD)
					TABLELINENUMBER=$(iptables --line-number -nL $tablename|grep -E "\b${ip}\b"|grep -Eo "^\s?[0-9]{1,}")
					eval "iptables -D LDTEMPHOLD $TABLELINENUMBER"
				;;
				esac
			fi
		done
	done &
	}
	#Check log, delete from log if not in iptable
	cleanlog(){
	TABLENAMES=$(echo -e "LDACCEPT|LDREJECT"|tr "|" "\\n")
	for tablename in $TABLENAMES; do
		case $tablename in
		LDACCEPT)
		IPLISTACCEPT=$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Ev "\b${RESPONSE3}\b"|grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}")
		for ip in $IPLISTACCEPT; do
			if ! { iptables -nL $tablename|grep -E "\b${CONSOLE}\b"|grep -E "${ip}"; }; then
			sed -i -E "/(m)?(${ip})\b/d" "/tmp/$RANDOMGET"
			fi
		done
			;;
		LDREJECT)
			IPLISTREJECT=$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E "\b${RESPONSE3}\b"|grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}")
		for ip in $IPLISTREJECT; do
			if ! { iptables -nL $tablename|grep -E "\b${CONSOLE}\b"|grep -E "${ip}"; }; then
			sed -i -E "/(m)?(${ip})\b/d" "/tmp/$RANDOMGET"
			fi
		done
		;;
		esac
	done &
	}
	#If IP is in ban table, remove from other tables.
	bantidy(){
	BANDTIDYLIST=$(iptables -nL LDBAN|grep -E "\b${CONSOLE}\b"|awk '{printf $4"\n"}'|grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}")
	for ip in $BANDTIDYLIST; do
			LINENUMBERBANDTIDYLISTACCEPTIP=$(iptables --line-number -nL LDACCEPT|grep -E "\b${ip}\b"|grep -Eo "^\s?[0-9]{1,}")
			LINENUMBERBANDTIDYLISTREJECTIP=$(iptables --line-number -nL LDREJECT|grep -E "\b${ip}\b"|grep -Eo "^\s?[0-9]{1,}")
			LINENUMBERBANDTIDYLISTTEMPHOLDIP=$(iptables --line-number -nL LDTEMPHOLD|grep -E "\b${ip}\b"|grep -Eo "^\s?[0-9]{1,}")
			if iptables -nL LDACCEPT|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"; then 
				eval "iptables -D LDACCEPT "$LINENUMBERBANDTIDYLISTACCEPTIP""
			fi
			if iptables -nL LDREJECT|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"; then 
				eval "iptables -D LDREJECT "$LINENUMBERBANDTIDYLISTREJECTIP""
			fi
			if iptables -nL LDTEMPHOLD|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"; then 
				eval "iptables -D LDTEMPHOLD "$LINENUMBERBANDTIDYLISTTEMPHOLDIP""
			fi
	done &
	}
	##### Clean Hold #####
	CLEANLDTEMPHOLDLIST=$(iptables -nL LDTEMPHOLD|tail +3|awk '{printf $3"\n"}')
	for item in $CLEANLDTEMPHOLDLIST; do
	CLEANLDTEMPHOLDNUM=$(iptables -nL --line-number LDTEMPHOLD|grep -E "\b${CONSOLE}\b"|grep -E "\b${item}\b"|grep -Eo "^\s?[0-9]{1,}")
		if ! { iptables -nL LDACCEPT && iptables -nL LDREJECT|grep -E "\b${item}\b"; }; then
		eval "iptables -D LDTEMPHOLD "$CLEANLDTEMPHOLDNUM""; #wait $!
		fi
		#continue &> /dev/null
	done
	##### Clean Hold #####

bantidy
cleantable
cleanlog
}

ping_tr_results(){
	#PING-TR RESULTS
	LIMITPERCENT="85"
	if { [ $PINGFULL -gt $(( LIMIT )) ] || [ $TRAVGFULL -gt $(( TRACELIMIT )) ]; }; then RESULT="${RED}${RESPONSE3}${NC}"
	else
		if [ $PINGFULL -le $(( LIMIT * LIMITPERCENT / 100 )) ] && [ $TRAVGFULL -le $(( TRACELIMIT * LIMITPERCENT / 100 )) ]; then
		RESULT="${LIGHTGREEN}${RESPONSE1}${NC}"
		else
			if [ $PINGFULL -gt $(( LIMIT * LIMITPERCENT / 100 )) ] && [ $PINGFULL -le $(( LIMIT )) ] && [ $TRAVGFULL -le $(( TRACELIMIT )) ] || [ $TRAVGFULL -gt $(( TRACELIMIT * LIMITPERCENT / 100 )) ] && [ $TRAVGFULL -le $(( TRACELIMIT )) ] && [ $PINGFULL -le $(( LIMIT )) ]; then
			RESULT="${YELLOW}${RESPONSE2}${NC}"
			fi
		fi
	
	fi
}

pingavgfornull(){
	if [ $SHOWLOCATION = 1 ]; then
	PING_HIST_AVG="" #Resets Ping history average to prevent unneeded multiple use
		if [ $POPULATE = 1 ]; then
			if ! { [ "${PINGFULL}" = "--" ] || [ "${PINGFULL}" = "0" ] || [ $PINGFULLDECIMAL = "0" ] || [ $PINGFULLDECIMAL = "--" ] || [ $PINGFULLDECIMAL = "\-\-" ]; } && ! { grep -F "$(echo -e "${PINGFULLDECIMAL}#${LDCOUNTRY}#"|sed "s/ms#/#/g")" ""$DIR"/42Kmi/${PINGMEM}"; }; then 
			echo -e "${PINGFULLDECIMAL}#${LDCOUNTRY}#"|sed "s/ms#/#/g"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g" >> ""$DIR"/42Kmi/${PINGMEM}"
			fi
		else
			if ! { [ "${PINGFULL}" = "--" ] || [ "${PINGFULL}" = "0" ] || [ $PINGFULLDECIMAL = "0" ] || [ $PINGFULLDECIMAL = "--" ] || [ $PINGFULLDECIMAL = "\-\-" ]; }; then 
			echo -e "${PINGFULLDECIMAL}#${LDCOUNTRY}#"|sed "s/ms#/#/g"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g" >> ""$DIR"/42Kmi/${PINGMEM}"
			fi
		fi
		
	PING_HIST_AVG_MIN=5 #Minimum number of similar regions to count before taking average
	
		if { [ "${PINGFULL}" = "--" ] || [ "${PINGFULL}" = "0" ] || [ $PINGFULLDECIMAL = "0" ] || [ $PINGFULLDECIMAL = "--" ] || [ $PINGFULLDECIMAL = "\-\-" ]; }; then
		LOCATION_filter=$(echo -e "#${LDCOUNTRY}#"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g")
		LOCATION_filter_Continent=$(echo "${LOCATION_filter}"|grep -Eo "[A-Z]{2}#$")
		LOCAL_LINES_count=$(tail +1 ""$DIR"/42Kmi/${PINGMEM}"|grep -Ec "${LOCATION_filter}")
		PING_HIST_AVG_COLOR=0 #Green for same city average
			if [ $LOCAL_LINES_count -lt $PING_HIST_AVG_MIN ]; then
				REGION_filter=$(echo -e "$LOCATION_filter"|grep -Eo "(,\ (.*\,)? [A-Z]{2}, [A-Z]{2}#)"|sed -E "s/(^\s\,)//g")
				REGION_LINES_count=$(tail +1 ""$DIR"/42Kmi/${PINGMEM}"|grep -Ec "${REGION_filter}")
				PING_HIST_AVG_COLOR=1 #Yellow for same region average
				if [ $REGION_LINES_count -lt $(( $PING_HIST_AVG_MIN * 2 )) ]; then
					COUNTRY_filter=$(echo -e "$REGION_filter"|grep -Eo "[A-Z]{2}, [A-Z]{2}#$")
					COUNTRY_LINES_count=$(tail +1 ""$DIR"/42Kmi/${PINGMEM}"|grep -Ec "${COUNTRY_filter}")
					PING_HIST_AVG_COLOR=2 #Cyan for same country average
						if [ $COUNTRY_LINES_count -lt $(( $PING_HIST_AVG_MIN * 5 )) ]; then
							CONTINENT_filter=$(echo -e "$COUNTRY_filter"|grep -Eo "[A-Z]{2}#$")
							CONTINENT_LINES_count=$(tail +1 ""$DIR"/42Kmi/${PINGMEM}"|grep -Ec "${CONTINENT_filter}")
							PING_HIST_AVG_COLOR=3 #Magenta for same continent average
							if [ $CONTINENT_LINES_count -lt $(( $PING_HIST_AVG_MIN * 12 )) ]; then
								PING_HIST_AVG_COLOR="XXXXXXXXXX"
								PINGFULL=""
								PINGFULLDECIMAL="$NULLTEXT"
								else
								GET_PING_VALUES=$(echo $(tail +1 ""$DIR"/42Kmi/${PINGMEM}"|grep "$LOCATION_filter_Continent"|grep "${CONTINENT_filter}"|sed -E "s/(ms)?#.*$//g"|sed "s/\.//g"|sed -E "s/$/+/g")|sed -E "s/(\+$)//g")
							fi
						else 
						GET_PING_VALUES=$(echo $(tail +1 ""$DIR"/42Kmi/${PINGMEM}"|grep "$LOCATION_filter_Continent"|grep "${COUNTRY_filter}"|sed -E "s/(ms)?#.*$//g"|sed "s/\.//g"|sed -E "s/$/+/g")|sed -E "s/(\+$)//g")
						fi

					else
					GET_PING_VALUES=$(echo $(tail +1 ""$DIR"/42Kmi/${PINGMEM}"|grep "$LOCATION_filter_Continent"|grep "${REGION_filter}"|sed -E "s/(ms)?#.*$//g"|sed "s/\.//g"|sed -E "s/$/+/g")|sed -E "s/(\+$)//g")
				fi
				else
				GET_PING_VALUES=$(echo $(tail +1 ""$DIR"/42Kmi/${PINGMEM}"|grep "$LOCATION_filter_Continent"|grep "${LOCATION_filter}"|sed -E "s/(ms)?#.*$//g"|sed "s/\.//g"|sed -E "s/$/+/g")|sed -E "s/(\+$)//g")
			fi
		GET_PING_VALUES_COUNT=$(echo "$GET_PING_VALUES"|wc -w)
		GET_PING_VALUES_SUM=$(( $(echo "$GET_PING_VALUES") ))
		PING_HIST_AVG=$(( GET_PING_VALUES_SUM / GET_PING_VALUES_COUNT ))
		PING_HIST_AVG_DECIMAL=$(echo "$(echo "$PING_HIST_AVG" | sed 's/.\{3\}$/.&/'| sed -E 's/^\./0./g'|sed -E 's/$/ms/g')")
		fi

		if [ $FORNULL = 1 ] && { [ $PINGFULLDECIMAL = "$PINGFULLDECIMAL" ] || [ $PINGFULLDECIMAL = "0" ]; }; then
			if [ $PING_HIST_AVG != 0 ]; then
			PINGFULL=$PING_HIST_AVG
			case "$PING_HIST_AVG_COLOR" in
				0)
					PINGFULLDECIMAL=$(echo -e "${GREEN}${PING_HIST_AVG_DECIMAL}${NC}")
					;;
				1)
					PINGFULLDECIMAL=$(echo -e "${YELLOW}${PING_HIST_AVG_DECIMAL}${NC}")
					;;
				2)
					PINGFULLDECIMAL=$(echo -e "${CYAN}${PING_HIST_AVG_DECIMAL}${NC}")
					;;
				3)
					PINGFULLDECIMAL=$(echo -e "${MAGENTA}${PING_HIST_AVG_DECIMAL}${NC}")
					;;
				XXXXXXXXXX)
					PINGFULLDECIMAL="$NULLTEXT"
					;;
			esac
			ping_tr_results
			else
			PINGFULLDECIMAL="$NULLTEXT" 
			fi
		fi
	fi
}

meatandtatoes(){ 
	#borneopeer="$(borneo "$peer")"
	borneopeer="$peer"
		#Do you believe in magic?
		##### Whitelisting/ NSLookup #####
		SERVERS="${ONTHEFLYFILTER}"
		if ! { { echo "$EXIST_LIST"; }|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"| tail +1 ""$DIR"/42Kmi/${FILTERIGNORE}"|grep -Eoq "^("$peer"|"$peerenc")$"; }; then
			if { nslookup "$peer" localhost|grep -Ev "\b(${IGNORE})\b"|grep -Eoi "\b(${SERVERS})\b"; }; then
			 eval "iptables -I LDIGNORE -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"; $IGNORE"; if ! { grep -Eo "^(${peer}|${peerenc})$" ""$DIR"/42Kmi/${FILTERIGNORE}"; }; then echo "$peerenc" >> ""$DIR"/42Kmi/${FILTERIGNORE}"; fi
				else
				WHOIS="$(curl -sk --no-keepalive --no-buffer --connect-timeout ${CURL_TIMEOUT} "https://rdap.arin.net/registry/ip/"$peer"")"
				WHOIS2="$(curl -sk --no-keepalive --no-buffer --connect-timeout ${CURL_TIMEOUT} "http://lacnic.net/cgi-bin/lacnic/whois?lg=EN&query="$peer"")"
				if { { { echo "$WHOIS"|sed -E "s/^\s*//g"|sed "s/\"//g"| sed -E "s/(\[|\]|\{|\}|\,)//g"|sed "s/\\n/,/g"; }|sed  "s/],/]\\n/g"|sed -E "s/(\[|\]|\{|\})//g"|sed -E "s/(\")\,(\")/\1\\n\2/g"|sed -E '/^\"\"$/d'|sed 's/"//g'; }|grep -Eoi "^[a-z]{1,}\:.*$"|grep -Ev "\b(${IGNORE})\b"|grep -Eoi "\b(${SERVERS})\b"; } 2>&1 >/dev/null; then eval "iptables -I LDIGNORE -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"; $IGNORE"; if ! { grep -Eo "^(${peer}|${peerenc})$" ""$DIR"/42Kmi/${FILTERIGNORE}"; }; then echo "$peerenc" >> ""$DIR"/42Kmi/${FILTERIGNORE}"; fi
				#Fallback
				elif { { { echo "$WHOIS"|sed -E "s/^\s*//g"|sed "s/\"//g"| sed -E "s/(\[|\]|\{|\}|\,)//g"|sed "s/\\n/,/g"; }|sed  "s/],/]\\n/g"|sed -E "s/(\[|\]|\{|\})//g"|sed -E "s/(\")\,(\")/\1\\n\2/g"|sed -E '/^\"\"$/d'|sed 's/"//g'; }|grep -Eoi "^[a-z]{1,}\:.*$"|grep -Ev "\b(${IGNORE})\b"|grep -Eoi "\b(${SERVERS})\b"; } 2>&1 >/dev/null; then eval "iptables -I LDIGNORE -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"; $IGNORE"; if ! { grep -Eo "^(${peer}|${peerenc})$" ""$DIR"/42Kmi/${FILTERIGNORE}"; }; then echo "$peerenc" >> ""$DIR"/42Kmi/${FILTERIGNORE}"; fi
				fi
			fi
		fi
		##### Whitelisting/ NSLookup #####
		$IGNORE 
		##### Get Country #####
		if ! { { echo "$EXIST_LIST"; }|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"| tail +1 ""$DIR"/42Kmi/${FILTERIGNORE}"|grep -Eoq "^("$peer"|"$peerenc")#"; }; then
			if [ $SHOWLOCATION = 1 ]; then getcountry; fi
		fi

		##### Get Country #####
		if ! { { echo "$EXIST_LIST"; }|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|tail +1 ""$DIR"/42Kmi/${FILTERIGNORE}"| grep -Eoq "^("$peer"|"$peerenc")$"; }; then
		##### The Ping #####
		theping(){
		#Rapid Ping, New Ping Method
		if [ "${MODE}" = 2 ]; then PINGFULLDECIMAL="$NULLTEXT";
		else
			if [ $SMARTMODE = 1 ]; then
			##### Smart Limit #####
			# Dynamically adjusts limit value for smarter limit control
			if tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eioq "\b(${RESPONSE1}|${RESPONSE2})\b"; then
				SMARTLINES="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed -E "/\b(${RESPONSE3}|\-\-)\b/d"|wc -l)"
				GETSMARTLIMIT="$(( $(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed "s/#/\ /g"|sed -E "/\b(${RESPONSE3}|\-\-)\b/d"|sed -E "s/(ms|\.)//g"|awk '{printf "%s\+" $4}'| sed -E 's/^\+//g') ))"
				LIMIT="$(echo "$(( (( GETSMARTLIMIT )) / SMARTLINES ))"|sed -E "s/(.{3})$/.\1/g")"; if [ $LIMIT = 0 ]; then LIMIT=$(echo "$SETTINGS"|sed -n 2p); fi; if echo "$LIMIT"| grep -Eo "\.([0-9]{3})$"; then LIMIT="$(echo "$LIMIT"|sed -E "s/\.//g")"; else LIMIT="$(( LIMIT * 1000 ))"; fi
				if [ $LIMITTEST = "" ]; then
				LIMITTEST=$(echo "$SETTINGS"|sed -n 2p); if echo "$LIMITTEST"| grep -Eo "\.([0-9]{3})$"; then LIMITTEST="$(echo "$LIMITTEST"|sed -E "s/\.//g")"; else LIMITTEST="$(( LIMITTEST * 1000 ))"; fi
				fi
				LIMITXSQ=$(echo $(( (( 2 * (( (( LIMITTEST - LIMIT )) ** 2 )) )) / (( LIMITTEST + LIMIT )) ))|sed "s/\-//g")
				if { { [ $SMARTLINES -lt $SMARTLINECOUNT ] || [ $LIMITTEST = "" ]; } || ! [ $(echo "$(for item in $(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed "s/#/\ /g"|sed -E "/\b(${RESPONSE3}|\-\-)\b/d"|sed -E "s/(ms|\.)//g"|awk '{printf $4"\n"}'); do echo $(( $item > $(( LIMIT * SMARTPERCENT / 100 )) )); done)"|grep -c "1") -ge $SMART_AVG_COND ]; }; then LIMIT=$(echo "$SETTINGS"|sed -n 2p); if echo "$LIMIT"| grep -Eo "\.([0-9]{3})$"; then LIMIT="$(echo "$LIMIT"|sed -E "s/\.//g")"; else LIMIT="$(( LIMIT * 1000 ))"; fi; else LIMIT="$(( LIMIT + LIMITXSQ ))"; fi
				LIMITTEST=$LIMIT
			else
			LIMIT=$(echo "$SETTINGS"|sed -n 2p) ### Your max average millisecond limit. Peers returning values higher than this value are blocked.
				if echo "$LIMIT"| grep -Eo "\.([0-9]{3})$"; then LIMIT="$(echo "$LIMIT"|sed -E "s/\.//g")"; else LIMIT="$(( LIMIT * 1000 ))"; fi
			fi
				if [ $SHOWSMART = 1 ]; then SHOWSMARTLOG=$(echo "$LIMIT"|sed -E "s/(.{3})$/.\1/g"); fi
			##### Smart Limit #####
			else LIMIT=$(echo "$SETTINGS"|sed -n 2p) ### Your max average millisecond limit. Peers returning values higher than this value are blocked.
			if echo "$LIMIT"| grep -Eo "\.([0-9]{3})$"; then LIMIT="$(echo "$LIMIT"|sed -E "s/\.//g")"; else LIMIT="$(( LIMIT * 1000 ))"; fi
			fi
			COUNT=$(echo "$SETTINGS"|sed -n 3p) ### How many packets to send. Default is 5
			if [ -f "$DIR"/42Kmi/tweak.txt ] ; then PINGRESOLUTION="${TWEAKPINGRESOLUTION}"; else PINGRESOLUTION=5; fi
			#PINGGET=$(echo $(echo "$(n=0; while [[ $n -lt "${COUNT}" ]]; do { ping -q -c "${PINGRESOLUTION}" -W 1 -s "${SIZE}" "${peer}" & } ; n=$((n+1)); done )"|grep -Eo "\/([0-9]{1,}\.[0-9]{1,})\/"|sed -E 's/(\/|\.)//g'|sed -E 's/(^|\b)(0){1,}//g'|sed -E 's/$/+/g')|sed -E 's/\+$//g') &> /dev/null
			PINGGET=$(echo $(echo "$(n=0; while [[ $n -lt "${COUNT}" ]]; do { ping -c "${PINGRESOLUTION}" -W 1 -s "${SIZE}" "${peer}" & } ; n=$((n+1)); done )"|grep -Eo "time=(.*)$"|sed -E 's/( ms|\.|time=)//g'|sed -E 's/(^|\b)(0){1,}//g'|sed -E 's/$/+/g')|sed -E 's/\+$//g') &> /dev/null
			wait $!
			PINGCOUNT=$(echo "$PINGGET"|wc -w)
			if ! [ "${PINGCOUNT}" != "$(echo -n "$PINGCOUNT" | grep -oEi "(0|)")" ]; then PINGCOUNT=$(( COUNT * PINGRESOLUTION )); fi #Fallback
			PINGSUM=$(( $PINGGET ))
			if [ $PINGSUM = 0 ]; then PINGSUM=$(( $(( LIMIT / 1000 + 1 )) * PINGRESOLUTION * COUNT )); FORNULL=1; else FORNULL=0; fi
			PINGFULL=$(( PINGSUM / PINGCOUNT ))
			PING=$(echo "$PINGFULL"|sed -E 's/.{3}$//g' )
			PINGFULLDECIMAL=$(echo "$(echo "$PINGFULL" | sed 's/.\{3\}$/.&/'| sed -E 's/^\./0./g'|sed -E 's/$/ms/g')")
		fi
		if [ "${MODE}" = "$(echo -n "$MODE" | grep -oEi "([0-1]{1})")" ]; then TRFULLDECIMAL="$NULLTEXT"; fi
		}
		##### The Ping #####
		MODE=$(echo "$SETTINGS"|sed -n 5p)
		if ! [ "$MODE" != "$(echo -n "$MODE" | grep -oEi "([2-5]{1})")" ]; then
		##### TRACEROUTE #####
		thetraceroute(){
			##### PARAMETERS #####
			MAXTTL=$(echo "$SETTINGS"|sed -n 6p)
			TTL=$(if [ "${MAXTTL}" -le 255 ] && [ "${MAXTTL}" -ge 1 ]; then echo "$MAXTTL"; else echo 10; fi)
			PROBES=$(echo "$SETTINGS"|sed -n 7p)
			if [ $SMARTMODE = 1 ]; then
			##### Smart TRACELIMIT #####
			# Dynamically adjusts TRACELIMIT value for smarter TRACELIMIT control
			if tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eioq "\b(${RESPONSE1}|${RESPONSE2})\b"; then
				SMARTLINES="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed -E "/\b(${RESPONSE3}|\-\-)\b/d"|wc -l)"
				GETSMARTTRACELIMIT="$(( $(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed "s/#/\ /g"|sed -E "/\b(${RESPONSE3}|\-\-)\b/d"|sed -E "s/(ms|\.)//g"|awk '{printf "%s\+" $5}'| sed -E 's/^\+//g') ))"
				TRACELIMIT="$(echo "$(( (( GETSMARTTRACELIMIT )) / SMARTLINES ))"|sed -E "s/(.{3})$/.\1/g")"; if [ $TRACELIMIT = 0 ]; then TRACELIMIT=$(echo "$SETTINGS"|sed -n 8p); fi; if echo "$TRACELIMIT"| grep -Eo "\.([0-9]{3})$"; then TRACELIMIT="$(echo "$TRACELIMIT"|sed -E "s/\.//g")"; else TRACELIMIT="$(( TRACELIMIT * 1000 ))"; fi
				if [ $TRACELIMITTEST = "" ]; then
				TRACELIMITTEST=$(echo "$SETTINGS"|sed -n 8p); if echo "$TRACELIMITTEST"| grep -Eo "\.([0-9]{3})$"; then TRACELIMITTEST="$(echo "$TRACELIMITTEST"|sed -E "s/\.//g")"; else TRACELIMITTEST="$(( TRACELIMITTEST * 1000 ))"; fi
				fi
				TRACELIMITXSQ=$(echo $(( (( 2 * (( (( TRACELIMITTEST - TRACELIMIT )) ** 2 )) )) / (( TRACELIMITTEST + TRACELIMIT )) ))|sed "s/\-//g")
				if { { [ $SMARTLINES -lt $SMARTLINECOUNT ] || [ $TRACELIMITTEST = "" ]; } || ! [ $(echo "$(for item in $(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed "s/#/\ /g"|sed -E "/\b(${RESPONSE3}|\-\-)\b/d"|sed -E "s/(ms|\.)//g"|awk '{printf $5"\n"}'); do echo $(( $item > $(( TRACELIMIT * SMARTPERCENT / 100 )) )); done)"|grep -c "1") -ge $SMART_AVG_COND ]; }; then TRACELIMIT=$(echo "$SETTINGS"|sed -n 8p); if echo "$TRACELIMIT"| grep -Eo "\.([0-9]{3})$"; then TRACELIMIT="$(echo "$TRACELIMIT"|sed -E "s/\.//g")"; else TRACELIMIT="$(( TRACELIMIT * 1000 ))"; fi; else TRACELIMIT="$(( TRACELIMIT + TRACELIMITXSQ ))"; fi
				TRACELIMITTEST=$TRACELIMIT
			else
			TRACELIMIT=$(echo "$SETTINGS"|sed -n 8p) ### Your max average millisecond TRACELIMIT. Peers returning values higher than this value are blocked.
				if echo "$TRACELIMIT"| grep -Eo "\.([0-9]{3})$"; then TRACELIMIT="$(echo "$TRACELIMIT"|sed -E "s/\.//g")"; else TRACELIMIT="$(( TRACELIMIT * 1000 ))"; fi
			fi
				if [ $SHOWSMART = 1 ]; then SHOWSMARTLOGTR=$(echo "$TRACELIMIT"|sed -E "s/(.{3})$/.\1/g"); fi
			##### Smart TRACELIMIT #####
			else TRACELIMIT=$(echo "$SETTINGS"|sed -n 8p)
			if echo "$TRACELIMIT"| grep -Eo "\.([0-9]{3})$"; then TRACELIMIT="$TRACELIMIT"; else TRACELIMIT="$(( TRACELIMIT * 1000 ))"; fi
			fi
			##### PARAMETERS #####
			if [ -f "$DIR"/42Kmi/tweak.txt ] ; then TRGETCOUNT="${TWEAKTRGETCOUNT}"; else TRGETCOUNT=20; fi
			MXP=$(( TTL * PROBES * TRGETCOUNT ))
			#New TraceRoute
			TRGET=$(echo $(echo "$(n=0; while [[ $n -lt "${TTL}" ]]; do { traceroute -Fn -m "${TRGETCOUNT}" -q "${PROBES}" -w 1 "${peer}" "${SIZE}" & } ; n=$((n+1)); done )"|grep -Eo "([0-9]{1,}\.[0-9]{3}\ ms)"|sed -E 's/(\/|\.|\ ms)//g'|sed -E 's/(^|\b)(0){1,}//g'|sed -E 's/$/+/g')|sed -E 's/\+$//g') &> /dev/null
			wait $!
			TRCOUNT=$(echo "$TRGET"|wc -w) #Counts for average
			if [ "${TRCOUNT}" = "$(echo -n "$TRCOUNT" | grep -oEi "(0|)")" ]; then TRCOUNT=$(( TTL * PROBES)); fi #Fallback
			TRSUM=$(( $TRGET ))
			if [ $TRGET = 0 ]; then TRGET=$(( $(( TRACELIMIT / 1000 + 1 )) * MXP )); FORNULLTR=1 ;else FORNULLTR=0; fi
			if [ "${TRCOUNT}" != 0 ]; then
			TRAVGFULL=$(( TRSUM / TRCOUNT )) #TRACEROURTE sum for math
			TRAVG=$(echo $TRAVGFULL | sed -E's/.{3}$//g')
			else
			TRAVGFULL=$(( TRSUM / MXP )) #TRACEROURTE sum for math
			TRAVG=$(echo $TRAVGFULL | sed -E's/.{3}$//g')
			fi
			TRAVGFULLDECIMAL=$(echo "$(echo "$TRAVGFULL" | sed 's/.\{3\}$/.&/'| sed -E 's/^\./0./g'|sed -E 's/$/ms/g')")
		}
		fi
		##### TRACEROUTE #####
		if ! { { echo "$EXIST_LIST"; }|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"| tail +1 ""$DIR"/42Kmi/${FILTERIGNORE}"|grep -Eoq "^("$peer"|"$peerenc")$"; }; then
		{ theping && thetraceroute; }
		timestamps
		fi
fi
		##### ACTION of IP Rule #####
		ACTION=$(echo "$SETTINGS"|sed -n 9p) ### DROP (1)/REJECT(0) 
		ACTION1=$(if [ "$ACTION" = "$(echo -n "$ACTION" | grep -oEi "(drop|1)")" ]; then echo "DROP"; else echo "REJECT"; fi)
		##### ACTION of IP Rule #####

		ping_tr_results
		
##### NULL/NO RESPONSE PEERS #####
if ! { { echo "$EXIST_LIST"; }|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"| tail +1 ""$DIR"/42Kmi/${FILTERIGNORE}"|grep -Eoq "^("$peer"|"$peerenc")$"; }; then
if [ $FORNULL = 1 ]; then
if { [ $PINGFULLDECIMAL = "$PINGFULLDECIMAL" ] && [ $TRAVGFULLDECIMAL = "0ms" ]; }; then eval "iptables -A LDIGNORE -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"; $IGNORE"; fi
fi
fi; $IGNORE
NULLTEXT="--"
if [ $FORNULL = 1 ] && { [ $PINGFULLDECIMAL = "$PINGFULLDECIMAL" ] || [ $PINGFULLDECIMAL = "0" ]; }; then PINGFULLDECIMAL="$NULLTEXT"; fi
#if [ $FORNULLTR = 1 ] && { [ $TRFULLDECIMAL = "$TRFULLDECIMAL" ] || [ $TRFULLDECIMAL = "0" ]; }; then TRFULLDECIMAL="$NULLTEXT"; fi
if [ $FORNULLTR = 1 ] && { [ $TRAVGFULLDECIMAL = "$TRAVGFULLDECIMAL" ] || [ $TRAVGFULLDECIMAL = "0" ]; }; then TRAVGFULLDECIMAL="$NULLTEXT"; fi
##### NULL/NO RESPONSE PEERS #####
if [ $PINGFULLDECIMAL = "$NULLTEXT" ] && [ TRAVGFULLDECIMAL = "$NULLTEXT" ]; then eval "iptables -A LDBAN -p all -s $peer -d $CONSOLE -j REJECT "${WAITLOCK}""; fi
		##### Count Connected IPs #####
		NUMBEROFPEERS=$(echo "$SETTINGS"|sed -n 17p)
		OMIT=$("$WHITELIST" && "$BLACKLIST"|sed -E 's/\^//g')
		IPCONNECTCOUNT=$(echo -ne "$IPCONNECT"| grep -Ev "$OMIT"|wc -l)
		##### Count Connected IPs #####
		#Rest on Multiplayer
		{
		if ! { { { echo "$EXIST_LIST"; }; }|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"| tail +1 ""$DIR"/42Kmi/${FILTERIGNORE}"|grep -Eoq "^("$peer"|"$peerenc")$"; }; then
		if ! { [ "$RESTONMULTIPLAYER" = "$(echo -n "$RESTONMULTIPLAYER" | grep -oEi "(yes|1|on|enable(d?))")" ] && [ "${IPCONNECTCOUNT}" -ge "${NUMBEROFPEERS}" ]; }; then
		##### BLOCK ##### // 0 or 1=Ping, 2=TraceRoute, 3=Ping or TraceRoute, 4=Ping & TraceRoute
		# Store ping histories for future approximating of null pings
		#if [ "$(curl example.com)" != "" ]; then
			if [ $SHOWLOCATION = 1 ]; then
				pingavgfornull
			fi
		#fi
			{
			case "${MODE}" in
				 "$(echo -n "${MODE}" | grep -oEiv "([2345])")") #0 or 1=Ping Only
					  BLOCK=$({ if [ "${PINGFULL}" -gt "${LIMIT}" ]; then { eval "iptables -A LDREJECT -s $peer -d $CONSOLE -j $ACTION1 "${WAITLOCK}";" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"$RESULT"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET;fi; }; else { eval "iptables -A LDACCEPT -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"$RESULT"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET;fi; } fi; } &)
					  ;;
				 "$(echo -n "${MODE}" | grep -oEi "([2])")") #2=TraceRoute Only
					  BLOCK=$({ if [ "${TRAVGFULL}" -gt "${TRACELIMIT}" ]; then { eval "iptables -A LDREJECT -s $peer -d $CONSOLE -j $ACTION1 "${WAITLOCK}";" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"$RESULT"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET;fi; }; else { eval "iptables -A LDACCEPT -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"$RESULT"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET;fi; } fi; } &)
					  ;;
				 "$(echo -n "${MODE}" | grep -oEi "([3])")") #3=Ping OR TraceRoute
					  BLOCK=$({ if [ "${PINGFULL}" -gt "${LIMIT}" ] || [ "${TRAVGFULL}" -gt "${TRACELIMIT}" ]; then { eval "iptables -A LDREJECT -s $peer -d $CONSOLE -j $ACTION1 "${WAITLOCK}";" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"$RESULT"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET;fi; }; else { eval "iptables -A LDACCEPT -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"$RESULT"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET;fi; } fi; } &)
					  ;; 
				 "$(echo -n "${MODE}" | grep -oEi "([4])")") #4=Ping AND TraceRoute
					  #LIMIT="$(( $LIMIT + 5000 ))" #Fuzzy. Lenient for ping times X ms above limit
					  BLOCK=$({ if  { [ "${PINGFULL}" -le "$(( ${LIMIT} + 5000 ))" ] && [ "${TRAVGFULL}" -gt "${TRACELIMIT}" ]; }; then { eval "iptables -A LDACCEPT -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"${YELLOW}${RESPONSE2}${NC}"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET; fi; }; elif { [ "${PINGFULL}" -gt "$(( ${LIMIT} + 5000 ))" ] && [ "${TRAVGFULL}" -gt "${TRACELIMIT}" ]; } || { [ "${PINGFULL}" -gt "$(( ${LIMIT} + 5000 ))" ] && [ "${TRAVGFULL}" -le "${TRACELIMIT}" ]; } || { [ "${PINGFULL}" -lt "1000" ] && [ "${TRAVGFULL}" -gt "${TRACELIMIT}" ]; }; then { eval "iptables -A LDREJECT -s $peer -d $CONSOLE -j $ACTION1 "${WAITLOCK}";" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"${RED}${RESPONSE3}${NC}"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET;fi; }; else { eval "iptables -A LDACCEPT -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"$RESULT"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET; fi; } fi; } &)
					  ;;
				 "$(echo -n "${MODE}" | grep -oEi "([5])")") #4=TraceRoute if Ping is null
				if [ "${PINGFULL}" = "--" ] || [ "${PINGFULL}" = "0" ] || [ $PINGFULLDECIMAL = "0" ] || [ $PINGFULLDECIMAL = "--" ] || [ $PINGFULLDECIMAL = "\-\-" ]; then
					BLOCK=$({ if [ "${TRAVGFULL}" -gt "${TRACELIMIT}" ]; then { eval "iptables -A LDREJECT -s $peer -d $CONSOLE -j $ACTION1 "${WAITLOCK}";" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"$RESULT"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET;fi; }; else { eval "iptables -A LDACCEPT -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"$RESULT"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET;fi; } fi; } &)
				else 
					BLOCK=$({ if  { [ "${PINGFULL}" -le "$(( ${LIMIT} + 5000 ))" ] && [ "${TRAVGFULL}" -gt "${TRACELIMIT}" ]; }; then { eval "iptables -A LDACCEPT -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"${YELLOW}${RESPONSE2}${NC}"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET; fi; }; elif { [ "${PINGFULL}" -gt "$(( ${LIMIT} + 5000 ))" ] && [ "${TRAVGFULL}" -gt "${TRACELIMIT}" ]; } || { [ "${PINGFULL}" -gt "$(( ${LIMIT} + 5000 ))" ] && [ "${TRAVGFULL}" -le "${TRACELIMIT}" ]; } || { [ "${PINGFULL}" -lt "1000" ] && [ "${TRAVGFULL}" -gt "${TRACELIMIT}" ]; }; then { eval "iptables -A LDREJECT -s $peer -d $CONSOLE -j $ACTION1 "${WAITLOCK}";" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"${RED}${RESPONSE3}${NC}"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET;fi; }; else { eval "iptables -A LDACCEPT -p all -s $peer -d $CONSOLE -j ACCEPT "${WAITLOCK}"" && if ! { tail +1 /tmp/$RANDOMGET| grep -Fo "$peer"; }; then echo -e "\"$EPOCH\"$DATETIME#"$borneopeer"#"$PINGFULLDECIMAL"#"$TRAVGFULLDECIMAL"#"$RESULT"#"$SHOWSMARTLOG"#"$SHOWSMARTLOGTR"#"$LDCOUNTRY_toLog"#" >> /tmp/$RANDOMGET; fi; } fi; } &)
				 fi
					  ;;

			esac &
			}
			if ! { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|echo "$PEERIP" |grep $peer; }; then
				if ! { echo "$EXIST_LIST"| grep $peer; }; then $BLOCK
					if ! { iptables -nL LDTEMPHOLD && iptables -nL LDIGNORE && iptables -nL LDBAN| grep $peer; }; then
					eval "iptables -A LDTEMPHOLD -s $peer -d $CONSOLE"
					fi
				fi
			fi

	fi
	fi
	}
		##### BLOCK #####
	
}
stale(){
STALE_NOW=$(date +%s)
STALE_MATH=$(( STALE_NOW - STALE_AGE ))
STALE_LIMIT=5 #In minutes
if [ $STALE_MATH -ge $(( 60 * $STALE_LIMIT )) ] ; then
	if [ $(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Ev "^$") != "" ]; then
		rm -f "/tmp/$RANDOMGET"
		echo -e "$STALE_STASH" > "/tmp/$RANDOMGET"
	fi
fi
}	
#User-Response Functions
#=================
#Executable processes, loops and stuff

	RESPONSE1="OK!!" #OK/GOOD
	RESPONSE2="Warn" #Pushing it...
	RESPONSE3="BLOCK" #BLOCKED

	#RESPONSE1="●●●●●●" #OK/GOOD
	#RESPONSE2="●●●●  " #Pushing it...
	#RESPONSE3="●●    " #BLOCKED
{
lagdrop(){
while "$@" &> /dev/null; do
(
wait $!
#magic Happens Here
##### SETTINGS & TWEAKS #####
SETTINGS=$(tail +1 "$DIR"/42Kmi/options_"$CONSOLENAME".txt|sed -E "s/#.*$//g"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E 's/^.*=//g') #Settings stored here, called from memory
SMARTLINECOUNT=8 #5
SMARTPERCENT=155
SMART_AVG_COND=$(( SMARTLINECOUNT * 40 / 100 )) #2

if [ $SHELLIS = "ash" ]; then
CURL_TIMEOUT=10
else
CURL_TIMEOUT=3
fi

SIZE=$(echo "$SETTINGS"|sed -n 4p) ### Size of packets. Default is 1024
MODE=$(echo "$SETTINGS"|sed -n 5p) ### 0 or 1=Ping, 2=TraceRoute, 3=Ping or TraceRoute, 4=Ping & TraceRoute. Default is 1.
DECONGEST=$(echo "$SETTINGS"|sed -n 18p)
SWITCH=$(echo "$SETTINGS"|tail -1) ### Enable (1)/Disable(0) LagDrop
RESTONMULTIPLAYER=$(echo "$SETTINGS"|sed -n 16p)
##### SETTINGS & TWEAKS #####
# Everything below depends on power switch
if ! [ "$SWITCH" = "$(echo -n "$SWITCH" | grep -oEi "(off|0|disable(d?))")" ]; then
	if [ $POPULATE = 1 ]; then 
	CONSOLE="${ROUTERSHORT_POP}[0-9]{1,3}\.[0-9]{1,3}"
	else
	CONSOLE=$(echo "$SETTINGS"|sed -n 1p) ### Your console's IP address. Change this in the options.txt file
	fi
	#CONSOLE="$(echo -e "$CONSOLE"|tr "|" \\n)" ### Multiple IPs can work! Just separate with "|"
	CHECKPORTS=$(echo "$SETTINGS"|sed -n 14p)
	PORTS=$(echo "$SETTINGS"|sed -n 15p)

	##### Check Ports #####
	getiplist(){
		if [ "$CHECKPORTS" = "$(echo -n "$CHECKPORTS" | grep -oEi "(yes|1|on|enable(d?))")" ]; then
			ADDPORTS='|grep -E "dport\=($PORTS)\b"'
		else
			ADDPORTS=""
		fi
		if [ -f "/proc/net/ip_conntrack" ]; then 
			IPCONNECT_SOURCE='/proc/net/ip_conntrack'
			else
			IPCONNECT_SOURCE='/proc/net/nf_conntrack'	
		fi
		IPCONNECT=$(grep -E "\b${CONSOLE}\b" "${IPCONNECT_SOURCE}""${ADDPORTS}") ### IP connections stored here, called from memory
		}
	getiplist
	##### Check Ports #####
	EXIST_LIST=$(iptables -nL LDACCEPT && iptables -nL LDREJECT && iptables -nL LDBAN && iptables -nL LDIGNORE|grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}"|grep -v "${CONSOLE}")
	IGNORE=$(echo $({ if { { { echo "$EXIST_LIST" && tail +1 ""$DIR"/42Kmi/${FILTERIGNORE}"; } ; }|grep -Eoq "([0-9]{1,3}\.?){4}"; } then echo "$({ { echo "$EXIST_LIST" && tail +1 ""$DIR"/42Kmi/${FILTERIGNORE}"; } ; }|grep -Eo "([0-9]{1,3}\.?){4}"|sort -u|grep -v "${CONSOLE}"|grep -v "127.0.0.1"|sed 's/\./\\\./g')"|sed -E 's/$/\|/g'; else echo "${ROUTER}"; fi; })|sed -E 's/\|$//g'|sed -E 's/\ //g')
	if [ -f "$DIR"/42Kmi/whitelist.txt ] ; then
		WHITELIST=$(echo $(echo "$(tail +1 "${DIR}"/42Kmi/whitelist.txt|sed -E -e "/(#.*$|^$|\;|#^[ \t]*$)|#/d" -e "s/^/\^/g" -e "s/\^#|\^$//g" -e "s/\^\^/^/g" -e "s/$/|/g")") -e 's/\|$//g' -e "s/(\ *)//g" -e 's/\b\.\b/\\./g') ### Additional IPs to filter out. Make whitelist.txt in 42Kmi folder, add IPs there. Can now support extra lines and titles. See README
		ADDWHITELIST="| grep -Ev "$WHITELIST""
	else 
		ADDWHITELIST=""
	fi
	PEERIP=$(echo "$IPCONNECT"|grep -Eo "(([0-9]{1,3}\.?){3})\.([0-9]{1,3})"|grep -Ev "^\b(${CONSOLE}|${ROUTER}|${IGNORE}|${ROUTERSHORT}|${FILTERIP}|${ONTHEFLYFILTER_IPs})\b""${ADDWHITELIST}"|awk '!a[$0]++'|sed -E "s/(\s)*//g") ### Get console Peer's IP DON'T TOUCH!
		##### BLACKLIST #####
		if [ -f "$DIR"/42Kmi/blacklist.txt ] ; then
		###*******Convert to for-loop!!!!!!!
		BLACKLIST=$(echo $(echo "$(tail +1 "${DIR}"/42Kmi/blacklist.txt|sed -E -e "/(#.*$|^$|\;|#^[ \t]*$)|#/d" -e "s/^/\^/g" -e "s/\^#|\^$//g" -e "s/\^\^/^/g" -e "s/$/|/g")") -e 's/\|$//g' -e "s/(\ *)//g" -e 's/\b\.\b/\\./g') ### Permananent ban. If encountered, automatically blocked.
			if { echo "${BLACKLIST}" |grep -E "${peer}"; }; then eval "iptables -A LDBAN -s $peer -d $CONSOLE -j $ACTION1 "${WAITLOCK}";"; fi &
		fi
		##### BLACKLIST #####
	if ! { ping -q -c 1 -W 1 -s 1 "${CONSOLE}"|grep -q -F -w "100% packet loss"; } &> /dev/null; then
	{
	for peer in $PEERIP; do
	if ! { echo "$EXIST_LIST"| grep -E "\b${peer}\b"; }; then
	peerenc="$(echo -n "$peer"|openssl enc -base64 -nosalt -k "42KmiLagDrop")"
	#peerenc="$(echo -n "$peer"|openssl enc -rc4-40 -nosalt -k "42KmiLagDrop")"
		PEERIP="${PEERIP//$peer/\b}"
		LDSIMULLIMIT=8
		if [[ $(printf "$PEERIP"|wc -l) <= $LDSIMULLIMIT ]] && [[ $(printf "$PEERIP"|wc -l) > 0 ]]; then
			wait $!
			{ meatandtatoes; } &
		else
			{ meatandtatoes; }
		fi
		if [ $POPULATE = 1 ]; then
			IGNORE="${IGNORE}|${peer}"
		fi
		$PEERIP
		cleanliness &> /dev/null &
		bancountry &> /dev/null &
	fi
	done
	}
	fi
	#end of LagDrop loops
fi
{
#####Decongest - Block all other connections#####
decongest(){
	if [ "$DECONGEST" = "$(echo -n "$DECONGEST" | grep -oEi "(yes|1|on|enable(d?))")" ]; then
			DECONGESTLIST=$(grep -v "\b${CONSOLE}\b" "${IPCONNECT_SOURCE}"|grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}"|awk '!a[$0]++'|grep -Ev "^${ROUTERSHORT}")
			for kta in $DECONGESTLIST; do
			if ! { iptables -nL LDKTA|grep $kta; }; then
				eval "iptables -A LDKTA -s $kta -j DROP "${WAITLOCK}" &> /dev/null"
			fi
			done

		else
		iptables -F LDKTA
			if { ping -q -c 1 -W 1 -s 1 "${CONSOLE}"|grep -q -F -w "100% packet loss"; }; then iptables -F LDKTA; fi
	fi
}
decongest &> /dev/null
#####Decongest - Block all other connections#####

##### Clear Old #####
#getiplist
CLEARLIMIT=$(echo "$SETTINGS"|sed -n 13p)
DELETEDELAY=60 #60 #300
#Allow
CLEARALLOWED=$(echo "$SETTINGS"|sed -n 11p)
if [ "$CLEARALLOWED" = "$(echo -n "$CLEARALLOWED" | grep -oEi "(yes|1|on|enable(d?))")" ];
then
	COUNTALLOW=$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Ev "\b${RESPONSE3}\b"|wc -l)
	if [ "${COUNTALLOW}" -gt "${CLEARLIMIT}" ]; then
	clearallow(){
	LINENUMBERACCEPTED=$(iptables --line-number -nL LDACCEPT|grep -E "\b${allowed1}\b"|grep -Eo "^\s?[0-9]{1,}")
	eval "iptables -D LDACCEPT "$LINENUMBERACCEPTED""
	sed -i -E "s/((.\[[0-9]{1}(\;[0-9]{2})m)?\b${allowed1}\b.*$)/$(echo -e "${BG_MAGENTA}")&/g" "/tmp/$RANDOMGET"; sleep 5 #Clear warning
	wait $!; sed -i -E "/(m)?${allowed1}#/d" "/tmp/$RANDOMGET"
	}
	clearallow_check(){
	getiplist
	if ! { echo "$IPCONNECT"|grep -Eq "\b${CONSOLE}\b"|grep -Eoq "\b${allowed1}\b"; }; then
	#eval "iptables -A LDTEMPHOLD -s ${allowed1} -d $CONSOLE"; else 
		clearallow
	fi
	}
		#Allowed List Clear
		ACCEPTED1=$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Ev "\b${RESPONSE3}\b"|grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}"|grep -Ev "\b${CONSOLE}\b") #|sed -n 1p)
		for allowed1 in $ACCEPTED1; do wait $!
		COUNTALLOW=$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Ev "\b${RESPONSE3}\b"|wc -l)
		getiplist
		ACCEPTED1="${ACCEPTED1//${allowed1}/\b}"
				{ wait $!
				if ! { echo "$IPCONNECT"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${allowed1}\b"; }; then
					if iptables -nL LDTEMPHOLD| grep -Eo "\b${allowed1}\b"; then
						if ! { echo "$IPCONNECT"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${allowed1}\b"; }; then
						LINENUMBERHOLD1=$(iptables --line-number -nL LDTEMPHOLD|grep -E "\b${allowed1}\b"|grep -Eo "^\s?[0-9]{1,}")
						iptables -D LDTEMPHOLD "$LINENUMBERHOLD1"
						sleep $DELETEDELAY
							clearallow_check
						fi
					else
							clearallow_check
					fi
				fi #& #Must not parallel. Parallelling cause problems.
				} #&
		done & #Must not parallel. Parallelling cause problems.
	fi
fi &
#Blocked
CLEARBLOCKED=$(echo "$SETTINGS"|sed -n 12p)
if [ "$CLEARBLOCKED" = "$(echo -n "$CLEARBLOCKED" | grep -oEi "(yes|1|on|enable(d?))")" ];
	then
		COUNTBLOCKED=$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E "\b${RESPONSE3}\b"|wc -l)
		if [ "${COUNTBLOCKED}" -gt "${CLEARLIMIT}" ]; then
	clearreject(){
		LINENUMBERREJECTED=$(iptables --line-number -nL LDREJECT|grep -E "\b${refused1}\b"|grep -Eo "^\s?[0-9]{1,}")
		eval "iptables -D LDREJECT "$LINENUMBERREJECTED""
		sed -i -E "s/((.\[[0-9]{1}(\;[0-9]{2})m)?\b${refused1}\b.*$)/$(echo -e "${BG_MAGENTA}")&/g" "/tmp/$RANDOMGET"; sleep 5 #Clear warning
		wait $!; sed -i -E "/(m)?${refused1}#/d" "/tmp/$RANDOMGET"
	}
	clearreject_check(){
		getiplist
			if ! { echo "$IPCONNECT"|grep -q "\b${CONSOLE}\b"|grep -Eoq "\b${refused1}\b"; }; then
				#eval "iptables -A LDTEMPHOLD -s ${refused1} -d $CONSOLE"; else 
					clearreject
			fi
	}
			#Blocked List Clear
			REJECTED1=$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E "\b${RESPONSE3}\b"|grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}"|grep -Ev "\b${CONSOLE}\b")
			for refused1 in $REJECTED1; do wait $!
			COUNTBLOCKED=$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E "\b${RESPONSE3}\b"|wc -l)
			getiplist
			REJECTED1="${REJECTED1//${refused1}/\b}"

					{ wait $!
					if ! { echo "$IPCONNECT"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${refused1}\b"; }; then
						if iptables -nL LDTEMPHOLD| grep -Eo "\b${refused1}\b"; then
							if ! { echo "$IPCONNECT"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${refused1}\b"; }; then
							LINENUMBERHOLD2=$(iptables --line-number -nL LDTEMPHOLD|grep "\b${refused1}\b"|grep -Eo "^\s?[0-9]{1,}")
							iptables -D LDTEMPHOLD "$LINENUMBERHOLD2"
							sleep $DELETEDELAY
								clearreject_check
							fi
						else 
							clearreject_check
						fi
					fi #& #Must not parallel. Parallelling cause problems.
					} #&
			done & #Must not parallel. Parallelling cause problems.
		fi
fi &
}

cleanliness &> /dev/null &
bancountry &> /dev/null &
break; exit
)
#continue
done &> /dev/null & 
}
( lagdrop & )
} #&& wait $!
#==========================================================================================================
###### SENTINELS #####
SENTINEL=$(echo "$SETTINGS"|sed -n 10p)
{
if [ "$SENTINEL" = "$(echo -n "$SENTINEL" | grep -oEi "(yes|1|on|enable(d?))")" ]; then
	BYTELOSSLIMIT=1
	BYTEMODE=3
	sentinel(){
	#Sentinel
	#Checks against intrinsic/extrinsic peer lag by comparing difference in transmitted bytes at 2 or more time points
	PACKET_OR_BYTE=1 #1 for packets, 2 for bytes
	SENTINELDELAYBIG=3
	SENTINELDELAYSMALL=1
	STRIKEMAX=3
	SENTINELLIST="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed -E "/\b(${RESPONSE3})\b/d"|grep -Eo "\b([0-9]{1,3}\.){3}([0-9]{1,3})\b")"
	for ip in $SENTINELLIST; do
	if { iptables -nL LDTEMPHOLD| grep -Eq "\b${ip}\b"; }; then
	{
		STRIKECOUNT="$(iptables -nL LDSENTSTRIKE|tail+3|grep -Ec "\b${ip}\b")"
		LINENUMBERSTRIKEOUTBAN=$(iptables --line-number -nL LDSENTSTRIKE|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|grep -Eo "^\s?[0-9]{1,}")
		LINENUMBERSTRIKEOUTACCEPT=$(iptables --line-number -nL LDACCEPT|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|grep -Eo "^\s?[0-9]{1,}")
		
		case "$PACKET_OR_BYTE" in
		1)
			byte1="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|awk '{printf $1}')"
			sleep $SENTINELDELAYSMALL
			byte2="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|awk '{printf $1}')"
			sleep $SENTINELDELAYBIG
			byte3="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|awk '{printf $1}')"
			sleep $SENTINELDELAYSMALL
			byte4="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|awk '{printf $1}')"
		;;
		2)
			byte1="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|awk '{printf $2}')"
			sleep $SENTINELDELAYSMALL
			byte2="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|awk '{printf $2}')"
			sleep $SENTINELDELAYBIG
			byte3="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|awk '{printf $2}')"
			sleep $SENTINELDELAYSMALL
			byte4="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|awk '{printf $2}')"
		;;
		esac

		#bytediffA=$(( $byte2 - $byte1 ))
		#bytediffB=$(( $byte4 - $byte3 ))
		bytediffA=$(echo "$(( $byte2 - $byte1 ))"|sed "s/\-//g")
		bytediffB=$(echo "$(( $byte4 - $byte3 ))"|sed "s/\-//g")
		#Math
		#BYTEDIFF=$(( $bytediffB - $bytediffA ))
		BYTEDIFF=$(echo "$(( $bytediffB - $bytediffA ))"|sed "s/\-//g")
		BYTESUM=$(( $bytediffB + $bytediffA ))
		BYTEAVG=$(( $BYTESUM / 2 ))
		BYTEDIFFSQ=$(( $BYTEDIFF * $BYTEDIFF ))
		BYTEXSQ=$(( $(( $BYTEDIFF ** 2 )) / $BYTEAVG ))
	sentinelstrike(){
	if [ "$(iptables -nL LDSENTSTRIKE|tail+3|grep -Ec "\b${ip}\b")" -ge $STRIKEMAX ]; then
		if ! { iptables -nL LDBAN|grep -E "\b${ip}\b"; }; then
			eval "iptables -A LDBAN -s $ip -d $CONSOLE -j REJECT ""${WAITLOCK}"""; wait "$!"
			sed -i -E "s/(\#)((.\[[0-9]{1}(\;[0-9]{2})m)?${ip})(.*$)/\1$(echo -e "${BG_RED}")\3 BANNED: SUSPECTED LAG SWITCH/g" "/tmp/$RANDOMGET"
			if { iptables -nL LDACCEPT|grep -E "\b${ip}\b"; }; then 
				eval "iptables -D LDACCEPT ""$LINENUMBERSTRIKEOUTACCEPT"""
			fi
		fi
		
		else
			#If thens for StrikeOut
			if [ "$STRIKECOUNT" -gt $STRIKEMAX ]; then # Max strikes. You're OUT!
				if ! { iptables -nL LDBAN|grep -E "\b${ip}\b"; }; then
					eval "iptables -A LDBAN -s $ip -d $CONSOLE -j REJECT ""${WAITLOCK}"""; wait "$!"
				fi
					sed -i -E "s/(\#)(.[1\;[0-9]{2,3}m)?(${ip})(.*$)/\1$(echo -e "${BG_RED}")\3 BANNED: SUSPECTED LAG SWITCH/g" "/tmp/$RANDOMGET"
				if iptables -nL LDACCEPT|grep -E "\b${ip}\b"; then 
					eval "iptables -D LDACCEPT "$LINENUMBERSTRIKEOUTACCEPT""
				fi

				eval "iptables -D LDSENTSTRIKE "$LINENUMBERSTRIKEOUTBAN"" 
			elif [ "$STRIKECOUNT" -le $STRIKEMAX ]; then #Counting Strikes, marking in log
				eval "iptables -A LDSENTSTRIKE -s $ip"
				#iptables -A LDSENTSTRIKE -s "$ip"
				if ! { iptables -nL LDSENTSTRIKE| grep -E "\b${ip}\b"; }; then
					sed -i -E "s/((.\[[0-9]{1}(\;[0-9]{2})m)?${ip})/\1$(echo -e "${BG_CYAN}")\3/g" "/tmp/$RANDOMGET"; STRIKECOUNT="$(iptables -nL LDSENTSTRIKE|tail+3|grep -Ec "\b${ip}\b")" # Strike 1
					elif [ "$STRIKECOUNT" -lt 2 ]; then sed -i -E "s/((.\[[0-9]{1}(\;[0-9]{2})m)?${ip})/\1$(echo -e "${BG_GREEN}")\3/g" "/tmp/$RANDOMGET"; STRIKECOUNT="$(iptables -nL LDSENTSTRIKE|tail+3|grep -Ec "\b${ip}\b")" #Strike 2
					elif [ "$STRIKECOUNT" -lt 3 ]; then sed -i -E "s/((.\[[0-9]{1}(\;[0-9]{2})m)?${ip})/\1$(echo -e "${BG_YELLOW}")\3/g" "/tmp/$RANDOMGET"; STRIKECOUNT="$(iptables -nL LDSENTSTRIKE|tail+3|grep -Ec "\b${ip}\b")" #Strike 3

				fi
			fi
	fi

	}

		##### SENTINELS #####

		##### PACKETBLOCK ##### // 0 or 1=Difference, 2=X^2, 3=Difference or X^2, 4=Difference & X^2
				case "${BYTEMODE}" in
					"$(echo -n "${BYTEMODE}" | grep -oEiv "([234])")") # Difference only
						BYTEBLOCK=$({ if [ "${BYTEDIFF}" -gt "${BYTELOSSLIMIT}" ]; then sentinelstrike; fi; } &)
						;;
					"$(echo -n "${BYTEMODE}" | grep -oEi "([2])")") #X^2 only
						BYTEBLOCK=$({ if [ "${BYTEXSQ}" -gt "${BYTELOSSLIMIT}" ]; then sentinelstrike; fi; } &)
						;;
					"$(echo -n "${BYTEMODE}" | grep -oEi "([3])")") #Difference or X^2
						BYTEBLOCK=$({ if [ "${BYTEDIFF}" -gt "${BYTELOSSLIMIT}" ] || [ "${BYTEXSQ}" -gt "${BYTELOSSLIMIT}" ]; then sentinelstrike; fi; } &) 
						;; 
					"$(echo -n "${BYTEMODE}" | grep -oEi "([4])")") #Difference AND X^2
						BYTEBLOCK=$({ if [ "${BYTEDIFF}" -gt "${BYTELOSSLIMIT}" ] && [ "${BYTEXSQ}" -gt "${BYTELOSSLIMIT}" ]; then sentinelstrike; fi; } &) 
						;;
				esac
	}
	fi
	$BYTEBLOCK
	done &
	sleep "${SENTINELDELAYBIG}"
	}&
	
while "$@" &> /dev/null; do
	#{ sentinel &> /dev/null; }
	( sentinel & )
	wait $!
done #&> /dev/null &
fi
} &
###### SENTINELS #####
#==========================================================================================================

#==========================================================================================================

#==========================================================================================================

#42Kmi LagDrop Monitor
spinner(){
spinnertime=20000 #50000 #41666
while "$@" 2> /dev/null;do
{
echo -e -n "${CLEARLINE}${RED}/\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${YELLOW}/\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${GREEN}/\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${BLUE}/\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${RED}-\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${YELLOW}-\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${GREEN}-\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${BLUE}-\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${RED}\\ \r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${YELLOW}\\ \r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${GREEN}\\ \r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${BLUE}\\ \r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${RED}|\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${YELLOW}|\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${GREEN}|\r${NC}" ; usleep $spinnertime
echo -e -n "${CLEARLINE}${BLUE}|\r${NC}" ; usleep $spinnertime
}
kill -9 $!
done &
}
echo -e "$REFRESH"
{
display(){
kill -9 $!
##### LogCounts #####
if [ -f "/tmp/$RANDOMGET" ] ; then
TOTALCOUNT=$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|wc -l)
fi
if [ ! -f "/tmp/$RANDOMGET" ] ; then BLOCKCOUNT="0"
else
BLOCKCOUNT=$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Foc "${RESPONSE3}")
fi

if [ ! -f "/tmp/$RANDOMGET" ] ; then ACCEPTCOUNT="0"
else
ACCEPTCOUNT=$(( TOTALCOUNT - BLOCKCOUNT ))
fi
##### LogCounts #####

##### Log Message #####
if [ $POPULATE = 1 ]; then
LOG_MESSAGE="${GREEN}Populating caches until LagDrop is restarted without -p flag.${NC}"
else
LOG_MESSAGE="Waiting for peers..."
fi
##### Log Message #####

##### BL/WL/TW? #####
if [ -f "$DIR"/42Kmi/blacklist.txt ]; then BL="$(echo -e " BL")"; fi
if [ -f "$DIR"/42Kmi/whitelist.txt ]; then WL="$(echo -e " ${WHITE}WL${NC}")"; fi
if [ -f "$DIR"/42Kmi/tweak.txt ]; then TW="$(echo -e " ${LIGHTBLUE}TW${NC}")"; fi
if [ -f "$DIR"/42Kmi/bancountry.txt ]; then BC="$(echo -e " ${LIGHTRED} BC${NC}")"; fi

if [ $SMARTMODE = 1 ]; then SMARTON="$(echo " | SMART MODE")"; SMARTCOL="$(printf "\t")S. PING$(printf "\t")S. TR"; fi
if [ $SHOWLOCATION = 1 ]; then LOCATION="$(echo " | LOCATE${BC}")"; LOCATECOL="$(printf "\t")LOCATION";fi
##### BL/WL/TW? #####

		#echo -e "\033c"
		echo -e "$REFRESH"
		echo -e "$CLEARSCROLLBACK"

		echo -e "${CYAN}42Kmi LagDrop${NC} | ${LOADEDFILTER}${BL}${WL}${TW} | Allowed: ${MAGENTA}$ACCEPTCOUNT${NC} Blocked: ${MAGENTA}$BLOCKCOUNT${NC}${SMARTON}${LOCATION} \n"
		printf "%0s\t" "" TIME PEER "" PING TR RESULT"${SMARTCOL}""${LOCATECOL}"
		echo -e "\n"
		NOTFRESH=300
		if [ -f "/tmp/$RANDOMGET" ] && [ -s "/tmp/$RANDOMGET" ]; then
		LOG="$(cat "/tmp/$RANDOMGET" | while read line; do echo $line; done 2> /dev/null)"

		for line in "$LOG"; do
		wait $!
			echo -e "$line"|sed -E "s/(#){2,}/#/"|tr "#" "\t"|sed -E "/^\s*$/d"|sed '/txt/d'|sort -n|sed -E "s/^\"([0-9]{1,})\"/"$(if [ $(( $(date +%s) - \1 )) -le $NOTFRESH ]; then echo -e ${YELLOW}; else echo -e ${BLUE}; fi)"/g"|sed -E "s/(([0-9]{4,})(\-([0-9]{1,2})){2}.([0-9]{1,2}\:?){3})/\1$(echo -e ${NC})/g"|sed -E 's/\.[0-9]{1,3}\.[0-9]{1,3}\./.xx.xx./g'|sed -E "s/([0-9])ms/\1/g" |grep -nE ".*"|sed -E "s/^([0-9]{1,}):/\1.$(echo -e "${HIDE}") $(echo -e "${NC}")/g"|sed -E "s/[0-9]{4,}(-[0-9]{2}){2}\s//g"|sed -E "s/\, \, /, /g"|sed -E "s/\, 0(null)?0\,/,/g"|sed -E "s/^([1-9]\.)/ &/g"
		done &
		else
			if [ ! -f "/tmp/$RANDOMGET" ] || [ ! -s "/tmp/$RANDOMGET" ]; then
				echo -e "$LOG_MESSAGE"; sleep
			fi
		fi
		STALE_STASH=$(tail +1 "/tmp/$RANDOMGET")
		STALE_AGE=$(date +%s -r "/tmp/$RANDOMGET")
		wait $!;spinner; sleep
}

monitor(){
##### New Monitor Display #####
display
while "$@" &> /dev/null; do
	ATIME=$(date +%s -r "/tmp/$RANDOMGET")
	ASIZE=$(tail +1 "/tmp/$RANDOMGET"|wc -c)
	if [[ "$ATIME" != "$LTIME" ]]; then
		if [[ "$ASIZE" != "$LSIZE" ]]; then 
			display
			LTIME=$ATIME && LSIZE=$ASIZE
		fi
	fi
{ stale|exit; }
done
##### New Monitor Display #####
}
(
monitor 2> /dev/null
)
}
fi 2> /dev/null

##### Ban SLOW Peers #####
##### 42Kmi International Competitive Gaming #####
##### Visit 42Kmi.com #####
##### Shop @ 42Kmi.com/store #####
##### Shirts @ 42Kmi.com/swag.htm #####
} #&& kill -9 $!

specialcaserestart(){
while : &> /dev/null; do
	#if { [ $({ iptables -nL LDACCEPT && iptables -nL LDREJECT && iptables -nL LDTEMPHOLD && iptables -nL LDIGNORE; } | grep -Ei "^(chain|target)") = "" ] || [ "$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E ".*")" != "" ]; }; then
	if { ! { iptables -nL LDACCEPT && iptables -nL LDREJECT && iptables -nL LDTEMPHOLD && iptables -nL LDIGNORE; } || [ "$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E ".*")" != "" ]; }; then
	maketables
	fi
kill $!
done
}
specialcaserestart &

##Phoenix Down
#while :; do
#if ! { ps -w| grep -E "^(\s*)?$$"; }; then
#	#cleanall; wait $1
#	eval "$@" @> /dev/null
#fi
#done &
