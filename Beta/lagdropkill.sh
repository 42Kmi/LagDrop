#!/bin/sh
#Version 2.0.5
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
##### Kill LagDrop #####
#Terminates all running scripts with "lagdrop" in its name
exec $(`ps -w | grep -E ".*lagdrop.*" | grep -vF "ps" |sed -E "s/root.*//g"| grep -oE "[0-9]{1,}"|sed -E "s/^/kill -9 /g"`) &> /dev/null
exec $(`ps -w | grep -E ".*lagdrop.*" | grep -vF "ps" |sed -E "s/root.*//g"| grep -oE "[0-9]{1,}"|sed -E "s/^/killall -9 /g"`) &> /dev/null
##### Kill LagDrop #####
