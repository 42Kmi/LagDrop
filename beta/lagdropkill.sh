#!/bin/sh
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
##### Kill LagDrop #####
#kill -9 `ps -w | grep -F "lagdrop" | grep -vF "ps" | grep -oE "[0-9]{1,}" | sed -n 1p` &> /dev/null
kill -9 `ps -w | grep -F "lagdrop" | grep -vF "ps" |sed -E "s/root.*//g"| grep -oE "[0-9]{1,}"` &> /dev/null
##### Kill LagDrop #####
