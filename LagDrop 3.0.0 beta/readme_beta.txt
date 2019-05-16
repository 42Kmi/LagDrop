LagDrop 3.0.0 beta, #OneForAll

Currently works on DD-WRT (tested on DD-WRT v24-sp2 (02/04/15) std and DD-WRT v3.0-r36247 std (06/29/18)) and OpenWRT (tested on OpenWrt 18.06.1 r7258-5eb055306f).


!!! ---Please ensure that openssl and curl are installed on your system. For OpenWRT, filter for "openssl-util" on the Software page. Same for "curl". Install openssl-util and curl--- !!!

Place lagdrop.sh and killall.sh in your directory of choice. chmod both to 777
==============================

LagDrop requires a console identifier (eg; WIIU, Switch, XBOX, PS4, PC). This decides the which filter to load.

example: /path_to/lagdrop.sh wiiu

Options: ending the line with following enables

-s : Smart mode. Averages ping and traceroute times as new ceilings.

-l : Locate. Where your opponents are.

-p : Populate. LagDrop will run to populate cache for more efficient operation but will not perform any filtering. Completely optional, and only needs to be run once if the you should choose.

eg: /jffs/lagdrop.sh wiiu -s -l

==============================
How to run.

Go to your terminal.

If you set your desired console to a static IP address, LagDrop will get its IP on first run, as long as a console identifier is included in the name.

If a static IP has not been set, just run lagdrop.sh with a console identifier then exit with ctrl+C. Navigate to the 42Kmi directory. Open the options_.txt file and put your console's IP address after the = on the first line.
==============================

If you experience any trouble closing lagdrop.sh, please open another terminal and run lagdrop.sh without arguments or run the killall.sh script

==============================

Added a feature to fill in approximate ping values for peers that return null ping results. Enabling location will save all valid ping times and their location of origin. When at least 8 are available, the average will be taken and used for later peers from the same area that return null pings. This is done at the city, provincial, and country levels if the previous is not available. These ping times will appear colored in the terminal: City = green, province = yellow, country = cyan, continent = magenta.

Additionally, an excel spreadsheet is provided for sorting and arranging the recorded pings for study. You can see how everyone connects to you by copying the contents of the pingmem file to the spreadsheet.

==============================
Thank you for your interest in beta testing!
As part of the beta, we ask that you please run in Smart Mode and Locate mode.
Please test in other shell environments.

A more robust documentation is underway, but some of the details from the previous version are still applicable.
Please send questions, comments, concerns, and testimonials! We would love to know how LagDrop helps improve your game!

If you would like to make videos featuring LagDrop, we recommend utilizing an overlay as done here https://youtu.be/F7XfFheooUU

Contact us for more ideas about incorporating LagDrop into your gaming experience.

Contact us @ http://42Kmi.com
Contact us @ github.com/42Kmi
Contact us @ twitter.com/42Kmi