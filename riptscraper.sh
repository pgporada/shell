#!/bin/bash
TEMP="$(mktemp)"
SITE="riptapparel.com"
EMAIL="philporada@gmail.com"
wget -q "${SITE}" -O "${TEMP}"

LINK=$(echo "RiptApparel")
PICNAME=$(grep content=\" "${TEMP}" | sed -n '12p' | sed -e 's/content=\"//' -e 's/" \/>//')
PIC=$(grep -i "uploads-riptapparel-com.s3.amazonaws.com/designs/" "${TEMP}" | sed -n '1p' | sed -e 's/    <meta property="og:image" content="//' -e 's/" \/>//')

rm -rf "${TEMP}"
echo $LINK "<br>" $PICNAME "<br>" $PIC #| mailx -a "Content-Type: text/html" -s "New Shit Alerts" $EMAIL
