Sentinel Tool ReadMe

Sentinel Tool monitors data flow of LagDrop-allowed peers and creates a file to view in Microsoft Excel. Use the included Excel macro to convert to graphs.

While lagdrop.sh is running in one terminal, open a new terminal to execute sentineltool.sh from the same directory as lagdrop.sh.

Usage:

./path_to/sentineltool.sh "some_name"

The "some_name" is optional. Text entered after the script will become the prefix of the file created.
While sentineltool is running, press Ctrl+C to exit.

Sentinel Tool creates files in the 42Kmi/sentinel_data directory. Created files are named [DATE_TIME]_SentinelToolResults_bytes.txt and [DATE_TIME]_SentinelToolResults_packet.


Microsoft Excel Convert

Open the included 42KmiLagDropSentinelToolConvert in Microsoft Execl, and follow the instructions.