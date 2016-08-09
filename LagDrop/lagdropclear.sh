#!/bin/sh
##### LagDrop iptables clear script. Clears LagDrop related iptables#####
##### Add this to cron to run at some interval. Execute this script to clear the LagDrop chains from iptables
iptables -F LDREJECT && iptables -F LDACCEPT