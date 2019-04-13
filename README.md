# 42Kmi LagDrop

![Super Smash Bros. Ultimate](https://i.imgur.com/FFhu9Pv.png)

Avoid laggy matches in any peer-to-peer matchmaking online games, such as Super Smash Bros. Ultimate, Street Fighter V, Dragon Ball FighterZ, and more!

## LagDrop 3.0.0 beta is still here! Still being finalized, but please check it out! New features include:
- Monitor to see LagDrop in action
- Unified script. If you can game on it, we got you. #OneForAll #Futureproof
- Location to see roughly where opponents are, with regional ban feature!
- Smart mode adjusts limits for best peers
- More!

Contact us if you're interested in testing Version 3.0.0!

What to expect in 3.0.0

![LagDrop Monitor](https://i.imgur.com/l4ODvaZ.png)


![LagDrop](http://i.imgur.com/GGJmYyr.png)

[See LagDrop in action!](https://www.youtube.com/watch?v=6g9MiaE-2k0)

[Preview LagDrop 3.0.0](https://youtu.be/F7XfFheooUU)

[Discuss LagDrop at 42Kmi.com](http://42kmi.com/Forum-42Kmi-LagDrop)


![FriendCode](https://i.imgur.com/FDSfaK0.jpg)
Down to play if I'm free from studying!

## How it works
________________
Some games, like Super Smash Bros for Wii U, utilize peer-to-peer matchmaking, meaning that opponents connect directly to each other for matches and do not rely on some distant server to maintain facilitation of controller inputs between players. LagDrop scans for peer IP addresses connected to your console and pings them with the parameters specified in the console-specific options.txt file. Any peer IP address that fails the test (returns an average ping time/TraceRoute average/ or packet loss percentage higher than the specified limit) is blocked from your console. Values above your limit are anticipated to be laggy, so why not prevent potential lag?

Starting with version 3.0.0, LagDrop runs differently from previous versions.

> LagDrop is natively console-agnostic. However, console specific server filters will run if use have certain keywords as your argument. See below for a more detailed explanation.

# How to use
----
#### Required:
* Router with [DD-WRT](http://dd-wrt.com) or other aftermarket firmware capable of running scripts. [Check if your router is compatible with DD-WRT here.](http://dd-wrt.com/site/support/router-database)
* SCP client to upload script and edit options file (e.g., WinSCP)
##### Optional:
* USB 2.0 LAN adapter for wired Wii U 
* SSH command-line interface (e.g., Putty) 

>Need a DD-WRT compatible router? Try [NETGEAR WNR3500L N30](http://amzn.to/2gV6GfI) or [TRENDnet TEW-818DRU AC190](http://amzn.to/2gvdGmt)!


*This guide uses DD-WRT as reference and assumes that you are familiar with DD-WRT or similar firmware. Do the equivalent of whatever firmware is on your compatible router.*

>***LagDrop is not intended or expected to harm your router, however, 42Kmi bears no responsibility for any damages that may occur.***
>***LagDrop is only intended to be used for automated lag-based peer blocking/filtering. Any use of, or modification to, LagDrop outside of its original intended scope is prohibited; 42Kmi will NOT have your back.***

* *Please read the changelog for version update details.*

1. In the DD-WRT web interface, go to the "Administration" tab and enable JFFS. To use a SCP client, enable SSH management (if you can't enable it, enable SSH in the "Secure Shell" settings located in the "services" tab first). Scroll to the bottom and apply settings.

2. Go to the "Services" tab in the DD-WRT web interface. Under the DHCP server settings, look for "static leases". Enter the MAC and IP addresses of your device. Include your console identifier, the keyword used for selecting the console filter, (wiiu, xbox, 3ds, ps4, PC etc.) in the hostname case. Scroll to the bottom of the page and apply settings.

3. In the SCP client, enter your router's IP in the hostname case, "root" as username and your password then click OK. Drop the following files in the jffs folder: lagdropclear.sh, lagdropcount.sh,and lagdrop.sh. Chmod the jffs folder to 777 recursive (In WinSCP, right-click jffs folder, go to properties, set permission to 777, enable checkbox for "Set group, owner, and permissions recursively").

4. In the DD-WRT web interface, go to Administration > Commands, and run lagdrop.sh and your appropriate console identifier or your device name as included in the DHCP settings page, in quotes, as the arugment, e.g.: "sh /jffs/lagdrop.sh "wiiu"", (or run "/jffs/lagdrop.sh "wiiu" &> /dev/null" from SSH command-line interface). The 42Kmi directory and options.txt will be created.

5. In the SCP client, navigate to /jffs/42Kmi. Open the options.txt file and edit the parameters. It should be pre-filled with your device's hostname and static IP address previously entered in DD-WRT's DHCP server settings for your device.

6. In the "Administration" tab of DD-wrt web interface, enable Cron and add this as an additional cron job:
    ```
    */1 * * * * root /bin/sh /jffs/lagdrop.sh "ARGUMENT"
    ```

    with quotes, where ARGUMENT is your console identifier or your hostname
    (eg: "*/1 * * * * root /bin/sh /jffs/lagdrop.sh wiiu" for will run lagdrop.sh for your the first static host with wiiu in its name).

Optionally: for steps 4-6, you can instead add /YOUR_DIRECTORY/lagdropstartup.sh "ARGUMENT" to the end of your router's startup script at Administration > Commands. An example should look like: 

```
/jffs/lagdropstartup.sh "wiiu"
```
	
7. Play online and enjoy! Be Glorious!

Note: LagDrop will rest when your console is not connected. LagDrop also has a script kill switch in case of need. Just run lagdrop.sh without any argument to terminate all instances of lagdrop.sh and LagDrop-related scripts.

# Options.txt
This file which is created on the first run of the LagDrop contains the parameters used by LagDrop. The file name will be options_IDENTIFIER.txt, but will referred to as "option.txt" here. The parameters include:

1. **[console name]:** your console’s static IP. This is filled on the first run of LagDrop after setting a static IP for your console. The [console name] is determined by name given in lagdrop.sh
2. **PingLimit:** This is the maximum average ping time in milliseconds permitted before blocking the peer. Default is 20.
3. **Count:** This is the number of packets sent to peer. Default is 20.
4. **Size:** This is the size of the packet in bytes, which tests of the peer’s bandwidth. Default is 2048
5. **Mode:** Determines which test(s) is/are used. 0 or 1 for Ping only, 2 for TraceRoute only, 3 for Ping or TraceRoute (peer is blocked if they fail ping test or TraceRoute test; recommended), 4 for Ping and TraceRoute (peer is blocked if they fail ping test AND TraceRoute test). Default is 1. 
6. **Max TTL:** Maximum TTL for the TraceRoute test (Active when Mode is set to 2, 3, or 4). Default is 20.
7. **Probes:** Number of times each node is checked during TraceRoute (Active when Mode is set to 2, 3, or 4). Default is 5.
8. **TraceLimit:** The limit of the TraceRoute time average (in milliseconds) *(TraceRoute tests the ping time between nodes from you to the peer. LagDrop reads it as an average of those times.)* . Values higher than this are blocked (Active when Mode is set to 2, 3, or 4). Default is 30
9. **ACTION:** Action performed when peer fails. Choose to REJECT (0 or REJECT) or DROP (1 or DROP) peers Default is REJECT. (The difference between REJECT and DROP is like replying "no thanks" messaged and just ignoring the message, resulting in a null ignore. REJECT is more "polite.")
10. **CHECKPACKETLOSS:** When enabled, will check ping for packet loss percentage (PACKETLOSSLIMIT). If packet loss is greater than the specified limit, then the peer is blocked. If no packet loss is detected, LagDrop proceeds with the other tests. *(This test has priority over ping and TraceRoute tests and is strict!)* Set to ON/on/1/YES/yes to enable. Default is OFF.
11. **PACKETLOSSLIMIT:** Value to determine blocking for CHECKPACKETLOSS. Default is 80 (80% Packet loss).
12. **SENTINEL:** Evaluates currently connected peer for packet loss. If packet loss occurs, peer is blocked. Intended as a proactive countermeasure to cheaters utilizing lag switches or any other means of inducing lag on play sessions. Experimental. Uses PACKETLOSSLIMIT parameter. Default OFF/NO/Disable/0
13. **CLEARALLOWED:** periodically clears older allowed peers no longer connected to router. Default is OFF/NO/Disable/0
14. **CLEARBLOCKED:** periodically clears older blocked peers no longer connected to router. Default is OFF/NO/Disable/0
15. **CLEARLIMIT:** Number of entries per ALLOWED/BLOCKED before clearing old entries begins. Default is 10
16. **CHECKPORTS:** Limits peer IP scanning to specified ports; to enable (1/ON/YES) or disable (0/OFF/NO). Default is NO. Recommended for PC gaming.
17. **PORTS:** Ports to check. Ports should be regex formatted
```
    eg: 3659|(46[0-9]{3}|5[0-3][0-9]{3}|54000) will limit peer IP scanning to ports 3659 and 46000-54000.
```
18. **RESTONMULTIPLAYER:** LagDrop will halt operation if the number of connected peers is greater than or equal to the number specified in the NUMBEROFPEERS field. Enable (1/ON/YES) or disable (0/OFF/NO) Rest on Multiplayer. Default is OFF.
19. **NUMBEROFPEERS:** The number of connected peers before LagDrop halts.
20. **DECONGEST:** Enabling this option blocks all incoming connections to the router except for peers connected to the console. Experimental
21. **SWITCH:** The master switch to enable (1/ON) or disable (0/OFF) LagDrop. Default is ON.

----

## whitelist.txt and blacklist.txt files
In the 42Kmi folder, whitelist.txt and blacklist.txt can be created in order to always allow (whitelist.txt) or always block (blacklist.txt) IPs from LagDrop. 

* IP addresses can be added in formatted single lines, with IP address separated by pipes (|), like Regular Expression, or they can be added to separate lines. IP ranges in the format 0.0.0.0-1.2.3.4 are not supported, instead write the IP range as regular expression. Titles/Headings can be added to group IP addresses, title/headings must be on one line surrounded by # (e.g., #This is a Heading#). Lines with # will not be interpreted by LagDrop.
```
    E.g.: ^192\.168\. will filter all addresses beginning with 192.168 from being checked by LagDrop.
    E.g.: ^192\.1(([0-3]{1}))0\. will filter addresses beginning with 192.100, 192.110, 192.120, and 192.130 from being checked by LagDrop.
```

----
## tweak.txt
This is an optional file you can create and add to the 42Kmi folder to adjust some extra parameters. Again, this is optional and not needed for LagDrop to run, however, you are free to experiment as you please.
```
PINGRESOLUTION=5
TRGETRESOLUTION=1
PACKETMODE=3
PACKETINTERVAL=3
SENTMODE=1
SENTLIMIT=0
SENTRUN=100
SENTRES=4
SENTINTERVAL=4
SENTINELXSQMODE=Standard
```
# Testimonials
----
* > Matchmaking was faster with LagDrop than with my PeerBlock country filtering since there was way more players "available" to play against. Be sure I'm gonna talk about \[LagDrop\] as it's the best and only way to fully enjoy P2P games.

* > I'm stunned at how it improved my SFV experience. Before and with country filtering, I'd play a "teleporting" guy one game out of three. Haven't faced any since.

* > It's incredible how the netcode/matchmaking benefits to those players with crappy internet/wi-fi or whatever. Thanks to \[LagDrop\] I've been much more competitive against 3K+ players as it got rid from all the laggers.


[![Donate to keep us going!](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=HA78KL8EWDJ8Q)
Donate to LagDrop development! Created and maintained by 42Kmi.
