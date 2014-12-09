#!/bin/bash
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

for i in {1..100} ; do 
    OUTPUT=$(openssl s_client -connect mail.ex2.secureserver.net:993 2>/dev/null | openssl x509 -noout -dates)
    NOTBEFORE=$(echo ${OUTPUT} | awk '{print $1,$2,$3,$4,$5}')
    NOTAFTER=$(echo ${OUTPUT} | awk '{print $6,$7,$8,$9,$10}')
    ERROR=$(echo ${OUTPUT} | awk '{print $9}')  
    if [[ $ERROR -eq "2014" ]] ;then
        echo "$YELLOW${NOTBEFORE} $RESET$RED<===== THAR YE SUX$RESET"
        echo "$YELLOW${NOTAFTER} $RESET$RED<===== THAR YE SUX$RESET"
    else
        echo ${NOTBEFORE}
        echo ${NOTAFTER}
    fi
    sleep 1
done

