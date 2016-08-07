42Kmi LagDrop

How it works
________________
Games such as Super Smash Bros for Wii U utilizes peer-to-peer matchmaking, meaning that opponents connect directly to each other for matches and do not rely on some far away server. This script scans for peer IP addresses connected to your Wii U and pings them with the details specified in options.txt file. Any IP address that returns an average ping time higher than your specified limit is blocked from your Wii U. Ping times above your limit are anticipated to be laggy, so why not prevent potential lag?

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


1. Go to the DD-WRT web interface. Go “Services” and find “Static Leases.” Click Add.
2. Set Wii U to static IP address on Router, include “WiiU” (or your console identifier [wiiu, xboxone, 3ds, etc.]) in the assigned hostname. Scroll to bottom of page and click “Apply Settings.” 
3. Place lagdrop.sh in jffs folder
4. In DD-WRT, go to Administration > Commands, and run  the appropriate Lagdrop for your system, eg: “sh /jffs/lagdrop_wii.sh” (or run “/jffs/lagdrop.sh” from SSH command-line interface). Initial files and directories will be created. Wii U static IP will be populated into options.txt file (this will be first listed static IP address with WiiU in the hostname).
5. In SCP client, navigate to /jffs/42Kmi and open and configure the options.txt file
6. Play Smash Bros for Wii U online and enjoy! Be Glorious!

Options.txt file: 4 parameters
WiiU: your Wii U’s static IP. This is filled by default after setting a static IP for your Wii U. You can change this to the Wii U static IP of your choice.
PingLimit: This is the maximum millisecond ping time allowed before blocking the peer. Default is 90.
Count: This is the number of packets to send to peer. Default is 5. This also controls the interval between script runs, (2 * COUNT_VALUE), in seconds.
Size: This is the size of the packet in bytes. This is really a test of the peer’s bandwidth. Default is 1024
Mode: Determine who to block by different tests. 1 for Ping, 2 for TraceRoute, 3 for Ping or TraceRoute, 4 for Ping and TraceRoute. Default is 1.
Max TTL: Maximum TTL for the TraceRoute test. Default is 10
Probes: Number of times each node is checked during TraceRoute. Default is 5
TraceLimit: The limit of the TraeRoute time average. Values higher than this are blocked. Default is 20
extraip.txt file
User can create this regex-formatted to filter additional IP addresses from LagDrop. All entries MUST be on the same line and separated by the pipe (|) with periods escaped with backslash \
Eg: ^192\.168\. will filter all addresses begining with 192.168 from being checked against LagDrop.
^192\.1(([0-3]{1}))0\. will filter addresses begining with 192.100, 192.110, 192.120, and 192.130
