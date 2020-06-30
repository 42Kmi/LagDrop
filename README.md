# 42Kmi LagDrop

![LagDrop](https://i.imgur.com/tLed6iA.png)


![Super Smash Bros. Ultimate](https://i.imgur.com/FFhu9Pv.png)

[![Donate to keep us going!](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=HA78KL8EWDJ8Q)
Donate to LagDrop development! Created and maintained by 42Kmi.

LagDrop is a dynamic firewall script that helps you avoid laggy matches in any peer-to-peer based matchmaking online game, such as Super Smash Bros. Ultimate, Street Fighter V, Dragon Ball FighterZ, and more! Especially developed with fighting games in mind! LagDrop works for any and all consoles/devices that can connect to your router!

## [LagDrop 3.0.0 beta is here!](https://github.com/42Kmi/LagDrop/releases) Still being finalized, but please check it out! New features include:
- Monitor to see LagDrop in action
- Location to see roughly where opponents are, with regional ban feature!
- Smart mode adjusts limits for best peers
- Sentinel: Checks for connection instability, suspected lag switch users (Cheaters!)
- More!

[@42Kmi on Twitter](http://twitter/42Kmi) [@LagDrop on Twitter](http://twitter/LagDrop)
[See LagDrop in action!](https://www.youtube.com/watch?v=6g9MiaE-2k0)
[Discuss LagDrop on our Discord server](http://42kmi.com/)

![FriendCode](https://i.imgur.com/FDSfaK0.jpg)
Down to play if I'm free from studying!

### Free tip for all: Check your router security configurations. Make sure multicast is allowed/permitted (not filtered), and make sure random anonymous pings are allowed/permitted (not filtered). Many online gaming services depend on these features being enabled for matchmaking. Make sure your router is synchronized to a time server.

## How it works
________________

First off: The foundational ideology of LagDrop is anti-lag/anti-cheat. LagDrop is NOT for causing lag to other players. If that's what you are looking for, we cannot help you. And you are scum. Both 42Kmi and 42Kmi LagDrop are actively against external acts and means committed to disrupt online gaming. Play fair and have fun.

Some games, like Super Smash Bros Ultimate, and most fighting games utilize peer-to-peer matchmaking, meaning that opponents connect directly to each other for matches and do not rely on a server to facilitate controller inputs between players. LagDrop tests peer IP addresses connected to your console against user-specified parameters. Peers that fail the test are softblocked from your router. Values above your limit are anticipated to be laggy, so why not prevent potential lag?

Starting with version 3.0.0, LagDrop runs differently from previous versions.

> LagDrop is natively console-agnostic. However, console specific server filters are enabled when using certain keywords as your identifier. See below for a more detailed explanation.

# How to use
----
#### Required:
* Router/device with [DD-WRT](http://dd-wrt.com), [OpenWRT](https://openwrt.org/), or other aftermarket firmware capable of running scripts. [Check if your router is compatible with DD-WRT here.](http://dd-wrt.com/site/support/router-database), [Check if your router is compatible with OpenWRT here.](https://openwrt.org/toh/views/toh_fwdownload)
* Please ensure that curl and openssl are installed on your router.
* SCP client to upload script and edit options file (e.g., [WinSCP](https://winscp.net/eng/download.php))
* SSH command-line interface for LagDrop execution (e.g., [Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)) 
##### Optional:
* USB 3.0 LAN adapter if needed (i.e., Nintendo Switch)

>Need a DD-WRT compatible router? Try [NETGEAR WNR3500L N30](http://amzn.to/2gV6GfI) or [TRENDnet TEW-818DRU AC190](http://amzn.to/2gvdGmt)!

Note: OpenWrt Users,
!!! ---Please ensure that openssl and curl are installed on your system. For OpenWRT, filter for "openssl-util" on the Software page. Same for "curl". Install openssl-util and curl--- !!!

*This guide will not cover how to install DD-WRT or OpenWRT on your router.*

*If you are confused by any of the steps included here, please do not go any further.*

*This guide uses DD-WRT as reference and assumes that you are familiar with DD-WRT or similar firmware. Do the equivalent for the firmware installed on your compatible router/network interface controller.*

>***LagDrop is not intended or expected to harm your router, however, 42Kmi bears no responsibility for any damages that may occur.***
>***LagDrop is only intended to be used for automated lag-based peer blocking/filtering. Any use of, or modification to, LagDrop outside of its original intended scope is prohibited; 42Kmi will NOT have your back.***

* *Please read the changelog for version update details.*

1. In the DD-WRT web interface, go to the "Administration" tab and enable JFFS. To use a SCP client, enable SSH management (if you can't enable it, enable SSH in the "Secure Shell" settings located in the "services" tab first). Scroll to the bottom and apply settings.

2. Go to the "Services" tab in the DD-WRT web interface. Under the DHCP server settings, look for "static leases". Enter the MAC and IP addresses of your device. Include your console identifier, the keyword used for selecting the console filter, (wiiu, xbox, 3ds, ps4, switch, PC, etc.) in the hostname case. Scroll to the bottom of the page and apply settings.

3. In the SCP client, enter your router's IP in the hostname case, "root" as username and your password then click OK. Drop the following files in the jffs folder: lagdrop.sh. Chmod the jffs folder to 777 recursive (In WinSCP, right-click jffs folder, go to properties, set permission to 777, enable checkbox for "Set group, owner, and permissions recursively").

	
4. In your terminal, log into your router, run lagrop.sh with your identifier and any flag (explained below). Like:

```
/path_to/lagdrop.sh switch -s 
```

5. In the SCP client, navigate to /jffs/42Kmi. Open the options.txt file to check the parameters. It should be pre-filled with your device's hostname and static IP address previously entered in DD-WRT's DHCP server settings for your device. If no IP address is found, please manually enter the IP address for your desired device. Multiple same/similar service device/consoles are supported. Separate the IP addresses with a door (|).

6. Play online and enjoy! Be Glorious!

Note: LagDrop will rest when your console is not connected. LagDrop also has a script kill switch in case of need. Just open a new instance of your terminal and run lagdrop.sh without any argument to terminate all instances of lagdrop.sh and LagDrop-related scripts.

# Flags
The following flags can be enabled to run certain features of LagDrop.
```
-s : Smart mode. Averages ping and traceroute times as new limits.

-p : Populate. LagDrop will run to populate cache for more efficient operation but will not perform any filtering. Completely optional, and only needs to be run once if the you should choose.

-t : Creates tweak.txt to adjust additional parameters.

-b : Bytes. When Sentinel is enabled, Sentinel will use bytes instead of packets. Strict.

-v : Verify. When Sentinel is enabled, LagDrop will create verify files for connected peers. Use our Excel macro to convert to graphs.

```

# Options.txt
This file is created on the first run of the LagDrop contains the parameters used by LagDrop. The file name will be options_IDENTIFIER.txt, but will referred to as "option.txt" here. The parameters include:

1. **[console name]:** your console’s static IP. This is filled on the first run of LagDrop after setting a static IP for your console. The [console name] is determined by name given as the identifier when running lagdrop.sh. Supports multiple device IP addresses when separated by door (|).
2. **PingLimit:** This is the maximum average ping time in milliseconds permitted before blocking the peer. Default is 100.
3. **Count:** This is the number of packets sent to peer. Default is 10.
4. **Size:** This is the size of the packet in bytes, which tests of the peer’s bandwidth. Default is 7500
5. **TraceLimit:** The limit of the TraceRoute time average (in milliseconds) *(TraceRoute tests the ping time between nodes from you to the peer. LagDrop reads it as an average of those times.)* . Values higher than this are blocked (Active when Mode is set to 2, 3, or 4). Default is 100
6. **ACTION:** Action performed when peer fails. Choose to REJECT (0 or REJECT) or DROP (1 or DROP) peers Default is REJECT. (The difference between REJECT and DROP is like replying "no thanks" messaged and just ignoring the message, resulting in a null ignore. REJECT is more "polite.")
7. **SENTINEL:** AKA, the lag-switch detector. Evaluates established connection for connection instability/aberration suggestive of network tampering. If detected, a strike is tallied against the peer. After a certain number of strikes, the peer is blocked. Default OFF/NO/Disable/0
8. **SENTBAN:** When enabled, Sentinel will ban peers after reaching the strike threshold. When disabled, Sentinel will continue counting strikes without punishment.
9. **STRIKERESET:** Strike counter can reset when no strikes are tallied after some time. Disable to count strikes continuously without chance of resetting.
10. **CLEARALLOWED:** periodically clears older allowed peers no longer connected to router. Default is OFF/NO/Disable/0
11. **CLEARBLOCKED:** periodically clears older blocked peers no longer connected to router. Default is OFF/NO/Disable/0
12. **CLEARLIMIT:** Number of entries per ALLOWED/BLOCKED before clearing old entries begins. Default is 10
13. **CHECKPORTS:** Limits peer IP scanning to specified ports; to enable (1/ON/YES) or disable (0/OFF/NO). Default is NO. Recommended for PC gaming.
14. **PORTS:** Ports to specify. All other ports will be ignored by LagDrop. Ports should be regex formatted
```
    eg: 3659|(46[0-9]{3}|5[0-3][0-9]{3}|54000) will limit peer IP scanning to ports 3659 and 46000-54000.
```
15. **RESTONMULTIPLAYER:** LagDrop will halt operation if the number of connected peers is greater than or equal to the number specified in the NUMBEROFPEERS field. Enable (1/ON/YES) or disable (0/OFF/NO) Rest on Multiplayer. Default is OFF.
16. **NUMBEROFPEERS:** The number of connected peers before LagDrop halts.
17. **DECONGEST:** Enabling this option blocks all incoming connections to the router except for peers connected to the console.
18. **SWITCH:** The master switch to enable (1/ON) or disable (0/OFF) LagDrop. Default is ON.

----
# Features
## Populate
When the -p flag is enabled, LagDrop will fill its cache for optimal running without processing incoming IP address. Except for filling caches, LagDrop is effectively not running. Completely optional to use. Don't use the -p flag while playing because peers will not be processed.

## Sentinel
Enable Sentinel in the option.txt file and LagDrop will monitor connected peers for network instability. Strikes are given when possible network instability is detected and are indicated in the terminal by a background color change for the line of offending peer. If a peer's number of strikes exceeds the user's specified limit, they are blocked.
```
Strike count: Appears on the right as white number with red background
Strike 1: Teal
Strike 2: Green
Strike 3: Yellow

Banned: Red, with a ban message.
```
Strikes can reset after some time has passed without network tampering occurrence.

## Clearing
When enabled, LagDrop clears entries once the minimum to clear limit is met. Cleared items are indicated with a magenta background before removal from the log.

## Regional banning
Create a file /42Kmi/bancountry.txt and you can enter lines in the format City, Region, Country to block connecting to peers from those regions. When enabled, peers may briefly appear in log before removal with a red background.

Written "CC" format for Country only; "RR, CC" format for Region by Country; "(RR|GG), CC" format for multiple regions by country. Eg:
```
City_name, RR, CC
```
Most regions and countries will use their region/country 2-letter abbreviations. RegEx is accepted. Priority is given to later characters to emphasize ban priority (country > region > city)

## Ping Approximation
Some peers may return a null ping time, "--", meaning that their router does not allow random pings. LagDrop can approximate a ping time for those peers, which is determined by averages of city -> region -> country -> continent. These ping times will appear colored in the terminal with a precedent superscript: City = green (1), province = yellow (2), country = cyan (3), continent = magenta (*). Uncolored ping times is the actual ping time for that peer.

## whitelist.txt and blacklist.txt files
In the 42Kmi folder, whitelist.txt and blacklist.txt can be created in order to always allow (whitelist.txt) or always block (blacklist.txt) IPs from LagDrop. 

* IP addresses can be added in formatted single lines, with IP address separated by pipes (|), like Regular Expression, or they can be added to separate lines. IP ranges in the format 0.0.0.0-1.2.3.4 are not supported, instead write the IP range as regular expression. Titles/Headings can be added to group IP addresses, title/headings must be on one line surrounded by # (e.g., #This is a Heading#). Lines with # will not be interpreted by LagDrop.
```
    E.g.: ^192\.168\. will filter all addresses beginning with 192.168 from being checked by LagDrop.
    E.g.: ^192\.1(([0-3]{1}))0\. will filter addresses beginning with 192.100, 192.110, 192.120, and 192.130 from being checked by LagDrop.
```
## tweak.txt
This is an optional file created in the 42Kmi folder by running the -t flag. Additional parameters will become available to adjust to your liking. Again, this is optional and not needed for LagDrop to run, however, you are free to experiment as you please. Rename or delete tweak.txt to disable the tweaks from LagDrop.
# Testimonials
----
* > Matchmaking was faster with LagDrop than with my PeerBlock country filtering since there was way more players "available" to play against. Be sure I'm gonna talk about \[LagDrop\] as it's the best and only way to fully enjoy P2P games.

* > I'm stunned at how it improved my SFV experience. Before and with country filtering, I'd play a "teleporting" guy one game out of three. Haven't faced any since.

* > It's incredible how the netcode/matchmaking benefits to those players with crappy internet/wi-fi or whatever. Thanks to \[LagDrop\] I've been much more competitive against 3K+ players as it got rid from all the laggers.


[![Donate to keep us going!](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=HA78KL8EWDJ8Q)
Donate to LagDrop development! Created and maintained by 42Kmi.
