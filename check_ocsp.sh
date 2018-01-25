#!/bin/bash
# AUTHOR: Phil Porada

DOMAIN=${1}
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [ -z ${1} ]; then
    echo "Missing domain"
    echo "Example: ${BOLD}./$(basename ${0} example.com)${RESET}"
    exit 1
fi

openssl s_client -connect ${1}:443 2>&1 < /dev/null | sed -n '/-----BEGIN/,/-----END/p' > ${1}.pem
OCSP_URL=$(openssl x509 -noout -ocsp_uri -in ${1}.pem)

if [ -z ${OCSP_URL} ]; then
    echo "${BOLD}Missing OCSP URL. Exiting...${RESET}"
    exit 1
fi

# Prepare the cert chain
openssl s_client -connect ${1}:443 -showcerts 2>&1 < /dev/null | sed -n '/-----BEGIN/,/-----END/p' > ${1}.tmpchain.pem

# Make sure we only get the chain certs because we already know our websites cert
comm --nocheck-order -3 ${1}.pem ${1}.tmpchain.pem | sed 's/^[[:space:]]//g' > ${1}.chain.pem

# Get the bare url
OCSP_URL_STRIPPED_PROTOCOL=$(echo ${OCSP_URL} | sed 's|http://||')

openssl ocsp \
    -verify_other ${1}.chain.pem \
    -respout ${1}.resp \
    -reqout ${1}.req \
    -issuer ${1}.chain.pem \
    -cert ${1}.pem \
    -text \
    -url ${OCSP_URL} \
    -header "HOST" "${OCSP_URL_STRIPPED_PROTOCOL}" \
    -no_nonce

# Bae64 encode the request so we can use it for the GET test
BASE64_REQUEST=$(openssl enc -a -in "${1}.req" | tr -d "\n")

echo -e "\n${BOLD}Testing GET${RESET}"
curl --verbose --url "${OCSP_URL}/$BASE64_REQ" > /dev/null
if [ $? -ne 0 ]; then
    echo "${BOLD}GET failed${RESET}"
else
    echo "${BOLD}GET was successful${RESET}"
fi

echo -e "\n${BOLD}Testing POST${RESET}"
curl --verbose --data-binary @${1}.req -H "Content-Type:application/ocsp-request" --url ${OCSP_URL} > /dev/null
if [ $? -ne 0 ]; then
    echo "${BOLD}POST failed${RESET}"
else
    echo "${BOLD}POST was successful${RESET}"
fi

# Cleanup
rm -f ${1}.tmpchain.pem ${1}.chain.pem ${1}.pem ${1}.resp ${1}.req ${1}.req.b64
