#!/bin/bash
DOMAIN=${1}

openssl s_client -connect ${1}:443 2>&1 < /dev/null | sed -n '/-----BEGIN/,/-----END/p' > ${1}.pem
OCSP_URL=$(openssl x509 -noout -ocsp_uri -in ${1}.pem)

if [ -z ${OCSP_URL} ]; then
    echo "Missing OCSP URL. Exiting..."
    exit 1
fi

# Prepare the cert chain
openssl s_client -connect ${1}:443 -showcerts 2>&1 < /dev/null | sed -n '/-----BEGIN/,/-----END/p' > ${1}.tmpchain.pem

# Make sure we only get the chain certs because we already know our websites cert
comm --nocheck-order -3 ${1}.pem ${1}.tmpchain.pem | sed 's/^[[:space:]]//g' > ${1}.chain.pem


OCSP_HOST=$(echo ${OCSP_URL} | sed 's|http://||')

# Make the OCSP request
openssl ocsp -verify_other ${1}.chain.pem -issuer ${1}.chain.pem -cert ${1}.pem -text -url ${OCSP_URL} -header "HOST" "${OCSP_HOST}" -no_nonce

# Cleanup
rm -f ${1}.tmpchain.pem ${1}.chain.pem ${1}.pem
