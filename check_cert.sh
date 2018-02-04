#!/bin/bash
# AUTHOR: Phil Porada

DOM=${1}
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [ -z ${DOM} ]; then
    echo "Missing domain"
    echo "Example: ${BOLD}./$(basename ${0} example.com)${RESET}"
    exit 1
fi

CERT=$(openssl s_client -connect ${DOM}:443 2>&1 < /dev/null | sed -n '/-----BEGIN/,/-----END/p')
SAN=$(openssl x509 -noout -text -in <(echo "${CERT}") | grep '^[[:space:]]*Subject: CN=' | sed 's/^[[:space:]]*Subject: CN=//')

DOM_A=$(echo ${DOM} | awk -F'\.' '{print $1"\."$1}' 2>/dev/null)
DOM_B=$(echo ${DOM} | awk -F'\.' '{print $2"\."$3}' 2>/dev/null)
DOM_TLD=$(echo ${DOM} | awk -F'\.' '{print $2}' 2>/dev/null)

SAN_TLD_A=$(echo ${SAN} | awk '{print $1}' | awk -F'\.' '{print $3}' 2>/dev/null)
SAN_TLD_B=$(echo ${SAN} | awk '{print $1}' | awk -F'\.' '{print $2}' 2>/dev/null)

function ok() {
    echo "${BOLD}${DOM}${RESET} Ok"
}

function error() {
    echo "${BOLD}${DOM}${RESET} ERROR - Invalid SAN cert"
}

function debug() {
    echo "DEBUG:"
    echo "DEBUG: DOM        ${DOM}"
    echo "DEBUG: DOM_A      ${DOM_A}"
    echo "DEBUG: DOM_B      ${DOM_B}"
    echo "DEBUG: DOM_TLD    ${DOM_TLD}"
    echo "DEBUG: DOM_CMB    ${SAN_TLD_B}.${SAN_TLD_A}"
    echo "DEBUG:"
    echo "DEBUG: SAN        ${SAN}"
    echo "DEBUG: SAN_TLD_A  ${SAN_TLD_A}"
    echo "DEBUG: SAN_TLD_B  ${SAN_TLD_B}"
    echo "DEBUG:"
}

COUNT=0

if  ([[ ! "${DOM_A}" =~ "${SAN}" ]] || [[ ! "${DOM_B}" =~ "${SAN}" ]]); then
    COUNT=$(( COUNT + 1 ))
fi

if [[ "${SAN_TLD_A}\.${SAN_TLD_B}" != "${DOM_B}" ]]; then
    COUNT=$(( COUNT + 1 ))
fi

if [[ "${DOM_B}" != "${SAN_TLD_B}\." ]]; then
    COUNT=$(( COUNT + 1 ))
fi

if [ "${COUNT}" -eq 2 ]; then
    ok
    # debug
    exit 0
fi

if [[ "${SAN_TLD_B}.${SAN_TLD_A}" == "${DOM_B}" ]]; then
    error
    # debug
    exit 0
fi

if [[ "${DOM_B}" != "${SAN_TLD_B}." ]]; then
    ok
    # debug
    exit 0
fi
