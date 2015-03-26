#!/bin/bash
# PGP v0.0.1
# VPN DNS Automatorizer v0.0.2

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)


function startUp () {
    if [ -e /etc/resolv.conf ] && grep -vo danlaw /etc/resolv.conf; then
        echo "${GREEN}[+]${RESET} Moving /etc/resolv.conf to /etc/.resolv.conf"
        mv -f /etc/resolv.conf /etc/.resolv.conf
        echo "search example.com" > /etc/resolv.conf
        echo "nameserver x.x.x.x" >> /etc/resolv.conf
        echo "nameserver x.x.x.x" >> /etc/resolv.conf
    elif [ ! -e /etc/resolv.conf ] && [ -e /etc/.resolv.conf ] && [ grep -o danlaw /etc/resolv.conf ]; then
        echo "${GREEN}[+]${RESET} /etc/.resolv.conf was found, moving it to /etc/resolv.conf"
        mv /etc/.resolv.conf /etc/resolv.conf
        echo "${RED}[!]${RESET} The script has exited. You have a config that will not allow you to access DNS services. Please install your previous working config."
        exit 1
    else
        echo "${RED}[!]${RESET} No good /etc/resolv.conf or /etc/.resolv.conf exists"
        echo "${GREEN}[+]${RESET} Creating danlaw config"
        echo "search example.com" > /etc/resolv.conf
        echo "domain example.com" >> /etc/resolv.conf
        echo "nameserver 127.0.0.1" >> /etc/resolv.conf
        echo "nameserver x.x.x.x" >> /etc/resolv.conf
        echo "nameserver x.x.x.x" >> /etc/resolv.conf
    fi
}

function middleStuff () {
    echo "${GREEN}[+]${RESET} The current config in place is"
    cat /etc/resolv.conf
    echo
    echo "${GREEN}[+]${RESET} Starting VPN. Please have your credentials on hand and not written down on a sticky note. Every insecure password and password leak makes the admin cry."
}

function cleanUp () {
    echo "${GREEN}[+]${RESET} Cleaning up after the VPN connection"
    if [ -e /etc/.resolv.conf ]; then
        mv -f /etc/.resolv.conf /etc/resolv.conf
    else
        echo "${RED}[!]${RESET} You removed /etc/.resolv.conf didn't you? >:|"
        exit 1
    fi
}


# Upon detecting any EXIT signal during this script, it will start the cleanUp function.
# Step 4
trap cleanUp EXIT

# Step 1
startUp
# Step 2
middleStuff
# Step 3 to actually start the VPN
openvpn --config ~/.client.ovpn
