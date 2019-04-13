LagDrop 3.0.0 beta, #OneForAll

Currently works on DD-WRT (tested on DD-WRT v24-sp2 (02/04/15) std and DD-WRT v3.0-r36247 std (06/29/18)) and OpenWRT (tested on OpenWrt 18.06.1 r7258-5eb055306f).


!!! ---Please ensure that openssl is installed on your system. --- !!!

Place lagdrop.sh and killall.sh in your directory of choice. chmod both to 777
==============================

LagDrop requires a console identifier (eg; WIIU, Switch, XBOX, PS4, PC). This decides the which filter to load.

example: /path_to/lagdrop.sh wiiu

Options: ending the line with following enables

-s : Smart mode. Averages ping and traceroute times as new ceilings.

-l : Locate. Where your opponents are.

==============================
How to run.

Go to your terminal.

If you set your desired console to a static IP address, LagDrop will get its IP on first run, as long as a console identifier is included in the name.

If a static IP has not been set, just run lagdrop.sh with a console identifier then exit with ctrl+C. Navigate to the 42Kmi directory. Open the options_.txt file and put your console's IP address after the = on the first line.
==============================

If you experience any trouble closing lagdrop.sh, please open another terminal and run lagdrop.sh without arguments or run the killall.sh script

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