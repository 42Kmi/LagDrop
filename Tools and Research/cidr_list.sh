#!/bin/sh
#42Kmi
#Expand CIDR formatted IP address to full range list.
#CIDR_RANGE="aaa.bbb.ccc.ddd/xx"

if [ "$1" = "" ]; then
	read -p "Enter CIDR IP: " userenter
else
	userenter="$1"
fi

IP=$(echo "$userenter"|sed -E "s/(\.|\\|\/)/\n/g")

aaa="$(echo $IP|awk '{printf $1}')"
bbb="$(echo $IP|awk '{printf $2}')"
ccc="$(echo $IP|awk '{printf $3}')"
ddd="$(echo $IP|awk '{printf $4}'|sed -E "s/\/.*$//g")"
xx="$(echo $IP|awk '{printf $4}'|sed -E "s/^.*\///g")"

##### Functions #####
geniplist(){
aaa_add_diff=$(( aaa + aaa_diff ))
bbb_add_diff=$(( bbb + bbb_diff ))
ccc_add_diff=$(( ccc + ccc_diff ))
ddd_add_diff=$(( ddd + ddd_diff ))
#aaa values
for aaav in $(i=$aaa; while [[ $i -le $aaa_add_diff ]]; do echo "$i"; let i++; done); do
	#bbb values
	for bbbv in $(j=$bbb; while [[ $j -le $bbb_add_diff ]]; do echo "$j"; let j++; done); do
		#ccc values
		for cccv in $(k=$ccc; while [[ $k -le $ccc_add_diff ]]; do echo "$k"; let k++; done); do
			#ddd values
			for dddv in $(l=$ddd; while [[ $l -le $ddd_add_diff ]]; do echo "$l"; let l++; done); do 
				echo "$aaav.$bbbv.$cccv.$dddv" #List all IPs in range sequentially. Wow!
			done
		done
	done
done
}
##### Functions #####

#Address Differences
{
case "$xx" in
	# ddd
	32) aaa_diff=0; bbb_diff=0;ccc_diff=0;ddd_diff=0
	;;
	31) aaa_diff=0;bbb_diff=0;ccc_diff=0;ddd_diff=1
	;;
	30) aaa_diff=0;bbb_diff=0;ccc_diff=0;ddd_diff=3
	;;
	29) aaa_diff=0;bbb_diff=0;ccc_diff=0;ddd_diff=7
	;;
	28) aaa_diff=0;bbb_diff=0;ccc_diff=0;ddd_diff=15
	;;
	27) aaa_diff=0;bbb_diff=0;ccc_diff=0;ddd_diff=31
	;;
	26) aaa_diff=0;bbb_diff=0;ccc_diff=0;ddd_diff=63
	;;
	25) aaa_diff=0;bbb_diff=0;ccc_diff=0;ddd_diff=127
	;;
	24) aaa_diff=0;bbb_diff=0;ccc_diff=0;ddd_diff=255
	;;
	#ccc
	23) aaa_diff=0;bbb_diff=0;ccc_diff=1;ddd_diff=255
	;;
	22) aaa_diff=0;bbb_diff=0;ccc_diff=3;ddd_diff=255
	;;
	21) aaa_diff=0;bbb_diff=0;ccc_diff=7;ddd_diff=255
	;;
	20) aaa_diff=0;bbb_diff=0;ccc_diff=15;ddd_diff=255
	;;
	19) aaa_diff=0;bbb_diff=0;ccc_diff=31;ddd_diff=255
	;;
	18) aaa_diff=0;bbb_diff=0;ccc_diff=63;ddd_diff=255
	;;
	17) aaa_diff=0;bbb_diff=0;ccc_diff=127;ddd_diff=255
	;;
	16) aaa_diff=0;bbb_diff=0;ccc_diff=255;ddd_diff=255
	;;
	15) aaa_diff=0;bbb_diff=1;ccc_diff=255;ddd_diff=255
	;;
	#bbb
	14) aaa_diff=0;bbb_diff=3;ccc_diff=255;ddd_diff=255
	;;
	13) aaa_diff=0;bbb_diff=7;ccc_diff=255;ddd_diff=255
	;;
	12) aaa_diff=0;bbb_diff=15;ccc_diff=255;ddd_diff=255
	;;
	11) aaa_diff=0;bbb_diff=31;ccc_diff=255;ddd_diff=255
	;;
	10) aaa_diff=0;bbb_diff=63;ccc_diff=255;ddd_diff=255
	;;
	9) aaa_diff=0;bbb_diff=127;ccc_diff=255;ddd_diff=255
	;;
	8) aaa_diff=0;bbb_diff=255;ccc_diff=255;ddd_diff=255
	;;
	7) aaa_diff=1;bbb_diff=255;ccc_diff=255;ddd_diff=255
	;;
	6) aaa_diff=3;bbb_diff=255;ccc_diff=255;ddd_diff=255
	;;
	#aaa
	5) aaa_diff=7;bbb_diff=255;ccc_diff=255;ddd_diff=255
	;;
	4) aaa_diff=15;bbb_diff=255;ccc_diff=255;ddd_diff=255
	;;
	3) aaa_diff=31;bbb_diff=255;ccc_diff=255;ddd_diff=255
	;;
	2) aaa_diff=63;bbb_diff=255;ccc_diff=255;ddd_diff=255
	;;
	1) aaa_diff=127;bbb_diff=255;ccc_diff=255;ddd_diff=255
	;;
	0) aaa_diff=255;bbb_diff=255;ccc_diff=255;ddd_diff=255
	;;
	esac
}
geniplist
