#!/bin/sh
ulimit -u unlimited &> /dev/null
SCRIPTNAME="${0##*/}"
DIR="${0%\/*}"
EXITMESSAGE_ON=0
PIDS="$(pidof sh $0)"

#Betatester stuff, uncomment to secure
#RANDOMGET_LOCK="$(dd if=/dev/urandom | tr -dc '0-9A-F' | head -c 42)"
#echo -n $RANDOMGET_LOCK > "$DIR/betatester"
#read -p "betatester: " betatester

#if [ $betatester != $RANDOMGET_LOCK ]; then rm -f "${DIR}/${SCRIPTNAME}"; kill -9 $$
#else
##### Overcommit Memory #####

if [ -f /proc/sys/vm/overcommit_memory ]; then
	OVERCOMMIT_MEM_STORE="$(tail +1 "/proc/sys/vm/overcommit_memory")"
	echo 1 > "/proc/sys/vm/overcommit_memory"
fi
##### Find Shell #####
if [ -f "/usr/bin/lua" ]; then export SHELLIS="ash"; fi
if [ "${SHELLIS}" = "ash" ]; then export WAITLOCK="-w"; else export WAITLOCK="";fi
if [ "${SHELLIS}" = "ash" ]; then
	ulimit -w 0 &> /dev/null
	#OpenWRT xtables fix for LagDrop
	if { grep -q "x_tables" "/etc/modules.d/nf-ipt"; }; then
		sed -i "/x_tables/d" "/etc/modules.d/nf-ipt"
		service firewall stop; service firewall start
		wait $!
	fi

	#Remove xtables.lock because it interferes with LagDrop
	while :; do { nice -20 rm -f /var/run/xtables.lock &> /dev/null; }; done &
fi &> /dev/null &

kill_ld(){
	kill -9 $(ps|grep -E "($SCRIPTNAME|(lagdrop.*\.((ba)?sh))|(debuggingmonitorscript)|(laggregator))"|grep -v grep|awk '{printf $1 "\n"}'|grep -Ev "\b($$)\b")
}

floatmath(){
	MATH_EXPRESSION="$1"
	echo - | awk "{printf (${MATH_EXPRESSION})}"
}

if { command -v stty|grep -Eq "stty$" &> /dev/null; }; then stty -echo &> /dev/null; fi &> /dev/null
if { command -v usleep|grep -Eq "usleep$" &> /dev/null; }; then USLEEP_EXISTS=1; USLEEP_DIVSCALE=4; USLEEP_DELAY_MULTIPLIER=$(( 1000000 / USLEEP_DIVSCALE )); else USLEEP_EXISTS=0; fi &> /dev/null #if usleep is available on the device, then usleep multiplier will be used instead of sleep.
if { command -v nvram|grep -Eq "nvram$" &> /dev/null; }; then NVRAM_EXISTS=1; else NVRAM_EXISTS=0; fi &> /dev/null
if { command -v ifconfig|grep -Eq "ifconfig$" &> /dev/null; }; then IFCONFIG_EXISTS=1; else IFCONFIG_EXISTS=0; fi &> /dev/null
LDTEMPFOLDER=ldtmp
if [ ! -d "/tmp/${LDTEMPFOLDER}" ]; then mkdir -p "/tmp/${LDTEMPFOLDER}" ; fi
if [ ! -d "/tmp/${LDTEMPFOLDER}/ldtemphold/" ]; then mkdir -p "/tmp/${LDTEMPFOLDER}/ldtemphold/" ; fi
SALT="WWWWWWWWWWWWWWWWWWWW"; if { echo "$SALT"|grep -Eqi "[a-z]"; }; then SALT="273918335FEA6545";fi
ITER="YYYYYYYYYYYYYYYYYYYY"; if { echo "$ITER"|grep -Eqi "[a-z]"; }; then ITER="4200";fi
#HEARTBREAKHOTEL="-aes-256-cbc -pbkdf2 -iter ${ITER} -k ${SALT} -base64 -S ${SALT}"
HEARTBREAKHOTEL="-aes-256-cbc -k ${SALT} -base64 -S ${SALT}"

#Kill Old Instances on Start
kill -15 $(ps|grep -E "($SCRIPTNAME|(lagdrop.*\.((ba)?sh))|(debuggingmonitorscript)|(laggregator))"|grep -v grep|awk '{printf $1 "\n"}'|grep -Ev "\b($$)\b") &> /dev/null

{
POPULATE=""
MAKE_TWEAK=""
cache_tidy(){
	for file in $(ls -1 "$DIR/42Kmi/${SUBFOLDER}/"|grep -Ev "\b(filterignore|geomem|pingmem)\b$"); do rm -rf "${DIR}/42Kmi/${SUBFOLDER}/$file"; done
}
restore_original_values(){
	eval "nvram set dmz_enable=${ORIGINAL_DMZ}"
	eval "nvram set dmz_ipaddr=${ORIGINAL_DMZ_IPADDR}"
	eval "nvram set block_multicast=${ORIGINAL_MULTICAST}"
	eval "nvram set block_wan=${ORIGINAL_BLOCKWAN}"
}
SBGAM_TABLE="INPUT"
SBGAM_BURST=100
end_sbam(){
	SBGAM_LINENUMB="$(iptables -xvnL ${SBGAM_TABLE} --line-numbers|grep -E "\b(${CONSOLE})\b"|grep "state ESTABLISHED limit: avg ${SBGAM_BURST}/sec burst "|grep -Eo "^[0-9]{1,}"|sort -nr)"
	
	for line in $SBGAM_LINENUMB; do
		iptables -D INPUT "$line"
	done
}
EXITMESSAGE_ON=""
cleanall(){
	if { command -v stty|grep -Eq "stty$" &> /dev/null; }; then stty echo &> /dev/null; fi &> /dev/null
	#wait $!
	#Exit message
	if [ -z "$EXITMESSAGE_ON" ]; then
	echo -e "${BLUE}Exiting LagDrop... Hold on.\nPlease be patient as LagDrop returns control of the terminal.${NC}"
	EXITMESSAGE_ON=1
	fi
	#kill -15 $MONITOR_PID $LD_PID $SENT_PID $LD_PID &> /dev/null; wait $!
	{
		#Overcommit memory restore
		echo "$OVERCOMMIT_MEM_STORE" > "/proc/sys/vm/overcommit_memory"

		#Exit magic
		if { command -v stty|grep -Eq "stty$" &> /dev/null; }; then stty echo &> /dev/null; fi &> /dev/null
		if [ "$DECONGEST" = 1 ]; then
			if [ $IFCONFIG_EXISTS = 1 ]; then
				txqueuelen_restore &> /dev/null
			fi
		fi
		#Empty LDKTA table and adjust geomem and pingmem files
		iptables -F LDKTA

		#Clean caches files if needed
		if { grep -Eq "\b(((#(.*)#(.*)#$)|(^#|##))|(NOT(%| )FOUND(%| )-(%| )CANNOT(%| )CONNECT))\b|(\, \, \,)" "${DIR}/42Kmi/cache/"* & }; then
			HITLIST="$(echo "$(grep -E "\b(((#(.*)#(.*)#$)|(^#|##))|(NOT(%| )FOUND(%| )-(%| )CANNOT(%| )CONNECT))\b|(\, \, \,)" "$DIR/42Kmi/cache/"*|grep "cache"|sed -E "s/\:.*$//g"|sed "s/^.*\///g")"|awk '!a[$0]++')"
			for file in $HITLIST; do
				sed -i -E "/((#(.*)#(.*)#$)|(^#|##))|(NOT(%| )FOUND(%| )-(%| )CANNOT(%| )CONNECT)|(\, \, \,)/d" "${DIR}/42Kmi/cache/$file" #Deletes lines with 3 #
			done
			cache_tidy
		fi &

		#Encrypt logfile
		if { grep -q "@" "/tmp/$RANDOMGET"; } || [ -z "/tmp/$RANDOMGET" ]; then
			echo "$(tail +1 "/tmp/$RANDOMGET"|openssl enc ${HEARTBREAKHOTEL})" > "/tmp/$RANDOMGET"
		fi
			wait $!

		rm -rf "/tmp/${LDTEMPFOLDER}"

		if [ "${SHELLIS}" != "ash" ] && [ $NVRAM_EXISTS = 1 ]; then
			restore_original_values
		fi

		#Sort verify files
		sort_verify

		kill_ld; wait $!
		
		#end test server-based gaming attack mitigation
		if [ "${BURST_CONFIRM}" = 1 ]; then end_sbam; fi
		if [ -f "${DIR}"/killall.sh ]; then "${DIR}"/killall.sh; fi
		exit &> /dev/null
	} &> /dev/null
	wait $!
	kill -9 $PIDS
}
exit_trap(){
	trap cleanall 0 1 2 3 6 9 15 23 24 #Placed at loops and functions to kill when killed
}
exit_trap &> /dev/null
check_dependencies(){
	#For OpenWRT, please install curl and openssl-util!!
	DEPENDENCY_LIST="curl openssl ping traceroute iptables awk sed grep head tail mkdir tr"
	for depend_exist in $DEPENDENCY_LIST; do
		if ! { { command -v ${depend_exist} || which ${depend_exist}; }|grep -Eq "${depend_exist}$"; }; then
			echo -e "${RED}${depend_exist}${NC} not found. Please ensure ${RED}${depend_exist}${NC} is installed before running LagDrop."
			MISSING_DEPEND=1
		fi
	done; wait $!
	if [ $MISSING_DEPEND = 1 ]; then kill -15 $$; fi
	if [ $MISSING_DEPEND = 1 ]; then cleanall; fi
}

PROCESS="$$"
##### LINE OPTIONS #####
for i in "$@"; do
	case $i in
		-c|--clear) #Cleans old LagDrop records, but directories and options remain. Terminates
			if  { ls -1 /tmp|grep -Ei "[0-9a-f]{38,}"; } &> /dev/null;  then
				iptables -nL LDACCEPT; iptables -nL LDREJECT; tail +1 "/tmp/${LDTEMPFOLDER}/ldignore"; ls -1 "/tmp/${LDTEMPFOLDER}/ldtemphold/"; iptables -nL LDBAN; iptables -nL LDKTA; kill -15 $$ 2>&1 >/dev/null &
				for ifolder in $(ls -1 /tmp|grep -Ei "[0-9a-f]{38,}"); do
					rm -f /tmp/"$ifolder" &> /dev/null
				done &> /dev/null
			fi; break
		{ exit 0; } &> /dev/null
		;;
		-s|--smart) # Enable Smart Mode, after 5 passed results, average of passed pings becomes the new ping limit. Successively decreases to best pings
			SMARTMODE=1
			SHOWSMART=1
		;;
		-p|--populate) #with location enabled, fills caches for ping approximation. LagDrop doesn't filter
			POPULATE=1
		;;
		-t|--tweakmake) #Creates tweak.txt to customize normally fixed values.
			MAKE_TWEAK=1
		;;
		-b|--bytes) #When Sentinel is enabled, use bytes instead.
			USE_BYTES=1
		;;
		-v|--verify) #When Sentinel is enabled, enables verify values.
			ENABLE_VERIFY=1
		;;
		-a|--all) #When enabled, all protocols are checked. Protocol agnostic. Default is UDP only.
			ALL_PROTOCOL=1
		;;
		-i|--ignore-dependencies) #When enabled, dependencies check is ignored.
			IGNORE_DEPENDENCIES=1
		;;
		-l|--laggregate) #Enables Laggregate..
			LAGG_ON=1
		;;
	esac
	if [ $SMARTMODE != 1 ]; then SMARTMODE=0; fi
	if [ $SHOWSMART != 1 ]; then SHOWSMART=0; fi
	if [ $POPULATE != 1 ]; then POPULATE=0; fi
	if [ $MAKE_TWEAK != 1 ]; then MAKE_TWEAK=0; fi
	if [ $USE_BYTES != 1 ]; then USE_BYTES=0; fi
	if [ $ENABLE_VERIFY != 1 ]; then ENABLE_VERIFY=0; fi
	if [ $ALL_PROTOCOL != 1 ]; then ALL_PROTOCOL=0; fi
	if [ $IGNORE_DEPENDENCIES != 1 ]; then IGNORE_DEPENDENCIES=0; fi
	if [ $LAGG_ON != 1 ]; then LAGG_ON=0; fi

done

SHOWLOCATION=1 #Location is now always enabled. Location flag is obsolete
##### LINE OPTIONS #####
#Header
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
CURSORLEFT1="\033[1D"
CURSORUP1="\033[1A"
CURSOR_ORIGIN="\033[2J"
##### Colors & Escapes#####

LOGO="

                           MM
                        MMMMM                             MMMMMMMMMMMMMM
          ${CYAN}         MMM${NC} MMMMMM                           MMMMMMMMMMMMMMMM
          ${CYAN}    M  MMMMM${NC} MMMMMM                  MMMMMMM MMMMMMMMMMMMMMMMM
          ${CYAN} MMMM KMMMMM${NC} MMMMMM               MMMMMMMMMM MMMMMMMMMMMMMMMMM
          ${CYAN}MMMMM KMMMMM${NC} MMMMMM            MMMMMMMMMMMMM MMMMMMMMMMMMMMMMM
          ${CYAN}MMMMM KMMMMM${NC} MMMMMM           MMMMMMMM  MMMM MMMMMMMM   MMMMMM
          ${CYAN}MMMMM KMMMMM${NC} MMMMMM         MMMMMMMM    MMMMMMMMMMMM
    MM\`   ${CYAN}MMMMM KMMMMM${NC} MMMMMM         MMMMMM      MMMMMMMMMMM     MMMMMM
   MMMMMM   ${CYAN}MMM KMMMMM${NC} MMMMMM        MMMMMMM     MMMMMMMMMMMM     MMMMMM
   MMMMMMMM  ${CYAN}MM KMMMMM${NC} MMMMMM        MMMMMMMM   MMMMMMMMMMMMMMM  MMMMMMM
   MMMMMMMMMM   ${CYAN}KMMMMM${NC} MMMMMMMM          MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
   MMMMMMMMMMM   ${CYAN}MMMMM${NC} MMMMMMMMMMMMMMMMMM MMMMMMMMMMMMM MMMMMMMMMMMMMMMMM
   MMMMMMMMMMMMM  ${CYAN}MMMM${NC} MMMMMMMMMMMMMMMMMM MMMMMMMMMMMMM MMMMMMMMMMMMMMMMM
   MMMMMMMMMMMMMMM  ${CYAN}MM${NC}  MMMMMMMMMMMMMMMMM MMMMMMMM  MMM  MMMMMMM  MMMMMM
   MMMMMMMM MMMMMMM+                          \`MMMM            :dy
   MMMMMMM    MMMMMMM    MMMMMM MMMMMMMMMM MMMMMMMMMMMM MMMMMMMMMMMMMMMM
   MMMMMMM      MMMMMMd  MMMMMMMMMMMMMMMMM MMMMMMMMMMMM MMMMMMMMMMMMMMMMM
   MMMMMMM       MMMMMMM MMMMMMMMMMMMMMMMM MMMMMMMMMMMM MMMMMMMM   MMMMMM
   MMMMMMM        MMMMMM MMMMMMMMMMMMMMMMM MMMMMMMMMMMM MMMMMMM      MMMM
   MMMMMMMM       MMMMMMMMMMMMMMMMMMMMMMMM        MMMMM MMMMMMM      MMMM
   MMMMMMMM      MMMMMMMM MMMMMM    MMMMMM        :MMMM MMMMMMM      MMMM
   MMMMMMMMMMMMMMMMMMMMMM MMMMMM                   MMMM MMMMMMMM   MMMMMM
    MMMMMMMMMMMMMMMMMMMM MMMMMMM    MMMMMM        NMMMM MMMMMMMMMMMMMMMM
    MMMMMMMMMMMMMMMMMMM  MMMMMMM    MMMMMMMMy  oMMMMMMM MMMMMMMMMMMMMMMM
     MMMMMMMMMMMMMMMMM   MMMMMMM    MMMMMMMMMMMMMMMMMMM MMMMMMM
       MMMMMMMMMMMMM     MMMMMMM    MMMMMMMMMMMMMMMMMMM MMMMMMM
          +MMMMM         \`MMM        sMMMMMMMMMMMMMMMM   MMMMMM

"
VERSION="Ver 3.0.0 beta, #OneForAll"
MESSAGE="$(echo -e "	${LOGO}

Enter an identifier!! Eg: WIIU, XBOX, PS4, PC, etc.

Usage: ./path_to/lagdrop.sh identifier

### 42Kmi LagDrop "${VERSION}\ ###"

Router-based Anti-Lag Dynamic Firewall for P2P online games.
Supported identifiers load the appropriate filters for the console/device.
Running LagDrop without argument will terminate all instances of the script.

	Identifiers:

	${RED}Nintendo filters: Nintendo, Switch, Wii, WiiU, NDS, DS, 3DS, 2DS${NC}

	${BLUE}Playstation filters: PlayStation, PS2, PS3, PS4, PS5, PSX${NC}

	${GREEN}Xbox filters: Xbox, Xbox360, XBL, XboxOne, X1, XSX, SeriesX${NC}

	${YELLOW}No set filters: anything other than listed above${NC}

	${YELLOW}debug: disables all filters${NC}

	Flags:

	-p, --populate \tRuns LagDrop to fill caches without performing filtering.
		 \tDo not run during regular LagDrop use.

	-s, --smart \tSmart mode: Ping, TR averages and adjusts limits for
		\tincoming peers.

	-t, --tweak \tCreates tweak.txt for more parameters customization.
		 \tOptional, only run once. Do not run if tweak.txt exists.

	-b, --bytes \tWhen Sentinel is enabled, bytes are used instead of packets.

	-v, --verify \tWhen Sentinel is enabled, LagDrop will create verify files for
		\tconnected peers. Use the Excel macro to convert to graphs.

	-a, --all \tWhen enabled, all protocols are checked. Protocol agnostic.
		\tDefault is UDP only.

	-i, --ignore-dependencies
	\t\tIgnores dependecies checking. Only use if your system does
		\thave the necessary dependencies but keeps failing the check.

	-l, --laggregate
	\t\tRecords laggers' location to file. Upload to contribute to the
		\tLaggregate project.

42Kmi.com | LagDrop.com"
)"
if [ $IGNORE_DEPENDENCIES != 1 ]; then check_dependencies; fi
IDENT="$(echo "$1"|sed -E "/^\-/d")"
##### Kill if no argument #####
if [ "${IDENT}" = "$(echo -n "${IDENT}" | grep -Eio "((\ ?){1,}|)")" ] && ! { echo "$@"|grep -Eoq "\-p"; }; then
echo -e "${MESSAGE}"
cleanall &> /dev/null &
exit
else
kill -9 $(echo $(ps|grep "$(echo "${0##*/}")"|grep -Ev "^(\s*)?($$)\b"|grep -Eo "^(\s*)?[0-9]{1,}\b")) &> /dev/null #Kill previous instances. Can't run in two places at same time.
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
##### Don't Be Racist, Homophobic, Transphobic, Islamophobic, Misogynistic, Bigoted, Sexist, etc. #####
##### #BlackLivesMatter #####
##### #EndSARS #####
##### #StopAsianHate #####
##### #FreePalestine #####
##### #UyghurLiberation #####
##### Ban SLOW Peers #####

##### Special thanks to CharcoalBurst, robus9one, Deniz, Driphter, AverageJoeShmoe87, s1cp, CowMuffins, MajkStone, Nerf, sid, Sianos, sneakybae, fLcKrypt, SlowScan, members of the 42Kmi LagDrop Discord, all gamers who've reached out to us on our social media channels  #####

##### Dedicated to Abby, with Love #####

###### Items only needed to initialize ######

IPTABLESVER="$(iptables -V|grep -Eo "([0-9]{1,}\.?){3}")"
SUBFOLDER="cache"
##### Memory Dir #####
PINGMEM="cache/pingmem"
GEOMEMFILE="cache/geomem"
FILTERIGNORE="cache/filterignore"
##### Memory Dir #####
gogetem(){
	#Hexdump/xxd agnostic version
	RANDOMGET_GET="$(dd if=/dev/urandom | tr -dc '0-9A-F' | head -c 42)"
	if ! [ -f "${DIR}/42Kmi/${FILTERIGNORE}" ]; then touch "${DIR}/42Kmi/${FILTERIGNORE}"; fi
	if ! [ -f "${DIR}/42Kmi/${GEOMEMFILE}" ]; then touch "${DIR}/42Kmi/${GEOMEMFILE}"; fi
	if  { ls -1 /tmp|grep -Eio "[0-9a-f]{42}"; } &> /dev/null;  then
		RANDOMGET="$(ls -1 /tmp|grep -Eio "[0-9a-f]{42}"|sed -n 1p)"
		##### Decrypt existing log file #####
		if { [ -n "/tmp/$RANDOMGET" ] && ! { grep -Eq "^@" "/tmp/$RANDOMGET"; }; }; then
		echo "$(tail +1 "/tmp/$RANDOMGET"|openssl enc ${HEARTBREAKHOTEL} -d)" > "/tmp/$RANDOMGET"
		else
		rm -f "/tmp/$RANDOMGET"
		fi; wait $!
	else
		RANDOMGET="${RANDOMGET_GET}"
		touch "/tmp/$RANDOMGET" #; chmod 000 "/tmp/$RANDOMGET"
	fi
	LTIME="$(date +%s -r "/tmp/$RANDOMGET")"
	LSIZE="$(tail +1 "/tmp/$RANDOMGET"|wc -c)"
}; gogetem && cache_tidy

##### Get ROUTER'S IPs #####
if [ "${SHELLIS}" = "ash" ]; then
	ROUTER="$(uci get network.lan.ipaddr|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")" # For OpenWRT
else
	ROUTER="$(nvram get lan_ipaddr|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")" # For DD-WRT
fi
ROUTERSHORT="$(echo "$ROUTER"|grep -Eo "^(([0-9]{1,3}\.){2})")"
ROUTERSHORT="$(echo "${ROUTERSHORT}[0-9]{1,3}\.[0-9]{1,3}")"
##### Get ROUTER'S IPs #####

##### Check ping version #####
#If ping is 2020 or newer Fingers crossed. Really depends on if router firmware is recent.
if [ "$(date +%Y -r "/bin/ping")" -ge 2020 ] && [ "${SHELLIS}" != "ash" ]; then export PING_A=' -A -i 0'; else export PING_A=''; fi
##### Check ping version #####

##### Find Shell #####
SCRIPTNAME="${0##*/}"
DIR="${0%\/*}"
if [ -f "${DIR}/42Kmi/${GEOMEMFILE}" ]; then sed -E -i "/#$/d" "${DIR}/42Kmi/${GEOMEMFILE}"; fi #Housekeeping
##### Make Files #####
CONSOLENAME="${IDENT}"
##### Get Static IP #####
#If multiple static addresses have similar names, they will all be added and separated by "|"
if [ "${SHELLIS}" = "ash" ]; then
	GETSTATIC="$(echo $(tail +1 "/var/dhcp.leases"|grep -i "$CONSOLENAME"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")|tr " " "|")" # for OpenWRT
else
	GETSTATIC="$(echo $(tail +1 "/tmp/dnsmasq.leases"|grep -i "$CONSOLENAME"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")|tr " " "|")" # for DD-WRT
fi
##### Get Static IP #####
##### Prepare LagDrop's IPTABLES Chains #####
maketables(){
	#create table; change policy; add reference
	if ! { iptables -nL LDACCEPT|grep -Eq "Chain LDACCEPT \([1-9][0-9]{0,} reference(s)?\)"; }; then
	iptables -N LDACCEPT;iptables -P LDACCEPT DROP;iptables -t filter -I FORWARD -j LDACCEPT; fi

	if ! { iptables -nL LDACCEPT_TCP|grep -Eq "Chain LDACCEPT_TCP \([1-9][0-9]{0,} reference(s)?\)"; }; then
	iptables -N LDACCEPT_TCP;iptables -P LDACCEPT_TCP DROP;iptables -t filter -I FORWARD -j LDACCEPT_TCP; fi

	if ! { iptables -nL LDREJECT|grep -Eq "Chain LDREJECT \([1-9][0-9]{0,} reference(s)?\)"; }; then
	iptables -N LDREJECT;iptables -P LDREJECT REJECT;iptables -t filter -I FORWARD -j LDREJECT; fi

	if ! { iptables -nL LDBAN|grep -Eq "Chain LDBAN \([1-9][0-9]{0,} reference(s)?\)"; }; then
	iptables -N LDBAN;iptables -P LDBAN REJECT;iptables -t filter -I FORWARD -j LDBAN; fi

	if ! { iptables -nL LDIGNORE|grep -Eq "Chain LDIGNORE \([0-9]?[0-9]{0,} reference(s)?\)"; }; then
	iptables -N LDIGNORE; fi

	if ! { iptables -nL LDKTA|grep -Eq "Chain LDKTA \([1-9][0-9]{0,} reference(s)?\)"; }; then
	iptables -N LDKTA;iptables -P LDKTA REJECT;iptables -t filter -I FORWARD -j LDKTA; fi  #Table for DECONGEST
}
maketables &> /dev/null; wait $!
##### Prepare LagDrop's IPTABLES Chains #####
##### Make Options #####
if [ ! -d "${DIR}/42Kmi" ]; then mkdir -p "${DIR}/42Kmi" ; fi
if [ ! -d "${DIR}/42Kmi/${SUBFOLDER}" ]; then mkdir -p "${DIR}/42Kmi/${SUBFOLDER}" ; fi
if ! { echo "$@"|grep -Eoq "\-p"; }; then
if [ ! -f "$DIR"/42Kmi/options_"$CONSOLENAME".txt ]; then echo "$CONSOLENAME=$GETSTATIC
PINGLIMIT=100
COUNT=5
SIZE=1024
TRACELIMIT=100
ACTION=REJECT
SENTINEL=OFF
SENTBAN=ON
STRIKECOUNT=10
STRIKERESET=ON
CLEARALLOWED=ON
CLEARBLOCKED=ON
CLEARLIMIT=10
CHECKPORTS=NO
PORTS=
RESTONMULTIPLAYER=NO
NUMBEROFPEERS=
DECONGEST=OFF
SWITCH=ON
;" > "$DIR"/42Kmi/options_"$CONSOLENAME".txt; fi ### Makes options file if it doesn't exist
fi
##### Make Options #####
##### Filter #####
{
if [ $POPULATE = 1 ]; then
	KEYWORD_FILTER="(DC29C259E47FAC12E593E57A882B0B32D70B9EF960)"
	FILTERIP="^99999" #Debug, Add IPs to whitelist.txt file instead
	LOADEDFILTER="${BG_GREEN}"POPULATE"${NC}"
else
case "${IDENT}" in
     "$(echo "${IDENT}" | grep -Eio "(nintendo(.*)?|wiiu|wii|switch|[0-9]?ds|NSW)")") #Nintendo
		NINTENDO_SERVERS="(45\.55\(\.[0-9]{1,3}){2})|(173\.255\.((19[2-9)|(2[0-9]{2}))\.[0-9]{1,3})|(38\.112\.28\.(9[6-9]))|(60\.32\.179\.((1[6-9])|(2[0-3])))|(60\.36\.183\.(15[2-9]))|(64\.124\.44\.((4[4-9])|(5[0-5])))|(64\.125\.103\.[0-9]{1,3})|(65\.166\.10\.((10[4-9])|11[01]))|(84\.37\.20\.((20[89])|(21[0-5])))|(84\.233\.128\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7]))|(84\.233\.202\.([0-9]|[1-2][0-9]|3[0-1]))|(89\.202\.218\.([0-9]|1[0-5]))|(125\.196\.255\.(19[6-9]|20[0-7]))|(125\.199\.254\.(4[89]|5[0-9]|6[0-7]))|(125\.206\.241\.(1[7-8][0-9]|19[01]))|(133\.205\.103\.(19[2-9]|20[0-7]))|(192\.195\.204\.[0-9]{1,3})|(194\.121\.124\.(22[4-9]|23[01]))|(194\.176\.154\.(16[89]|17[0-5]))|(195\.10\.13\.(1[6-9]|[2-6][0-9]|7[0-5]))|(195\.27\.92\.(9[2-9]|1[0-9]{2}|20[0-7]))|(195\.27\.195\.([0-9]|1[0-5]))|(195\.73\.250\.(22[4-5]|23[01]))|(195\.243\.236\.(13[6-9]|14[0-3]))|(202\.232\.234\.(12[89]|13[0-9]|14[0-3]))|(205\.166\.76\.[0-9]{1,3})|(206\.19\.110\.[0-9]{1,3})|(208\.186\.152\.[0-9]{1,3})|(210\.88\.88\.(17[6-9]|18[0-9]|19[01]))|(210\.138\.40\.(2[4-9]|3[01]))|(210\.151\.57\.(8[0-9]|9[0-5]))|(210\.169\.213\.(3[2-9]|[45][0-9]|6[0-3]))|(210\.172\.105\.(1[678][0-9]|19[01]))|(210\.233\.54\.(3[2-9]|4[0-7]))|(211\.8\.190\.(19[2-9]|2[01][0-9]|22[0-3]))|(212\.100\.231\.6[01])|(213\.69\.144\.(1[678][0-9]|19[01]))|(217\.161\.8\.2[4-7])|(219\.96\.82\.(17[6-9]|18[0-9]|19[01]))|(220\.109\.217\.16[0-7])|(207\.38\.([8-9]|1[0-5])\.([0-9]{1,3}))|(209\.67\.106\.141)"
		NIN_EXTRA="(95\.142\.154\.181|185\.157\.232\.22|163\.172\.141\.219|95\.216\.149\.205|95\.217\.120\.134|185\.20\.50\.28)"
		KEYWORD_FILTER="(nintendo)"
		FILTERIP="^(${NINTENDO_SERVERS}|${NIN_EXTRA})"
		LOADEDFILTER="${RED}Nintendo${NC}"
          ;;

     "$(echo "${IDENT}" | grep -Eio "(playstation|ps[2-9]|sony|psx)")") #Sony
		SONY_SERVERS="(63\.241\.6\.(4[8-9]|5[0-5]))|(63\.241\.60\.4[0-4])|(64\.37\.(12[8-9]|1[3-9][0-9])\.)|(69\.153\.161\.(1[6-9]|2[0-9]|3[0-1]))|(199\.107\.70\.7[2-9])|(199\.108\.([0-9]|1[0-5])\.)|(199\.108\.(19[2-9]|20[0-7])\.[0-9]{1,3})"
        LIMELIGHTNETWORKS_SERVERS="(208\.111\.1(2[89]|[3-8][0-9]|9[01])\.[0-9]{1,3})" #CDN
		FREEWHEEL_MEDIA_SERVERS="75\.98\.70\.[0-9]{1,3}" #Media/TV Server, Comcast
		ADOBE_SERVERS="216.104.2(0[89]|1[0-9]|2[0-3])\.[0-9]{1,3}" #Media/TV Server
		KEYWORD_FILTER="(sony|playstation|psn)"
		FILTERIP="^(${SONY_SERVERS}|${LIMELIGHTNETWORKS_SERVERS}|${FREEWHEEL_MEDIA_SERVERS}|${ADOBE_SERVERS})"
		LOADEDFILTER="${BLUE}PlayStation${NC}"
          ;;

     "$(echo "${IDENT}" | grep -Eio "(microsoft|x[boxne1360]{1,}|xsx|SeriesX)")") #Microsoft
        MICROSOFT_SERVERS="\b(^104\.((6[4-9]{1})|(7[0-9]{1})|(8[0-9]{1})|(9[0-9]{1})|(10[0-9]{1})|(11[0-9]{1})|(12[0-7]{1})))| (^13\.((6[4-9]{1})|(7[0-9]{1})|(8[0-9]{1})|(9[0-9]{1})|(10[0-7]{1})))| (^131\.253\.(([2-4]{1}[1-9]{1}))(\.[0-9]{1,3}){2})| (^134\.170(\.[0-9]{1,3}){2})| (^137\.117(\.[0-9]{1,3}){2})| (^137\.135(\.[0-9]{1,3}){2})| (^138\.91(\.[0-9]{1,3}){2})| (^152\.163(\.[0-9]{1,3}){2})| (^168\.((6[1-3]{1}))(\.[0-9]{1,3}){2})| (^191\.239\.160\.97)| (^23\.((3[2-9]{1})|(6[0-7]{1}))(\.[0-9]{1,3}){2})| (^23\.((9[6-9]{1})|(10[0-3]{1}))(\.[0-9]{1,3}){2})| (^2((2[4-9]{1})|(3[0-9]{1}))(\.[0-9]{1,3}){3})| (^40\.((7[4-9]{1})|([8-9]{1}[0-9]{1})|(10[0-9]{1})|(11[0-9]{1})|(12[0-5]{1}))(\.[0-9]{1,3}){2})| (^52\.((8[4-9]{1})|(9[0-5]{1}))(\.[0-9]{1,3}){2})| (^54\.((22[4-9]{1})|(23[0-9]{1}))(\.[0-9]{1,3}){2})| (^54\.((23[0-1]{1}))(\.[0-9]{1,3}){2})| (^64\.86(\.[0-9]{1,3}){2})| (^65\.((5[2-5]{1}))(\.[0-9]{1,3}){2})| (^69\.164\.(([0-9]{1})|([1-5]{1}[0-9]{1})|((6[0-3]{1}))(\.[0-9]{1,3}))| (^40.(7[4-9]|[8-9][0-9]|1[0-1][0-9]|12[0-7])(\.[0-9]{1,3}){2})| (^157\.(5[4-9]|60)(\.[0-9]{1,3}){2})| (^(204\.79\.(19[5-7])\.[0-9]{1,3}))\b"
		XBOX_EXTRA="(93\.184\.215\.[0-9]{1,3}|205\.185\.216\.[0-9]{1,3})"
		KEYWORD_FILTER="(xbox|xbl|microsoft|msft|stackpath|HIGHWINDS)"
		FILTERIP="^(${MICROSOFT_SERVERS}|${XBOX_EXTRA})"
		LOADEDFILTER="${GREEN}Xbox${NC}"
          ;;

     *) #PC/Debug/Custom
        KEYWORD_FILTER="(DC29C259E47FAC12E593E57A882B0B32D70B9EF960)"
		FILTERIP="^99999" #Debug, Add IPs to whitelist.txt file instead
		LOADEDFILTER="${YELLOW}${IDENT}${NC}"

esac
fi
}
if [ "${IDENT}" != "$(echo "${IDENT}" | grep -Eio "debug")" ] || [ $POPULATE != 0 ]; then
	ONTHEFLYFILTER="(\b${KEYWORD_FILTER}\b)|(((([0-9A-Za-z\-]+\.)*google\.(((co|ad|ae)(m)?(\.)?[a-z]{2})|cat)(/|$)))|GOOGLE\-CLOUD|GOGL|goog)|((amazon(\s)?aws)|(AMAZO)|(Amazon\.com)|(Amazon Data Services))|((akamai(\s)?technologies)|(Akamai)|(AKAMAI\-[A-Z]{1,})|(AKAMAI-TATAC))|(verizondigitalmedia)|((UUnet Technologies)|(EDGECAST\-NETBLK\-[0-9]{1,}))|\b(TWITT)\b|((EDGECAST(.*)?)|(edgecast))|(cdn)|(nintendowifi\.net)|((nintendo|xboxlive|sony|playstation)\.net)|(ps[2-9])|((nflxvideo)|(netflix))|(easo\.ea\.com|\.ea\.com)|(\.1e100\.net)|(Sony Online Entertainment)|(cloudfront\.net)|(facebook|fb-net)|(\b((IANA)|(IANA-RESERVED)|(Internet Assigned Numbers Authority)|(MCAST-NET))\b)|(CLOUDFLARENET|Cloudflare)|(BAD REQUEST)|(blizzard)|((NC Interactive)|(ncsoft)|(NCINT))|(RIOT(\s)?GAMES|RIOT)|(SQUARE ENIX)|(Valve Corporation)|(Ubisoft)|(LVLT-ORG-[0-9]{1,}-[0-9]{1,})|(not found)|(LINODE)|(oath(\s)holdings)|(thePlatform)|(MoPub\,\sInc|mopub)|(([0-9A-Za-z\-]+\.)*nintendo(-europe|servicecentre)?\.(((co(m)?)((\.)?[a-z]{2})?)))|(limelightnetworks\.com|limelightnetworks|LLNW|ipapi\.co)|((AMAZON-DUB)|((ARIN Operations)|(ARIN Operations Abuse)))" # Ignores if these words are found in whois requests
	AMAZON_SERVERS="^\b((13\.(2(4[89]|5[01]))\.[0-9]{1,3}\.[0-9]{1,3})|(52\.([0-2][0-9]|3[[01])\.[0-9]{1,3}\.[0-9]{1,3})|(54\.23[01]\.[0-9]{1,3}\.[0-9]{1,3})|(52\.(3[2-9]|[4-5][0-9]|6[0-3])(\.[0-9]{1,3}){2})|(13\.249(\.[0-9]{1,3}){2}))\b"
	GOOGLE_SERVERS="^\b((173.194\.[0-9]{1,3}\.[0-9]{1,3})|(64\.233\.(1[6-8][0-9]|19[01])\.[0-9]{1,3})|(74\.125\.[0-9]{1,3}\.[0-9]{1,3})|(64\.233\.(1[7-8][0-9]|19[0-1])\.[0-9]{1,3})|(13\.249(\.[0-9]{1,3}){2}))\b"
	MSFT_SERVERS="^\b((52\.(1((4[5-9])|([5-8][0-9])|(9[0-1])))\.[0-9]{1,3}\.[0-9]{1,3})|(52\.(2(2[4-9]|[3-5][0-9]))\.[0-9]{1,3}\.[0-9]{1,3})|(52\.(9[6-9]|10[0-9]|11[1-5])\.[0-9]{1,3}\.[0-9]{1,3})|(131\.253\.1[2-8]\.[0-9]{1,3})|(70\.37\.(1?[0-9]?[01])\.[0-9]{1,3})|(13\.(6[4-9]|[7-9][0-9]|10[0-7])(\.[0-9]{1,3}){2})|(52\.(13[2-9]|14[0-3])(\.[0-9]{1,3}){2}))\b"
	LINODE="^\b(173\.255\.((19[2-9])|(2[0-9]{2})\.))\b"
	CLOUDFLARE="^\b(162\.15[89]\.[0-9]{1,3}\.[0-9]{1,3})\b"
	LEVEL_3_SERVERS="^\b(8\.(2((2[4-9])|[3-9][0-9]))\.[0-9]{1,3}\.[0-9]{1,3})\b"
	IANA_IPs="^\b((10(\.[0-9]{1,3}){3})|(2(2[4-9]|3[0-9])(\.[0-9]{1,3}){3})|(255(\.([0-9]){1,3}){3})| (100\.((6[4-9])|[7-9][0-9]|1(([0-1][0-9])|(2[0-7]))))|(172\.((1[6-9])|(2[0-9])|(3[0-1]))\.([0-9]){1,3}\.([0-9]){1,3})|(169\.254\.[0-9]{1,3}\.[0-9]{1,3})|(2(2[4-9]|3[0-9])(\.[0-9]{1,3}){3})|(192\.0\.2\.[0-9]{1,3})|(100\.((6[4-9])|([7-9][0-9])|([1-2][0-9]{2}))(\.[0-9]{1,3}){2})|(2(2[4-9]|3[0-9])(\.[0-9]{1,3}){3})|((22[4-9]|23[0-9])(\.([0-9]{1,3})){3}))\b"
	ARIN="^\b((192\.136\.136\.[0-9]{1,3})|(199\.71\.0\.[0-9]{1,3})|(199\.5\.26\.[0-9]{1,3})|(199\.71\.0\.[0-9]{1,3})|(172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3})|((22[4-9]|23[0-9])\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))\b"
	AKAMAI="^\b((23.(3[2-9]|[4-5][0-9]|6[0-7])(\.[0-9]{1,3}){2})|(23\.7[2-9](\.[0-9]{1,3}){2})|(64\.86\.206\.[0-9]{1,3})|(184\.(2[4-9]|3[0-1])(\.[0-9]{1,3}){2})|(23\.((19[2-9])|2(([01][0-9])|(2[0-3])))(\.[0-9]{1,3}){2}))\b"
	RESERVED_IPs="^\b((203(\.[0-9]{1,3}){3})|(172\.((1[6-9])|[23][0-9])(\.[0-9]{1,3}){2})|((22[4-9]|23[0-9])(\.[0-9]{0,3}){3})|(172\.(1[6-9]|2[0-9]|3[0-1])(\.[0-9]{0,3}){2})|(172\.(1[6-9]|2[0-9]|3[0-1])(\.([0-9]{1,3})){2}))\b"
	ONTHEFLYFILTER_IPs="${IANA_IPs}|${ARIN}|${MSFT_SERVERS}|${LINODE}|${CLOUDFLARE}|${AMAZON_SERVERS}|${GOOGLE_SERVERS}|${LEVEL_3_SERVERS}|${AKAMAI}|${RESERVED_IPs}|1\.0\.0\.1|1\.1\.1\.1|127\.0\.0\.1|8\.8\.8\.8|8\.8\.4\.4|(151\.101\.[0-9]{1,3}\.[0-9]{1,3})|(148\.25[123]{1}\.[0-9]{1,3}\.[0-9]{1,3})" #Ignores these IPs, usually IANA reserved or something
	#GO TO TESTING
	GTT_ISPs="((Highwinds( Network Group)?)|(Suddenlink Communications)|(SUDDE)|(Buckeye Cablevision)|(Google Fiber)|(Comcast Cable Communications)|(Comcast IP Services)|((comcast)|(Comcast Cable Communications))|(spectrum)|(Charter( Communications Inc)?)|(Charter)|(Legacy Time Warner Cable IP Assets)|(fios)|(SBC[A-Z0-9]{2}-[A-Z0-9]{4}-[A-Z0-9]{4})|Vodafone|(Cogent( Communications)?)|(Adams CATV)|(Movistar Fibra)|((WIDEOPENWEST)|(Wide Open West))|(Rogers Cable)|(MEDIACOM-RESIDENTIAL-CUST)|(Cox Communications)|(Optimum Online)|(SAUDINET_DSL_POOL)|(Antietam Cable Television)|(Antietam Broadband)|(BSKYB-BROADBAND)|(mega(\s)?cable)|(SKY-BROADBAND)|(wisper(\s)?isp)|((AT&T Corp)|(ATT Internet Services))|(BT Public Internet Service)|(Bell Canada)|(Windstream Communications)|(CENTURYLINK)|(Watch Communications)|(WATCHCOMM)|(UNINET|UniNet)|((ELONU)|Elon (University|university|college))|(BCI Mississippi Broadband)|(MAXXSOUTH)|(timbrasil)|(Consolidated Communications)|(NTT America)|((MetroNet|metronet)|(Cinergy Metronet)|(Cinergy))|((CABLEONE)|(CABLE ONE)|(Cable ONE Network Operations Center))|((Mediacom)|(Mediacom Communications Corp))|((Hargray)|(Hargray Communications Group))|((Cable Bahamas)|(cablebahamas))|(Eagle Communications|eaglecom)|(Charter( Communications Inc)?))|((Internet Operations U S WEST)|(bullet-proof)|(BULLETPROOF))|((Seaside Communications)|(SEASIDE-CABLE))|(TDS TELECOM)" #Internet providers

	GTT_TYPE="((\"ASSIGNMENT\")|(allocated)|(ASSIGNED P[AI])|(PARTITIONED PA))" #IP Allocation type, *should* distinguish consumer/residential from businesses
	GTT_KEYWORDS="((\b(residen(t|ce|tial)))|(customer(s)?)|(Dynamic pools))"
	GTT_NAME="(\"name\" ?\: ?\"\b(([A-Z]{3}|[A-Z]{5,})(-[A-Z0-9]{3,}){1,}(-[0-9]{1,})?)\b\")" #Name regex
	GOTTOTESTING="(${GTT_NAME}|${GTT_ISPs}|${GTT_TYPE}|${GTT_KEYWORDS})" #Should prevent incidental misses.
else
	ONTHEFLYFILTER="${RANDOMGET}"
	ONTHEFLYFILTER_IPs="${RANDOMGET}"
	GOTTOTESTING="${RANDOMGET}"
fi

IGNORE_NOT_FOUND="Not Found"
##### Filter #####
##### TWEAKS #####
# create 42Kmi/tweak.txt to edit these values
if [ $MAKE_TWEAK = 1 ]; then
if [ ! -f "$DIR"/42Kmi/tweak.txt ]; then
echo -e "TWEAK_PINGRESOLUTION=1 #Number of pings sent
TWEAK_SMARTLINECOUNT=8 #Number of lines before averaging
TWEAK_SMARTPERCENT=155 #Percentage of average before using average
TWEAK_SMART_AVG_COND=2 #Number of items that must be higher than average before using average
TWEAK_SENTMODE=5 #0 or 1=Difference, 2=X^2, 3=Difference or X^2, 4=Difference & X^2, 5=Difference & X^2 & StdDev
TWEAK_SENTLOSSLIMIT= #Number before Sentinel takes action. Remember to set to appropriate value when switching between packet or byte mode
TWEAK_SENTINELDELAYSMALL=1 #Interval to record difference"|sed -E "s/^(\s)*//g" > "$DIR"/42Kmi/tweak.txt
fi
fi

if [ -f "$DIR"/42Kmi/tweak.txt ]; then
	TWEAK_SETTINGS="$(tail +1 "$DIR"/42Kmi/tweak.txt|sed -E "s/(\s*)?#.*$//g"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E 's/^.*=//g')" #Settings stored here, called from memory
	TWEAK_PINGRESOLUTION="$(echo "$TWEAK_SETTINGS"|sed -n 1p)"
	TWEAK_SMARTLINECOUNT="$(echo "$TWEAK_SETTINGS"|sed -n 2p)"
	TWEAK_SMARTPERCENT="$(echo "$TWEAK_SETTINGS"|sed -n 3p)"
	TWEAK_SMART_AVG_COND="$(echo "$TWEAK_SETTINGS"|sed -n 4p)"
	TWEAK_SENTMODE="$(echo "$TWEAK_SETTINGS"|sed -n 5p)"
	TWEAK_SENTLOSSLIMIT="$(echo "$TWEAK_SETTINGS"|sed -n 6p)"
	TWEAK_SENTINELDELAYSMALL="$(echo "$TWEAK_SETTINGS"|sed -n 7p)"
fi
##### TWEAKS #####
##### Get Country via ipapi.co #####
#ipapi.co, © 2018 Kloudend, Inc.
panama(){
	VACATION="$1"

	if [ $2 != "" ]; then
		ROUND_TRIP="$2"
	else
		ROUND_TRIP=1
	fi

	#PAD
	if ! { echo "$VACATION"|grep -Eq "^\b([0-9]{1,3}(\.[0-9]{1,3}){3})\b$"; }; then
		PADDED="$VACATION"
	else
		PADDED="$(printf "$VACATION"|sed -E -e "s/\b([0-9]{1,2})\b/$(echo "00\1")/g" -e "s/\b0([0-9]{3})\b/\1/g")" #Single-line piped padding
	fi
	for destination in "$PADDED"; do
		if [ $ROUND_TRIP -gt 0 ]; then
			n=0; while [[ $n -lt $ROUND_TRIP ]]; do { destination_new="$(printf $(printf "$destination"|openssl enc -base64)|sed "s/\s//g")"; destination=$destination_new; } ; n=$((n+1)); done
			wait $!
			printf $destination_new
		else
			printf $destination
		fi
	done
	wait $!
}
if [ $SHOWLOCATION = 1 ]; then
	##### Regional & Country Bans #####
	bancountry(){
		BANCOUNTRY="" #Reinitialize
		if [ -f "$DIR"/42Kmi/bancountry.txt ]; then
			#Country
			BANCOUNTRY="$(echo $(echo "$(tail +1 ""${DIR}"/42Kmi/bancountry.txt"|sed -E "s/$/|/g")")|sed -E "s/\|$//g"|sed -E "s/\| /|/g"|sed 's/,/\\,/g'|sed -E "s/\|$//"|sed -E "s/\s/\%/g")" # "CC" format for Country only; "RR, CC" format for Region by Country; "(RR|GG), CC" format for multiple regions by country
			if { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"| grep -Ei "($BANCOUNTRY)"; }; then
				BANCOUNTRYIP="$(tail +1 "/tmp/$RANDOMGET"|grep -Ei "($BANCOUNTRY).\[.*$"|grep -Eo "(([0-9]{1,3}\.){3})([0-9]{1,3})\b""${ADDWHITELIST}")"
				for ip in $BANCOUNTRYIP; do
					if ! { iptables -nL LDBAN|grep -Eoq "\b${ip}\b"; }; then
						iptables -A LDBAN -s $ip -d $CONSOLE -j REJECT --reject-with icmp-host-prohibited ${WAITLOCK}; wait $!
					fi
					TABLENAMES="LDACCEPT LDREJECT LDTEMPHOLD"
					for tablename in $TABLENAMES; do
						TABLELINENUMBER="$(iptables --line-number -nL $tablename|grep -E "\b${ip}\b"|grep -Eo "^(\s*)?[0-9]{1,}")"
						if iptables -nL $tablename "$WAITLOCK"; then
							iptables -D $tablename "$TABLELINENUMBER"
						fi
					done
					sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m)?(${ip})\b/$(echo -e "#${BG_RED}")\2/g" "/tmp/$RANDOMGET"; sleep 5 #Background color notification for banned country/region
					sed -i -E "/(m)?${ip}#/d" "/tmp/$RANDOMGET"
				done #&
			fi #&
		fi
	}
	location_corrections(){
		#Add corrections for formatting.
		case "${LDCOUNTRY}" in
		#Blank
			"$(echo "${LDCOUNTRY}"|grep -Eo "^$")")
				LDCOUNTRY="NOT FOUND - CANNOT CONNECT"
				;;
		#All
			"$(echo "${LDCOUNTRY}"|grep -F "City of ")")
				LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/City of //g")"
				;;
			"$(echo "${LDCOUNTRY}"|grep -F "Township of ")")
				LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/Township of //g")"
				;;
			"$(echo "${LDCOUNTRY}"|grep -F "Fort ")")
				LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/Fort /Ft. /g")"
				;;
			"$(echo "${LDCOUNTRY}"|grep -F "Mount ")")
				LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/Mount /Mt. /g")"
				;;
			"$(echo "${LDCOUNTRY}"|grep -F "Saint ")")
				LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/Saint /St. /g")"
				;;
			"$(echo "${LDCOUNTRY}"|grep -F "St ")")
				LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/St /St. /g")"
				;;
			"$(echo "${LDCOUNTRY}"|grep -F " Municipality")")
				LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/ Municipality//g")"
				;;
		#AF
		#AS
			#Taiwan
				"$(echo "${LDCOUNTRY}"|grep -Eo "^Taipei\, TPE\, TW\, AS\, Peicity Digital Cable Television\.\, LTD")")
					LDCOUNTRY="Taipei, TPE, TW, AS"
					;;
			#China
				"$(echo "${LDCOUNTRY}"|grep -F " Chengguanzhen")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/ Chengguanzhen//g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eo "^水果湖街道\, CN\, AS")")
					LDCOUNTRY="Wuhan, HB, CN, AS" #Shuiguo Lake, HB, CN, AS
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eo "^luohe shi\,Henan\, CN\, AS")")
					LDCOUNTRY="Luohe, HA, CN, AS"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Henan\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Henan\,/, HA,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Tianjin\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Tianjin\,/, TJ,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Anhui\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Anhui\,/, AH,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Beijing\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Beijing\,/, BJ,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Chongqing\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Chongqing\,/, CQ,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Hainan\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Hainan\,/, HI,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Heilongjiang\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Heilongjiang\,/, HL,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Shanghai\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Shanghai\,/, SH,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Jiangsu\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Jiangsu\,/, JS,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Jiangxi\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Jiangxi\,/, JX,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Fujian\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Fujian\,/, FJ,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Sh(a){1,2}nxi\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Sh(a){1,2}nxi\,/, SX,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Zhejiang\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Zhejiang\,/, ZJ,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Sichuan\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Sichuan\,/, SC,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Hubei\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Hubei\,/, HB,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Hebei\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Hebei\,/, HE,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Liaoning\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Liaoning\,/, LN,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Inner Mongolia\, CN\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Inner Mongolia\,/, NM,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "(([A-Za-z]{4,}( )?[Ss]hi), .*, CN, AS)$")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/([A-Za-z]{4,})(( )?[Ss]hi)(, .*, CN, AS)/\1\4/g")" #Removes "Shi" suffix from city name.
					;;
			#Japan
				"$(echo "${LDCOUNTRY}"|grep -Eoi "(([A-Za-z]{4,}([ -])[Ss]hi), .*, JP, AS)$")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/([A-Za-z]{4,})(([ -])[Ss]hi)(, .*, JP, AS)/\1\4/g")" #Removes "Shi" suffix from city name.
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^Higashi-Hiroshima\, Hiroshima\, JP\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/Higashi-Hiroshima\,/Higashihiroshima,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^Kita Ward\, Ōsaka\, JP\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/Kita Ward\,/Kita-ku,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, ÅŒsaka\, JP\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, ÅŒsaka\,/, Ōsaka,/g")"
					;;
			#Saudi Arabia
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, ((Riyadh Region)|(Ar Riyāḑ))\, SA\, AS")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, ((Riyadh Region)|(Ar Riyāḑ))\,/, Riyadh,/g")"
					;;
		#AT
		#EU
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Moscow\, MOW\, RU\, EU\, [a-zA-Z]{3,} Moscow city telephone network")")
				LDCOUNTRY="Moscow, MOW, RU, EU"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "RU\, EU\, [a-zA-Z]{3,} Moscow city telephone network")")
				LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/(\, RU\, EU).*$/\1/g")"
				;;
			#GB
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, England\, GB\, EU")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, England\,/, ENG,/g")"
					;;
			#FR
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Auvergne-Rhône-Alpes\, FR\, EU")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Auvergne-Rhône-Alpes\,/, ARA,/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Provence-Alpes-Côte d'Azur\, FR\, EU")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Provence-Alpes-Côte d'Azur\,/, PAC,/g")"
					;;
		#NA
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Emigrant Gap\, US\, NA")")
				LDCOUNTRY="Emigrant Gap, CA, US, NA"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Research Triangle Park, US, NA")")
				LDCOUNTRY="Research Triangle Park, NC, US, NA"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "^(Newcastle\, US\, NA)|(Newcastle\, Washington\, US\, NA)")")
				LDCOUNTRY="Newcastle, WA, US, NA"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Maplewood\, US\, NA")")
				LDCOUNTRY="Maplewood, MN, US, NA"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "^(Northlake\, US\, NA)|(Northlake\, Illinois\, US)")")
				LDCOUNTRY="Northlake, Il, US, NA"
				;;
			"$(echo "${LDCOUNTRY}"|grep -Eo "^Tysons\, Virginia\, US\, NA")")
				LDCOUNTRY="Tysons, VA, US, NA"
				;;
			#UnitedStates
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Alabama\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Alabama\,/, AL,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Alaska\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Alaska\,/, AK,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Arizona\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Arizona\,/, AZ,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Arkansas\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Arkansas\,/, AR,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, California\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, California\,/, CA,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Colorado\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Colorado\,/, CO,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Delaware\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Delaware\,/, DE,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Florida\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Florida\,/, FL,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Georgia\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Georgia\,/, GA,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Hawaii\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Hawaii\,/, HI,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Idaho\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Idaho\,/, ID,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Illinois\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Illinois\,/, IL,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Indiana\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Indiana\,/, IN,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Iowa\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Iowa\,/, IA,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Kansas\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Kansas\,/, KS,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Kentucky\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Kentucky\,/, KY,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Louisiana\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Louisiana\,/, LA,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Maine\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Maine\,/, ME,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Maryland\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Maryland\,/, MD,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Massachusetts\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Massachusetts\,/, MA,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Michigan\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Michigan\,/, MI,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Minnesota\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Minnesota\,/, MN,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Mississippi\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Mississippi\,/, MS,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Missouri\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Missouri\,/, MO,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Montana\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Montana\,/, MT,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Nebraska\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Nebraska\,/, NE,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Nevada\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Nevada\,/, NV,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, New Hampshire\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, New Hampshire\,/, NH,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, New Jersey\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, New Jersey\,/, NJ,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, New Mexico\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, New Mexico\,/, NM,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, New York\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, New York\,/, NY,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, North Carolina\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, North Carolina\,/, NC,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, North Dakota\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, North Dakota\,/, ND,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Ohio\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Ohio\,/, OH,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Oklahoma\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Oklahoma\,/, OK,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Oregon\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Oregon\,/, OR,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Pennsylvania\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Pennsylvania\,/, PA,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Rhode Island\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Rhode Island\,/, RI,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, South Carolina\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, South Carolina\,/, SC,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, South Dakota\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, South Dakota\,/, SD,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Tennessee\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Tennessee\,/, TN,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Texas\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Texas\,/, TX,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Utah\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Utah\,/, UT,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Vermont\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Vermont\,/, VT,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Virginia\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Virginia\,/, VA,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Washington\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Washington\,/, WA,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, West Virginia\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, West Virginia\,/, WV,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Wisconsin\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Wisconsin\,/, WI,/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Wyoming\, US\, NA")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Wyoming\,/, WY,/g")"
						;;

		#SA
			#Brazil
				"$(echo "${LDCOUNTRY}"|grep -Eo "^Manguinhos\, BR\, SA")")
					LDCOUNTRY="Manguinhos, RJ, BR, SA"
					;;
			#Colombia
				"$(echo "${LDCOUNTRY}"|grep -Eo "Cochabamba\, BO\, SA")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Cochabamba\, BO\, SA/, C, BO, SA/g")"
					;;
				"$(echo "${LDCOUNTRY}"|grep -Eo "La Paz,\, BO\, SA")")
					LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, La Paz\, BO\, SA/, L, BO, SA/g")"
					;;
		#OC
			#Australia
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, Western Australia\, AU\, OC")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Western Australia\, AU\, OC/, WA, AU, OC/g")"
						;;
					"$(echo "${LDCOUNTRY}"|grep -Eoi "^(.*)\, \, AU\, OC")")
						LDCOUNTRY="$(echo "$LDCOUNTRY"|sed -E "s/\, Queensland\, AU\, OC/, QLD, AU, OC/g")"
						;;

		#General null region
			"$(echo "${LDCOUNTRY}"|grep -Eo "^([a-zA-Z -]{1,})\, ([A-Z]{2})\, ([A-Z]{2})$")")
				LDCOUNTRY="$(echo "${LDCOUNTRY}"|sed -E "s/([a-zA-Z -]{1,})\, ([A-Z]{2})\, ([A-Z]{2})/\1, 0null0, \2, \3/g")"
				;;
		esac
	}
	peerdecay(){
		#approximate location from terminal decay of encrypted IP address, location of unknown IP address is assumed to be similar to location of similar encrypted IP addresses
		PEERENC_STR_LENGTH_SET="$(printf "$peerenc" | wc -c)"
		PEERENC_STR_LENGTH="$PEERENC_STR_LENGTH_SET"
		PEERENC_STR_LENGTH_LIMIT=10 #Maximum number of runs (number of trailing characters to remove)
		PEER_DECAY="$peerenc"
		PEER_DECAY_GEOMEM_COUNT=""
		PEER_DECAY_GEOMEM_COUNT_LIMIT=5 #10 #Minimum number of results needed before determining location from IP
		PEER_DECAY_NEXT_PART=0
		PEER_DECAY_NEW="${PEER_DECAY}"
		
		#PEER_DECAY_TERMINAL_SET="$(printf "${PEER_DECAY}"|sed -E "s/(.{${PEERENC_STR_LENGTH_LIMIT}})$//g")"
		PEER_DECAY_TERMINAL_SET="${PEER_DECAY:0:-${PEERENC_STR_LENGTH_LIMIT}}"
		PEER_DECAY_GEOMEM_PREPULL="$(grep -E "^(${PEER_DECAY_TERMINAL_SET})" "${DIR}/42Kmi/${GEOMEMFILE}")" #Full pull of the exhausted PEER_DECAY is read instead so geomem is not conitnually called.

		until [ $PEERENC_STR_LENGTH -le $PEERENC_STR_LENGTH_LIMIT ] || [ $PEER_DECAY_GEOMEM_COUNT -ge $PEER_DECAY_GEOMEM_COUNT_LIMIT ]; do
			PEER_DECAY_NEW="$(printf "${PEER_DECAY_NEW}"|sed -E "s/(^[a-zA-Z0-9]{1,})(.)/\1/g")"

			#PEER_DECAY_GEOMEM_GET="$(grep -E "^(${PEER_DECAY_NEW})" "${DIR}/42Kmi/${GEOMEMFILE}")" #List of locations partially matching PEER_DECAY, from beginning 
			PEER_DECAY_GEOMEM_GET="$(echo "${PEER_DECAY_GEOMEM_PREPULL}"|grep -E "^(${PEER_DECAY_NEW})")" #List of locations partially matching PEER_DECAY, from beginning 
			PEER_DECAY_GEOMEM_COUNT="$(printf "${PEER_DECAY_GEOMEM_GET}"|wc -l)"

			if [ $PEER_DECAY_GEOMEM_COUNT -lt $PEER_DECAY_GEOMEM_COUNT_LIMIT ]; then
				PEER_DECAY_NEXT_PART=0
				PEERENC_STR_LENGTH=$(( PEERENC_STR_LENGTH - 1 ))
			else
				PEER_DECAY_NEXT_PART=1
			fi
		done; wait $!

		if [ $PEER_DECAY_NEXT_PART = 1 ]; then
			if [ $PEER_DECAY_GEOMEM_COUNT -ge $PEER_DECAY_GEOMEM_COUNT_LIMIT ]; then
				PEER_DECAY_GETLOCATE="$(printf "${PEER_DECAY_GEOMEM_GET}"|sed -E "s/^(.*)#//g"|awk '!a[$0]++')" #Locations list; each location is counted later to determine how many times it appears in PEER_DECAY_GEOMEM_GET
				{
					IFS=$'\n'
					LOCATION_COUNT_SORT="$(for line in ${PEER_DECAY_GETLOCATE}; do PEER_DECAY_LOCATION_COUNT="$(printf "${PEER_DECAY_GEOMEM_GET}"|grep -Ec "#(${line})$")"; echo "${PEER_DECAY_LOCATION_COUNT}#${line}"; done|sort -nr|sed -n 1p|sed -E "s/^[0-9]{1,}#//g")"
				}; wait $!
				LDCOUNTRY="${LOCATION_COUNT_SORT}"
				unset IFS
			else
				LDCOUNTRY=", , ,"
			fi
		else
			LDCOUNTRY=", , ,"
		fi
	}
	ZYZZX="$(echo "aHR0cHM6Ly9pcGFwaS5jbw=="|openssl enc -base64 -d)"
	new_location(){
		LDCOUNTRY="" #Clears location, seems to be necessary
		LOCATION_DATA_STORE="$({ curl --no-keepalive --no-buffer --connect-timeout ${CURL_TIMEOUT} -sk -A "${RANDOMGET_GET}" "${ZYZZX}/"$peer"/json/" & LOCATE_PID=$!; ( sleep ${CURL_FORCED_TIMEOUT} && kill -9 $LOCATE_PID ) & }|sed -E -e "/\{|\}/d" -e "s/^\s*//g" -e "s/,$//g" -e "s/\"//g")"
		if ! { echo "$LOCATION_DATA_STORE"|grep -Eqi "((reason: RateLimited)|(RateLimited)|(error: true))"; }; then
			if ! { echo "$LOCATION_DATA_STORE"|grep -Eqi "((reason: Reserved IP Address)|(org: ARIN(-[A-Z0-9]{3,}){2}))"; }; then
				if ! { echo "$LOCATION_DATA_STORE"|grep -Eqi "RateLimited"; }; then
					LOCATE_STORE_CITY="$(echo "$LOCATION_DATA_STORE"|grep "city:"|sed "s/^.*:\s*//g")"
					LOCATE_STORE_REGION="$(echo "$LOCATION_DATA_STORE"|grep "region:"|sed "s/^.*:\s*//g")"
					LOCATE_STORE_REGION_CODE="$(echo "$LOCATION_DATA_STORE"|grep "region_code:"|sed "s/^.*:\s*//g")"
					LOCATE_STORE_COUNTRY="$(echo "$LOCATION_DATA_STORE"|grep "country_name:"|sed "s/^.*:\s*//g")"
					LOCATE_STORE_COUNTRY_CODE="$(echo "$LOCATION_DATA_STORE"|grep "country_code:"|sed "s/^.*:\s*//g")"
					LOCATE_STORE_COUNTRY_CODE_ISO="$(echo "$LOCATION_DATA_STORE"|grep "country_code_iso3"|sed "s/^.*:\s*//g")"
					LOCATE_STORE_COUNTRY_CODE_TLD="$(echo "$LOCATION_DATA_STORE"|grep "country_tld:"|sed "s/^.*:\s*//g"|sed -E "/\.//"|awk '{print toupper($0)}')"
					LOCATE_STORE_CONTINENT_CODE="$(echo "$LOCATION_DATA_STORE"|grep "continent_code:"|sed "s/^.*:\s*//g")"
				fi
			else
				if ! { echo "$FILTERIGNORE_GET"|grep -Eo "^(${peer}|${peerenc})$"; } || ! { grep -Eo "^(${peer}|${peerenc})$" "${DIR}/42Kmi/${FILTERIGNORE}"; }; then echo "$peerenc" >> "${DIR}/42Kmi/${FILTERIGNORE}"; fi
			fi
		else
			LDCOUNTRY=""
			LOCATION_RATE_LIMIT=1
		fi
		
		if [ $LOCATION_RATE_LIMIT != 1 ]; then LOCATION_RATE_LIMIT=0; fi
		LOC1="$LOCATE_STORE_CITY" #City
		if { echo "$LOCATE_STORE_REGION_CODE"|grep -Eiq "((null)|([0-9]{2,}))"; }; then LOC2="$LOCATE_STORE_REGION";else LOC2="$LOCATE_STORE_REGION_CODE";fi #Region
		LOC3="$LOCATE_STORE_COUNTRY_CODE" #Country
		LOC4="$LOCATE_STORE_CONTINENT_CODE" #Continent
		if { echo "$LOC2"|grep -iq "null"; }; then LOC2="";fi #Region
			#Region Abbreviation preference: if region name length for LOC2 is greater than 3 chars, LagDrop will check geomem for a similar location entry that uses the region abbreviation instead to replace the name ipapi found.
			if [ "$(echo -n "$LOC2"|wc -c)" -gt 3 ]; then
				GET_REGION_NAME="$(grep -E "${LOC1}, .*, ${LOC3}, ${LOC4}" "${DIR}/42Kmi/${GEOMEMFILE}"|sed -e "s/^.*#//g"|awk '!a[$0]++'|sed -E "s/\b("${LOC1}, ${LOC2}, ${LOC3}, ${LOC4}")\b//g" -e "s/\b(${LOC1},|, ${LOC3}|, ${LOC4})\b//g" -e "s/^(\s|\d)*$//g"|awk '!a[$0]++')"
				
				if [ "$GET_REGION_NAME" != "" ]; then
					if [ "$(echo -n "$GET_REGION_NAME"|wc -c)" -lt "$(echo -n "$LOC2"|wc -c)" ]; then LOC2="$GET_REGION_NAME"; fi
				fi
			else
				#Fail fallback
				LOC2="$LOC2" #Region
			fi

			if [ $LOCATION_RATE_LIMIT = 1 ] || [ $LDCOUNTRY = "" ]; then
				if [ "$STORE_OLD_LOCATION" != "" ] || [ -n "$STORE_OLD_LOCATION" ]; then
					LDCOUNTRY="${STORE_OLD_LOCATION}"
				else
					if [ $GEOMEMCOUNTLOCK != 1 ]; then GEOMEMCOUNT="$(wc -l "${DIR}/42Kmi/${GEOMEMFILE}")"; GEOMEMCOUNTLOCK=1; fi
					if [ "$GEOMEMCOUNT" -ge 1500 ]; then
						peerdecay
					else
						LDCOUNTRY=", , ,"
					fi
				fi
			else
				LDCOUNTRY="${LOC1}, ${LOC2}, ${LOC3}, ${LOC4}"
			fi
			wait $!

			location_corrections
			
			DAYinSEC=86400; STAGGER_PAD=""; until [ "${STAGGER_PAD}" -le 30 ] && [ "${STAGGER_PAD}" -ge 10 ]; do STAGGER_PAD="$(dd if=/dev/urandom | tr -dc '0-9' | head -c 2| sed "s/^0//g")"; done; wait $!
			STAGGER_PAD="$(( STAGGER_PAD * DAYinSEC ))"
			WriteNew_IP_TIME_Get="$(date +%s)"; WriteNew_IP_TIME="$(( WriteNew_IP_TIME_Get + STAGGER_PAD ))"
			
			if ! { grep -Eoq "^("$peer"|"$peerenc")#" "${DIR}/42Kmi/${GEOMEMFILE}"; }; then echo ""$peerenc"#"$WriteNew_IP_TIME"#"$LDCOUNTRY"" >> "${DIR}/42Kmi/${GEOMEMFILE}"; fi
			LDCOUNTRYCHECK="$(echo "$LDCOUNTRY"|sed -E "s/.{4}$//g")"
			CONTINENT="$(echo $LDCOUNTRY|sed -E "s/.{4}$//g")"
	}
	##### Regional & Country Bans #####
	checkcountry(){
		LDCOUNTRY="" #Clears location, seems to be necessary
		if [ $1 != "" ] && { echo "$1"|grep -Eoq "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b" ;}; then
			peer="$1"
			peerenc="$(panama $1)"
		fi
		if { echo "$GEOMEM_GET"|grep -Eoq "^("$peer"|"$peerenc")#"; };then
			DAYinSEC=86400
			IP_LEASE_TIME_LIMIT=30 #Days
			NOW_IP_TIME="$(date +%s)"
			GET_PREV_IP_TIME="$(grep -E "^($peerenc)" "${DIR}/42Kmi/${GEOMEMFILE}"|grep -Eo "#\d*#"|sed -E "s/#//g")"

			IP_AGE="$(( NOW_IP_TIME - GET_PREV_IP_TIME ))"; IP_AGE="$(( IP_AGE / DAYinSEC ))"

			#Check age of location in geomem
			STORE_OLD_LOCATION=""
			if ! { echo "$FILTERIGNORE_GET"|grep -Eoq "^(${peer}|${peerenc})$"; }; then
				if [ "$IP_AGE" = "" ] || [ "$IP_AGE" -ge "$IP_LEASE_TIME_LIMIT" ]; then
					#Location hold over, in case of rate limit reached
					STORE_OLD_LOCATION="$(echo "$GEOMEM_GET"|grep -E "^("$peer"|"$peerenc")#"|sed -n 1p|sed -E "s/^($peer|$peerenc)#\d*#//g")"
					sed -i -E "/^($peer|$peerenc)#/d" "${DIR}/42Kmi/${GEOMEMFILE}"; wait $! #delete expired entry to generate new
					new_location
				else
					LDCOUNTRY="$(echo "$GEOMEM_GET"|grep -E "^("$peer"|"$peerenc")#"|sed -n 1p|sed -E "s/^($peer|$peerenc)#\d*#//g")"
				fi
			fi
		else
			new_location
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

		LDCOUNTRY_toLog="${LDCOUNTRY_toLog// /%}"
	}
	getcountry(){
		LDCOUNTRY="" #Reinitialize
		LDCOUNTRY_toLog="" #Reinitialize
		checkcountry; bancountry
	}
fi
##### Get Country via ipapi.co #####
timestamps(){ EPOCH="$(date +%s)";DATETIME="$(date -d "@$EPOCH" +"%Y-%m-%d#%X")"; }
remove_tmp_data(){
	IP_FILENAME="$(panama ${ip})"
	rm -f "/tmp/${LDTEMPFOLDER}/ld_act_state/${IP_FILENAME}#"
	rm -f "/tmp/${LDTEMPFOLDER}/ld_state_counter/${IP_FILENAME}#"
	rm -f "/tmp/${LDTEMPFOLDER}/oldval/${IP_FILENAME}#"
	rm -f "/tmp/${LDTEMPFOLDER}/ld_act_lock/${IP_FILENAME}"
	rm -f "/tmp/${LDTEMPFOLDER}/ld_sentstrike_count/${IP_FILENAME}"
}
cleantable(){
	#Check tables, delete from tables if not in log.
	TABLENAMES="LDACCEPT LDREJECT LDTEMPHOLD"
	for tablename in $TABLENAMES; do
		IPLIST="$(iptables -nL $tablename "$WAITLOCK"|tail +3|grep -E "\b${CONSOLE}\b"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|grep -Ev "\b(${CONSOLE}|0.0.0.0)\b")"
			for ip in $IPLIST; do
			if ! { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eoq "\b${ip}#"; }; then
				case $tablename in
				LDACCEPT)
					TABLELINENUMBER="$(iptables --line-number -nL LDACCEPT "$WAITLOCK"|grep -E "\b${ip}\b"|grep -Eo "^(\s*)?[0-9]{1,}")"
					remove_tmp_data
					iptables -D LDACCEPT $TABLELINENUMBER
					;;
				LDREJECT)
					TABLELINENUMBER="$(iptables --line-number -nL LDREJECT "$WAITLOCK"|grep -E "\b${ip}\b"|grep -Eo "^(\s*)?[0-9]{1,}")"
					iptables -D LDREJECT $TABLELINENUMBER
				;;
				esac
			fi
		done
		if [ $tablename = "LDTEMPHOLD" ]; then
			IPLIST="$(ls -1 "/tmp/${LDTEMPFOLDER}/ldtemphold/")"
			for ip in $IPLIST; do
				if ! { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eoq "\b${ip}#"; }; then
					rm -f "/tmp/${LDTEMPFOLDER}/ldtemphold/$ip"
				fi
			done
		fi
		
		
	done &
}
cleanlog(){
	#Check log, delete from log if not in iptable; Don't change!
	TABLENAMES="LDACCEPT LDREJECT"
	for tablename in $TABLENAMES; do
		case $tablename in
			LDACCEPT)
				IPLISTACCEPT="$(tail +1 "/tmp/$RANDOMGET"|sed -E "/\b${SENTINEL_BAN_MESSAGE}\b/d"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Ev "\b(${RESPONSE3}|${SENTINEL_BAN_MESSAGE})\b"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")"
				for ip in $IPLISTACCEPT; do
					if [ "${SHELLIS}" != "ash" ]; then
						if ! { iptables -nL LDACCEPT|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${ip}\b"; }; then
							remove_tmp_data
							sed -i -E "/(#|m)?(${ip})\b/d" "/tmp/$RANDOMGET"
						fi
					else
						if ! { iptables -nL LDACCEPT "$WAITLOCK"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${ip}\b"; }; then
							remove_tmp_data
							sed -i -E "/(#|m)?(${ip})\b/d" "/tmp/$RANDOMGET"
						fi
					fi
				done
			;;
			LDREJECT)
				IPLISTREJECT="$(tail +1 "/tmp/$RANDOMGET"|sed -E "/\b${SENTINEL_BAN_MESSAGE}\b/d"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E "\b${RESPONSE3}\b"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")"
				for ip in $IPLISTREJECT; do
					if [ "${SHELLIS}" != "ash" ]; then
						if ! { iptables -nL LDREJECT|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${ip}\b"; }; then
							sed -i -E "/(#|m)?(${ip})\b/d" "/tmp/$RANDOMGET"
						fi
					else
						if ! { iptables -nL LDREJECT "$WAITLOCK"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${ip}\b"; }; then
							sed -i -E "/(#|m)?(${ip})\b/d" "/tmp/$RANDOMGET"
						fi
					fi
				done
			;;
		esac
	done &
}
bantidy(){
	#If IP is in ban table, remove from other tables.
	BANDTIDYLIST="$(iptables -nL LDBAN|grep -E "\b${CONSOLE}\b"|awk '{printf $4"\n"}'|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|awk '!a[$0]++')"
	for ip in $BANDTIDYLIST; do
		LINENUMBERBANDTIDYLISTACCEPTIP="$(iptables --line-number -nL LDACCEPT|grep -E "\b${ip}\b"|grep -Eo "^(\s*)?[0-9]{1,}")"
		LINENUMBERBANDTIDYLISTREJECTIP="$(iptables --line-number -nL LDREJECT|grep -E "\b${ip}\b"|grep -Eo "^(\s*)?[0-9]{1,}")"
		LINENUMBERBANDTIDYLISTTEMPHOLDIP="$(iptables --line-number -nL LDTEMPHOLD|grep -E "\b${ip}\b"|grep -Eo "^(\s*)?[0-9]{1,}")"
		if { iptables -nL LDACCEPT "$WAITLOCK"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${ip}\b"; }; then
			iptables -D LDACCEPT "$LINENUMBERBANDTIDYLISTACCEPTIP"
			sed -i -E "/(#|m)?(${ip})\b/d" "/tmp/$RANDOMGET"
			remove_tmp_data
		fi
		if { iptables -nL LDREJECT "$WAITLOCK"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${ip}\b"; }; then
			iptables -D LDREJECT "$LINENUMBERBANDTIDYLISTREJECTIP"
			sed -i -E "/(#|m)?(${ip})\b/d" "/tmp/$RANDOMGET"
		fi
		if { ls -1 "/tmp/${LDTEMPFOLDER}/ldtemphold/"|grep -Eoq "\b${ip}\b"; }; then
			rm -f "/tmp/${LDTEMPFOLDER}/ldtemphold/$ip"
		fi
		rm -f "/tmp/${LDTEMPFOLDER}/ld_sentstrike_count/$(panama ${ip})"
	done &
}
tcp_clean(){
	LDACCEPT_TCP_IPLIST="$(iptables -nL LDACCEPT_TCP|tail +3|grep -E "\b${CONSOLE}\b"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|grep -Ev "\b(${CONSOLE}|0.0.0.0)\b")"
	for ip in $LDACCEPT_TCP_IPLIST; do
		TABLELINENUMBER="$(iptables --line-number -nL LDACCEPT_TCP|grep -E "\b${ip}\b"|grep -Eo "^(\s*)?[0-9]{1,}")"
		if ! { iptables -nL LDACCEPT|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b($ip)\b"; }; then
			iptables -D LDACCEPT_TCP $TABLELINENUMBER
		fi
	done
}
sentinel_bans(){
	##### SENTINEL BANS #####
	SENTINEL_BANS_LIST_GET="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Ev "(${RESPONSE1}|${RESPONSE2}|${RESPONSE3})"|grep -E "${SENTINEL_BAN_MESSAGE}"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")"

	for ip in $SENTINEL_BANS_LIST_GET; do
		CONSOLE="$(grep -E "\b($CONSOLE)\b" "$IPCONNECT_SOURCE"|grep -E "\b($ip)\b"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|awk '!a[$0]++'|grep -E "\b($CONSOLE)\b")"
		if ! { iptables -nL LDBAN "$WAITLOCK"|grep -Eoq "\b${ip}\b"; }; then
			iptables -A LDBAN -s $ip -d $CONSOLE -j REJECT ${WAITLOCK}
		fi
	done
}
cleanliness(){
	##### Clean Hold #####
	CLEANLDTEMPHOLDLIST="$(ls -1 "/tmp/${LDTEMPFOLDER}/ldtemphold/")"
	for ip in $CLEANLDTEMPHOLDLIST; do
		if { ! { echo "$(iptables -nL LDACCEPT; iptables -nL LDREJECT)"|grep -Eoq "\b${ip}\b"; } || { iptables -nL LDBAN|grep -Eoq "\b${ip}\b"; }; }; then
			rm -f "/tmp/${LDTEMPFOLDER}/ldtemphold/$ip"
		fi
		wait $!
	done

	sentinel_bans &

bantidy
cleantable
tcp_clean
cleanlog
}
cleanup_sentinel(){
	##### Clear LDSENTSTRIKE #####
	rm -f "/tmp/${LDTEMPFOLDER}/ld_sentstrike_count/$(panama ${ip})"
	CLEANUP_SENTINEL_PID=$!
}
cleansentinel(){
	##### Clean Sentinel #####
	CLEANLDSENTSTRIKELIST="$(iptables -nL LDACCEPT|tail +3|awk '{printf $3"\n"}'|awk '!a[$0]++')"

	for ip in $CLEANLDSENTSTRIKELIST; do
		STRIKE_MARK_COUNT_GET_CLEAN="$(grep -E "#(.\[[0-9]{1}\;[0-9]{2}m)?(${ip})\b" "/tmp/$RANDOMGET"|sed "/${SENTINEL_BAN_MESSAGE}/d"|grep -Eo "(${STRIKE_MARK_SYMB}{1,}$)"|wc -c)"
		if [ $STRIKE_MARK_COUNT_GET_CLEAN -le 0 ]; then STRIKE_MARK_COUNT_GET_CLEAN=0; else STRIKE_MARK_COUNT_GET_CLEAN=$(( STRIKE_MARK_COUNT_GET_CLEAN - 1 )); fi

		#If IP exists in LDACCEPT and has zero strikes
		if [ $STRIKE_MARK_COUNT_GET_CLEAN -le 0 ] || [ $STRIKE_MARK_COUNT_GET_CLEAN = "" ] || [ -z $STRIKE_MARK_COUNT_GET_CLEAN  ] ; then
			cleanup_sentinel
		fi
		if { iptables -nL LDACCEPT "$WAITLOCK"|grep -Eoq "\b(${ip})\b"; }; then
			if [ $STRIKE_MARK_COUNT_GET_CLEAN -le 0 ] || [ $STRIKE_MARK_COUNT_GET_CLEAN = "" ] || [ -z $STRIKE_MARK_COUNT_GET_CLEAN  ] ; then
				cleanup_sentinel
			fi
		fi
		if ! { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eoq "\b(${ip})\b"; }; then
			cleanup_sentinel
		fi
		# If IP does not exist in LDACCEPT
		if ! { iptables -nL LDACCEPT "$WAITLOCK"|grep -Eoq "\b(${ip})\b"; }; then
			cleanup_sentinel
		fi
	done
}
ping_tr_results(){
	#PING-TR RESULTS: Nested if-then statements in gradation from Response3 (Block) to Response1 (OK!!)
	LIMITPERCENT=85

	if { [ "$(floatmath "$PINGFULL > $LIMIT")" = 1 ] && [ "$(floatmath "$TRAVGFULL > $TRACELIMIT")" = 1 ]; }; then
		RESULT="${RED}${RESPONSE3}${NC}"
	else
		if { [ "$(floatmath "$PINGFULL > ( $LIMIT * $LIMITPERCENT / 100 )")" = 1 ] && [ "$(floatmath "$PINGFULL <= $LIMIT")" = 1 ] && [ "$(floatmath "$TRAVGFULL <= $TRACELIMIT")" = 1 ]; } || { [ "$(floatmath "$TRAVGFULL > ( $TRACELIMIT * $LIMITPERCENT / 100 )")" = 1 ] && [ "$(floatmath "$TRAVGFULL <= $TRACELIMIT")" = 1 ] && [ "$(floatmath "$PINGFULL <= $LIMIT")" = 1 ]; }; then
			RESULT="${YELLOW}${RESPONSE2}${NC}"
		else
			if [ "$(floatmath "$PINGFULL <= ( $LIMIT * $LIMITPERCENT / 100 )")" = 1 ] && [ "$(floatmath "$TRAVGFULL <= ( $TRACELIMIT * $LIMITPERCENT / 100 )")" = 1 ]; then
				RESULT="${LIGHTGREEN}${RESPONSE1}${NC}"
			fi
		fi
	fi
}
pingavgfornull(){
	if [ ! -d "/tmp/${LDTEMPFOLDER}/pingavgfornull" ]; then mkdir "/tmp/${LDTEMPFOLDER}/pingavgfornull"; fi
	PFN_FOLDER="/tmp/${LDTEMPFOLDER}/pingavgfornull"
	export NULLTEXT="--"
	if [ $SHOWLOCATION = 1 ]; then
		PING_HIST_AVG="" #Resets Ping history average to prevent unneeded multiple use
		PING_HIST_AVG_MIN_CITY=3 #Minimum number of similar regions to count before taking average
		PING_HIST_AVG_MIN_REG=$(( PING_HIST_AVG_MIN_CITY * 2 ))
		PING_HIST_AVG_MIN_CNTRY=$(( PING_HIST_AVG_MIN_REG * 2 ))
		PING_HIST_AVG_MIN_CONT=$(( PING_HIST_AVG_MIN_CNTRY * 2 ))
		PING_ITEM_MAX=3000 #256 #Apparently to many items may cause false values, so here's a limit. City and region values sorted in reverse order and read from bottom to bias against high ping values when more than limit exist. Country and continent values are filtered for unique values.

		LOCATION_filter_get="$(echo -e "#${LDCOUNTRY}#"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|tr "," "\n"|sed -E "s/^(\s*)//g")"
		PFA_CITY="$(echo "${LOCATION_filter_get}"|sed -n 1p)"
		PFA_REGION="$(echo "${LOCATION_filter_get}"|sed -n 2p)"
		PFA_COUNTRY="$(echo "${LOCATION_filter_get}"|sed -n 3p)"
		PFA_CONTINENT="$(echo "${LOCATION_filter_get}"|sed -n 4p)"

		CALL_PING_MEM="$(grep -E "(${PFA_CONTINENT})$" "${DIR}/42Kmi/${PINGMEM}")"

		LOCATION_filter="${PFA_CITY}, ${PFA_REGION}, ${PFA_COUNTRY}, ${PFA_CONTINENT}"
		LOCAL_LINES_count="$(echo "${CALL_PING_MEM}"|grep -Ec "\b(${LOCATION_filter})$")"
		PING_HIST_AVG_COLOR=0 #Green for same city average

		#Logic: if count is smaller than threshhold, move to next factor.
		if [ $LOCAL_LINES_count -le $PING_HIST_AVG_MIN_CITY ]; then
			REGION_filter=", ${PFA_REGION}, ${PFA_COUNTRY}, ${PFA_CONTINENT}"
			REGION_LINES_count="$(echo "${CALL_PING_MEM}"|grep -Ec "\b(${REGION_filter})$")"
			PING_HIST_AVG_COLOR=1 #Yellow for same region average
			if [ $REGION_LINES_count -lt $PING_HIST_AVG_MIN_REG ]; then
				COUNTRY_filter=", ${PFA_COUNTRY}, ${PFA_CONTINENT}"
				COUNTRY_LINES_count="$(echo "${CALL_PING_MEM}"|grep -Ec "\b(${COUNTRY_filter})$")"
				PING_HIST_AVG_COLOR=2 #Cyan for same country average
					if [ $COUNTRY_LINES_count -lt $PING_HIST_AVG_MIN_CNTRY ]; then
						CONTINENT_filter=", ${PFA_CONTINENT}"
						CONTINENT_LINES_count="$(echo "${CALL_PING_MEM}"|grep -Ec "\b(${CONTINENT_filter})$")"
						PING_HIST_AVG_COLOR=3 #Magenta for same continent average
						if [ $CONTINENT_LINES_count -lt $PING_HIST_AVG_MIN_CONT ]; then
							PING_HIST_AVG_COLOR="XXXXXXXXXX"
							PINGFULL=""
							PINGFULLDECIMAL="$NULLTEXT"
						else
							#Average from continent, unique values only
							GET_PING_VALUES="$(echo $(echo "${CALL_PING_MEM}"|grep -E "(${CONTINENT_filter})$"|sed -E "s/(ms)?#.*$//g"|awk '!a[$0]++'|sed -E "s/$/+/g")|sed -E "s/(\+*$)//g")"; wait $!
						fi
				else
					#Average from country, unique values only
					GET_PING_VALUES="$(echo $(echo "${CALL_PING_MEM}"|grep -E "(${COUNTRY_filter})$"|sed -E "s/(ms)?#.*$//g"|awk '!a[$0]++'|sed -E "s/$/+/g")|sed -E "s/(\+*$)//g")"; wait $!
					fi
			else
				#Average from region/state, biases toward lower values
				GET_PING_VALUES="$(echo $(echo "${CALL_PING_MEM}"|grep -E "(${REGION_filter})$"|sed -E "s/(ms)?#.*$//g"|sort -nr|sed -E "s/$/+/g")|sed -E "s/(\+*$)//g")"; wait $!
			fi
		else
			#Average from city, biases toward lower values
			GET_PING_VALUES="$(echo $(echo "${CALL_PING_MEM}"|grep -E "(${LOCATION_filter})$"|sed -E "s/(ms)?#.*$//g"|sort -nr|sed -E "s/$/+/g")|sed -E "s/(\+*$)//g")"; wait $!
		fi; wait $!

		GET_PING_VALUES_COUNT="$(echo "$GET_PING_VALUES"|wc -w)"; if [ $GET_PING_VALUES_COUNT = 0 ]; then GET_PING_VALUES_COUNT=1; fi
		GET_PING_VALUES_SUM="$(floatmath "$GET_PING_VALUES")"
		PING_HIST_AVG="$(floatmath "${GET_PING_VALUES_SUM}/${GET_PING_VALUES_COUNT}")"
		if ! { echo "$PING_HIST_AVG_DECIMAL"|grep -Fq "."; }; then PING_HIST_AVG_DECIMAL="${PING_HIST_AVG_DECIMAL}.000}"; fi
		PING_HIST_AVG_DECIMAL="$(echo "${PING_HIST_AVG}0"|sed -E "s/(\.[0-9]{3}).*$/\1ms/g")"

		if [ $PING_HIST_AVG != 0 ]; then
			PINGFULL=$PING_HIST_AVG
			case "$PING_HIST_AVG_COLOR" in
				0) #City
					PINGFULLDECIMAL="$(echo -e "${GREEN}${CURSORLEFT1}¹${PING_HIST_AVG_DECIMAL}${NC}")"
					;;
				1) #State/Provence/Territory
					PINGFULLDECIMAL="$(echo -e "${YELLOW}${CURSORLEFT1}²${PING_HIST_AVG_DECIMAL}${NC}")"
					;;
				2) #Country
					PINGFULLDECIMAL="$(echo -e "${CYAN}${CURSORLEFT1}³${PING_HIST_AVG_DECIMAL}${NC}")"
					;;
				3) #Continent
					PINGFULLDECIMAL="$(echo -e "${MAGENTA}${CURSORLEFT1}*${PING_HIST_AVG_DECIMAL}${NC}")"
					;;
				XXXXXXXXXX)
					PINGFULLDECIMAL="$NULLTEXT"
					;;
			esac
		else
			PINGFULLDECIMAL="$NULLTEXT"
		fi
		printf "${PINGFULLDECIMAL}" > "${PFN_FOLDER}/${peerenc}"
	fi
	wait $!
}

#Status Emblems and Strike Marker
export STRIKE_MARK_SYMB="~"
export CONNECT_MARK_SYMB="●"
export NOT_CONNECT_MARK_SYMB="×"
export CONNECT_MARK="$(echo -e "${GREEN}${CONNECT_MARK_SYMB}${NC}")"
export NOT_CONNECT_MARK="$(echo -e "${RED}${NOT_CONNECT_MARK_SYMB}${NC}")"
#export PENDING="$(echo -e "${YELLOW}¤${NC}")" #Currency sign
export PENDING="$(echo -e "${YELLOW}◊${NC}")" #Lozenge
export STANDBY_SYMB="$(echo -e "${MAGENTA}■${NC}")"
export ACT_PLACEHOLD="@"

HANG_TIMEOUT=10

##### The Ping #####
allinoneping(){
	PINGTTL=255
	for port in $IDENTPORTS; do
		for bytesizes in $SIZES;
			do { ping${PING_A} -c "${PINGRESOLUTION}" -W 1 -t "${PINGTTL}" -s "${bytesizes}" "${peer}:${port}" & PING_PID=$!; ( sleep $HANG_TIMEOUT && kill -9 $PING_PID ) & } & #Prevents hanging
		done &
	done; kill -9 $!
}
theping(){
	#Rapid Ping, New Ping Method

	if [ $SMARTMODE = 1 ]; then
		##### Smart Limit #####
		# Dynamically adjusts limit value for smarter limit control
		if tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eioq "\b(${RESPONSE1}|${RESPONSE2})\b"; then
			SMARTLINES="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed -E "/((\b(${RESPONSE3}|\-\-)\b)([¹²³\*]))/d"|wc -l)"
			GETSMARTLIMIT="$(( $(tail +1 "/tmp/$RANDOMGET"|sed -E -e "s/.\[[0-9]{1}(\;[0-9]{2})?m//g" -e "s/#/\ /g"|sed -e "/((\b(${RESPONSE3}|\-\-)\b)|([¹²³\*]))/d" -e "s/(ms|\.)//g"|awk '{printf "%s\+" $4}'| sed -E 's/(^\+)|(\+*$)//g') ))"
			LIMIT="$(echo "$(( (( GETSMARTLIMIT )) / SMARTLINES ))"|sed -E "s/(.{3})$/.\1/g")"
			if [ $LIMIT = 0 ]; then LIMIT="$(echo "$SETTINGS"|sed -n 2p)"; fi; if echo "$LIMIT"| grep -Eo "\.([0-9]{3})$"; then LIMIT="$(echo "$LIMIT"|sed -E "s/\.//g")"; else LIMIT="$(( LIMIT * 1000 ))"; fi
			if [ $LIMITTEST = "" ]; then
				LIMITTEST="$(echo "$SETTINGS"|sed -n 2p)"; if echo "$LIMITTEST"| grep -Eo "\.([0-9]{3})$"; then LIMITTEST="$(echo "$LIMITTEST"|sed -E "s/\.//g")"; else LIMITTEST="$(( LIMITTEST * 1000 ))"; fi
			fi
			LIMITXSQ="$(echo $(( (( 2 * (( (( LIMITTEST - LIMIT )) * (( LIMITTEST - LIMIT )) )) )) / (( LIMITTEST + LIMIT )) ))|sed "s/\-//g")"
			if { { [ $SMARTLINES -lt $SMARTLINECOUNT ] || [ $LIMITTEST = "" ]; } || ! [ "$(echo "$(for item in $(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed "s/#/\ /g"|sed -E "/((\b(${RESPONSE3}|\-\-)\b)|([¹²³\*]))/d"|sed -E "s/(ms|\.)//g"|awk '{printf $4"\n"}'); do echo $(( item > $(( LIMIT * SMARTPERCENT / 100 )) )); done)"|grep -c "1")" -ge $SMART_AVG_COND ]; }; then
			LIMIT="$(echo "$SETTINGS"|sed -n 2p)"
				if echo "$LIMIT"| grep -Eo "\.([0-9]{3})$"; then
					LIMIT="$(echo "$LIMIT"|sed -E "s/\.//g")";
				else
					LIMIT="$(( LIMIT * 1000 ))"
				fi
			else
				LIMIT="$(( LIMIT + LIMITXSQ ))"
			fi
			LIMITTEST=$LIMIT
		else
		LIMIT="$(echo "$SETTINGS"|sed -n 2p)" ### Your max average millisecond limit. Peers returning values higher than this value are blocked.
			if echo "$LIMIT"| grep -Eo "\.([0-9]{3})$"; then LIMIT="$(echo "$LIMIT"|sed -E "s/\.//g")"; else LIMIT="$(( LIMIT * 1000 ))"; fi
		fi

		if [ $SHOWSMART = 1 ]; then SHOWSMARTLOG="$(echo "$LIMIT"|sed -E "s/(.{3})$/.\1/g")"; fi
	##### Smart Limit #####
	else
		LIMIT="$(echo "$SETTINGS"|sed -n 2p)" ### Your max average millisecond limit. Peers returning values higher than this value are blocked.
		if echo "$LIMIT"| grep -Eo "\.([0-9]{3})$"; then LIMIT="$(echo "$LIMIT"|sed -E "s/\.//g")"; else LIMIT="$(( LIMIT * 1000 ))"; fi
	fi
	if [ $POPULATE = 1 ]; then
	COUNT=5
	else
	COUNT="$(echo "$SETTINGS"|sed -n 3p)" ### How pings to run. Default is 5
	fi
	if [ -f "$DIR"/42Kmi/tweak.txt ]; then PINGRESOLUTION="${TWEAK_PINGRESOLUTION}"; else PINGRESOLUTION=1; fi #3
	if { ping${PING_A} -c 1 -W 1 -t 255 -s 64 "${peer}"|grep -Foq "100% packet loss"; }; then PACKET_LOSS=1; PINGGET=0
	else
		PINGTTL=255
		PINGGET="$(echo $(echo "$(n=0; while [[ $n -lt "${COUNT}" ]]; do { allinoneping; } & n=$((n+1)); done )"|grep -Eo "time=(.*)$"|sed -E 's/( ms|time=)//g'|sed -E 's/(^|\b)(0){1,}(\d)/\3/g'|sed -E 's/$/+/g')|sed -E 's/(\+){1,}/+/g'|sed -E "s/\s?\'?\(DUP\!\)+\'/+/g"|sed -E "/[a-zA-Z]{1,}/d"|sed -E "s/(\+*$)//g")" &> /dev/null; wait $!
	fi
	PINGCOUNT="$(echo "$PINGGET"|wc -w)"
	if ! [ "${PINGCOUNT}" != "$(echo -n "$PINGCOUNT" | grep -Eio "(0|)")" ]; then PINGCOUNT=$(( COUNT * PINGRESOLUTION )); fi #Fallback
	PINGSUM="$(floatmath "$PINGGET")"
	if [ $PINGSUM = "" ] || [ -z $PINGSUM ]; then
		if { ping${PING_A} -c 1 -W 1 -t 255 -s 64 "${peer}"|grep -Foq "100% packet loss"; }; then PACKET_LOSS=1; else PACKET_LOSS=0;fi
	fi
	if [ $PINGSUM = 0 ] || [ $PINGSUM = "" ] || [ $PACKET_LOSS = 1 ]; then FORNULL=1; else FORNULL=0; fi
	if [ $FORNULL != 1 ]; then
		PINGFULL="$(floatmath "${PINGSUM}/${PINGCOUNT}")"
		PINGFULLDECIMAL="$(echo "${PINGFULL}0"|sed -E "s/(\.[0-9]{3}).*$/\1ms/g")"
		if  { echo "$PINGFULLDECIMAL"|grep -Eq "[0-9]{1,}"; }; then
			if ! { echo "$PINGFULLDECIMAL"|grep -Fq "."; }; then PINGFULLDECIMAL="${PINGFULLDECIMAL}.000}"; fi
		fi
	else
		if [ $POPULATE = 1 ]; then :
		else pingavgfornull &
		fi
	fi
}
##### The Ping #####

##### TRACEROUTE #####
allinonetr(){
		for port in $IDENTPORTS; do
			for bytesizes in $SIZES; do
				traceroute -Fn -I -f "${FIRST_START}" -p $port -t 8 -m "${TRGETCOUNT}" -q "${PROBES}" -w 1 "${peer}":"${port}" "${bytesizes}" &
				traceroute -Fn -f "${FIRST_START}" -p $port -t 16 -m "${TRGETCOUNT}" -q "${PROBES}" -w 1 "${peer}":"${port}" "${bytesizes}" &
			done &
		done; kill -9 $!
}
thetraceroute(){
	##### PARAMETERS #####
	TTL=$COUNT
	PROBES=1
	if [ $SMARTMODE = 1 ]; then
		##### Smart TRACELIMIT #####
		# Dynamically adjusts TRACELIMIT value for smarter TRACELIMIT control
		if tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eioq "\b(${RESPONSE1}|${RESPONSE2})\b"; then
			SMARTLINES="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed -E "/((\b(${RESPONSE3}|\-\-)\b)|([¹²³\*]))/d"|wc -l)"
			GETSMARTTRACELIMIT="$(( $(tail +1 "/tmp/$RANDOMGET"|sed -E -e "s/.\[[0-9]{1}(\;[0-9]{2})?m//g" -e "s/#/\ /g" -e "/((\b(${RESPONSE3}|\-\-)\b)|([¹²³\*]))/d" -e "s/(ms|\.)//g"|awk '{printf "%s\+" $5}'| sed -E 's/(^\+)|(\+*$)//g') ))"
			TRACELIMIT="$(echo "$(( (( GETSMARTTRACELIMIT )) / SMARTLINES ))"|sed -E "s/(.{3})$/.\1/g")"
			if [ $TRACELIMIT = 0 ]; then TRACELIMIT="$(echo "$SETTINGS"|sed -n 5p)"; fi
			if echo "$TRACELIMIT"| grep -Eo "\.([0-9]{3})$"; then TRACELIMIT="$(echo "$TRACELIMIT"|sed -E "s/\.//g")"; else TRACELIMIT="$(( TRACELIMIT * 1000 ))"; fi
			if [ $TRACELIMITTEST = "" ]; then
				TRACELIMITTEST="$(echo "$SETTINGS"|sed -n 8p)"; if echo "$TRACELIMITTEST"| grep -Eo "\.([0-9]{3})$"; then TRACELIMITTEST="$(echo "$TRACELIMITTEST"|sed -E "s/\.//g")"; else TRACELIMITTEST="$(( TRACELIMITTEST * 1000 ))"; fi
			fi
			TRACELIMITXSQ="$(echo $(( (( 2 * (( (( TRACELIMITTEST - TRACELIMIT )) * (( TRACELIMITTEST - TRACELIMIT )) )) )) / (( TRACELIMITTEST + TRACELIMIT )) ))|sed "s/\-//g")"
			if { { [ $SMARTLINES -lt $SMARTLINECOUNT ] || [ $TRACELIMITTEST = "" ]; } || ! [ "$(echo "$(for item in $(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed "s/#/\ /g"|sed -E "/((\b(${RESPONSE3}|\-\-)\b)|([¹²³\*]))/d"|sed -E "s/(ms|\.)//g"|awk '{printf $5"\n"}'); do echo $(( item > $(( TRACELIMIT * SMARTPERCENT / 100 )) )); done)"|grep -c "1")" -ge $SMART_AVG_COND ]; }; then
				TRACELIMIT="$(echo "$SETTINGS"|sed -n 5p)"
					if echo "$TRACELIMIT"| grep -Eo "\.([0-9]{3})$"; then
						TRACELIMIT="$(echo "$TRACELIMIT"|sed -E "s/\.//g")"
					else
						TRACELIMIT="$(( TRACELIMIT * 1000 ))"
					fi
			else
				TRACELIMIT="$(( TRACELIMIT + TRACELIMITXSQ ))"
			fi
			TRACELIMITTEST=$TRACELIMIT
		else
			TRACELIMIT="$(echo "$SETTINGS"|sed -n 5p)" ### Your max average millisecond TRACELIMIT. Peers returning values higher than this value are blocked.
			if echo "$TRACELIMIT"| grep -Eo "\.([0-9]{3})$"; then TRACELIMIT="$(echo "$TRACELIMIT"|sed -E "s/\.//g")"; else TRACELIMIT="$(( TRACELIMIT * 1000 ))"; fi
		fi

		if [ $SHOWSMART = 1 ]; then SHOWSMARTLOGTR="$(echo "$TRACELIMIT"|sed -E "s/(.{3})$/.\1/g")"; fi
		##### Smart TRACELIMIT #####
	else
		TRACELIMIT="$(echo "$SETTINGS"|sed -n 5p)"
		if echo "$TRACELIMIT"| grep -Eo "\.([0-9]{3})$"; then TRACELIMIT="$TRACELIMIT"; else TRACELIMIT="$(( TRACELIMIT * 1000 ))"; fi
	fi
	##### PARAMETERS #####
	if ! { traceroute -Fn -I -f 255 -t 8 -m 255 -q 1 -w 1 "${peer}" 64| grep -Foq "*"; }; then
		FIRST_START=255
		TRGETCOUNT=255
	else
		NON_TERMINAL_TR=1
		FIRST_START=6
		TRGETCOUNT=17
	fi
	MXP=$(( TTL * PROBES * TRGETCOUNT ))

	#New TraceRoute
	TRGET="$(echo $(echo "$(n=0; while [[ $n -lt "${TTL}" ]]; do { allinonetr; } & n=$((n+1)); done )"|grep -Eo "([0-9]{1,}\.[0-9]{3}\ ms)"|sed -E 's/(\/|\ ms)//g'|sed -E 's/(^|\b)(0){1,}(\d)/\3/g'|sed -E 's/$/+/g')|sed -E 's/(\+){1,}/+/g'|sed -E "s/\s?\'?\(DUP\!\)+\'/+/g"|sed -E "/[a-zA-Z]{1,}/d"|sed -E "s/(\+*$)//g")" &> /dev/null; wait $!
	TRCOUNT="$(echo -n "$TRGET"|wc -w)" #Counts for average
	if [ "${TRCOUNT}" = 0 ]; then TRCOUNT=$(( TTL * PROBES )); fi #Fallback
	TRSUM="$(floatmath "$TRGET")"
	if [ $TRGET = 0 ] || [ $TRGET = "" ]; then FORNULLTR=1 ;else FORNULLTR=0; fi
	if [ $FORNULLTR != 1 ]; then
		if [ "${TRCOUNT}" != 0 ]; then
			TRAVGFULL="$(floatmath "${TRSUM}/${TRCOUNT}")"; #TRACEROURTE sum for math
		else
			TRAVGFULL="$(floatmath "${TRSUM}/${MXP}")"; #TRACEROURTE sum for math
		fi
		TRAVGFULLDECIMAL="$(echo "${TRAVGFULL}0"|sed -E "s/(\.[0-9]{3}).*$/\1ms/g")"
	fi
}
##### TRACEROUTE #####

##### LagDrop Action Conditions #####
ldtemphold_add(){
	if ! { echo "$(ls -1 "/tmp/${LDTEMPFOLDER}/ldtemphold/"; tail +1 "/tmp/${LDTEMPFOLDER}/ldignore"; iptables -nL LDBAN)"| grep -Eoq "\b${peer}\b"; }; then
		touch "/tmp/${LDTEMPFOLDER}/ldtemphold/$peer"
	fi
}
	if [ "${SHELLIS}" != "ash" ] || [ "${BURST_CONFIRM}" = 1 ]; then
		IN_OUT='-i + ' #Remember the trailing space!
		#IN_OUT='-i + ! -o +' #Does not reliably detect data transfer
		#LDACCEPT_STATE="ESTABLISHED,RELATED"
		LDACCEPT_STATE=" -m state --state ESTABLISHED"
		
		#Enabling rate-limiting can cause Sentinel to function improperly
		LIMIT_PKT_PER_SEC=30 #Number of packets in 1 second that will trigger rate limit
		LIMIT_BURST=2 #Number times LIMIT_PKT_PER_SEC is exceeded before enforcing RATE_LIMIT
		RATE_LIMIT=" -m limit --limit ${LIMIT_PKT_PER_SEC}/sec --limit-burst ${LIMIT_BURST}"
	else
		IN_OUT=''
		LDACCEPT_STATE=''
		LIMIT_PKT_PER_SEC=''
		RATE_LIMIT=''
	fi
ldaccept(){
	if [ $ALL_PROTOCOL = 1 ]; then
		iptables -A LDACCEPT ${IN_OUT}-p all -s $peer -d ${CONSOLE}${LDACCEPT_STATE}${RATE_LIMIT} -j ACCEPT ${WAITLOCK} #All protocols
	else
		if [ "$(echo "$IDENTPORTS"|wc -w)" -gt 1 ]; then
			iptables -A LDACCEPT ${IN_OUT}-p udp -m multiport --dports $DPORTS -s $peer -d ${CONSOLE}${LDACCEPT_STATE}${RATE_LIMIT} -j ACCEPT ${WAITLOCK} #UDP only
		else
			iptables -A LDACCEPT ${IN_OUT}-p udp -s $peer -d ${CONSOLE}${LDACCEPT_STATE}${RATE_LIMIT} -j ACCEPT ${WAITLOCK}
		fi
		iptables -A LDACCEPT_TCP ${IN_OUT}-p ! udp -s $peer -d ${CONSOLE}${LDACCEPT_STATE}${RATE_LIMIT} -j ACCEPT ${WAITLOCK} #TCP and all other protocols add
	fi
}
ldreject(){
	iptables -A LDREJECT -s $peer -d ${CONSOLE} -j $ACTION1 ${WAITLOCK}
}
lagdrop_accept_condition(){
	#OK!! or Warn, depending on how close ping time is to ping limit
	if ! { iptables -nL LDACCEPT|tail +3|awk '{printf $4"\n"}'|awk '!a[$0]++'|grep -Eoq "\b(${peer})\b"; }; then
		if ldaccept; then
			if ! { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eoq "\b(${peer})\b"; }; then
				echo -e "${ACT_PLACEHOLD}%\"$EPOCH\"${DATETIME}#${borneopeer}#${PINGFULLDECIMAL}#${TRAVGFULLDECIMAL}#${RESULT}#${SHOWSMARTLOG}#${SHOWSMARTLOGTR}#${LDCOUNTRY_toLog}#" >> "/tmp/$RANDOMGET"
			fi
			ldtemphold_add
		fi
	fi
}
lagdrop_warn_condition(){
	#Warn; conditional on null ping/ping approximation or if ping is under limit but TR is beyond TR limit
	if ! { iptables -nL LDACCEPT|tail +3|awk '{printf $4"\n"}'|awk '!a[$0]++'|grep -Eoq "\b(${peer})\b"; }; then
		if ldaccept; then
			if ! { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eoq "\b(${peer})\b"; }; then
				echo -e "${ACT_PLACEHOLD}%\"$EPOCH\"${DATETIME}#${borneopeer}#${PINGFULLDECIMAL}#${TRAVGFULLDECIMAL}#${YELLOW}${RESPONSE2}${NC}#${SHOWSMARTLOG}#${SHOWSMARTLOGTR}#${LDCOUNTRY_toLog}#" >> "/tmp/$RANDOMGET"
			fi
			ldtemphold_add
		fi
	fi
}
lagdrop_reject_condition(){
	#Block
	if ! { iptables -nL LDREJECT|tail +3|awk '{printf $4"\n"}'|awk '!a[$0]++'|grep -Eoq "\b(${peer})\b"; }; then
		if ldreject; then
			if ! { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eoq "\b(${peer})\b"; }; then
				echo -e "${ACT_PLACEHOLD}%\"$EPOCH\"${DATETIME}#${borneopeer}#${PINGFULLDECIMAL}#${TRAVGFULLDECIMAL}#${RED}${RESPONSE3}${NC}#${SHOWSMARTLOG}#${SHOWSMARTLOGTR}#${LDCOUNTRY_toLog}#" >> "/tmp/$RANDOMGET"
			fi
			ldtemphold_add
		fi
	fi
}
##### LagDrop Action Conditions #####
WYZZX="$(echo "aHR0cHM6Ly9yZGFwLmFyaW4ubmV0L3JlZ2lzdHJ5L2lw"|openssl enc -base64 -d)"
meatandtatoes(){
	borneopeer="$peer"
	if ! { { echo "$EXIST_LIST_GET"|grep -Eoq "\b(${peer})\b"; } || { tail +1 "/tmp/${LDTEMPFOLDER}/ldignore"|grep -Eoq "\b($peer)\b"; } || { tail +1 "/tmp/${LDTEMPFOLDER}/geomem"|grep -Eoq "^\b("$peer"|"$peerenc")\b"; }; }; then

		# Add FILTERIP to LDIGNORE
		if { echo "$peer"|grep -Eoq "\b(${FILTERIP})\b"; }; then
			for ip in $CONSOLE_SEPARATE; do
				echo "$peer" >> "/tmp/${LDTEMPFOLDER}/ldignore"
			done
		fi &

		# Checks filterignore cache, adds to LDIGNORE to prevent unnecessary checking
		if ! { echo "$EXIST_LIST_GET"|grep -Eoq "\b(${peer})\b"; }; then
			if { echo "$FILTERIGNORE_GET"|grep -Eoq "^(${peer}|${peerenc})$"; }; then
				for ip in $CONSOLE_SEPARATE; do
					echo "$peer" >> "/tmp/${LDTEMPFOLDER}/ldignore"
				done
			fi
		fi &
		#Do you believe in magic?
		##### Whitelisting/ NSLookup #####
		SERVERS="${ONTHEFLYFILTER}"
		if ! { { echo "$EXIST_LIST_GET"|grep -Eoq "\b(${peer})\b"; } || { echo "$FILTERIGNORE_GET"|grep -Eoq "^("$peer"|"$peerenc")$"; }; }; then
			WHOIS="$({ curl -sk --no-keepalive --no-buffer --connect-timeout ${CURL_TIMEOUT} "${WYZZX}/"$peer"" & WHOIS_PID=$!; ( sleep ${CURL_FORCED_TIMEOUT} && kill -9 $WHOIS_PID ) & }|sed -E -e "s/^\s*//g" -e "s/\"//g" -e "s/(\[|\]|\{|\}|\,)//g" -e "s/\\n/,/g" -e "s/],/]\\n/g" -e "s/(\[|\]|\{|\})//g" -e "s/(\")\,(\")/\1\\n\2/g" -e '/^\"\"$/d' -e 's/"//g')"
			if { echo "$WHOIS"|grep -E "\b(${IGNORE_NOT_FOUND})\b"; } || { { echo "$WHOIS"|grep -Ev "\b(${IGNORE})\b"|grep -Eoi "\b(${SERVERS})\b"; } && ! { echo "$WHOIS"|grep -Ei "\b(${GOTTOTESTING})\b"; }; }; then
				for ip in $CONSOLE_SEPARATE; do
					echo "$peer" >> "/tmp/${LDTEMPFOLDER}/ldignore"
				done
				if ! { echo "$FILTERIGNORE_GET"|grep -Eo "^(${peer}|${peerenc})$"; } || ! { grep -Eo "^(${peer}|${peerenc})$" "${DIR}/42Kmi/${FILTERIGNORE}"; }; then echo "$peerenc" >> "${DIR}/42Kmi/${FILTERIGNORE}"; fi
			fi
		fi &
		##### Whitelisting/ NSLookup #####

		##### Get Country #####
		if [ $SHOWLOCATION = 1 ]; then getcountry; fi
		##### Get Country #####
		wait $!
	fi
		
		if [ $POPULATE = 1 ]; then
			if [ "$(grep -c "$LDCOUNTRY" "${DIR}/42Kmi/${PINGMEM}")" -lt 100 ]; then
				{ theping; } #Traceroot doesn't run in Populate mode.
			fi
		else
			{ theping; thetraceroute; }
		fi
			
		##### ACTION of IP Rule #####
		ACTION="$(echo "$SETTINGS"|sed -n 6p)" ### DROP (1)/REJECT(0)
		if [ "$ACTION" = "$(echo -n "$ACTION" | grep -Eio "(drop|1)")" ]; then ACTION1="DROP"; else ACTION1="REJECT"; fi
		##### ACTION of IP Rule #####

	##### NULL/NO RESPONSE PEERS #####
	export NULLTEXT="--"
	if [ $FORNULLTR = 1 ]; then TRAVGFULLDECIMAL="$NULLTEXT"; fi
	if ! { echo "$TRAVGFULLDECIMAL" |grep -Eoq "\."; }; then TRAVGFULLDECIMAL="${TRAVGFULLDECIMAL}.000"; fi; if { echo "$TRAVGFULLDECIMAL"|grep -E "\b(0.000)\b"; }; then TRAVGFULLDECIMAL="--"; fi
	##### NULL/NO RESPONSE PEERS #####

		##### Count Connected IPs #####
		NUMBEROFPEERS="$(echo "$SETTINGS"|sed -n 17p)"
		IPCONNECTCOUNT="$(echo -ne "$IPCONNECT"| grep -Ev "\b${EXIST_LIST}\b"|wc -l)"
		##### Count Connected IPs #####
		#Rest on Multiplayer
	if ! { { echo "$EXIST_LIST_GET"|grep -Eoq "\b(${peer})\b"; } || { grep -Eoq "^("$peer"|"$peerenc")$" "${DIR}/42Kmi/${FILTERIGNORE}"; }; }; then
		if ! { [ "$RESTONMULTIPLAYER" = 1 ] && [ "${IPCONNECTCOUNT}" -ge "${NUMBEROFPEERS}" ]; }; then
		##### BLOCK #####
			# Store ping histories for future approximating of null pings
			if [ $FORNULL != 1 ]; then
				#Add ping to pingmem, does not add ping approximation to pingmem
				if [ $POPULATE = 1 ]; then
					if [ $FORNULL != 1 ] && ! { grep -F "$(echo -e "${PINGFULLDECIMAL}#${LDCOUNTRY}#"|sed "s/ms#/#/g")" "${DIR}/42Kmi/${PINGMEM}"; }; then
						echo -e "${PINGFULLDECIMAL}#${LDCOUNTRY}#"|sed "s/ms#/#/g"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g" >> "${DIR}/42Kmi/${PINGMEM}"
					fi
				else
					if [ $FORNULL != 1 ]; then
						echo -e "${PINGFULLDECIMAL}#${LDCOUNTRY}#"|sed "s/ms#/#/g"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g" >> "${DIR}/42Kmi/${PINGMEM}"
					fi
				fi
			fi

			ping_tr_results

			if [ $POPULATE = 1 ]; then :
			else
				if ! { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eoq "\b(${peer})\b"; }; then
					if [ $NON_TERMINAL_TR = 1 ]; then
						TRAVGFULLDECIMAL="$(echo -e "${CYAN}${TRAVGFULLDECIMAL}${NC}")"
					fi
					CONSOLE="$(grep -E "\b($CONSOLE)\b" "$IPCONNECT_SOURCE"|grep -E "\b($peer)\b"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|awk '!a[$0]++'|grep -E "\b($CONSOLE)\b")"; if [ $POPULATE = 1 ]; then CONSOLE=9999999999; break; fi
					timestamps
					#5=TraceRoute if Ping is null
					if [ $FORNULL = 1 ]; then #If ping is zero/null, use TR value instead
						PINGFULLDECIMAL="$(tail +1 "/tmp/${LDTEMPFOLDER}/pingavgfornull/$peerenc")"
						if [ -z $PINGFULLDECIMAL ] || [ ! -f "/tmp/${LDTEMPFOLDER}/pingavgfornull/$peerenc" ]; then PINGFULLDECIMAL="$NULLTEXT"; fi
						BLOCK="$(if [ "$(floatmath "$TRAVGFULL > $TRACELIMIT")" = 1 ]; then lagdrop_reject_condition; else lagdrop_warn_condition; fi)"
						rm -f "/tmp/${LDTEMPFOLDER}/pingavgfornull/$peerenc"
					else
						if [ $CONSOLE != "9999999999" ] || [ $peer != "999.999.999.999" ]; then
							LIMIT="$(floatmath "$LIMIT + 5")" #using floatmath, ping pad must be adjusted to match
							BLOCK="$(
							if { [ "$(floatmath "$PINGFULL > $LIMIT")" = 1 ] && [ "$(floatmath "$TRAVGFULL > $TRACELIMIT")" = 1 ]; }; then lagdrop_reject_condition; elif  { [ "$(floatmath "$PINGFULL <= $LIMIT")" = 1 ] && [ "$(floatmath "$TRAVGFULL > $TRACELIMIT")" = 1 ]; }; then lagdrop_warn_condition; else lagdrop_accept_condition; fi )"
						fi
					fi
					$BLOCK
				fi
			fi
		fi
	fi
		##### BLOCK #####

}

remove_tmp_data_co(){
	IP_FILENAME="$(panama ${allowed1})"
	rm -f "/tmp/${LDTEMPFOLDER}/ld_act_state/${IP_FILENAME}#"
	rm -f "/tmp/${LDTEMPFOLDER}/ld_state_counter/${IP_FILENAME}#"
	rm -f "/tmp/${LDTEMPFOLDER}/oldval/${IP_FILENAME}#"
	rm -f "/tmp/${LDTEMPFOLDER}/ld_act_lock/${IP_FILENAME}"
	rm -f "/tmp/${LDTEMPFOLDER}/ld_sentstrike_count/${IP_FILENAME}"
}
clearallow(){
	LINENUMBERACCEPTED="$(iptables --line-number -nL LDACCEPT|grep -E "\b${allowed1}\b"|grep -Eo "^(\s*)?[0-9]{1,}")"
	sleep $DELAY_DELETE_CHECK
	iptables -D LDACCEPT "$LINENUMBERACCEPTED"
	sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m)(${allowed1})\b/$(echo -e "#${BG_MAGENTA}")\2/g" "/tmp/$RANDOMGET"; sleep 5 #Clear warning
	wait $!; sed -i -E "/#((.\[[0-9]{1}(\;[0-9]{2})m))?${allowed1}\b/d" "/tmp/$RANDOMGET"
	remove_tmp_data_co
}
clearallow_check(){
	getiplist
	sleep $DELAY_DELETE_CHECK
	if ! { echo "$IPCONNECT"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${allowed1}\b"; }; then
		clearallow
	fi
}
clearreject(){
	LINENUMBERREJECTED="$(iptables --line-number -nL LDREJECT|grep -E "\b${refused1}\b"|grep -Eo "^(\s*)?[0-9]{1,}")"
	sleep $DELAY_DELETE_CHECK
	iptables -D LDREJECT "$LINENUMBERREJECTED"
	sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m)(${refused1})\b/$(echo -e "#${BG_MAGENTA}")\2/g" "/tmp/$RANDOMGET"; sleep 5 #Clear warning
	wait $!; sed -i -E "/((.\[[0-9]{1}(\;[0-9]{2})m))?${refused1}\b/d" "/tmp/$RANDOMGET"
}
clearreject_check(){
	getiplist
	sleep $DELAY_DELETE_CHECK
	if ! { echo "$IPCONNECT"|grep -q "\b${CONSOLE}\b"|grep -Eoq "\b${refused1}\b"; }; then
			clearreject
	fi
}
clear_old(){
	DELETEDELAY=5 #30 #150
	DELAY_DELETE_CHECK=1 #10
	#Allow
	if [ "$CLEARALLOWED" = 1 ]; then
		COUNTALLOW="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Ev "\b(${RESPONSE3}|${SENTINEL_BAN_MESSAGE})\b"|wc -l)"
		if [ "${COUNTALLOW}" -gt "${CLEARLIMIT}" ]; then
			#Allowed List Clear
			ACCEPTED1="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Ev "\b(${RESPONSE3}|${SENTINEL_BAN_MESSAGE})\b"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")" #|sed -n 1p)
			for allowed1 in $ACCEPTED1; do
				getiplist; wait $!
				{
					if ! { echo "$IPCONNECT"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${allowed1}\b"; }; then
						sleep $DELAY_DELETE_CHECK
						if ls -1 "/tmp/${LDTEMPFOLDER}/ldtemphold/"| grep -Eoq "\b${allowed1}\b"; then
							if ! { echo "$IPCONNECT"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${allowed1}\b"; }; then
								rm -f "/tmp/${LDTEMPFOLDER}/ldtemphold/$allowed1"
								sleep $DELETEDELAY
								clearallow_check
							else
								if ! { ls -1 "/tmp/${LDTEMPFOLDER}/ldtemphold/"|grep -Eoq "\b${allowed1}\b";}; then
									touch "/tmp/${LDTEMPFOLDER}/ldtemphold/$allowed1"
								fi
							fi
						fi
					fi #& #Must not parallel. Parallelling cause problems.
				} #&
			done & #Must not parallel. Parallelling cause problems.
		fi
	fi &
	#Blocked
	if [ "$CLEARBLOCKED" = 1 ]; then
			COUNTBLOCKED="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E "\b${RESPONSE3}\b"|wc -l)"
			if [ "${COUNTBLOCKED}" -gt "${CLEARLIMIT}" ]; then
			#Blocked List Clear
			REJECTED1="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E "\b${RESPONSE3}\b"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")"
			for refused1 in $REJECTED1; do
				getiplist; wait $!
				{
				if ! { echo "$IPCONNECT"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${refused1}\b"; }; then
					sleep $DELAY_DELETE_CHECK
					if ls -1 "/tmp/${LDTEMPFOLDER}/ldtemphold/"| grep -Eoq "\b${refused1}\b"; then
						if ! { echo "$IPCONNECT"|grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${refused1}\b"; }; then
							rm -f "/tmp/${LDTEMPFOLDER}/ldtemphold/$refused1"
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

txqueuelen_adjust(){
	QUELENGTH_NEW_VALUE=2
	IFCONFIG_INTERFACES="$(ifconfig|grep -Eo "^[a-z0-9\.]{1,}\b"|grep -Ev "^(br.*|lo.*)\b")"
	for interface in $IFCONFIG_INTERFACES; do
		TXQUEUELEN_GET="$(ifconfig $interface| grep -Eo "txqueuelen:[0-9]{1,}"|sed -E "s/txqueuelen://g")"
		if [ ${TXQUEUELEN_GET} != ${QUELENGTH_NEW_VALUE} ]; then
			eval "ifconfig ${interface} txqueuelen ${QUELENGTH_NEW_VALUE}"
		fi
	done
}
txqueuelen_restore(){
	IFCONFIG_INTERFACES="$(ifconfig|grep -Eo "^[a-z0-9\.]{1,}\b"|grep -Ev "^(br.*|lo.*)\b")"
	for interface in $IFCONFIG_INTERFACES; do
		TXQUEUELEN_GET="$(ifconfig $interface| grep -Eo "txqueuelen:[0-9]{1,}"|sed -E "s/txqueuelen://g")"
		if [ ${TXQUEUELEN_GET} != 1000 ]; then
			eval "ifconfig ${interface} txqueuelen 1000"
		fi
	done
}
write_null_to_log(){
	printf "\\0" >> "/tmp/$RANDOMGET" # Adds null byte to refresh log
}
#User-Response Functions
#=================
#Executable processes, loops and stuff
	export RESPONSE1="OK!!" #OK/GOOD
	export RESPONSE2="Warn" #Pushing it...
	export RESPONSE3="BLOCK" #BLOCKED
	export SENTINEL_BAN_MESSAGE='‼‼‼‼‼%BANNED%-%SUSPECTED%CONNECTION%INSTABILITY%‼‼‼‼‼'
	export SENTINEL_BAN_MESSAGE="${SENTINEL_BAN_MESSAGE// /%}"
{
	#Store Values
	if [ "${SHELLIS}" != "ash" ] && [ $NVRAM_EXISTS = 1 ]; then
		store_original_values(){
		ORIGINAL_DMZ="$(echo $(nvram get dmz_enable))"
		ORIGINAL_DMZ_IPADDR="$(echo $(nvram get dmz_ipaddr))"
		ORIGINAL_MULTICAST="$(echo $(nvram get block_multicast))"
		ORIGINAL_BLOCKWAN="$(echo $(nvram get block_wan))"
		}
		store_original_values
	fi
#ARIN and ipapi to LDIGNORE
arin_ipapi_ignore(){
	IGNORE_URLS='ipapi.co arin.net ipify.org'
	for table in INPUT FORWARD LDIGNORE; do 
		for url in $IGNORE_URLS; do
			IGNORE_URLS_IP="$(nslookup $url|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|awk '!a[$0]++')"
			for ip in $IGNORE_URLS_IP; do
				if ! { iptables -nL $table|grep -Eq "\b($ip)\b"; }; then iptables -A $table -s $ip -j ACCEPT; fi
				if [ "$table" = "LDIGNORE" ]; then
					if ! { tail +1 "/tmp/${LDTEMPFOLDER}/ldignore"|grep -Eoq "\b($ip)\b"; }; then
						echo "$ip" >> "/tmp/${LDTEMPFOLDER}/ldignore"
					fi
				fi
			done
		done
	done
} &> /dev/null
arin_ipapi_ignore &> /dev/null
#Get Public IP
get_public_ip(){
	curl --no-keepalive --no-buffer --connect-timeout 30 -sk -A "${RANDOMGET_GET}" "http://api.ipify.org/" ||
	curl --no-keepalive --no-buffer --connect-timeout 30 -sk -A "${RANDOMGET_GET}" "http://checkip.amazonaws.com/" ||
	curl --no-keepalive --no-buffer --connect-timeout 30 -sk -A "${RANDOMGET_GET}" "http://whatismyip.akamai.com/"
}
GET_NOW="$(date +%s)"
GET_NOW="$(( GET_NOW / 86400 ))" #in Days
LD_PUBLIC_IP_CREATED="$(date +%s -r "/tmp/LD_PUBLIC_IP")"
LD_PUBLIC_IP_CREATED="$(( LD_PUBLIC_IP_CREATED / 86400 ))" #in Days
LD_PUBLIC_IP_CREATED_time_since="$(( GET_NOW - LD_PUBLIC_IP_CREATED ))"
getcaches(){
	GEOMEM_GET="$(tail +1 "${DIR}/42Kmi/${GEOMEMFILE}")"
	FILTERIGNORE_GET="$(tail +1 "${DIR}/42Kmi/${FILTERIGNORE}")"
}
temphold_refresh(){
	if [ -d "/tmp/${LDTEMPFOLDER}/ldtemphold" ]; then
		TEMPHOLD_LIST="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")"
		for ip in $TEMPHOLD_LIST; do
			if ! [ -f "/tmp/${LDTEMPFOLDER}/ldtemphold/$ip" ]; then touch "/tmp/${LDTEMPFOLDER}/ldtemphold/$ip"; fi
		done &
		wait $!
	fi
}; temphold_refresh
if [ ! -f "/tmp/LD_PUBLIC_IP" ] || { [ $LD_PUBLIC_IP_CREATED_time_since -ge 1 ] && [ "$(get_public_ip)" != "$(tail +1 "/tmp/LD_PUBLIC_IP")" ]; }; then
	echo "$(get_public_ip|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b$")" > "/tmp/LD_PUBLIC_IP"
fi &> /dev/null
	PUBLIC_IP="$(tail +1 "/tmp/LD_PUBLIC_IP")"
	if [ -z "/tmp/LD_PUBLIC_IP" ]; then echo "$(get_public_ip|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b$")" > "/tmp/LD_PUBLIC_IP"; fi

##### SETTINGS & TWEAKS #####
SETTINGS="$(tail +1 "$DIR"/42Kmi/options_"$CONSOLENAME".txt|sed -E "s/#.*$//g"|sed -E "/(^#.*#$|^$|\;|#^[ \t]*$)|#/d"|sed -E 's/^.*=//g')" #Settings stored here, called from memory
if [ -f "$DIR"/42Kmi/tweak.txt ]; then
	SMARTLINECOUNT=$TWEAK_SMARTLINECOUNT
	SMARTPERCENT=$TWEAK_SMARTPERCENT
	SMART_AVG_COND=$TWEAK_SMART_AVG_COND
else
	SMARTLINECOUNT=5 #8 #5
	SMARTPERCENT=155 #155
	SMART_AVG_COND=$(( SMARTLINECOUNT * 40 / 100 )) #2
fi

CURL_TIMEOUT=30
CURL_FORCED_TIMEOUT=10 #5

#Get self location
{ checkcountry "${PUBLIC_IP}"; wait $!; export SELF_LOCATE="${LDCOUNTRY}"; } &> /dev/null

#Byte sizes used by ping and traceroute
#SIZE="$(echo "$SETTINGS"|sed -n 4p)" ### User-defined packet size. Default is 7500
SIZE_1=64;SIZE_2=256 #Additional bytes to run for ping and traceroute
#SIZES="$(echo -e "${SIZE_1}\n${SIZE_2}\n${SIZE}"|grep -Eo "[0-9]*"|awk '!a[$0]++')"
SIZES="$(echo -e "${SIZE_1}\n${SIZE_2}"|grep -Eo "[0-9]*"|awk '!a[$0]++')"

if [ $POPULATE = 1 ]; then
SWITCH=1
else
export SENTINEL="$(echo "$SETTINGS"|sed -n 7p)"; if [ "$SENTINEL" = "$(echo -n "$SENTINEL" | grep -Eio "(yes|1|on|enable(d?))")" ]; then export SENTINEL=1; else SENTINEL=0; fi
export SENTBAN="$(echo "$SETTINGS"|sed -n 8p)"; if [ "$SENTBAN" = "$(echo -n "$SENTBAN" | grep -Eio "(yes|1|on|enable(d?))")" ]; then export SENTBAN=1; else SENTBAN=0; fi
export STRIKECOUNT_LIMIT="$(echo "$SETTINGS"|sed -n 9p)"
export STRIKERESET="$(echo "$SETTINGS"|sed -n 10p)"; if [ "$STRIKERESET" = "$(echo -n "$STRIKERESET" | grep -Eio "(yes|1|on|enable(d?))")" ]; then export STRIKERESET=1; else STRIKERESET=0; fi
CLEARALLOWED="$(echo "$SETTINGS"|sed -n 11p)"; if [ "$CLEARALLOWED" = "$(echo -n "$CLEARALLOWED" | grep -Eio "(yes|1|on|enable(d?))")" ]; then CLEARALLOWED=1; else CLEARALLOWED=0; fi
CLEARBLOCKED="$(echo "$SETTINGS"|sed -n 12p)"; if [ "$CLEARBLOCKED" = "$(echo -n "$CLEARBLOCKED" | grep -Eio "(yes|1|on|enable(d?))")" ]; then CLEARBLOCKED=1; else CLEARBLOCKED=0; fi
CLEARLIMIT="$(echo "$SETTINGS"|sed -n 13p)"
CHECKPORTS="$(echo "$SETTINGS"|sed -n 14p)"; if [ "$CHECKPORTS" = "$(echo -n "$CHECKPORTS" | grep -Eio "(yes|1|on|enable(d?))")" ]; then CHECKPORTS=1; else CHECKPORTS=0; fi
PORTS="$(echo "$SETTINGS"|sed -n 15p)"
RESTONMULTIPLAYER="$(echo "$SETTINGS"|sed -n 16p)"; if [ "$RESTONMULTIPLAYER" = "$(echo -n "$RESTONMULTIPLAYER" | grep -Eio "(yes|1|on|enable(d?))")" ]; then RESTONMULTIPLAYER=1; else RESTONMULTIPLAYER=0; fi
DECONGEST="$(echo "$SETTINGS"|sed -n 18p)"; if [ "$DECONGEST" = "$(echo -n "$DECONGEST" | grep -Eio "(yes|1|on|enable(d?))")" ]; then DECONGEST=1; else DECONGEST=0; fi
SWITCH="$(echo "$SETTINGS"|tail -1)"; if [ "$SWITCH" = "$(echo -n "$SWITCH" | grep -Eio "(yes|1|on|enable(d?))")" ]; then SWITCH=1; else SWITCH=0; fi ### Enable (1)/Disable(0) LagDrop
fi
##### SETTINGS & TWEAKS #####

##### CONOSLE IP & DD-WRT OPTIMIZATIONS #####
if [ $POPULATE = 1 ]; then
	CONSOLE="${ROUTERSHORT}"
else
	CONSOLE="$(echo "$SETTINGS"|sed -n 1p)" ### Your console's IP address. Change this in the options.txt file
fi
{
	#DD-WRT
	#Enable Multicast, Enable Anonymous Pings, Set to DMZ
	if ! [ "${SHELLIS}" = "ash" ] && [ $NVRAM_EXISTS = 1 ]; then

		#Set to DMZ
		CONSOLE_IP_END="$(echo "${CONSOLE}"|grep -Eo "[0-9]{1,3}$")"
		if ! [ "$(nvram get dmz_enable)" = 1 ]; then
			eval "nvram set dmz_enable=1"

			if ! [ "$(nvram get dmz_ipaddr)" = "${CONSOLE_IP_END}" ]; then
				eval "nvram set dmz_ipaddr=${CONSOLE_IP_END}"
			fi
		fi

		#Enable multicast
		if ! [ "$(nvram get block_multicast)" = 0 ]; then
			eval "nvram set block_multicast=0"
		fi

		#Enable Pings
		if ! [ "$(nvram get block_wan)" = 0 ]; then
			eval "nvram set block_wan=0"
		fi

		#Disable Shortcut Forwarding Engine
		if { "$(nvram show sfe)"; }; then
			if ! [ "$(nvram get sfe)" = 0 ]; then
				eval "nvram set sfe=0"
			fi
		fi
	fi
}
##### CONOSLE IP & DD-WRT OPTIMIZATIONS #####

##### Check Ports #####
if [ "$CHECKPORTS" = 1 ]; then
	#limit to peers matching the destination port pattern.
	ADDPORTS="$PORTS"
else
	ADDPORTS=""
fi

if [ -f "/proc/net/nf_conntrack" ]; then
	IPCONNECT_SOURCE='/proc/net/nf_conntrack'
	if [ $POPULATE = 1 ]; then
		FILTER_NDPI=''
	else
		FILTER_NDPI='|grep -Evi "ndpi=(HTTP|SSL|DNS|STUN|Nintendo|Sony|PlayStation|Xbox|XboxLive|XBL|Google|GoogleServices|Netflix|ICMP|IGMP|Amazon|BitTorrent|Cloudflare|Microsoft|Steam|WorldOfWarcraft)\b"'
	fi
else
	IPCONNECT_SOURCE='/proc/net/ip_conntrack'
	FILTER_NDPI=''
fi
getiplist(){
	export IPCONNECT="$(grep -E "\bsrc=(${CONSOLE})\b" "${IPCONNECT_SOURCE}"|grep -E "dport\=($ADDPORTS)\b")" ### IP connections stored here, called from memory
}
	##### Check Ports #####
#####Decongest - Block all other connections#####
decongest(){
	if [ "$DECONGEST" = 1 ]; then
		if [ $IFCONFIG_EXISTS = 1 ]; then txqueuelen_adjust &> /dev/null; fi
		KTALIST="$(iptables -nL LDKTA|awk '{printf $4"\n"}'|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|awk '!a[$0]++')"
		KTALIST_COUNT="$(echo "$KTALIST"|wc -l)"
		if [ $KTALIST_COUNT -ge 500 ]; then
			iptables -F LDKTA
		fi
		if [ $KTALIST_COUNT -gt 0 ]; then
			DECONGEST_EXIST="$(echo $KTALIST|awk '!a[$0]++'|sed -E "s/\s/|/g")"
		else
			DECONGEST_EXIST="${CONSOLE}"
		fi
		
		
		DECONGEST_FILTER="$(echo $(grep -E "\b${CONSOLE}\b" "${IPCONNECT_SOURCE}"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|awk '!a[$0]++')|sed -E "s/\s/|/g")"
		DECONGESTLIST="$(tail +1 "${IPCONNECT_SOURCE}"|grep -Ev "\b(${CONSOLE})\b"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|grep -Ev "^\b(${DECONGEST_FILTER}|${ARIN}|${FILTERIP}|${DECONGEST_EXIST}|${PUBLIC_IP}|0.0.0.0|(198\.11\.209\.(22[4-9]|23[0-1])))\b"|grep -Ev "^${ROUTERSHORT}"|awk '!a[$0]++')"
		for kta in $DECONGESTLIST; do
			if ! { echo "$KTALIST"|grep -Eo "\b${kta}\b"; } &> /dev/null; then
				iptables -A LDKTA -s $kta -j DROP ${WAITLOCK}
			fi
		done

	else
		iptables -F LDKTA
	fi
}
	export CONSOLE_SEPARATE="$(echo "$CONSOLE"|sed 's/|/ /g')"
#WHITELIST: Additional IPs to filter out. Make whitelist.txt in 42Kmi folder, add IPs there.
if [ -f "$DIR"/42Kmi/whitelist.txt ] && [ "$(wc -c "${DIR}/42Kmi/whitelist.txt")" -gt 1 ]; then
	WHITELIST="$(echo $(echo "$(tail +1 "${DIR}"/42Kmi/whitelist.txt|awk '!a[$0]++'|sed -E -e "/(#.*$|^$|\;|#^[ \t]*$)|#/d" -e "s/^/\^/g" -e "s/\^#|\^$//g" -e "s/\^\^/^/g" -e "s/$/|/g")")|sed -e 's/\|$//g' -e "s/(\ *)//g" -e 's/\b\.\b/\\./g')"
	ADDWHITELIST="|grep -Ev "$WHITELIST""
else
	ADDWHITELIST=""
fi
	whitelist(){
		if { grep -E "\b(${peer})\b" "${DIR}"/42Kmi/whitelist.txt; }; then
				if ! { tail +1 "/tmp/${LDTEMPFOLDER}/ldignore"|grep -Eoq "\b($peer)\b"; }; then
					echo "$peer" >> "/tmp/${LDTEMPFOLDER}/ldignore"
				fi
			PEERIP="$(echo "${PEERIP}"|sed -E "/\b($peer)\b/d")"
			peer="999.999.999.999"
		fi
	}
#BLACKLIST: Permananent ban. If encountered, immediately blocked.
if [ -f "$DIR"/42Kmi/blacklist.txt ]; then
	BLACKLIST="$(echo $(echo "$(tail +1 ""${DIR}"/42Kmi/blacklist.txt"|awk '!a[$0]++'|sed -E -e "s/#.*$//g" -e "/(#.*$|^$|\;|#^[ \t]*$)|#/d" -e "s/^/\^/g" -e "s/\^#|\^$//g" -e "s/\^\^/^/g" -e "s/$/|/g")")| sed -E 's/\|$//g')"
	blacklist(){
		if { grep -E "\b(${peer})\b" "${DIR}"/42Kmi/blacklist.txt; }; then
				if ! { iptables -nL LDBAN "$WAITLOCK"|grep -Eoq "\b($peer)\b"; }; then
					iptables -I LDBAN -s $peer -j DROP "${WAITLOCK}"
				fi
			PEERIP="$(echo "${PEERIP}"|sed -E "/\b($peer)\b/d")"
			peer="999.999.999.999"
		fi
	}
fi
clean_ldignore(){
	CLEAN_AT_START=700 #When this many entries reached...
	REMOVE_LINES_VALUE=500 #...remove this many from the top of ldignore
	if [ "$(tail +1 "/tmp/${LDTEMPFOLDER}/ldignore"|wc -l)" -ge $CLEAN_AT_START ]; then sed -i -e  "1,${REMOVE_LINES_VALUE}d" "/tmp/${LDTEMPFOLDER}/ldignore"; fi &> /dev/null
}
BURST_CONFIRM_CHECK=0
burst_confirm_check(){
	BURST_CONFIRM=0
	#Checks if iptables is capable of burst limiting
	if { iptables -A LDIGNORE -s "$ip" -d "$ip" -m limit --limit 100/sec --limit-burst 5 -j ACCEPT; }; then
		#Works
		GET_LINE_NUMBER="$(iptables --line-numbers -nL LDIGNORE|grep -F "limit: avg 100/sec burst 5"|awk '{printf $1"\n"}')"
		iptables -D LDIGNORE "${GET_LINE_NUMBER}"
		BURST_CONFIRM=1
	else
		#Does not work
		BURST_CONFIRM=0
	fi
	BURST_CONFIRM_CHECK=1
}
if [ "$BURST_CONFIRM_CHECK" -lt 1 ]; then 
	for ip in $CONSOLE_SEPARATE; do burst_confirm_check; done
fi

if [ "${BURST_CONFIRM}" = 1 ]; then

ddos_mitigation(){
	#Mitigate DDOS from salty players
	for table in INPUT OUTPUT FORWARD; do
		if ! { iptables -xvnL $table|grep "ctstate INVALID"|grep -Eq "\b(0\.0\.0\.0\/0\s{1,}0\.0\.0\.0\/0)\b"; }; then
			iptables -I $table -m conntrack --ctstate INVALID -j DROP
		fi
		if ! { iptables -xvnL $table|grep "tcp flags:0x3F/0x29"|grep -Eq "\b(0\.0\.0\.0\/0\s{1,}0\.0\.0\.0\/0)\b"; }; then
			iptables -I $table -p tcp -m tcp --tcp-flags ALL FIN,PSH,URG -j DROP
		fi
		if ! { iptables -xvnL $table|grep "tcp flags:0x03/0x03"|grep -Eq "\b(0\.0\.0\.0\/0\s{1,}0\.0\.0\.0\/0)\b"; }; then
			iptables -I $table -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
		fi
	done &> /dev/null &

	#Drop incoming bogus packets
	for ip in $CONSOLE_SEPARATE; do
		for table in INPUT OUTPUT FORWARD; do
			if ! { iptables -xvnL $table|grep "ctstate INVALID"|grep -Eq "\b(0\.0\.0\.0\/0\s{1,}\b(${ip}))\b"; }; then
				iptables -I $table -d $ip -m conntrack --ctstate INVALID -j DROP
			fi
			if ! { iptables -xvnL $table|grep "tcp flags:0x3F/0x29"|grep -Eq "\b(0\.0\.0\.0\/0\s{1,}\b(${ip}))\b"; }; then
				iptables -I $table -d $ip -p tcp -m tcp --tcp-flags ALL FIN,PSH,URG -j DROP
			fi
			if ! { iptables -xvnL $table|grep "tcp flags:0x03/0x03"|grep -Eq "\b(0\.0\.0\.0\/0\s{1,}\b(${ip}))\b"; }; then
				iptables -I $table -d $ip -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
			fi
		done
	done &> /dev/null &
	#test server-based gaming attack mitigation
	if [ $BURST_CONFIRM = 1 ]; then
		for ip in $CONSOLE_SEPARATE; do
			if ! { iptables -xvnL ${SBGAM_TABLE}|grep "state ESTABLISHED limit: avg ${SBGAM_BURST}/sec burst"|grep -Eq "\b(0\.0\.0\.0\/0\s{1,}\b(${ip}))\b"; }; then
				iptables -I ${SBGAM_TABLE} -i + -p all -d $ip -m state --state ESTABLISHED -m limit --limit ${SBGAM_BURST}/sec --limit-burst 5 -j ACCEPT ${WAITLOCK}
			fi
		done
	fi
}; ddos_mitigation &

fi
N=0
LD_ON=0
#GEOMEMCOUNT="$(wc -l "${DIR}/42Kmi/${GEOMEMFILE}")"

lagdrop(){
	exit_trap
	
	while [ $LD_ON != 1 ] &> /dev/null; do
		exit_trap
		if [ $LD_ON != 1 ]; then
		wait $LD_PID
		LD_ON=1; wait
			{
				#magic Happens Here

				# Everything below depends on power switch
				if ! [ "$SWITCH" = 0 ]; then

					getcaches
					getiplist

					EXIST_LIST_GET="$({ echo "$(iptables -nL LDACCEPT; iptables -nL LDREJECT; iptables -nL LDBAN; tail +1 "/tmp/${LDTEMPFOLDER}/ldignore"; iptables -nL LDKTA)"; }|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|awk '!a[$0]++')"
					if [ "$EXIST_LIST_GET" != "" ]; then
						EXIST_LIST="$(echo ${EXIST_LIST_GET}|sed -E "s/\s/|/g"|sed -E "s/\|$//g")"
					else
						EXIST_LIST="${CONSOLE}"
					fi
					LOGIP_LIST="$(echo $(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")|sed "s/ /|/g")"
					if [ "$LOGIP_LIST" = "" ]; then LOGIP_LIST="99999.99999.99999"; fi
					IGNORE="$(echo $({ if { { { echo "$EXIST_LIST_GET" && tail +1 "${DIR}/42Kmi/${FILTERIGNORE}"; } ; }|grep -Eoq "([0-9]{1,3}\.?){4}"; }; then echo "$({ { echo "$EXIST_LIST_GET" && tail +1 "${DIR}/42Kmi/${FILTERIGNORE}"; } ; }|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|awk '!a[$0]++'|grep -Ev "\b(${CONSOLE})\b"|grep -v "127.0.0.1"|sed 's/\./\\\./g')"|sed -E 's/$/\|/g'; else echo "${ROUTER}"; fi; })|sed -E 's/\|$//g'|sed -E 's/\ //g')"

					PEERIP="$({ echo "$IPCONNECT""${FILTER_NDPI}"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b"|grep -Ev "\b(192\.168(\.[0-9]{1,3}){2})\b"|grep -Ev "^\b(${CONSOLE}|${LOGIP_LIST}|${ROUTER}|${IGNORE}|${EXIST_LIST}|${ROUTERSHORT}|${FILTERIP}|${ONTHEFLYFILTER_IPs}|${PUBLIC_IP})\b""${ADDWHITELIST}"|awk '!a[$0]++'|sed -E "s/(\s)*//g"; }; PEERIP_PID=$!; ( sleep $HANG_TIMEOUT && kill -9 $PEERIP_PID ) & )" ### Get console Peer's IP DON'T TOUCH!
						if [ -n "$PEERIP" ]; then
							{
							LDLOOPLIM=3
							if [ $N -ge $LDLOOPLIM ]; then
							wait $LD_PID
							N=0
							fi
							for peer in $PEERIP; do
							PEERIP="$(echo "${PEERIP}"|sed -E "/\b(${peer})\b/d")"
							if [ -n "$peer" ]; then
								if [ -f "${DIR}/42Kmi/blacklist.txt" ] && [ -n "${DIR}/42Kmi/blacklist.txt" ]; then blacklist; fi
								if [ -f "${DIR}/42Kmi/whitelist.txt" ] && [ -n "${DIR}/42Kmi/whitelist.txt" ]; then whitelist; fi
								peerenc="$(panama $peer)"
								PEERIP="$(echo "${PEERIP}"|sed -E "/\b(${peer})\b/d")"
								if [ $N -lt $LDLOOPLIM ]; then
									if [ "$(eval "echo \$$(echo ${peerenc}_ID)")" != 1 ]; then
										eval "${peerenc}_ID=1"
										{
											#Get ports established by peer for traceroute testing
											if ! { tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eoq "\b(${peer})\b"; }; then
												IDENTPORTS="$(echo $(echo "$IPCONNECT"|grep -E "\b(${peer})\b"|grep -Eo ".port=[0-9]*"|sed -E "s/^.*=//g"|awk '!a[$0]++'))"
												DPORTS="$(echo "$IDENTPORTS"|sed "s/ /,/g")"
												if { echo "$FILTERIGNORE_GET"|grep -Eoq "^(${peer}|${peerenc})$"; }; then
													if ! { tail +1 "/tmp/${LDTEMPFOLDER}/ldignore"|grep -Eoq "\b($peer)\b"; }; then
														for ip in $CONSOLE_SEPARATE; do
															echo "$peer" >> "/tmp/${LDTEMPFOLDER}/ldignore"
														done
													fi
												else
													( meatandtatoes )
												fi

												if [ $POPULATE = 1 ]; then
													if [ -f "/tmp/$RANDOMGET" ]; then rm -f "/tmp/$RANDOMGET"; fi
													if ! { tail +1 "/tmp/${LDTEMPFOLDER}/ldignore"|grep -Eoq "\b($peer)\b"; }; then
														echo "$peer" >> "/tmp/${LDTEMPFOLDER}/ldignore"
													fi
												fi
												clean_ldignore
												cleanliness &> /dev/null #&
												bancountry &> /dev/null #&
												eval "${peerenc}_ID=0"
											fi
										} &
									fi
									N=$(( N + 1 ))
								fi

							fi
							done
							}
						fi
					#end of LagDrop loops
				fi
				{
					#####Decongest - Block all other connections#####
					if [ "$DECONGEST" = 1 ]; then
						decongest &> /dev/null
					fi
					##### Clear Old #####
					clear_old &
				}

				cleanliness &> /dev/null &
				bancountry &> /dev/null &
		LD_ON=0; wait
			};LD_PID=$!
		wait $!
		fi
	done &> /dev/null
	}
lagdrop &
}
#==========================================================================================================
##### GET VALUES FOR SENTINEL AND ACTIVE STATUS #####
#Functions
USLEEP_DELAY_TIME="$(( SENTINELDELAYSMALL * USLEEP_DELAY_MULTIPLIER ))"
get_the_values(){
	#Get iptables LDACCEPT values
	GET_DATE_INIT="$(date +%s)"; wait $!
		echo "$GET_DATE_INIT" > "/tmp/${LDTEMPFOLDER}/getdateinit"; wait $!
	GET_LDACCEPT_VALUES1="$(iptables -xvnL LDACCEPT; iptables -xvnL LDACCEPT_TCP)"; wait $!
	if [ $USLEEP_EXISTS = 1 ]; then usleep $USLEEP_DELAY_TIME; wait $!; else sleep $SENTINELDELAYSMALL; wait $!; fi
	GET_LDACCEPT_VALUES2="$(iptables -xvnL LDACCEPT; iptables -xvnL LDACCEPT_TCP)"; wait $!
	{
		echo "$GET_LDACCEPT_VALUES1" > "/tmp/${LDTEMPFOLDER}/ldacceptval1"; wait $!
		echo "$GET_LDACCEPT_VALUES2" > "/tmp/${LDTEMPFOLDER}/ldacceptval2"; wait $!
	} &
	if [ $ALL_PROTOCOL = 1 ]; then
		until iptables -Z LDACCEPT; do iptables -Z LDACCEPT; done
	else
		until iptables -Z LDACCEPT; do iptables -Z LDACCEPT; done
		until iptables -Z LDACCEPT_TCP; do iptables -Z LDACCEPT_TCP; done
	fi # Zeroes to prevents apparent ramping. Don't change.
}

if [ $POPULATE = 1 ]; then :
else
	( GTV_ON=0; while [ $GTV_ON != 1 ]; do GTV_ON=1; get_the_values; GET_THE_VALUES_PID=$!; wait $GET_THE_VALUES_PID; GTV_ON=0; done ) &
fi
##### GET VALUES FOR SENTINEL AND ACTIVE STATUS #####
#==========================================================================================================
###### SENTINELS #####
if [ "$SENTINEL" = 1 ]; then
SENTON_SIG=1
{
	#Sentinel: Checks against intrinsic/extrinsic peer lag by comparing difference in transmitted data at 2 sequential time points. Only for constant data stream (i.e.: gaming). Unreliable for intermittent data flow.
	
	if [ ! -d "/tmp/${LDTEMPFOLDER}/oldval" ]; then mkdir -p "/tmp/${LDTEMPFOLDER}/oldval" ; fi
	#1 for packets, 2 for bytes (referred to as delta)
	if [ $USE_BYTES = 1 ]; then
		PACKET_OR_BYTE=2
	else
		PACKET_OR_BYTE=1
	fi
	if [ $ENABLE_VERIFY = 1 ]; then
		VERIFY_VALUES=1 #Creates verifyvalues.txt in 42Kmi/verify to check Sentinel values.
		VV_APPEND=':V'
	else
		VERIFY_VALUES=0
		VV_APPEND=''
	fi
	if [ $PACKET_OR_BYTE = 2 ]; then
		SENT_APPEND=':B'
	else
		SENT_APPEND=':P'
	fi
	if [ $ALL_PROTOCOL = 1 ]; then
		SENT_ALL_PROTOCOL=':A'
	else
		SENT_ALL_PROTOCOL=':U'
	fi
	if [ $LAGG_ON = 1 ]; then
		SENT_LAGG_ON=':L'
	else
		SENT_LAGG_ON=''
	fi
	LAGG_LOADEDFILTER="$(echo "${LOADEDFILTER}"|sed -E 's/\\[0-9]{1,}\[([0-9]{1,};)?[0-9]{1,}m//g')"
	LAGG_SUB_ON=""
	laggregate(){
		LAGG_SUB_ON=""
		if ! [ $LAGG_SUB_ON = 1 ]; then
			LAGG_SUB_ON=1
			#Make laggregate file
			if ! [ -f "${DIR}/42Kmi/laggregate.txt" ]; then echo "LAGGREGATE#SUBMITTER_LOCATION=${SELF_LOCATE}" > "${DIR}/42Kmi/laggregate.txt"; fi

			#Add entry to laggregate.txt

			#Unique ID
			LAGG_ID="$(panama ${SENTIPFILENAME} 5)"

			#Retrieve location
			LAGG_LOCATION="$(grep -E "^(${SENTIPFILENAME})" "${DIR}/42Kmi/${GEOMEMFILE}"|sed -E "s/^.*#//g")"

			#Write to file

			if ! { "$(echo "$LAGG_LOCATION"|grep -oq ", , ,")"; }; then

				if [ $STRIKE_MARK_COUNT_GET -ge $LAGG_COUNT_MIN ]; then
					if ! { grep -Eq "^(${SENTIPFILENAME})" "${DIR}/42Kmi/laggregate.txt"; }; then
						echo "${SENTIPFILENAME}#${LAGG_ID}#${LAGG_LOADEDFILTER}#${GET_DATE}#${LAGG_LOCATION}" >> "${DIR}/42Kmi/laggregate.txt"
					fi
				fi
			fi &> /dev/null
			LAGG_SUB_ON=0
		fi
	}
	continuous_mode(){
		DELTA_old="$(tail +1 "/tmp/${LDTEMPFOLDER}/oldval/${SENTIPFILENAME}#")"
	}
	errata_work(){
		if [ $POWER_TEST = 0 ]; then
			if [ "$(printf "$DELTA_new"|wc -c)" -ge $POWER_FLOOR ] || [ "$(printf "$DELTA_old"|wc -c)" -ge $POWER_FLOOR ]; then
				for power in $POWER_SET; do
				POWER_MATH_THRESHOLD=$(( 10 ** power )) #10-factor threshhold for dynamic rates/errata
				POWER_MATH_DIV_STEPUP=$(( 10 ** $(( power + 1 )) ))
				POWER_MATH_AVG=$(( $(( POWER_MATH_DIV_STEPUP - POWER_MATH_THRESHOLD)) * POWER_DIV_FACTOR / 100 ))
				#eg, if Deltas A and B are greater than 10000; then diff min becomes 1350
					if [ $DELTA_old -ge $POWER_MATH_THRESHOLD ] && [ $DELTA_new -ge $POWER_MATH_THRESHOLD ]; then
						DELTA_OFFSET=0
						DIFF_MIN=$POWER_MATH_AVG #For high data transfer
						SENTLOSSLIMIT=$POWER_MATH_AVG #For high data transfer
						POWER_TEST=1
					fi
				done
			fi
		fi
	}
	errata(){
		#Rescale DIFF_MIN if both DELTA_old and DELTA_new are significantly greater than expected
		POWER_DIV_FACTOR=75 #Don't change
		POWER_TEST=0
		if [ $PACKET_OR_BYTE = 2 ]; then
			#Values for Bytes
			POWER_FLOOR=5 #Number of digits in value (ie, 10000 has 5 digits)
			POWER_SET='8 7 6 5 4' #Checks for values greater than or equal to 10000
				errata_work
		else
			#Values for Packets
			POWER_FLOOR=4 #Number of digits in value (ie, 10000 has 5 digits)
			POWER_SET='8 7 6 5 4 3' #Checks for values greater than or equal to 1000
				errata_work
		fi 2> /dev/null
		if [ $POWER_TEST = 0 ]; then
			DELTA_OFFSET=0
			DIFF_MIN=$SENTLOSSLIMIT
		fi
	}
	write_strike_folder(){
		echo "${STRIKE_MARK_SYMB}" >> "${STRIKE_FOLDER}"
	}
	add_strike(){
		if [ $STRIKE_MARK_COUNT_GET = $STRIKECOUNT_GET ] && [ ! -f "/tmp/${LDTEMPFOLDER}/ld_act_lock/${SENTIPFILENAME}" ]; then
			#Regular strike add
			sed -i -E "s/^.*(#|m)${ip}\b.*$/&${STRIKE_MARK_SYMB}/g" "/tmp/$RANDOMGET" #&& #Adds mark for strikes
			write_strike_folder #&&
			write_null_to_log
			STRIKE_ADDED=1

			#Resets ASR counter
			if [ $STRIKERESET = 1 ]; then
				rm -f "/tmp/${LDTEMPFOLDER}/ld_state_counter/${SENTIPFILENAME}#"
			fi
		fi
		rm -f "/tmp/${LDTEMPFOLDER}/in_lobby/${SENTIPFILENAME}"
	}
	add_strike_fix(){
		#For Strike correction
		if [ ! -f "/tmp/${LDTEMPFOLDER}/ld_act_lock/${SENTIPFILENAME}" ]; then
			sed -i -E "s/^.*(#|m)${ip}\b.*$/&${STRIKE_MARK_SYMB}/g" "/tmp/$RANDOMGET" #Adds mark for strikes
			write_null_to_log
		fi
	}
	remove_all_strikes_from_ldsentstrike(){
		rm -f "${STRIKE_FOLDER}"
	}
	remove_from_ldaccept(){
		LINENUMBERSTRIKEOUTACCEPT="$(iptables --line-number -nL LDACCEPT|grep -E "\b${CONSOLE}\b"|grep -E "\b${ip}\b"|grep -Eo "^(\s*)?[0-9]{1,}")"
		for line in $LINENUMBERSTRIKEOUTACCEPT; do
			iptables -D LDACCEPT $line
		done
	}
	FIX_HITCH=0
	fix_strikes(){
		wait $AP_PID
		wait $ACT_PEER_PID
		wait $SENT_STRIKE_PID

		get_strike_counts
		#Strike numbers correction; prevents incorrect strike numbers.

		if [ $STRIKECOUNT_GET != $STRIKE_MARK_COUNT_GET ] && [ ! -f "/tmp/${LDTEMPFOLDER}/ld_act_lock/${SENTIPFILENAME}" ] && [ $FIX_HITCH != 1 ]; then
			FIX_HITCH=1
			if [ "$CLEANUP_SENTINEL_PID" != "" ]; then wait $CLEANUP_SENTINEL_PID; fi
			if [ $STRIKECOUNT_GET -lt $STRIKE_MARK_COUNT_GET ]; then
				#If the number of strikes recorded in LDSENTSTRIKE is less than number of strikes recorded in the log, add to SENTSTRIKE
				STRIKE_DIFF="$(( STRIKE_MARK_COUNT_GET - STRIKECOUNT_GET ))"
				if [ "$STRIKE_DIFF" -gt "0" ] && [ "$STRIKE_MARK_COUNT_GET" -gt "0" ]; then
					strike_diff_turn_count_remain=0; while [[ $strike_diff_turn_count_remain -lt "${STRIKE_DIFF}" ]]; do { write_strike_folder; }; strike_diff_turn_count_remain="$(( strike_diff_turn_count_remain + 1 ))"; done
				fi; #wait $!
			elif [ $STRIKE_MARK_COUNT_GET -lt $STRIKECOUNT_GET ]; then
				#If the number of strikes recorded in the log is less than number of strikes recorded in LDSENTSTRIKE
				STRIKE_DIFF="$(( STRIKECOUNT_GET - STRIKE_MARK_COUNT_GET ))"
				if [ "$STRIKE_DIFF" -gt "0" ] && [ "$STRIKECOUNT_GET" -gt "0" ]; then
					strike_diff_turn_count_remain=0; while [[ $strike_diff_turn_count_remain -lt "${STRIKE_DIFF}" ]]; do { add_strike_fix; }; strike_diff_turn_count_remain="$(( strike_diff_turn_count_remain + 1 ))"; done
				fi
			elif { [ $STRIKECOUNT_GET = 0 ] && [ $STRIKE_MARK_COUNT_GET != 0 ]; } || { [ $STRIKE_MARK_COUNT_GET = 0 ] && [ $STRIKECOUNT_GET != 0 ]; }; then
				if [ $STRIKECOUNT_GET = 0 ] && [ $STRIKE_MARK_COUNT_GET != 0 ]; then
					#Hopefully ensures that if log has strikes but no entries are found in LDSENTSTRIKE, then the log stirkes will clear.
					sed -i -E "s/(^.*\b${ip}\b.*)(${STRIKE_MARK_SYMB}{1,)$/\1/g" "/tmp/$RANDOMGET"

				elif [ $STRIKE_MARK_COUNT_GET = 0 ] && [ $STRIKECOUNT_GET != 0 ]; then
					#Hopefully ensures that if log has no strikes but entries are found in LDSENTSTRIKE, then LDSENTSTRIKE will clear.
					remove_all_strikes_from_ldsentstrike
				fi

				write_null_to_log
			fi

			#Accurate color to counter matching
			case $STRIKE_MARK_COUNT_GET in
				0)
					if [ $STRIKE_MARK_COUNT_GET -lt 1 ]; then
						if { grep -Eoq "(.\[[0-9]{1}\;[0-9]{2}m){1,}(${ip})\b" "/tmp/$RANDOMGET"; }; then
							sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m){1,}(${ip}\b)/#\2/g" "/tmp/$RANDOMGET"
						fi
					fi
				;;
				1)
					if [ $STRIKE_MARK_COUNT_GET = 1 ]; then
						if { grep -Eoq "(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip})\b" "/tmp/$RANDOMGET"; }; then
							sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip}\b)/#$(echo -e "${BG_CYAN}")\2/g" "/tmp/$RANDOMGET"
						fi
					fi
				;;
				2)
					if [ $STRIKE_MARK_COUNT_GET = 2 ]; then
						if { grep -Eoq "(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip})\b" "/tmp/$RANDOMGET"; }; then
							sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip}\b)/#$(echo -e "${BG_GREEN}")\2/g" "/tmp/$RANDOMGET"
						fi
					fi
				;;
				3)
					if [ $STRIKE_MARK_COUNT_GET = 3 ]; then
						if { grep -Eoq "(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip})\b" "/tmp/$RANDOMGET"; }; then
							sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip}\b)/#$(echo -e "${BG_YELLOW}")\2/g" "/tmp/$RANDOMGET"
						fi
					fi
				;;
				*)
					if [ $STRIKE_MARK_COUNT_GET -ge 4 ]; then
						if { grep -Eoq "(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip})\b" "/tmp/$RANDOMGET"; }; then
							sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip}\b)/#$(echo -en "${BG_BLUE}")\2/g" "/tmp/$RANDOMGET"
						fi
					fi
				;;
			esac
		fi; if [ $FIX_HITCH != 0 ]; then FIX_HITCH=0; fi
		wait $!
	}
	sentinelstrike(){
		if [ ! -f "/tmp/${LDTEMPFOLDER}/ld_act_lock/${SENTIPFILENAME}" ]; then
			ACT_STATE="$(tail +1 "/tmp/${LDTEMPFOLDER}/ld_act_state/${SENTIPFILENAME}#")"
			STAND_COUNT_READ="$(tail +1 "/tmp/${LDTEMPFOLDER}/ld_act_standby_counter/${SENTIPFILENAME}#")"
			STAND_COUNT_LIMIT=2
			if [ $STAND_COUNT_READ -ge $STAND_COUNT_LIMIT ]; then SAFE_TO_BAN=1; else SAFE_TO_BAN=0; fi
			if { [ $STRIKECOUNT_GET -ge $STRIKEMAX ] || [ $STRIKE_MARK_COUNT_GET -ge $STRIKEMAX ]; }; then
				# Max strikes. You're OUT!
				if [ $SAFE_TO_BAN = 1 ]; then
					if { echo "${SENT_LDACCEPT_STORE}"|grep -Eoq "\b${ip}\b"; }; then
						remove_all_strikes_from_ldsentstrike; remove_from_ldaccept
					fi
					if ! { echo "${SENT_LDBAN_STORE}"|grep -Eoq "\b${ip}\b"; }; then
						iptables -A LDBAN -s $ip -j REJECT ${WAITLOCK}
						sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m){1,}(${ip})(.*$)/#$(echo -e "${BG_RED}")\2%${SENTINEL_BAN_MESSAGE}%@%$(date +"%X")%$(echo -e "${NC}")/g" "/tmp/$RANDOMGET"; sleep 5
					fi
				fi

			# If less than the max number of strikes...
			else
				if [ "$STRIKECOUNT_GET" -lt "$STRIKEMAX" ]; then

					#Counting Strikes, marking in log
					case "$STRIKECOUNT_GET" in
						0)
							# Strike 1
							if { [ "$STRIKECOUNT_GET" -lt 1 ]; }; then
								sed -i -E "s/#(${ip})\b/#$(echo -e "${BG_CYAN}")\1/g" "/tmp/$RANDOMGET"
								add_strike
							fi
						;;

						1)
							# Strike 2
							if [ "$STRIKECOUNT_GET" = 1 ]; then
								sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip})\b/#$(echo -e "${BG_GREEN}")\2/g" "/tmp/$RANDOMGET"
								add_strike
							fi
						;;

						2)
							# Strike 3
							if [ "$STRIKECOUNT_GET" = 2 ]; then
								sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip})\b/#$(echo -e "${BG_YELLOW}")\2/g" "/tmp/$RANDOMGET"
								add_strike
							fi
						;;

						*)
							# Strike 4 and beyond
							if [ "$STRIKECOUNT_GET" -ge 3 ]; then
								sed -i -E "s/#(.\[[0-9]{1}\;[0-9]{2}m){0,}(${ip})\b/#$(echo -e "${BG_BLUE}")\2/g" "/tmp/$RANDOMGET"
								add_strike
							fi
						;;

					esac
				fi
			fi; SENT_STRIKE_PID=$!
		fi
	}
	walkback_strike(){
		if [ $INLINE_CORRECT_HITCH = 1 ] || [ $STRIKE_ADDED = 1 ] ; then
			#Deletes top-most strike entry for the peer
			sed -i 1d "${STRIKE_FOLDER}"
			sed -E -i "s/^(.*(#|m)${ip}.*)(~$)/\1/" "/tmp/$RANDOMGET"
			write_null_to_log
		fi
		wait $!
	}
	verify_filename(){
		if [ $VERIFY_VALUES = 1 ]; then
			VV_FILENAME="${DIR}/42Kmi/verify/verifyvalues#${LAGG_LOADEDFILTER}#${IDENT}#${BYTE_LABEL}#${SENTIPFILENAME}#.txt"
		else
			VV_FILENAME="/tmp/${LDTEMPFOLDER}/verify/verifyvalues#${LAGG_LOADEDFILTER}#${IDENT}#${BYTE_LABEL}#${SENTIPFILENAME}#.txt"
		fi
	}
	verifyvalues_action(){
		verify_filename
		if [ $VV_LINE_COUNT -gt 10 ] && [ $VV_LINE_COUNT -lt 30 ]; then sort_verify; fi; wait $!
			#Write values
			VV_WRITE_LIMIT=1
			if { { { [ $DELTA_old = 0 ] && [ $DELTA_new != 0 ]; } && [ "$(tail +2 "${VV_FILENAME}"|tail -${VV_WRITE_LIMIT}|grep -Eo "0\t0\t0\t0\t1\t0\t0\t0$"|wc -l)" = $VV_WRITE_LIMIT ]; } || { { { [ $DELTA_old != 0 ] && [ $DELTA_new = 0 ]; } || { [ $DELTA_old = 0 ] && [ $DELTA_new != 0 ]; };} && [ "$(tail +2 "${VV_FILENAME}"|tail -$(( ${VV_WRITE_LIMIT} * 5 ))|grep -Eo "[1-9]?[0-9]?[1-9]{1,}\t[1-9]?[0-9]?[1-9]{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$"|wc -l)" != $VV_WRITE_LIMIT ]; }; }; then

				write_DELTA_old=0
				write_DELTA_new=0
				write_DELTA_SUM=0
				write_DELTA_DIFF=0
				write_DELTA_AVG=1
				write_DELTA_DIFFSQ=0
				write_DELTA_XSQ=0
				write_DELTA_STD_DEV=0
			else
				write_DELTA_old=$DELTA_old
				write_DELTA_new=$DELTA_new
				write_DELTA_SUM=$DELTA_SUM
				write_DELTA_DIFF=$DELTA_DIFF
				write_DELTA_AVG=$DELTA_AVG
				write_DELTA_DIFFSQ=$DELTA_DIFFSQ
				write_DELTA_XSQ=$DELTA_XSQ
				write_DELTA_STD_DEV=$DELTA_STD_DEV
			fi
			{
				#Prep for verify file
				if ! [ -f "$VV_FILENAME" ]; then
					GET_LOCATION_VV="$(grep -E "^(${SENTIPFILENAME})#" "${DIR}/42Kmi/${GEOMEMFILE}"|sed -E "s/^.*#//g")"
					IP_MASK="$(echo ${ip}|sed -E "s/\.[0-9]{1,3}\.[0-9]{1,3}\./.xx.xx./g")"
				fi

				#Make verify folder
				if [ $VERIFY_VALUES = 1 ]; then
					if ! [ -d "${DIR}/42Kmi/verify/" ]; then mkdir "${DIR}/42Kmi/verify/"; fi
				else
					if ! [ -d "/tmp/${LDTEMPFOLDER}/verify/" ]; then mkdir "/tmp/${LDTEMPFOLDER}/verify/"; fi
				fi

				#Populate verifyvalues.txt
				VV_WRITE_LIMIT=1 #Maximum allowed number of consecutive 0 entries. To save space.
				if [ $write_DELTA_SUM = 0 ] && [ $write_DELTA_DIFF = 0 ] && [ $write_DELTA_STD_DEV = 0 ] && [ "$(tail +2 "${VV_FILENAME}"|tail -${VV_WRITE_LIMIT}|grep -Eo "0\t0\t0\t0\t1\t0\t0\t0$"|wc -l)" = $VV_WRITE_LIMIT ]; then if ! [ -d "/tmp/${LDTEMPFOLDER}/in_lobby/" ]; then mkdir "/tmp/${LDTEMPFOLDER}/in_lobby/"; echo "~" >> "/tmp/${LDTEMPFOLDER}/in_lobby/${SENTIPFILENAME}"; fi #In_Lobby counter #:;
				else
					if ! [ -f "$VV_FILENAME" ]; then vv_header; fi
					#GET_DATE=$(( GET_DATE - SENTINELLIST_COUNT )) # Corrects apparent temporal drift; subtracts the number of IPs in the log from the epoch time.
					until ! { [ $GET_DATE = "" ] || [ "$(echo "$GET_DATE"|wc -c)" -lt 10 ]; }; do GET_DATE="$(tail +1 "/tmp/${LDTEMPFOLDER}/getdateinit")"; done
					WRITE_DATE="$(date -d "@$GET_DATE" +%X)"
					GET_DATE_MINUS_1="$(( GET_DATE - 1))"
					WRITE_DATE_MINUS_1="$(date -d "@$GET_DATE_MINUS_1" +%X)"
					GET_DATE_PLUS_1="$(( GET_DATE + 1))"
					WRITE_DATE_PLUS_1="$(date -d "@$GET_DATE_PLUS_1" +%X)"
					WRITE_BLANK="${GET_DATE_MINUS_1}\t${WRITE_DATE_MINUS_1}\t0\t0\t0\t0\t1\t0\t0\t0"

					#Add a blank after consecutive blanks just before adding real value. For graph accuracy.
					if [ "$(tail +2 "${VV_FILENAME}"|tail -${VV_WRITE_LIMIT}|grep -Eo "0\t0\t0\t0\t1\t0\t0\t0$"|wc -l)" = $VV_WRITE_LIMIT ]; then
					if ! { grep -Eq "^${GET_DATE_MINUS_1}" "${VV_FILENAME}"; }; then
						echo -e "${WRITE_BLANK}" >> "${VV_FILENAME}"
					fi
				fi ; wait $!

				if [ -n "$IC_PID" ]; then wait $IC_PID; fi

				if { grep -Eq "^${GET_DATE}\b" "${VV_FILENAME}"; }; then
					if ! { grep -Eq "^${GET_DATE_PLUS_1}\b" "${VV_FILENAME}"; }; then
						echo -e "${GET_DATE_PLUS_1}\t${WRITE_DATE_PLUS_1}\t${write_DELTA_old}\t${write_DELTA_new}\t${write_DELTA_SUM}\t${write_DELTA_DIFF}\t${write_DELTA_AVG}\t${write_DELTA_DIFFSQ}\t${write_DELTA_XSQ}\t${write_DELTA_STD_DEV}" >> "${VV_FILENAME}"
					fi
				else
					echo -e "${GET_DATE}\t${WRITE_DATE}\t${write_DELTA_old}\t${write_DELTA_new}\t${write_DELTA_SUM}\t${write_DELTA_DIFF}\t${write_DELTA_AVG}\t${write_DELTA_DIFFSQ}\t${write_DELTA_XSQ}\t${write_DELTA_STD_DEV}" >> "${VV_FILENAME}"
				fi ; wait $!
			fi; wait $!
		if { tail -4 "${VV_FILENAME}"|grep -Eoq "\t0\t0\t0\t0\t1\t0\t0\t0$"; }; then
		InlineCorrections #&
		fi &
		}
}
	vv_header(){
		#Make header for verifyvalues.txt
		HEADER_VV="Epoch\tTIME\t${BYTE_LABEL}diffA\t${BYTE_LABEL}diffB\t${BYTE_LABEL}SUM\t${BYTE_LABEL}DIFF\t${BYTE_LABEL}AVG\t${BYTE_LABEL}DIFFSQ\t${BYTE_LABEL}XSQ\t${BYTE_LABEL}STD_DEV"
		HEADER_ID="${LAGG_LOADEDFILTER} ${IDENT} ${IP_MASK} ${LOG_PING} ${LOG_TR} [${GET_LOCATION_VV}] $(date)"
		HEADER_HIGHLIGHT="${DELTA_AVGLIMIT}\t${SENTLOSSLIMIT_store}\t${CHI_LIMIT}\t${DELTA_STD_DEV_LIMIT}"
		if [ -f "${VV_FILENAME}" ]; then
			if ! { grep -Eq "^(${HEADER_VV})" "${VV_FILENAME}"; }; then
				echo -e "${HEADER_VV}\t${HEADER_HIGHLIGHT}\t${HEADER_ID}" >> "${VV_FILENAME}"
			fi
		else
			echo -e "${HEADER_VV}\t${HEADER_HIGHLIGHT}\t${HEADER_ID}" > "${VV_FILENAME}"
		fi
	}
	INLINE_CORRECT_HITCH=0
	InlineCorrections(){
		ADJUST_RUN_COUNT="" #Set to nothing at start
		READING_FRAME=4
		if [ -f "${VV_FILENAME}" ] && [ $INLINE_CORRECT_HITCH != 1 ] && [ ! -f "/tmp/${LDTEMPFOLDER}/ld_act_lock/${SENTIPFILENAME}" ]; then
			INLINE_CORRECT_HITCH=1
			#Reads the last 4 lines of verify file for patterns for cleaner graph presentation
			GET_LINE_TO_CORRECT="$(tail -${READING_FRAME} "${VV_FILENAME}"|sed "/[a-zA-Z]/d")"
			CHECK_LINE1="$(echo "$GET_LINE_TO_CORRECT"|sed -n 1p)"
			CHECK_LINE2="$(echo "$GET_LINE_TO_CORRECT"|sed -n 2p)"
			CHECK_LINE3="$(echo "$GET_LINE_TO_CORRECT"|sed -n 3p)"
			CHECK_LINE4="$(echo "$GET_LINE_TO_CORRECT"|sed -n 4p)"
			ZEROED_LINE='\t0\t0\t0\t0\t1\t0\t0\t0$'
			NONZERO_LINE='(^[0-9]{10,}\t(\d{2}:\d{2}:\d{2})\t(([1-9]?[0-9]?[1-9]{1,}0?\t){2}.*$))'
			AB_ZERONON_LINE='^[0-9]{10,}\t(\d{2}:\d{2}:\d{2})\t(([1-9]?[0-9]?[1-9]{1,}0?\t\b0|\b0\t[1-9]?[0-9]?[1-9]{1,}0?).*$)'

			#Regular cases
			#00 00 XX 00
			if { echo "$CHECK_LINE3"|grep -Evq "$ZEROED_LINE"; } && { { echo "$CHECK_LINE1"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE2"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE4"|grep -Eq "$ZEROED_LINE"; }; }; then
				INLINE_CASE=3
				ADJUST_RUN_COUNT=$(( ADJUST_RUN_COUNT + 1 ))
			#00 XX 00 00
			elif { echo "$CHECK_LINE2"|grep -Evq "$ZEROED_LINE"; } && { { echo "$CHECK_LINE1"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE3"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE4"|grep -Eq "$ZEROED_LINE"; }; }; then
				INLINE_CASE=2
				ADJUST_RUN_COUNT=$(( ADJUST_RUN_COUNT + 1 ))
			#XX 00 00 00
			elif { echo "$CHECK_LINE1"|grep -Evq "$ZEROED_LINE"; } && { { echo "$CHECK_LINE2"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE3"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE4"|grep -Eq "$ZEROED_LINE"; }; }; then
				INLINE_CASE=1
				ADJUST_RUN_COUNT=$(( ADJUST_RUN_COUNT + 1 ))

			#Special cases
			#00 XX XX 00
			elif { { echo "$CHECK_LINE2"|grep -Evq "$ZEROED_LINE"; } && { echo "$CHECK_LINE3"|grep -Evq "$ZEROED_LINE"; }; } && { { echo "$CHECK_LINE1"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE4"|grep -Eq "$ZEROED_LINE"; }; }; then
				INLINE_CASE=4
				ADJUST_RUN_COUNT=$(( ADJUST_RUN_COUNT + 2 ))

			#0X 00 00 00
			elif { echo "$CHECK_LINE1"|grep -Eq "$AB_ZERONON_LINE"; } && { { echo "$CHECK_LINE2"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE3"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE4"|grep -Eq "$ZEROED_LINE"; }; }; then
				INLINE_CASE=5
				ADJUST_RUN_COUNT=$(( ADJUST_RUN_COUNT + 1 ))

			#00 00 00 0X
			elif { echo "$CHECK_LINE4"|grep -Eq "$AB_ZERONON_LINE"; } && { { echo "$CHECK_LINE2"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE3"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE1"|grep -Eq "$ZEROED_LINE"; }; }; then
				INLINE_CASE=6
				ADJUST_RUN_COUNT=$(( ADJUST_RUN_COUNT + 1 ))

			#XX 00 00 0X
			elif { echo "$CHECK_LINE1"|grep -Evq "$ZEROED_LINE"; } && { { echo "$CHECK_LINE2"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE3"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE4"|grep -Eq "$AB_ZERONON_LINE"; }; }; then
				INLINE_CASE=7
				ADJUST_RUN_COUNT=$(( ADJUST_RUN_COUNT + 1 ))

			#0X 00 00 XX
			elif { echo "$CHECK_LINE1"|grep -Eq "$AB_ZERONON_LINE"; } && { { echo "$CHECK_LINE2"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE3"|grep -Eq "$ZEROED_LINE"; } && { echo "$CHECK_LINE4"|grep -Evq "$ZEROED_LINE"; }; }; then
				INLINE_CASE=8
				ADJUST_RUN_COUNT=$(( ADJUST_RUN_COUNT + 1 ))
			else
				INLINE_CASE=0
			fi

			case "$INLINE_CASE" in
				#First: Check 3rd line for non-zero, check if lines 1,2,4 are zeroed.
				3)
					CHECK_LINE3_sub="$(echo "$CHECK_LINE3"|sed -E "s/\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$/0\t0\t0\t0\t1\t0\t0\t0/g")"
					sed -i -E "s/${CHECK_LINE3}/${CHECK_LINE3_sub}/" "${VV_FILENAME}"
				;;

				#Second: Check 2nd line for non-zero, check if lines 1,3,4 are zeroed.
				2)
					CHECK_LINE2_sub="$(echo "$CHECK_LINE2"|sed -E "s/\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$/0\t0\t0\t0\t1\t0\t0\t0/g")"
					sed -i -E "s/${CHECK_LINE2}/${CHECK_LINE2_sub}/" "${VV_FILENAME}"
				;;

				#Third: Check 1st line for non-zero, check if lines 2,3,4 are zeroed.
				1)
					CHECK_LINE1_sub="$(echo "$CHECK_LINE1"|sed -E "s/\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$/0\t0\t0\t0\t1\t0\t0\t0/g")"
					sed -i -E "s/${CHECK_LINE1}/${CHECK_LINE1_sub}/" "${VV_FILENAME}"
				;;

				#Fourth: Check 2nd and 3rd lines for non-zero, check if lines 1 and 4 are zeroed.
				4)
					CHECK_LINE2_sub="$(echo "$CHECK_LINE2"|sed -E "s/\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$/0\t0\t0\t0\t1\t0\t0\t0/g")"
					CHECK_LINE3_sub="$(echo "$CHECK_LINE3"|sed -E "s/\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$/0\t0\t0\t0\t1\t0\t0\t0/g")"
					sed -i -E "s/${CHECK_LINE3}/${CHECK_LINE3_sub}/;s/${CHECK_LINE2}/${CHECK_LINE2_sub}/" "${VV_FILENAME}"
				;;
				#Fifth: Change X0 leading to zeros to zero
				5)
					CHECK_LINE1_sub="$(echo "$CHECK_LINE1"|sed -E "s/\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$/0\t0\t0\t0\t1\t0\t0\t0/g")"
					sed -i -E "s/${CHECK_LINE1}/${CHECK_LINE1_sub}/" "${VV_FILENAME}"
				;;
				#Sixth: Change X0 coming from zeros to zero
				6)
					CHECK_LINE4_sub="$(echo "$CHECK_LINE1"|sed -E "s/\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$/0\t0\t0\t0\t1\t0\t0\t0/g")"
					sed -i -E "s/${CHECK_LINE4}/${CHECK_LINE4_sub}/" "${VV_FILENAME}"
				;;
				#Seventh: Change X0 leading to zeros to zero, but headed by nonzero
				7)
					CHECK_LINE4_sub="$(echo "$CHECK_LINE1"|sed -E "s/\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$/0\t0\t0\t0\t1\t0\t0\t0/g")"
					sed -i -E "s/${CHECK_LINE4}/${CHECK_LINE4_sub}/" "${VV_FILENAME}"
				;;
				#Eighth: Change X0 coming from zeros to zero, but headed by nonzero
				8)
					CHECK_LINE1_sub="$(echo "$CHECK_LINE1"|sed -E "s/\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$/0\t0\t0\t0\t1\t0\t0\t0/g")"
					sed -i -E "s/${CHECK_LINE1}/${CHECK_LINE1_sub}/" "${VV_FILENAME}"
				;;
			esac #; if [ $INLINE_CASE != 0 ]; then walkback_strike; fi
			IC_PID=$!; wait $!

			#Remove blips between all-zero values: full-comb
			{
				GET_LINE_TO_CORRECT="$(tail "${VV_FILENAME}"|sed -n '/\b0\t0\t0\t0\t1\t0\t0\t0/{n;n};/\b0\t0\t0\t0\t1\t0\t0\t0/{N;p}'|grep -Ev "(\b0\t0\t0\t0\t1\t0\t0\t0).*$"|sed "/[a-zA-Z]/d"|awk '!a[$0]++'|sed "s/\t/#/g")"

				for line in $GET_LINE_TO_CORRECT; do
					line="$(echo "$line"|sed -E "s/#/\t/g")"
					COMB_GET_LINE_TO_CORRECT="$(grep -Eo -C 1 "${line}" "${VV_FILENAME}")"
					COMB_CHECK_LINE1="$(echo "$COMB_GET_LINE_TO_CORRECT"|sed -n 1p)"
					COMB_CHECK_LINE2="$(echo "$COMB_GET_LINE_TO_CORRECT"|sed -n 2p)"
					COMB_CHECK_LINE2_sub="$(echo "$COMB_CHECK_LINE2"|sed -E "s/\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}\t\d{1,}$/0\t0\t0\t0\t1\t0\t0\t0/g")"
					COMB_CHECK_LINE3="$(echo "$COMB_GET_LINE_TO_CORRECT"|sed -n 3p)"
					if { { echo "$COMB_CHECK_LINE1"|grep -Eoq "(\t0\t0\t0\t0\t1\t0\t0\t0$)"; } && { echo "$COMB_CHECK_LINE3"|grep -Eoq "(\t0\t0\t0\t0\t1\t0\t0\t0$)"; }; }; then
						sed -i -E "s/${COMB_CHECK_LINE2}/${COMB_CHECK_LINE2_sub}/" "${VV_FILENAME}"
						#walkback_strike
						ADJUST_RUN_COUNT=$(( ADJUST_RUN_COUNT + 1 ))
					fi
				done
			} #&
		n=0; while [[ $n -lt $ADJUST_RUN_COUNT ]]; do { walkback_strike; }; n=$((n+1)); done #Run for ADJUST_RUN_COUNT number of times.
		#wait $!
		ADJUST_RUN_COUNT="" #Set to nothing at end
		INLINE_CORRECT_HITCH=0
		fi
		STRIKE_ADDED=0
	}
	sort_verify(){
		#Sort verify files
		if [ $VERIFY_VALUES = 1 ]; then
			FILENAME_LIST="$(ls -1 ""${DIR}"/42Kmi/verify/")"

			for file in $FILENAME_LIST; do
				FILESTORE="$(tail +1 ""${DIR}"/42Kmi/verify/$file")"
				FILE_BODY="$(echo "$FILESTORE"|tail +2)"

				if ! { echo "$FILE_BODY"|sort -cn &> /dev/null; }; then
					HEADER="$(echo "$FILESTORE"|sed -n 1p)"
					FILE_BODY_SORT="$(echo "$FILE_BODY"|sort -k 1 -n)"
					echo -e "${HEADER}\n${FILE_BODY_SORT}" > ""${DIR}"/42Kmi/verify/$file"
				fi
			done
			wait $!
		fi
	}
	sent_action(){
		fix_strikes

		if { echo "${SENT_LDACCEPT_STORE}"| grep -E "\b${CONSOLE}\b"|grep -Eoq "\b${ip}\b"; }; then
			wait $GET_THE_VALUES_PID &&
		{
			GET_LDACCEPT_VALUES1="$(tail +1 "/tmp/${LDTEMPFOLDER}/ldacceptval1")"
			GET_LDACCEPT_VALUES2="$(tail +1 "/tmp/${LDTEMPFOLDER}/ldacceptval2")"

			case $PACKET_OR_BYTE in
				1)
					#Packet
					BYTE_LABEL="PACKETS"
					byte1="$(echo "${GET_LDACCEPT_VALUES1}"|grep -E "\b${ip}\b"|awk '{printf $1 "\n"}'|sed -n 1p)"
					byte2="$(echo "${GET_LDACCEPT_VALUES2}"|grep -E "\b${ip}\b"|awk '{printf $1 "\n"}'|sed -n 1p)"
					byte1_tare="$(echo "${GET_LDACCEPT_VALUES1}"|grep -E "\b${ip}\b"|awk '{printf $2 "\n"}'|sed -n 1p)"
					byte2_tare="$(echo "${GET_LDACCEPT_VALUES2}"|grep -E "\b${ip}\b"|awk '{printf $2 "\n"}'|sed -n 1p)"
				;;
				2)
					#Bytes
					BYTE_LABEL="BYTES"
					byte1="$(echo "${GET_LDACCEPT_VALUES1}"|grep -E "\b${ip}\b"|awk '{printf $2 "\n"}'|sed -n 1p)"
					byte2="$(echo "${GET_LDACCEPT_VALUES2}"|grep -E "\b${ip}\b"|awk '{printf $2 "\n"}'|sed -n 1p)"
					byte1_tare_pkts="$(echo "${GET_LDACCEPT_VALUES1}"|grep -E "\b${ip}\b"|awk '{printf $1 "\n"}'|sed -n 1p)"
					byte2_tare_pkts="$(echo "${GET_LDACCEPT_VALUES2}"|grep -E "\b${ip}\b"|awk '{printf $1 "\n"}'|sed -n 1p)"
				;;
			esac

			#Absolute value adjust
			byte1="$(echo -n "$byte1"|sed -E "s/-//g")"
			byte2="$(echo -n "$byte2"|sed -E "s/-//g")"

			#Math
			
			#Set DELTA_new
			DELTA_new="$(( byte2 - byte1 )) "
			DELTA_new="$(echo -n "$DELTA_new"|sed -E "s/-//g")"
			DELTA_new="$(( DELTA_new / SENTINELDELAYSMALL ))"
			
			#Add padding: allows Sentinel to correctly tare "lobby" flow. Removed later.
			if [ $DELTA_new -gt 0 ]; then DELTA_new="$(( DELTA_new + 1000 ))"; fi
			
			if [ $PACKET_OR_BYTE != 2 ]; then
				DELTA_new_tare="$(( $(( byte2_tare - byte1_tare )) / SENTINELDELAYSMALL ))"
			else
				DELTA_tare_pkts="$(( $(( byte2_tare_pkts - byte1_tare_pkts )) / SENTINELDELAYSMALL ))"
			fi
						
			#Tare: Set delta values less than TARE to 0. Should prevent reading of spikes during lobbies and pregame, but allow Sentinel to see true zero transfers.
			if [ $PACKET_OR_BYTE = 2 ]; then
				#bytes
				if { [ $DELTA_new -le $TARE ] || [ $DELTA_tare_pkts -le $PACKET_TARE ]; } && [ $DELTA_new -gt 1 ]; then
					DELTA_new=0
					
					#Handles leading zero to what is expected to be lobby/low-transfer time.
					if [ -f "/tmp/${LDTEMPFOLDER}/oldval/${SENTIPFILENAME}#" ] && [ $DELTA_new = 0 ]; then echo $DELTA_new > "/tmp/${LDTEMPFOLDER}/oldval/${SENTIPFILENAME}#"; fi
				fi
			else
				#packets
				if [ $DELTA_new_tare -le $TARE ] || [ $DELTA_new -lt $DELTA_AVGLIMIT ] || { [ $DELTA_new -lt $PACKET_TARE ] && [ $DELTA_new -gt 1 ]; }; then
					DELTA_new=0
					
					#Handles leading zero to what is expected to be lobby/low-transfer time.
					if [ -f "/tmp/${LDTEMPFOLDER}/oldval/${SENTIPFILENAME}#" ] && [ $DELTA_new = 0 ]; then echo $DELTA_new > "/tmp/${LDTEMPFOLDER}/oldval/${SENTIPFILENAME}#"; fi
				fi
			fi
			
			#Remove padding
			if [ $DELTA_new -gt 0 ]; then DELTA_new="$(( DELTA_new - 1000 ))"; fi

			#Set DELTA_old
			if ! [ -f "/tmp/${LDTEMPFOLDER}/oldval/${SENTIPFILENAME}#" ]; then echo $DELTA_new > "/tmp/${LDTEMPFOLDER}/oldval/${SENTIPFILENAME}#"; fi
			continuous_mode

			#Ensures deltas are positive integers
			DELTA_old="$(echo -n "$DELTA_old"|sed -E "s/-//g")"
			DELTA_new="$(echo -n "$DELTA_new"|sed -E "s/-//g")"
			DELTA_new_tare="$(echo -n "$DELTA_new_tare"|sed -E "s/-//g")"
			DELTA_tare_pkts="$(echo -n "$DELTA_tare_pkts"|sed -E "s/-//g")"
			
			##Check delta values. Delete when done
			#echo "$DELTA_new" >> /jffs/42Kmi/delta_bytes.txt
			#echo "$DELTA_tare_pkts" >> /jffs/42Kmi/delta_pkts.txt
			
			DELTA_SUM="$(( DELTA_new + DELTA_old ))"
			DELTA_DIFF="$(( DELTA_new - DELTA_old ))"

			DELTA_DIFF="$(echo -n "$DELTA_DIFF"|sed -E "s/-//g")"

			if [ $DELTA_new = $DELTA_old ]; then DELTA_DIFF=0; fi #DELTA_DIFF Correction

			SENTLOSSLIMIT_store=$SENTLOSSLIMIT
			errata

			DELTA_AVG="$(( DELTA_SUM / 2 ))"
			if [ $DELTA_AVG = 0 ]; then DELTA_AVG=1; fi

			DELTA_DIFFSQ="$(floatmath "$DELTA_DIFF * $DELTA_DIFF")"
			
			#if-else for XSq and std_dev
			verify_filename
			SENT_POP="$(tail +2 "${VV_FILENAME}"|grep -Ev "^[0-9]{10,}\t(\d{2}:\d{2}:\d{2})\t0\t0\t0\t0\t1\t0\t0\t0$.*$")"
			SENT_POP_COUNT="$(echo "${SENT_POP}"|wc -l)"
			if [ "${SENT_POP_COUNT}" -ge 5 ]; then
				#Average of diff history: column 4
				SENT_POP_DIFF_GET="$(echo "${SENT_POP}"|awk '{printf $4 "\n"}'|grep -Ev "^0")"
				SENT_POP_DIFF_GET_COUNT="$(echo "${SENT_POP_DIFF_GET}"|wc -l)"
				SENT_POP_DIFF_GET_SUM="$(( $(echo ${SENT_POP_DIFF_GET}|tr " " "+") ))"
				SENT_POP_DIFF_MEAN="$(floatmath "${SENT_POP_DIFF_GET_SUM}/${SENT_POP_DIFF_GET_COUNT}")" #Population diff mean
				SENT_POP_SIZE="$(echo $"{SENT_POP}"|sed -E "/^[0-9]{10,}\t(\d{2}:\d{2}:\d{2})\t(([1-9]?[0-9]?[1-9]{1,}0?\t\b0|\b0\t[1-9]?[0-9]?[1-9]{1,}0?).*$)/d"|wc -l)" #Excludes all-zeroes entries
				#-----
				DELTA_XSQ="$(floatmath "$DELTA_DIFFSQ / $SENT_POP_DIFF_MEAN")"
				DELTA_STD_DEV="$(floatmath "( 100 * (${DELTA_AVG} - ${SENT_POP_DIFF_MEAN})/${SENT_POP_DIFF_MEAN})")"
				else
				DELTA_XSQ="$(floatmath "$DELTA_DIFFSQ / $DELTA_AVG")"
				DELTA_STD_DEV="$(floatmath "( 100 * ( $DELTA_new - $DELTA_AVG ) / $DELTA_AVG )")"
			fi
			if [ $DELTA_old = 0 ] && [ $DELTA_new = 0 ] && [ $DELTA_AVG = 1 ]; then DELTA_STD_DEV=0; fi 

			# These values should never be negative. That causes problems. This occurs often when using bytes.
			DELTA_DIFFSQ="$(echo -n "$DELTA_DIFFSQ"|sed -E "s/-//g")"

			#Trim trailing decimals for ease of use with built-it math
			DELTA_XSQ="$(echo -n "$DELTA_XSQ"|sed -E "s/-//g"|awk '{printf "%.0f\n", $1}')" #Rounds trailing decimals
			DELTA_STD_DEV="$(echo -n "$DELTA_STD_DEV"|sed -E "s/-//g"|awk '{printf "%.0f\n", $1}')" #Round Trim trailing decimals

			if [ ! -d "/tmp/${LDTEMPFOLDER}" ]; then mkdir -p "/tmp/${LDTEMPFOLDER}" ; fi
			echo "$DELTA_new" > "/tmp/${LDTEMPFOLDER}/oldval/${SENTIPFILENAME}#"

			##Verify: The logic behind striking
			#verifyvalues_action &

			##### SENTINELS #####
			{
				#errata
				if [ $DELTA_new -gt $DELTA_AVGLIMIT ] || [ $DELTA_old -gt $DELTA_AVGLIMIT ]; then
					##### PACKETBLOCK ##### // 0 or 1=Difference, 2=X^2, 3=Difference or X^2, 4=Difference & X^2, 5=Difference, X^2, & Std Dev
					case "${SENTMODE}" in
						0|1) # Difference only
							DELTA_BLOCK="$({ if { { [ $DELTA_new -gt $DELTA_AVGLIMIT ] || [ $DELTA_old -gt $DELTA_AVGLIMIT ]; } && [ "${DELTA_AVG}" -gt "${DELTA_AVGLIMIT}" ] && [ "${DELTA_DIFF}" -ge "${SENTLOSSLIMIT}" ]; }; then sentinelstrike; fi; } &)"
							;;
						2) #X^2 only
							DELTA_BLOCK="$({ if { { [ $DELTA_new -gt $DELTA_AVGLIMIT ] || [ $DELTA_old -gt $DELTA_AVGLIMIT ]; } && [ "${DELTA_AVG}" -gt "${DELTA_AVGLIMIT}" ] && [ "${DELTA_XSQ}" -gt "${CHI_LIMIT}" ]; }; then sentinelstrike; fi; } &)"
							;;
						3) #Difference or X^2
							DELTA_BLOCK="$({ if { [ $DELTA_new -gt $DELTA_AVGLIMIT ] || [ $DELTA_old -gt $DELTA_AVGLIMIT ]; } && { [ "${DELTA_AVG}" -gt "${DELTA_AVGLIMIT}" ] && [ "${DELTA_DIFF}" -ge "${SENTLOSSLIMIT}" ]; } || [ "${DELTA_XSQ}" -gt "${CHI_LIMIT}" ]; then sentinelstrike; fi; } &)"
							;;
						4) #Difference AND X^2
							DELTA_BLOCK="$({ if { [ $DELTA_new -gt $DELTA_AVGLIMIT ] || [ $DELTA_old -gt $DELTA_AVGLIMIT ]; } && { [ "${DELTA_AVG}" -gt "${DELTA_AVGLIMIT}" ] && [ "${DELTA_DIFF}" -ge "${SENTLOSSLIMIT}" ]; } && [ "${DELTA_XSQ}" -gt "${CHI_LIMIT}" ]; then sentinelstrike; fi; } &)"
							;;
						5) #Difference AND X^2 AND STD_DEV
							DELTA_BLOCK="$({ if { [ $DELTA_new -gt $DELTA_AVGLIMIT ] || [ $DELTA_old -gt $DELTA_AVGLIMIT ]; } && { [ "${DELTA_AVG}" -gt "${DELTA_AVGLIMIT}" ] && [ "${DELTA_DIFF}" -ge "${SENTLOSSLIMIT}" ] && [ "${DELTA_XSQ}" -gt "${CHI_LIMIT}" ] && [ "${DELTA_STD_DEV}" -gt "${DELTA_STD_DEV_LIMIT}" ]; }; then sentinelstrike; fi; } &)"
					;;
					esac
				fi
			}
			#Verify: The logic behind striking
			verifyvalues_action &

		} & #Comment if it causes problems
		fi
			#Sentinel Activity
			{
				if { [ $DELTA_old = 0 ] && [ $DELTA_new = 0 ]; } || { [ $DELTA_SUM = 0 ] || [ $DELTA_DIFF = 0 ]; }; then :; #Don't run Sentinel action for zero values.
				else
					if [ $DELTA_new != $DELTA_old ]; then
						if ! { [ $DELTA_new = $DELTA_old ] && [ $DELTA_DIFF != 0 ]; }; then
							if [ $DELTA_new -gt $DELTA_AVGLIMIT ] && [ $DELTA_old -gt $DELTA_AVGLIMIT ]; then
								if [ $DELTA_SUM != 0 ]; then
									if [ $DELTA_DIFF != 0 ]; then
										if [ $DELTA_new -gt $(( DIFF_MIN + DELTA_OFFSET )) ] || [ $DELTA_old -gt $(( DIFF_MIN + DELTA_OFFSET )) ]; then
											$DELTA_BLOCK
										fi
									fi
								fi
							fi
						fi
					fi
				fi
			}
		eval "${SENTIPFILENAME}_ID=0"
	}
	sentinel_tweak(){
		SENTMODE=$TWEAK_SENTMODE
		SENTLOSSLIMIT=$TWEAK_SENTLOSSLIMIT
		SENTINELDELAYSMALL=$TWEAK_SENTINELDELAYSMALL
	}
	sentinel_default_settings(){
		SENTINELDELAYSMALL=1 #1 #Establishes deltas
		ABS_VAL=1 #Absolute value (e.g.: 3 - 5 = 2). Set to 0 to disable. Don't Change. Obsoleted.
		SENTMODE=5 #0 or 1=Difference, 2=X^2, 3=Difference or X^2, 4=Difference & X^2, 5=Difference & X^2 & StdDev

		if [ $PACKET_OR_BYTE = 2 ]; then
			#Bytes
			DELTA_AVGLIMIT=1600 #Threshold value. Deltas must be above this value to be active. #"${BYTE_LIMIT}"
			SENTLOSSLIMIT_BASE=2000 #DIFF #Don't change 
			TARE=1200 #"${BYTE_LIMIT}" #"${DELTA_AVGLIMIT}"
			PACKET_TARE=12 #Don't change
		else
			#Packets
			DELTA_AVGLIMIT=12 #Threshold value. Deltas must be above this value to be active. #Don't change
			SENTLOSSLIMIT_BASE=10 #DIFF #Don't change
			TARE=1200 #"${BYTE_LIMIT}" #Tare acts based on bytes transferred
			PACKET_TARE=12 #Don't change
		fi
		if [ $USLEEP_EXISTS = 1 ]; then
			SENTLOSSLIMIT_BASE=$(( SENTLOSSLIMIT_BASE / USLEEP_DIVSCALE )) #This will matter.
		fi
		CHI_LIMIT=$(( $(( SENTLOSSLIMIT_BASE * 5 )) / 10 )) #Previous 7
		DELTA_STD_DEV_LIMIT=15 #20 #Don't change
	}
	sentinel_scaling(){
		LOG_PINGTRGET="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -E "\b(${ip})\b"|grep -Eo "\b([0-9]{1,}\.[0-9]{3})ms\b"|sed "s/#//g"|sed -E "s/\.[0-9]{3}ms$//g")" #Includes approximated pings
		LOG_PING="$(echo "$LOG_PINGTRGET"|sed -n 1p)"; if ! { echo "$LOG_PING"|grep -Eo "[0-9]{1,}" &> /dev/null; }; then LOG_PING=0; fi
		LOG_TR="$(echo "$LOG_PINGTRGET"|sed -n 2p)"; if ! { echo "$LOG_TR"|grep -Eo "[0-9]{1,}" &> /dev/null ; }; then LOG_TR=0; fi
		if [ $LOG_PING = 0 ]; then LOG_TR=0; fi

		#Math
		LOG_PING_TR_SUM=$(( LOG_PING + LOG_TR ))
		LOG_PING_TR_AVG=$(( LOG_PING_TR_SUM / 2 ))
		if [ $LOG_PING_TR_AVG = 0 ]; then LOG_PING_TR_AVG=1; fi
		LOG_PING_TR_DIFF=$(( LOG_PING - LOG_TR ));LOG_PING_TR_DIFF="$(echo -n "$LOG_PING_TR_DIFF"|sed -E "s/-//g")"
		LOG_PING_TR_DIFFSQ=$(( LOG_PING_TR_DIFF * LOG_PING_TR_DIFF ))
		LOG_PING_TR_XSQ=$(( LOG_PING_TR_DIFFSQ / LOG_PING_TR_AVG )); LOG_PING_TR_XSQ="$(echo -n "$LOG_PING_TR_XSQ"|sed -E "s/-//g")"
		LOG_PING_TR_MATH="$LOG_PING_TR_XSQ"

		COEFFICIENT=$(( LOG_PING_TR_XSQ ))

		LOG_PING_LIMIT_BOTTOM=100
		LOG_PING_LIMIT_TOP=300

		#Scaling
		if [ $COEFFICIENT -ge $LOG_PING_LIMIT_BOTTOM ] && [ $COEFFICIENT -le $LOG_PING_LIMIT_TOP ]; then
			SENTLOSSLIMIT_INIT=$(( $(( SENTLOSSLIMIT_BASE * 5 )) / 9 ))
			SENTLOSSLIMIT=$(( $(( SENTLOSSLIMIT_INIT * COEFFICIENT )) / 100 )) #Scales based on PING time
			if [ $SENTLOSSLIMIT -lt $SENTLOSSLIMIT_BASE ]; then SENTLOSSLIMIT=$SENTLOSSLIMIT_BASE; fi
		else
			SENTLOSSLIMIT=$SENTLOSSLIMIT_BASE #Don't change
		fi
	}

	BYTE_LIMIT=2000 #Don't change. Derived from active matches during Super Smash Bros. Ultimate.

	if [ $SENTBAN = 1 ]; then
		STRIKEMAX="$STRIKECOUNT_LIMIT"
	else
		STRIKEMAX=999999999 #Effectively disabled
	fi
	get_strike_counts(){
		 #Get strike count from log.
		STRIKE_MARK_COUNT_GET="$(grep -E "#(.\[[0-9]{1}\;[0-9]{2}m)?(${ip})\b" "/tmp/$RANDOMGET"|sed "/${SENTINEL_BAN_MESSAGE}/d"|grep -Eo "(${STRIKE_MARK_SYMB}{1,}$)"|wc -c)"
		if [ $STRIKE_MARK_COUNT_GET -le 0 ]; then STRIKE_MARK_COUNT_GET=0; else STRIKE_MARK_COUNT_GET=$(( STRIKE_MARK_COUNT_GET - 1 )); fi

		#Get strikes from LDSENTSTRIKE
		STRIKECOUNT_GET="$(tail +1 "${STRIKE_FOLDER}"|wc -l)"
	}
	ip_process(){
		SENTVAL1="$(tail +1 "/tmp/${LDTEMPFOLDER}/ldacceptval1"|grep -E "\b($ip)\b"|awk '{printf $2}'|sed -n 1p)"
		SENTVAL2="$(tail +1 "/tmp/${LDTEMPFOLDER}/ldacceptval2"|grep -E "\b($ip)\b"|awk '{printf $2}'|sed -n 1p)"

		if [ "$SENTVAL1" != 0 ] || [ "$SENTVAL2" != 0 ]; then

			SENTIPFILENAME="$(panama ${ip})"
			STRIKE_FOLDER="/tmp/${LDTEMPFOLDER}/ld_sentstrike_count/${SENTIPFILENAME}"

			#Strike Counts
			get_strike_counts

			if [ $LAGG_ON = 1 ]; then
				#Add entry to laggregate.txt
				LAGG_COUNT_MIN=5
				if [ $STRIKE_MARK_COUNT_GET -ge $LAGG_COUNT_MIN ] && ! { grep -Eq "^(${SENTIPFILENAME})" "${DIR}/42Kmi/laggregate.txt"; }; then
					laggregate
				fi
			fi & #Do not remove

			if [ -f "$DIR"/42Kmi/tweak.txt ]; then
				sentinel_tweak
			else
				sentinel_default_settings
				sentinel_scaling
			fi

			#usleep corrections
			if [ $USLEEP_EXISTS = 1 ]; then
				DELTA_AVGLIMIT=$(( DELTA_AVGLIMIT / USLEEP_DIVSCALE ))
				TARE=$(( TARE / USLEEP_DIVSCALE ))
				PACKET_TARE=$(( PACKET_TARE / USLEEP_DIVSCALE ))
			fi

			if [ "$(eval "echo \$$(echo ${SENTIPFILENAME}_ID)")" != 1 ]; then
			eval "${SENTIPFILENAME}_ID=1"
			(
			sent_action #&
			) #&
			fi

		fi
	}
	SENT_ON=0
	SENT_IP_LOCK=0
	
	sentinel(){
		exit_trap
		if [ ! -d "/tmp/${LDTEMPFOLDER}/ld_sentstrike_count" ]; then mkdir "/tmp/${LDTEMPFOLDER}/ld_sentstrike_count"; fi
		while [ $SENT_ON != 1 ]; wait &> /dev/null; do
		if [ $SENT_ON != 1 ]; then
		wait $SENT_PID
		SENT_ON=1
		wait $GET_THE_VALUES_PID &&
			{
				GET_DATE="$(tail +1 "/tmp/${LDTEMPFOLDER}/getdateinit")"; wait $!
				SENTINELLIST="$(tail +1 "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed -E "/\b(${RESPONSE3})\b/d"|sed "/${SENTINEL_BAN_MESSAGE}/d"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")"
				SENTINELLIST_COUNT="$(echo "$SENTINELLIST"|wc -l)"
				SENT_LDACCEPT_STORE="$(iptables -nL LDACCEPT)"
				SENT_LDBAN_STORE="$(iptables -nL LDBAN)"

			#====================================================

				#This is where Sentinel Execution happens.
				for ip in $SENTINELLIST; do
					(
					if [ $SENT_IP_LOCK != 1 ]; then
						SENT_IP_LOCK=1
						ip_process
						SENT_IP_LOCK=0
					fi
					) &
				done 2> /dev/null
		SENT_ON=0
			}; SENT_PID=$!
		fi
		done 2> /dev/null
	}
	if [ $POPULATE = 1 ]; then :
	else
		sentinel 2> /dev/null &
	fi

}
fi
###### SENTINELS #####
#==========================================================================================================
##### ACTIVE PEER INDICATOR #####
act_peer_task(){
	if [ "$(tail +1 "/tmp/${LDTEMPFOLDER}/ld_act_state/${ACTIPFILENAME}#")" != "${ACT_SUB_WRITE}" ]; then
		echo "${ACT_SUB_WRITE}" > "/tmp/${LDTEMPFOLDER}/ld_act_state/${ACTIPFILENAME}#"
		touch -c "/tmp/${LDTEMPFOLDER}/ld_act_state"
		WRITE_NULL=1
	fi
}
delete_strikes(){
	rm -f "/tmp/${LDTEMPFOLDER}/ld_sentstrike_count/${ACTIPFILENAME}"
	sed -i -E "s/(^.*(#|m)${ip}\b.*)/${ASR_GET_LINE_CLEAR_STRIKE}/g" "/tmp/$RANDOMGET"
	rm -f "/tmp/${LDTEMPFOLDER}/ld_state_counter/${ACTIPFILENAME}#"
}
act_peer_action(){
	ACTIPFILENAME="$(panama ${ip})"
	if [ "$(eval "echo \$$(echo ${ACTIPFILENAME}_ID)")" != 1 ]; then
	eval "${ACTIPFILENAME}_ID=1"
	#Byte
	byte_act1="$(echo $(echo "${ACTIVE_PEER_GET1}"|grep -E "\b${ip}\b"|awk '{printf $2 "\n"}')|sed "s/ /+/g")"
	byte_act1="$(( byte_act1 ))"
	byte_act2="$(echo $(echo "${ACTIVE_PEER_GET2}"|grep -E "\b${ip}\b"|awk '{printf $2 "\n"}')|sed "s/ /+/g")"
	byte_act2="$(( byte_act2 ))"

	#Byte deltas
	byte_act_deltaA="$(( byte_act2 - byte_act1 ))"
	#Abs Values
	byte_act_deltaA="$(echo -n "$byte_act_deltaA"|sed -E "s/-//g")"

	case $byte_act_deltaA in
		0)
			#if a byte delta is zero...
			#... write a red X
			ACT_SUB_WRITE="${NOT_CONNECT_MARK}"
			act_peer_task
		;;
		*)
			if [ $byte_act_deltaA -ge $ACTIVE_BYTE_LIMIT ]; then
				#if a byte delta is greater than 800...
				#... write green dot.
				ACT_SUB_WRITE="${CONNECT_MARK}"
				act_peer_task
			elif [ $byte_act_deltaA -lt $ACTIVE_BYTE_LIMIT ] && [ $byte_act_deltaA -gt 0 ]; then
				#if a byte delta is greater than zero but less than 800...
				#... write magenta square.
				ACT_SUB_WRITE="${STANDBY_SYMB}"
				act_peer_task
			fi
		;;
	esac

	{
	if [ "$SENTINEL" = 1 ]; then
		#Standby counter: increments when status is in standby. Used by Sentinel for safe banning.
		if [ "$SENTBAN" = 1 ]; then
			if [ ! -d "/tmp/${LDTEMPFOLDER}/ld_act_standby_counter" ]; then mkdir "/tmp/${LDTEMPFOLDER}/ld_act_standby_counter"; fi
			GET_STATE="$(tail +1 "/tmp/${LDTEMPFOLDER}/ld_act_state/${ACTIPFILENAME}#")"
			STAND_COUNT_GET="$(tail +1 "/tmp/${LDTEMPFOLDER}/ld_act_standby_counter/${ACTIPFILENAME}#")"
			STAND_COUNT_GET_ADD_1=$(( STAND_COUNT_GET + 1 ))

			STAND_GET_LINE="$(tail +1 "/tmp/$RANDOMGET"|grep -E "(#|m)(${ip})\b")"
			STAND_STRIKE_MARK_COUNT="$(echo "$ASR_GET_LINE"|grep -Eo "(${STRIKE_MARK_SYMB}{1,})$"|wc -c)"
			if [ $STAND_STRIKE_MARK_COUNT -le 0 ]; then STAND_STRIKE_MARK_COUNT=0; else STAND_STRIKE_MARK_COUNT=$(( ASR_STRIKE_MARK_COUNT - 1 )); fi

			if [ $STAND_STRIKE_MARK_COUNT -gt 0 ]; then
				if [ "$GET_STATE" != "$CONNECT_MARK" ]; then
					echo "$STAND_COUNT_GET_ADD_1" > "/tmp/${LDTEMPFOLDER}/ld_act_standby_counter/${ACTIPFILENAME}#"
				else
					if [ $ASR_STRIKE_MARK_COUNT -gt $STRIKECOUNT_LIMIT ]; then :;
					else
						echo "0" > "/tmp/${LDTEMPFOLDER}/ld_act_standby_counter/${ACTIPFILENAME}#"
					fi
				fi
			fi
		fi

		#Auto Strike Reset
		if [ "$STRIKERESET" = 1 ]; then
			#Make counter folder
			if [ ! -d "/tmp/${LDTEMPFOLDER}/ld_state_counter/" ]; then mkdir "/tmp/${LDTEMPFOLDER}/ld_state_counter"; fi
			#Make ASR_Lockfile folder
			if [ ! -d "/tmp/${LDTEMPFOLDER}/ld_act_lock" ]; then mkdir "/tmp/${LDTEMPFOLDER}/ld_act_lock"; fi

			#Counter Establish
			if ! [ -f "/tmp/${LDTEMPFOLDER}/ld_state_counter/${ACTIPFILENAME}#" ]; then
				STAT_COUNT=0 #When zero,
			else
				STAT_COUNT="$(tail +1 "/tmp/${LDTEMPFOLDER}/ld_state_counter/${ACTIPFILENAME}#")" #Have Sentinel reference this file before banning
			fi

			ASR_COUNTER_INCREMENT_LIMIT=1

			#Get Strike count
			ASR_GET_LINE="$(tail +1 "/tmp/$RANDOMGET"|grep -E "(#|m)(${ip})\b")"
			ASR_STRIKE_MARK_COUNT="$(echo "$ASR_GET_LINE"|grep -Eo "(${STRIKE_MARK_SYMB}{1,})$"|wc -c)"
			if [ $ASR_STRIKE_MARK_COUNT -le 0 ]; then ASR_STRIKE_MARK_COUNT=0; else ASR_STRIKE_MARK_COUNT=$(( ASR_STRIKE_MARK_COUNT - 1 )); fi
			
			PENALTY_MAX=60 #Penalty cannot go over 60.
			PENALTY=$(( ASR_STRIKE_MARK_COUNT / 5 * 10 )) #Penalizes frequent strikes by increasing zero-strike interval to reset strike count
			if [ $PENALTY -ge 60 ]; then PENALTY=60; fi

			#Write increment to counter. Significant data transfer happening. Stall Sentinel banning
			STAT_COUNT_ADD_1=$(( STAT_COUNT + 1 ))

			if [ $ASR_STRIKE_MARK_COUNT -gt 0 ]; then
				echo -n "$STAT_COUNT_ADD_1" > "/tmp/${LDTEMPFOLDER}/ld_state_counter/${ACTIPFILENAME}#"
			fi

			#Reset Sentinel Strikes
			STAT_COUNT_LIMIT_PLUS_PEN=$(( STAT_COUNT_LIMIT + PENALTY ))
			IN_LOBBY_COUNT="$(grep -c "~" "/tmp/${LDTEMPFOLDER}/in_lobby/${ACTIPFILENAME}")" #In_Lobby counter
			if [ $STAT_COUNT -ge $STAT_COUNT_LIMIT_PLUS_PEN ] && ! { [ "$SENTBAN" = 1 ] && [ $ASR_STRIKE_MARK_COUNT -ge $STRIKECOUNT_LIMIT ];} && [ ! -f "/tmp/${LDTEMPFOLDER}/ld_act_lock/${ACTIPFILENAME}" ]; then
				#Make ASR_Lockfile for peer.
				touch "/tmp/${LDTEMPFOLDER}/ld_act_lock/${ACTIPFILENAME}"
				ASR_GET_LINE_CLEAR_STRIKE="$(echo -n "$ASR_GET_LINE"|sed -E "s/(${STRIKE_MARK_SYMB}{1,})$//g"|grep -Eo "^.*#"|sed -E "s/(.\[[0-9]{1}\;[0-9]{2}m){1,}(${ip}\b)/\2/g")"
				if { echo "$ASR_GET_LINE"|grep -Eoq "${STRIKE_MARK_SYMB}"; }; then #Only act if strike marks are found
					delete_strikes
					wait $!
				else
					rm -f "/tmp/${LDTEMPFOLDER}/ld_state_counter/${ACTIPFILENAME}#"
				fi
				rm -f "/tmp/${LDTEMPFOLDER}/ld_act_lock/${ACTIPFILENAME}"
			fi; wait $!
			if [ $IN_LOBBY_COUNT -ge 10 ]; then
				delete_strikes; "/tmp/${LDTEMPFOLDER}/in_lobby/${ACTIPFILENAME}"
			fi #In_Lobby counter
		fi
	fi
	} &
	eval "${ACTIPFILENAME}_ID=0"
	fi
}
AP_ID_ON=0
active_peer_id(){
	STAT_COUNT_LIMIT=60 #80 #Value when Sentinel will automatically reset strikes against peer. Approximately in seconds when regular data transfer occurs.

	while [ $AP_ID_ON != 1 ]; wait &> /dev/null; do
		if [ $AP_ID_ON != 1 ]; then
			#wait $AP_PID
			AP_ID_ON=1
			ACTIVE_BYTE_LIMIT=2000 #1000
			{
				#usleep corrections
				if [ $USLEEP_EXISTS = 1 ]; then ACTIVE_BYTE_LIMIT=$(( ACTIVE_BYTE_LIMIT / USLEEP_DIVSCALE ));fi

				if [ ! -d "/tmp/${LDTEMPFOLDER}/ld_act_state" ]; then mkdir "/tmp/${LDTEMPFOLDER}/ld_act_state"; fi

				#Get Values
				ACTIVE_PEER_GET1="$(tail +1 "/tmp/${LDTEMPFOLDER}/ldacceptval1"))"
				ACTIVE_PEER_GET2="$(tail +1 "/tmp/${LDTEMPFOLDER}/ldacceptval2")"
				ALLOWED_PEERS_LIST="$(grep -v "${RESPONSE3}" "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")"

				if [ "$ALLOWED_PEERS_LIST" = "" ]; then write_null_to_log; fi

				#Do Math
				{
					for ip in $ALLOWED_PEERS_LIST; do
						act_peer_action; export ACT_PEER_PID=$!
					done & #; wait $!
				} 2> /dev/null
				wait $!
				if [ "$WRITE_NULL" = 1 ]; then
					write_null_to_log
					WRITE_NULL=0
					sleep 1
				fi
				AP_ID_ON=0
			}; export AP_PID=$!
		fi
	done 2> /dev/null &
}
if [ $POPULATE = 1 ]; then :
else
	active_peer_id &> /dev/null & #ACT_PEER_PID=$!
fi
##### ACTIVE PEER INDICATOR #####
#==========================================================================================================
#42Kmi LagDrop Monitor
spinnertime=20000
SYMB='\ | / -'
SPIN_ON=0
spinner(){
	kill -9 $SPIN_PID &> /dev/null
	kill -9 $SPIN_PIDD &> /dev/null
	while [ $SPIN_ON != 1 ]; wait &> /dev/null; do
	if [ $SPIN_ON != 1 ]; then
	{
	wait $SPIN_PIDD
	SPIN_ON=1
		for char in $SYMB; do
			printf "${CLEARLINE}${RED}$char \r${NC}"; usleep $spinnertime
			printf "${CLEARLINE}${YELLOW}$char \r${NC}"; usleep $spinnertime
			printf "${CLEARLINE}${GREEN}$char \r${NC}"; usleep $spinnertime
			printf "${CLEARLINE}${BLUE}$char \r${NC}"; usleep $spinnertime
		done
		wait $!
	}; SPIN_PIDD=$!
	SPIN_ON=0
	else
	wait $SPIN_PIDD
	fi
	done
}
echo -e "$REFRESH"
{
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
	if [ -f "$DIR"/42Kmi/bancountry.txt ]; then BC="$(echo -e " ${LIGHTRED}BC${NC}")"; fi

	if [ $SMARTMODE = 1 ]; then SMARTON="$(echo " | SMART MODE")"; SMARTCOL="$(printf "\t")S. PING$(printf "\t")S. TR"; fi
	if [ $SHOWLOCATION = 1 ]; then LOCATION="$(echo " | LOCATE${BC}")"; LOCATECOL="$(printf "\t")LOCATION"; fi

	display(){
		##### LogCounts #####
		if [ -f "/tmp/$RANDOMGET" ]; then
			TOTALCOUNT="$(grep -Evi "^[a-z]]" "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed -E "/^(\s*)?$/d"|wc -l)"
		fi
		if [ ! -f "/tmp/$RANDOMGET" ]; then
			BLOCKCOUNT="0"
			ACCEPTCOUNT="0"
		else
			BLOCKCOUNT="$(grep -Evi "^[a-z]]" "/tmp/$RANDOMGET"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|sed -E "/^(\s*)?$/d"|grep -Foc "${RESPONSE3}")"
			ACCEPTCOUNT=$(( TOTALCOUNT - BLOCKCOUNT ))
			if [ $ACCEPTCOUNT -lt 0 ]; then ACCEPTCOUNT="0"; fi #correction
		fi

		##### LogCounts #####
		if [ $SENTON_SIG = 1 ]; then SENTON="$(echo -e " | ${BLUE}[${NC}${MAGENTA}S${SENT_APPEND}${VV_APPEND}${SENT_ALL_PROTOCOL}${SENT_LAGG_ON}${NC}${BLUE}]${NC}")"; fi
		##### BL/WL/TW? #####

		if [ -f "/tmp/$RANDOMGET" ] && grep -Eo "^(\s*)?$" "/tmp/$RANDOMGET"; then sed -i -E "/^(\s*)?$/d" "/tmp/$RANDOMGET"; fi

		printf "${CURSOR_ORIGIN}${CLEARSCROLLBACK}"
		echo -e " ${CYAN}42Kmi LagDrop${NC} | ${LOADEDFILTER}${BL}${WL}${TW} | Allowed: ${MAGENTA}$ACCEPTCOUNT${NC} Blocked: ${MAGENTA}$BLOCKCOUNT${NC}${SMARTON}${LOCATION}${SENTON}\n"
		printf "%0s\t" "" TIME PEER "" PING TR RESULT"${SMARTCOL}""${LOCATECOL}"; wait $!
		echo -en "\n"

		if [ -f "/tmp/$RANDOMGET" ] && [ -s "/tmp/$RANDOMGET" ]; then
			LOG="$(tail +1 "/tmp/$RANDOMGET"|sed -E -e "/^(\s*)?$/d" -e "/^(\s*)?[a-zA-Z]$/d")"

			{
				for line in $LOG; do
					{
						#Count strikes as numbers
						if { echo "$line" | grep -Eoq "(${STRIKE_MARK_SYMB}{1,}$)"; }; then
							STRIKE_MARK_COUNT="$(echo -n "$line"|grep -Eo "(${STRIKE_MARK_SYMB}{1,})$"|wc -c)"
							STRIKE_MARK_COUNT=$(( STRIKE_MARK_COUNT - 1 ))
							#corrections
							STRIKE_MARK_COUNT="$(echo -en "${BG_RED}${WHITE}${STRIKE_MARK_COUNT}${NC}")"
							sed -E "s/(${STRIKE_MARK_SYMB}{1,})$/${BG_RED}${STRIKE_MARK_COUNT}${NC}/g"
						fi

						#Active Peer Symbol Substitution
						ACT_PEER="$(echo "$line"|sed -E "s/.\[[0-9]{1}(\;[0-9]{2})?m//g"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")"
						ACT_FILE_GET="$(panama $ACT_PEER)#"

						if ! { echo "$line"|grep -q "${RESPONSE3}"; }; then
							#Is not a block
							if [ -f "/tmp/${LDTEMPFOLDER}/ld_act_state/${ACT_FILE_GET}" ]; then
								ACT_SUB="$(tail +1 "/tmp/${LDTEMPFOLDER}/ld_act_state/${ACT_FILE_GET}")"
							else
								ACT_SUB="${PENDING}"
							fi
						else
							#Is a block
							ACT_SUB="${NOT_CONNECT_MARK}"
						fi

						{ echo -en "${line}"|sed -E -e "s/^${ACT_PLACEHOLD}/${ACT_SUB}/" -e "s/%/ /g" -e "s/#(${STRIKE_MARK_SYMB}{1,})$/ ${STRIKE_MARK_COUNT}/g" -e "s/(#){1,}/#/g" -e "s/#/\t/g" -e "/^\s*$/d" -e '/txt/d'|sort -n|sed -E -e "s/\"([0-9]{1,})\"/$(echo -en ${BLUE})/g" -e "s/(([0-9]{4,})(\-([0-9]{1,2})){2}.([0-9]{1,2}\:?){3})/\1$(echo -en ${NC})/g" -e 's/\.[0-9]{1,3}\.[0-9]{1,3}\./.xx.xx./g' -e "s/([0-9])ms/\1/g" -e "s/(\t){1,}/\t/g"; }
					}
				done &
			}|grep -nE ".*"|sed -E -e "s/^([0-9]{1,}):/\1.$(echo -en "${HIDE}") $(echo -en "${NC}")/g" -e "s/[0-9]{4,}(-[0-9]{2}){2}\s//g" -e "s/\, \, /, /g" -e "s/\, 0(null)?0\,/,/g" -e "s/^([1-9]\.)/ &/g" -e "s/${STRIKE_MARK_SYMB}//g" &

		else
			if [ $POPULATE = 1 ] || { [ ! -f "/tmp/$RANDOMGET" ] || [ ! -s "/tmp/$RANDOMGET" ]; }; then
				echo -e "$LOG_MESSAGE"
			fi
		fi
		wait $!
	}
	MON_ON=0
	monitor(){
		##### New Monitor Display #####
		display; DISP_PID=$!
			wait $!
			wait $ACT_PEER_PID
			wait $LD_PID

		( spinner & fg ); SPIN_PID=$!
		while [ $MON_ON != 1 ]; wait &> /dev/null; do
		if [ $MON_ON != 1 ]; then
			wait $MON_PID
			MON_ON=1
			wait $!
			{
				ALLOWED_PEERS_LIST="$(tail +1 "/tmp/$RANDOMGET"|grep -Eo "\b(([0-9]{1,3}\.){3})([0-9]{1,3})\b")"
				LOG_LINE_COUNTA="$(grep -Evic "^.*$" "/tmp/$RANDOMGET")"
				LOG_LINE_COUNTA="$(( LOG_LINE_COUNTA - 1 ))"
				#sentinel_bans &
				cleansentinel &
				if [ -f "/tmp/$RANDOMGET" ]; then
					ATIME="$(date +%s -r "/tmp/$RANDOMGET")"
					ASIZE="$(tail +1 "/tmp/$RANDOMGET"|wc -c)"
					if [ "$ATIME" != "$LTIME" ]; then
						if [ "$ASIZE" != "$LSIZE" ]; then
							kill -9 $DISP_PID
							printf "$CURSOR_ORIGIN"|display; DISP_PID=$!
							LTIME=$ATIME && LSIZE=$ASIZE
						fi
					else
						if [ -f "/tmp/$RANDOMGET" ] && [ -s "/tmp/$RANDOMGET" ]; then
							if [ "$LOG_LINE_COUNTA" -gt "$LOG_LINE_COUNTL" ]; then
								kill -9 $DISP_PID
								printf "$CURSOR_ORIGIN"|display; DISP_PID=$!
								LTIME=$ATIME && LSIZE=$ASIZE
							fi
						fi
					fi
				fi
				printf "$CLEARLINE"
				LOG_LINE_COUNTL=$LOG_LINE_COUNTA
			}; MON_PID=$!
			wait
			MON_ON=0
		else
		wait $MON_PID
		fi
		if [ $LOG_LINE_COUNTL -gt 10 ]; then sleep $(( LOG_LINE_COUNTL / 10 ));else sleep 3; fi
		done
		##### New Monitor Display #####
	}
	( monitor 2> /dev/null )
}; MONITOR_PID=$!
fi 2> /dev/null

#fi 2> ""${DIR}"/42Kmi/lderrorlog.txt"

##### Ban SLOW Peers #####
##### 42Kmi International Competitive Gaming #####
##### 42Kmi.com #####
##### LagDrop.com #####
} 2> /dev/null #; wait $$

#betatester stuff, uncomment to secure
#fi