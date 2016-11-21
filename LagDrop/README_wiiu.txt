42Kmi LagDrop
Avoid laggy matches in peer-to-peer matchmaking online games, such as Super Smash Bros. for Wii U.

LagDrop in action at https://www.youtube.com/watch?v=6g9MiaE-2k0

How it works 
________________
Games such as Super Smash Bros for Wii U utilizes peer-to-peer matchmaking, meaning that opponents connect directly to each other for matches and do not rely on some far away server. This script scans for peer IP addresses connected to your Wii U and pings them with the details specified in options.txt file. Any IP address that returns an average ping time higher than your specified limit is blocked from your Wii U. Ping times above your limit are anticipated to be laggy, so why not prevent potential lag?

LagDrop is natively console-agnostic. Console specific scripts reflect console-specific severs ignored before testing for pingd times. IE, if the conles IP address in option.txt file for the lagdrop_wiiu script is set to a PlayStation 4 IP address, LagDrop will run for the PlayStation 4, however Sony IP addresses will still be scanned as the lagdrop_wiiu script is set to ignore Nintendo sever IP addresses.

How to use
________________
Required:
·Router with DD-WRT or other aftermarket firmware capable of running scripts.
·SCP client to upload script and edit options file (e.g., WinSCP)


Optional:
· USB 2.0 LAN adapter for wired Wii U 
· SSH command-line interface (e.g., Putty) 


This guide uses DD-WRT as reference and assumes that you are familiar with DD-WRT or similar firmware. Do the equivalent of whatever custom firmware is on your router.


***This is not intended or expected to harm your router, however, 42Kmi bears no responsibility for any damages that may occur.*** 
***LagDrop is only intended to be used for automated lag-based peer blocking/filtering. Any use of, or modification to, LagDrop outside of its original intended scope is prohibited.***



1. Go to the DD-WRT web interface. Go “Services” and find “Static Leases.” Click Add.
2. Set Wii U to static IP address on Router, include “WiiU” (or your console identifier [wiiu, xboxone, 3ds, etc.]) in the assigned hostname. Scroll to bottom of page and click “Apply Settings.” 
3. Place lagdrop.sh in jffs folder
4. In DD-WRT, go to Administration > Commands, and run the appropriate Lagdrop for your system, eg: “sh /jffs/lagdrop_wii.sh” (or run “/jffs/lagdrop.sh” from SSH command-line interface). Initial files and directories will be created. Wii U static IP will be populated into options.txt file (this will be first listed static IP address with WiiU in the hostname).
5. In SCP client, navigate to /jffs/42Kmi and open and configure the options.txt file
6. In Administration, Cron Add "*/1 * * * * root /bin/sh /jffs/runlagdrop.sh SUFFIX" without quotes, where SUFFIX is the suffix of your intended LagDrop script, eg: wiiu for will run lagdrop_wiiu.sh
7. Play Smash Bros for Wii U online and enjoy! Be Glorious!

Options.txt file: the parameters
1. WiiU [console name]: your Wii U’s static IP. This is filled by default after setting a static IP for your Wii U. You can change this to the Wii U static IP of your choice.
2. PingLimit: This is the maximum millisecond ping time allowed before blocking the peer. Default is 90.
3. Count: This is the number of packets to send to peer. Default is 5.
4. Size: This is the size of the packet in bytes. This is really a test of the peer’s bandwidth. Default is 1024
5. Mode: Determine who to block by different tests. 1 for Ping, 2 for TraceRoute, 3 for Ping or TraceRoute, 4 for Ping and TraceRoute. Default is 1.
6. Max TTL: Maximum TTL for the TraceRoute test. Default is 10
7. Probes: Number of times each node is checked during TraceRoute. Default is 5
8. TraceLimit: The limit of the TraceRoute time average. Values higher than this are blocked. Default is 20
9. ACTION: Action select. Choose to REJECT (0 or REJECT) or DROP (1 or DROP) peers Default is REJECT.
10. CHECKPACKETLOSS: When enabled, will check ping for packet loss percentage (PACKETLOSSLIMIT). If packet loss is greater than the specified limit, then the peer is blocked. If no packet loss is detected, LagDrop proceeds with the other tests. Set to ON, on, 1, YES, or yes to enable. Default is OFF.
11. PACKETLOSSLIMIT: Value to determine blocking for CHECKPACKETLOSS. Default is 80.
12. SENTINEL: checks most recent allowed peer for packet loss. If packet loss occurs, peer is blocked. Uses PACKETLOSSLIMIT parameter. Default OFF/NO/Disable/0
13. CLEARALLOWED: periodically clears older allowed peers no longer connected to router. Default is OFF/NO/Disable/0
14. CLEARBLOCKED: periodically clears older blocked peers no longer connected to router. Default isOFF/NO/Disable/0
15. CLEARLIMIT: Number of entries per ALLOWED/BLOCKED before clearing old entries begins. Default is 10
16. SWITCH: The master switch to enable (1 or ON) or disable (0 OFF) LagDrop. Default is ON.

Add "*/1 * * * * root /bin/sh /jffs/runlagdrop.sh SUFFIX" without quotes to cron to run your LagDrop script and keep it alive. SUFFIX is the suffix to your desired LagDrop script, eg: "*/1 * * * * root /bin/sh /jffs/runlagdrop.sh wiiu" for lagdrop_wiiu.sh

whitelist.txt and blacklist.txt files
	User can create this regex-formatted to exclude (whitelist.txt) or always block (blacklist.txt) IP addresses from LagDrop. IP addresses can be added in formatted single lines, which IP address separated by pipes (|) (like Regular Expression) or they can be added to separate lines. Titles/Headings can be added to group IP addresses, title/headings must be on one line surrounded by # (eg, #This is a Heading#). 
	
	Eg: ^192\.168\. will filter all addresses begining with 192.168 from being checked against LagDrop.
	^192\.1(([0-3]{1}))0\. will filter addresses begining with 192.100, 192.110, 192.120, and 192.130
