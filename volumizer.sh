#!/bin/bash
export TZ='America/Detroit'
HOUR=$(date +%H | sed 's/^0//g') # strip leading 0

# Configured as a systemd timer to run hourly

# Between 10PM and 8AM set the volume lower
# At 8AM we can raise the volume to a normal level
if [ ${HOUR} -ge 20 ] || [ ${HOUR} -lt 8 ]; then
    volumio volume 50 > /dev/null 2>&1
elif [ ${HOUR} -eq 8 ]; then
    volumio volume 70 > /dev/null 2>&1
fi
