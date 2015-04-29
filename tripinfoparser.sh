#!/usr/bin/env bash
BOLD=$(tput bold)
RESET=$(tput sgr0)

TD="http://localhost:24224/"
INDEX="NAME.distribute"
URL=${TD}${INDEX}

if [ ! -x /usr/bin/dos2unix ]; then
    echo "dos2unix is not installed"
    echo "Running: ${BOLD}sudo yum -y install dos2unix${RESET}"
    sudo yum -y install dos2unix
fi

usage() {
    echo "${BOLD}./$(basename $0) <directory>${RESET}"
    echo "Provide a directory to find trip data files"
    echo "+-----------------------------------------+"
    echo "This directory       :   ${BOLD}./$(basename $0) .${RESET}"
    echo "Previous directory   :   ${BOLD}./$(basename $0) ..${RESET}"
    echo "Any other directory  :   ${BOLD}./$(basename $0) /path/to/dir${RESET}"
}

# Check amount of arguments
if [ $# -eq 0 ]; then
    usage
    exit 1
elif [ $# -gt 1 ]; then
    usage
    exit 2
fi

# Check if your argument is a directory
if [ -d "${1}" ]; then
    DIR="${1}"
    echo "Your dir is: ""${DIR}"
else
    usage
    exit 1
fi
for FILE in $(find "${DIR}" -maxdepth 1 -type f -iname "*.txt"); do
    dos2unix "${FILE}"
    echo "Parsing: ""${FILE}"
    IMEI=$(echo "${FILE}" | cut -d'_' -f1 | sed 's|.*/||g')
    while read LINE
    do
        curl -X POST -d"json={\"imei\":\"${IMEI}\", \"data\":\"${LINE}\"}" ${URL}
    done < "${FILE}"
done
