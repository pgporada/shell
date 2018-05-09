#!/bin/bash
# AUTHOR: Phil Porada

DOMAIN=${1}
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [ -z ${1} ]; then
    echo "Missing domain"
    echo "Example: ${BOLD}./$(basename ${0}) example.com${RESET}"
    exit 1
fi

CERT=$(openssl s_client -connect ${DOMAIN}:443 2>&1 < /dev/null | sed -n '/-----BEGIN/,/-----END/p')
OCSP_URL=$(openssl x509 -noout -ocsp_uri -in <(echo "${CERT}"))

if [ -z ${OCSP_URL} ]; then
    echo "${BOLD}Missing OCSP URL. Exiting...${RESET}"
    exit 1
fi

# Prepare the cert chain
TMPCHAIN=$(openssl s_client -connect ${DOMAIN}:443 -showcerts 2>&1 < /dev/null | sed -n '/-----BEGIN/,/-----END/p')

# Make sure we only get the chain certs because we already know our websites cert
CHAIN=$(comm --nocheck-order -3 <(echo "${CERT}") <(echo "${TMPCHAIN}") | sed 's/^[[:space:]]//g')

# Get the bare url
OCSP_URL_STRIPPED_PROTOCOL=$(echo ${OCSP_URL} | sed 's|http://||')

openssl ocsp \
    -verify_other <(echo "${CHAIN}") \
    -respout ${DOMAIN}.resp \
    -reqout ${DOMAIN}.req \
    -issuer <(echo "${CHAIN}") \
    -cert <(echo "${CERT}") \
    -text \
    -url ${OCSP_URL} \
    -header "HOST" "${OCSP_URL_STRIPPED_PROTOCOL}" \
    -no_nonce

# Bae64 encode the request so we can use it for the GET test
BASE64_REQUEST=$(openssl enc -a -in "${DOMAIN}.req" | tr -d "\n")

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

# Cleanup
rm -f ${DOMAIN}.resp ${DOMAIN}.req ${DOMAIN}.req.b64
