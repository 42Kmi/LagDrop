#!/bin/sh
##### 42Kmi LagDrop, Written by 42Kmi. Property of 42Kmi, LLC. #####
##### Kill LagDrop #####
kill -9 `ps -w | grep -F "lagdrop" | grep -vF "ps" | grep -oE "[0-9]{1,5}" | sed -n 1p` &> /dev/null
##### Kill LagDrop #####
