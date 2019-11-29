#!/bin/sh
cleanall(){
PROC="$(ps|grep -E "$(echo $(ps|grep "${0##*/}"|grep -Ev "^(\s)?($$)\b"|grep -Ev "(\[("kthreadd"|"ksoftirqd"|"kworker"|"khelper"|"writeback"|"bioset"|"crypto"|"kblockd"|"khubd"|"kswapd"|"fsnotify_mark"|"deferwq"|"scsi_eh_"|"usb-storage"|"cfg80211"|"jffs2_gcd_mtd3").*\])"|grep -Ev "SW(.?)"|awk '{printf $3" "$4"|\n"}'|awk '!a[$0]++')|sed -E 's/.$//')"|grep -Ev "\b($$)\b"|grep -v "rm"|grep -Eo "^(\s*)?[0-9]{1,}")"

#Empty LDKTA table and adjust geomem and pingmem files
	misterclean(){
		kill -9 $(ps|grep "${0##*/}"|grep -Eo "^(\s*)?[0-9]{1,}\b"|grep -Ev "\b($$)\b") &> /dev/null #&

		for process in $PROC; do
			{ rm -rf "/proc/$process" 2>&1 >/dev/null 2> /dev/null; } &> /dev/null #&
		done &> /dev/null #&
	}
( n=0; while [[ $n -lt 5 ]]; do { misterclean & } ; n=$((n+1)); done )
wait $!
kill -9 $(ps|grep "${0##*/}"|grep -Eo "^(\s*)?[0-9]{1,}")
exit
} &> /dev/null
trap cleanall 0 1 2 3 6 9 15

SCRIPTNAME="${0##*/}"
DIR="${0%\/*}"

if [ "$1" != "" ]; then
NAME="$1_$(date +%Y-%m-%d_%H-%M-%S)"
else
NAME="$(date +%Y-%m-%d_%H-%M-%S)"
fi

SUBFOLDER="sentinel_data"

if ! [ -d ""${DIR}"/42Kmi/"${SUBFOLDER}"" ]; then mkdir ""${DIR}"/42Kmi/"${SUBFOLDER}""; fi

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

#HEADER="IP TIME bytediffA bytediffB BYTESUM BYTEDIFF BYTEAVG BYTEDIFFSQ BYTEXSQ"
HEADER="IP\tTIME\tbytediffA\tbytediffB\tBYTESUM\tBYTEDIFF\tBYTEAVG\tBYTEDIFFSQ\tBYTEXSQ"

echo -e "${CYAN}42Kmi LagDrop Sentinel Tool${NC} | Press Ctrl+C to exit"

# Sentinel Check
workitout(){

	#Settings
	SENTINELDELAYBIG=1
	SENTINELDELAYSMALL=1
	
	#PACKET_OR_BYTE="$1"
	
	case "$1" in
		*)
			PACKET_OR_BYTE=1 #1 for packets, 2 for bytes
		;;
		2)
			PACKET_OR_BYTE=2 #1 for packets, 2 for bytes
		;;
	esac
	
	ABS_VAL=1
	
	#if [ $packet_bytediffA != 0 ] || [ $byte_bytediffA != 0 ]; then sleep $SENTINELDELAYBIG ; fi
	
	if [ "$PACKET_OR_BYTE" = 1 ]; then
		MODESET="PACKET"
		{
		byte1="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${ip}\b"|awk '{printf $1}')"
		sleep $SENTINELDELAYSMALL
		byte2="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${ip}\b"|awk '{printf $1}')"
		sleep $SENTINELDELAYBIG
		byte3="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${ip}\b"|awk '{printf $1}')"
		sleep $SENTINELDELAYSMALL
		byte4="$(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${ip}\b"|awk '{printf $1}')"
		} &
		elif [ "$PACKET_OR_BYTE" = 2 ]; then
		MODESET="BYTE"
		{
		byte1="$(( $(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${ip}\b"|awk '{printf $2}') / 1000 ))"
		sleep $SENTINELDELAYSMALL
		byte2="$(( $(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${ip}\b"|awk '{printf $2}') / 1000 ))"
		sleep $SENTINELDELAYBIG
		byte3="$(( $(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${ip}\b"|awk '{printf $2}') / 1000 ))"
		sleep $SENTINELDELAYSMALL
		byte4="$(( $(iptables -xvnL LDACCEPT|tail +3|grep -E "\b${ip}\b"|awk '{printf $2}') / 1000 ))"
		}
	fi &
	
	#if [ "$PACKET_OR_BYTE" = 1 ]; then
		#MODESET="PACKET"
		#Math get Packets
		{
		packet_byte1="$({ iptables -xvnL LDACCEPT; wait $!; }|tail +3|grep -E "\b${ip}\b"|awk '{printf $1}')"
		byte_byte1="$(( $({ iptables -xvnL LDACCEPT; wait $!; }|tail +3|grep -E "\b${ip}\b"|awk '{printf $2}') / 1000 ))"
		sleep $SENTINELDELAYSMALL; wait $!
		packet_byte2="$({ iptables -xvnL LDACCEPT; wait $!; }|tail +3|grep -E "\b${ip}\b"|awk '{printf $1}')"
		byte_byte2="$(( $({ iptables -xvnL LDACCEPT; wait $!; }|tail +3|grep -E "\b${ip}\b"|awk '{printf $2}') / 1000 ))"
		sleep $SENTINELDELAYBIG; wait $!
		packet_byte3="$({ iptables -xvnL LDACCEPT; wait $!; }|tail +3|grep -E "\b${ip}\b"|awk '{printf $1}')"
		byte_byte3="$(( $({ iptables -xvnL LDACCEPT; wait $!; }|tail +3|grep -E "\b${ip}\b"|awk '{printf $2}') / 1000 ))"
		sleep $SENTINELDELAYSMALL; wait $!
		packet_byte4="$({ iptables -xvnL LDACCEPT; wait $!; }|tail +3|grep -E "\b${ip}\b"|awk '{printf $1}')"
		byte_byte4="$(( $({ iptables -xvnL LDACCEPT; wait $!; }|tail +3|grep -E "\b${ip}\b"|awk '{printf $2}') / 1000 ))"
		}
	#fi
	wait
	if [ $ABS_VAL = 1 ]; then
		#Packet
		packet_bytediffB=$(echo "$(( (( $packet_byte4 - $packet_byte3 )) / $SENTINELDELAYSMALL ))"|sed "s/-//g")
		packet_bytediffA=$(echo "$(( (( $packet_byte2 - $packet_byte1 )) / $SENTINELDELAYSMALL ))"|sed "s/-//g")
		#Bytes
		byte_bytediffB=$(echo "$(( (( $byte_byte4 - $byte_byte3 )) / $SENTINELDELAYSMALL ))"|sed "s/-//g")
		byte_bytediffA=$(echo "$(( (( $byte_byte2 - $byte_byte1 )) / $SENTINELDELAYSMALL ))"|sed "s/-//g")
		packet_BYTESUM=$(echo $(( $packet_bytediffB + $packet_bytediffA ))|sed "s/-//g")
	else
		#packet
		packet_bytediffA=$(echo "$(( (( $packet_byte2 - $packet_byte1 )) / $SENTINELDELAYSMALL ))")
		packet_bytediffB=$(echo "$(( (( $packet_byte4 - $packet_byte3 )) / $SENTINELDELAYSMALL ))")
		#byte
		byte_bytediffA=$(echo "$(( (( $byte_byte2 - $byte_byte1 )) / $SENTINELDELAYSMALL ))")
		byte_bytediffB=$(echo "$(( (( $byte_byte4 - $byte_byte3 )) / $SENTINELDELAYSMALL ))")
		packet_BYTESUM=$(( $packet_bytediffB + $packet_bytediffA ))
	fi
	
	#Math Packets
	if [ $packet_bytediffA = "" ]; then packet_bytediffA=0; fi
	if [ $packet_bytediffB = "" ]; then packet_bytediffB=0; fi
	packet_BYTEDIFF=$(echo "$(( $packet_bytediffB - $packet_bytediffA ))"|sed "s/-//g")
	packet_BYTEAVG=$(( $packet_BYTESUM / 2 ))

	if [ $packet_BYTEAVG = 0 ]; then packet_BYTEAVG=1; fi
	packet_BYTEDIFFSQ=$(( $packet_BYTEDIFF * $packet_BYTEDIFF ))
	packet_BYTEXSQ=$(( $packet_BYTEDIFFSQ / $packet_BYTEAVG ))

	#Math Bytes
	if [ $byte_bytediffA = "" ]; then byte_bytediffA=0; fi
	if [ $byte_bytediffB = "" ]; then byte_bytediffB=0; fi
	byte_BYTEDIFF=$(echo "$(( $byte_bytediffB - $byte_bytediffA ))"|sed "s/-//g")
	byte_BYTESUM=$(( $byte_bytediffB + $byte_bytediffA ))
	byte_BYTEAVG=$(( $byte_BYTESUM / 2 ))

	if [ $byte_BYTEAVG = 0 ]; then byte_BYTEAVG=1; fi
	byte_BYTEDIFFSQ=$(( $byte_BYTEDIFF * $byte_BYTEDIFF ))
	byte_BYTEXSQ=$(( $byte_BYTEDIFFSQ / $byte_BYTEAVG ))

	ip=$(echo $ip|sed -E "s/([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/\1.xx.xx.\4/g")
	if [ $byte_BYTESUM != "" ]; then
		#Prints IP TIME bytediffA bytediffB BYTESUM BYTEDIFF BYTEAVG BYTEDIFFSQ BYTEXSQ
		echo -e "$(echo $ip)\t$(date +%X)\t${byte_bytediffA}\t${byte_bytediffB}\t${byte_BYTESUM}\t${byte_BYTEDIFF}\t${byte_BYTEAVG}\t${byte_BYTEDIFFSQ}\t${byte_BYTEXSQ}" >> ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_bytes.txt" &
	fi
	
	#Packet
	if [ $packet_BYTESUM != "" ]; then
		#Prints IP TIME bytediffA bytediffB BYTESUM BYTEDIFF BYTEAVG BYTEDIFFSQ BYTEXSQ
		echo -e "$(echo $ip)\t$(date +%X)\t${packet_bytediffA}\t${packet_bytediffB}\t${packet_BYTESUM}\t${packet_BYTEDIFF}\t${packet_BYTEAVG}\t${packet_BYTEDIFFSQ}\t${packet_BYTEXSQ}" >> ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_packet.txt" &
	fi
}

#Packet
if [ -f ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_packet.txt" ]; then
	if ! { grep -Eq "^(${HEADER})" ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_packet.txt"; }; then
	echo -e "${HEADER}\tPACKETS\t$(date)" >> ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_packet.txt"
	fi
	else
	echo -e "${HEADER}\tPACKETS\t$(date)" > ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_packet.txt"
fi

#Bytes
if [ -f ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_bytes.txt" ]; then
	if ! { grep -Eq "^(${HEADER})" ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_bytes.txt"; }; then
	echo -e "${HEADER}\tBYTES\t$(date)" >> ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_bytes.txt"
	fi
	else
	echo -e "${HEADER}\tBYTES\t$(date)" > ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_bytes.txt"
fi

while sleep 1; do
	wait

#===============================
	LIST=$(iptables -nL LDACCEPT|tail +3|awk '{printf $4 "\n"}')
	if [ "$LIST" != "" ]; then
		#echo -e "${BLUE}Sentinel Test | $(date)${NC}"
		echo -e "${BLUE}Entry written | $(date)${NC}"
#===============================

		for ip in $LIST; do
			workitout & #2> /dev/null
			#wait $!
		done 2> /dev/null &
		wait $!;kill -9 $! 2> /dev/null
		
		#for file in ; do
		if { grep -Eq "\t()\t" ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_bytes.txt"; }; then
			sed -E -i "s/\t()\t/\t0\t/g" ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_bytes.txt"
		fi

		if { grep -Eq "\t()\t" ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_packet.txt"; }; then
			sed -E -i "s/\t()\t/\t0\t/g" ""${DIR}"/42Kmi/"${SUBFOLDER}"/"${NAME}"_SentinelToolResults_packet.txt"
		fi
		#done
	echo "-------------------------------"
	fi 2> /dev/null
done
