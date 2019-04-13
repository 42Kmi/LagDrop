#!/bin/sh
#Obfuscate your script. Quick and simple. Enter your "/path/to/script.sh" as the argument.
#Requires openssl

INPUT="$1"
#OUTPUT="$2"
DIR="${0%\/*.*}"

OUT_FILENAME="$DIR/"${1}_enc""


echo '#!/bin/sh' > "$OUT_FILENAME"
echo 'eval "$(echo "' >> "$OUT_FILENAME"
echo "$(tail +1 "$1")"|openssl enc -base64 >> "$OUT_FILENAME"
echo "\"|openssl enc -base64 -d) &> /dev/null\"" >> "$OUT_FILENAME"

chmod 777 "$OUT_FILENAME"
