#!/bin/bash

DOMAIN=${1}
BOLD=$(tput bold)
RESET=$(tput sgr0)
METHOD="POST"
echo "Testing OCSP with curl ${METHOD}"

if [ -z ${1} ]; then
    echo "Missing domain"
    echo "Example: ${BOLD}./$(basename ${0}) example.com${RESET}"
    exit 1
fi

CERT=$(openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} 2>&1 < /dev/null | sed -n '/-----BEGIN/,/-----END/p')
OCSP_URL=$(openssl x509 -noout -ocsp_uri -in <(echo "${CERT}"))

if [ -z ${OCSP_URL} ]; then
    echo "${BOLD}Missing OCSP URL. Exiting...${RESET}"
    exit 1
fi

# Prepare the cert chain
TMPCHAIN=$(openssl s_client -connect ${DOMAIN}:443 -showcerts 2>&1 < /dev/null | sed -n '/-----BEGIN/,/-----END/p')

# Make sure we only get the chain certs because we already know our websites cert
CHAIN=$(comm --nocheck-order -3 <(echo -e "${CERT}") <(echo -e "${TMPCHAIN}") | sed 's/^[[:space:]]//g')

# Get the bare url
OCSP_URL_STRIPPED_PROTOCOL=$(echo ${OCSP_URL} | sed 's|https\?://||')

# https://tools.ietf.org/html/rfc5019
# Clients MUST use SHA1 as the hashing algorithm for the
# If you specify -sha256, the CA (probably boulder) will return Responder Error: unauthorized (6)
# because the CA must respond with its own issuer name hash and issuer key hash which would
# mean generating twice as many responses in a HSM
openssl ocsp \
    -sha1 \
    -issuer <(echo "${CHAIN}") \
    -cert <(echo "${CERT}") \
    -verify_other <(echo "${CHAIN}") \
    -respout ${DOMAIN}.resp \
    -reqout ${DOMAIN}.req \
    -text \
    -url ${OCSP_URL} \
    -header "HOST=${OCSP_URL_STRIPPED_PROTOCOL}" \
    -no_nonce

# Bae64 encode the request so we can use it for the GET test
BASE64_REQ=$(openssl enc -a -in "${DOMAIN}.req" | tr -d "\n")

function dont_need_this() {
    echo -e "\n${BOLD}Testing GET${RESET}"
    curl --verbose --url "${OCSP_URL}/$BASE64_REQ" > /dev/null
    if [ $? -ne 0 ]; then
        echo "${BOLD}GET failed${RESET}"
    else
        echo "${BOLD}GET was successful${RESET}"
    fi

    echo -e "\n${BOLD}Testing POST${RESET}"
    curl --verbose --data-binary @${DOMAIN}.req -H "Content-Type:application/ocsp-request" --url ${OCSP_URL} > /dev/null
    if [ $? -ne 0 ]; then
        echo "${BOLD}POST failed${RESET}"
    else
        echo "${BOLD}POST was successful${RESET}"
    fi

    echo "Check for CDN caching improperly returning the wrong serial"
    if [[ "${METHOD}" == "POST" ]]; then
        TEST_SERIAL1="$(curl -s -H 'Content-Type: application/ocsp-request' --data-binary @${DOMAIN}.req ${OCSP_URL} | openssl ocsp -respin - -noverify -text | grep 'Serial Number: ' | awk '{print $3}')"
        curl --trace-ascii debug.txt -H 'Expect: 100-continue' -H 'Content-Type: application/ocsp-request' --data-binary @${DOMAIN}.req ${OCSP_URL} | openssl ocsp -respin - -noverify -text | grep 'Serial Number: ' | awk '{print $3}' > /dev/null 2>&1
        TEST_SERIAL2="$(curl -s -H 'Expect: 100-continue' -H 'Content-Type: application/ocsp-request' --data-binary @${DOMAIN}.req ${OCSP_URL} | openssl ocsp -respin - -noverify -text | grep 'Serial Number: ' | awk '{print $3}')"
    elif [[ "${METHOD}" == "GET" ]]; then
        TEST_SERIAL1="$(curl -s --url "${OCSP_URL}/${BASE64_REQ}" | openssl ocsp -respin - -noverify -text | grep 'Serial Number:' | awk '{print $3}')"
        curl --trace-ascii debug.txt -H 'Expect: 100-continue' --url "${OCSP_URL}/${BASE64_REQ}" > /dev/null 2>&1
        TEST_SERIAL2="$(curl -s -H 'Expect: 100-continue' --url "${OCSP_URL}/${BASE64_REQ}" | openssl ocsp -respin - -noverify -text | grep 'Serial Number:' | awk '{print $3}')"
    else
        echo "No curl method selected"
    fi

    if [[ "${TEST_SERIAL1}" == "${TEST_SERIAL2}" ]]; then
        echo "Doesn't appear to be a CDN problem."
        echo "https://crt.sh/?serial=${TEST_SERIAL1} and https://crt.sh/?serial=${TEST_SERIAL2}"
    else
        echo "Something is *VERY* wrong."
        echo "https://crt.sh/?serial=${TEST_SERIAL1} and https://crt.sh/?serial=${TEST_SERIAL2}"
        for i in ${TEST_SERIAL1} ${TEST_SERIAL2}; do
            echo "Checking serial: ${i}"
            for j in $(curl -sL https://crt.sh/?serial=${i} | grep 'href="?id=' | sed -e 's/<TD style="text-align:center">//' -e 's|</A></TD>||' | awk -F '>' '{print $2}'); do
                openssl x509 -in <(curl -sL https://crt.sh/?d=${j}) -noout -subject
            done
        done
    fi
}

echo "Request with Expect header has been output to debug.txt"
rm -f ${DOMAIN}.resp ${DOMAIN}.req ${DOMAIN}.req.b64
