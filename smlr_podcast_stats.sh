#!/bin/bash

if [ ! -z ${1} ] && [ ${1} == "-h" ]; then
    echo -e "USAGE:
                ./$(basename $0) test
            "
    exit 0
fi

if [ "${EUID}" -eq 0 ]; then
    echo "You don't need to be running this with privileges. Exiting..."
    exit 1
fi

STATS_FILE="${HOME}/stats.txt"

# Check dependencies
for i in pip3 jq gnuplot; do
    command -v ${i} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "You need to install ${i} through your systems package manager. Exiting..."
        exit 1
    fi
done

command -v ia-mine > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Installing the internet archive data miner utility via pip3"
    pip3 install --user iamine
    pip3 install --upgrade --user iamine
fi

if [ ! -z ${1} ] && [ ${1} == "test" ]; then
    # Format stats for ease of further consumption
    sed -i \
        -e 's/SMLR E /SMLR /g' \
        -e 's/SMLR E/SMLR /g' \
        -e 's/SMLR - Episode /SMLR /g' \
        -e 's/hpr0879 :: SMLR /SMLR /g' \
        -e 's/hpr.*:: Sunday Morning Linux Review.*Episode/SMLR/' \
        -e 's/Sunday Morning Linux Review Episode/SMLR/g' \
        -e 's/null/0/g' \
        -e '/SUSE and Venus/d' \
        -e '/Test Episode/d' \
        -e '/SMLR Promo/d' \
        ${STATS_FILE}

    # Further refinement of stats
    TMP=$(mktemp)
    grep ',SMLR ' ${STATS_FILE} | sort -t',' -k2 > ${TMP}
    mv ${TMP} ${STATS_FILE}

    # Cleanup any extra schmoo that happens to get left over for whatever reason
    if [ -f ${TMP} ]; then
        rm -f ${TMP}
    fi

    # Do some interesting stats while we have the raw data
    echo "+-------+"
    echo "There are $(wc -l ${STATS_FILE}) entries"
    echo "There are $(awk '{print $2}' ${STATS_FILE} | uniq -u | wc -l) distinct entries"

    LAST_EPISODE=$(tail -n1 ${STATS_FILE} | awk '{print $1}' )
    for i in 1..${LAST_EPISODE}; do
        echo $i
    done
    echo "We are missing episodes"

    # Plot the data
    echo -e "
        set term svg
        set output \"graph.svg\"
        set boxwidth 0.5
        set style fill solid
        plot \"${STATS_FILE}\" with boxes
        exit" | gnuplot
else
    ia-mine --secure -s SMLR | jq -r '.response.docs[] | "\(.downloads),\(.title)"' > ${STATS_FILE}
fi
