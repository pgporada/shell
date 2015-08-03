#!/bin/bash
# PURPOSE: To prepare the data and deployment directory with the latest available Confluence from Atlassian

# Color settings
BOLD=$(tput bold)
RESET=$(tput sgr0)
YEL=$(tput setaf 3)
CYN=$(tput setaf 6)
RED=$(tput setaf 1)
GRN=$(tput setaf 2)

WARN="${BOLD}${YEL}[-]${RESET}"
INFO="${BOLD}${CYN}[~]${RESET}"
CRIT="${BOLD}${RED}[!]${RESET}"
GOOD="${BOLD}${GRN}[+]${RESET}"

CONFDIR="/opt/j2ee/danlawinc.com/wiki/webapps"


# Script prep
curl -s https://confluence.atlassian.com/display/DOC/Confluence+Release+Notes -o /tmp/.conf-release-notes
DANLAWDEPLOYMENT=$(readlink ${CONFDIR}/deployments/current | grep -o "[0-9].*")
DANLAWDATA=$(readlink ${CONFDIR}/data/current | grep -o "[0-9].*")
echo "${GOOD} Current version is: ${BOLD}${DANLAWDEPLOYMENT}${RESET}"


# Print available versions for the latest Confluence
echo "${INFO} Choose from the following"
# For example, gets 5.8 or 5.9 or6.4
AVAILABLEMAJORMINOR=$(grep "Documentation for" /tmp/.conf-release-notes | head -n1 | grep -o "[0-9]\.[0-9]")
# For example, gets 5.8.1 or 5.8.2 or 6.4.0
LATESTVERSION=$(grep -o "$AVAILABLEMAJORMINOR\.[0-9]" /tmp/.conf-release-notes | sort -u -r | head -n1)
grep -o "$AVAILABLEMAJORMINOR\.[0-9]" /tmp/.conf-release-notes | sort -u -r | sed "s|${LATESTVERSION}|${LATESTVERSION} ${BOLD}${GRN}<===== LATEST${RESET}|"


# Clean up the previous release notes 
if [ -f /tmp/.conf-release-notes ]; then 
    rm -f /tmp/.conf-release-notes
fi


# User prompt to choose version
echo -n "${INFO} Which version will you prep for: ${BOLD}"
read USERCHOICE
echo -n "${RESET}"
REGEX="[0-9]{1}\.[0-9]{1}\.[0-9]{1}"
if [[ ${USERCHOICE} =~ ${REGEX} ]]; then
    echo "${INFO} You chose: ${BOLD}${USERCHOICE}${RESET}"
else
    echo "${INFO} +------------------+"
    echo "${CRIT} Your choice did not match the regex. Try again."
    echo "${INFO} +------------------+"
    exit
fi


# Download and prep of the deployment directory
if [[ ${LATESTAVAILABLE} =~ ${DANLAWDEPLOYMENT} ]]; then
    echo "${INFO} +------------------+"
    echo "${GOOD} You have the latest available Confluence deployment dir: ${BOLD}${LATESTAVAILABLE}${RESET}"
    echo "${INFO} +------------------+"
    exit
else
    echo "${INFO} +------------------+"
    echo "${INFO} Downloading Confluence version ${BOLD}${USERCHOICE}${RESET}"
    echo "${INFO} +------------------+"
    wget https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${USERCHOICE}.tar.gz -P ${CONFDIR}/deployments/
fi
cd ${CONFDIR}/deployments
echo "${INFO} +------------------+"
echo "${INFO} Prior deployment directory configuration"
echo "${INFO} +------------------+"
ls -al .
if [ -f atlassian-confluence-${USERCHOICE}.tar.gz ]; then
    echo "${INFO} Extracting atlassian-confluence-${USERCHOICE}.tar.gz"
    tar zxf atlassian-confluence-${USERCHOICE}.tar.gz
    rm -f atlassian-confluence-${USERCHOICE}.tar.gz
    if [ -L $(readlink ${CONFDIR}/deployments/next 2> /dev/null) ]; then 
        rm -rf next/
        unlink next
    fi
    ln -s atlassian-confluence-${USERCHOICE} next
    echo "${INFO} Fixing permissions on next/"
    chown -R root:root next/
    cd next
    rm -rf bin/ conf/ lib/ LICENSE licenses/ logs/ NOTICE README.* RELEASE-NOTES RUNNING.txt temp/ webapps/ work/
    mv confluence exploded_war
    cd ..
    echo "${INFO} Fixing confluence-init.properties"
    echo "confluence.home=/opt/j2ee/danlawinc.com/wiki/webapps/data/current" > ${CONFDIR}/deployments/next/exploded_war/WEB-INF/classes/confluence-init.properties
    echo "${INFO} Prepare to fix seraph-config.xml"
    sleep 3
    vim ${CONFDIR}/deployments/next/exploded_war/WEB-INF/classes/seraph-config.xml
fi
echo "${INFO} +------------------+"
echo "${INFO} Post deployment directory configuration"
echo "${INFO} +------------------+"
ls -al .


# Prep of the data directory
cd ${CONFDIR}/data
echo "${INFO} +------------------+"
echo "${INFO} Prior data directory configuration"
echo "${INFO} +------------------+"
ls -al .
# Check if the next symlink doesn't exist. If it does not, then we prep the data dir.
if [[ ${LATESTAVAILABLE} =~ ${DANLAWDATA} ]]; then
    echo "${INFO} +------------------+"
    echo "${GOOD} Data directory is the latest version"
    echo "${INFO} +------------------+"
    exit
else
    echo "${INFO} +------------------+"
    echo "${INFO} Prepping data directory"
    echo "${INFO} +------------------+"
    if [ -L $(readlink ${CONFDIR}/data/next 2> /dev/null) ]; then 
        mkdir -p atlassian-confluence-${USERCHOICE}
    else
        unlink next
    fi
fi
ln -s atlassian-confluence-${USERCHOICE} next
echo "${INFO} Fixing permissions on next/"
chown -R j2ee-wiki:j2ee-wiki next/
echo "${INFO} +------------------+"
echo "${INFO} Post data directory configuration"
echo "${INFO} +------------------+"
ls -al .
echo "${INFO} You're going to want to do the following once the actual maintenance happens"
echo "${INFO} ${BOLD}1)${RESET} Place Confluence into safe mode => https://wiki.danlawinc.com/plugins/servlet/upm#manage"
echo "${INFO} ${BOLD}2)${RESET} ${BOLD}svc -d /service/j2ee.wiki.danlawinc.com ; watch svstat /service/j2ee.wiki.danlawinc.com${RESET}"
echo "${INFO} ${BOLD}3)${RESET} Clear tomcat work directory"
echo "${INFO} ${BOLD}4)${RESET} Rsync data directory current to next: ${BOLD}rsync -avHSP --delete current/ next/${RESET}"
echo "${INFO} ${BOLD}5)${RESET} Symlink swap: ${BOLD}unlink previous ; mv current previous ; mv next current${RESET}"
echo "${INFO} ${BOLD}6)${RESET} Backup the database: ${BOLD}su - postgres ; pg_dump -O j2ee-wiki | gzip > backups/other/j2ee-wiki-PRE-FILL_IN_THIS_VERSION.dmp.gz${RESET}"
echo "${INFO} ${BOLD}6)${RESET} ${BOLD}svc -u /service/j2ee.wiki.danlawinc.com ; tailf /service/j2ee.wiki.danlawinc.com/log/main/current${RESET}"
