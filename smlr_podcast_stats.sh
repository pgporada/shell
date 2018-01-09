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
for i in pip3 jq gnuplot display; do
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

    LAST_EPISODE="$(tail -n1 ${STATS_FILE} | awk -F' ' '{print $2}' )"

    TOTAL_VIEWS="$(awk '{sum+=$1} END {print sum}' ${STATS_FILE})"
    #sed 's/SMLR//g' ${STATS_FILE} | awk '$2=p+1 {sum+=$1} {print sum} {p=$2}' > file

    HIGHEST="$(sort -k1 -rug ${STATS_FILE} | head -n1)"
    HIGHEST_VIEWS="$(echo ${HIGHEST} | awk -F',' '{print $1}')"
    HIGHEST_VIEWS_EPISODE="$(echo ${HIGHEST} | awk -F' ' '{print $2}')"

    LOWEST="$(sort -k1 -ug ${STATS_FILE} | head -n1)"
    LOWEST_VIEWS="$(echo ${LOWEST} | awk -F',' '{print $1}')"
    LOWEST_VIEWS_EPISODE="$(echo ${LOWEST} | awk -F' ' '{print $2}')"

    ENTRIES="$(wc -l ${STATS_FILE} | awk '{print $1}')"
    DISTINCT_ENTRIES="$(awk '{print $2}' ${STATS_FILE} | sort -gu | wc -l)"

    #MISSING_EPISODES="$(awk -F' ' '{print $2}' ${STATS_FILE} | sort -k2| uniq -u | awk -F' ' '$1!=p+1 {print p+1} {p=$1}' | tr '\n' ',' | sed 's/,$//')"

    # Do some interesting stats while we have the raw data
    echo "There are ${ENTRIES} entries"
    echo "There are ${DISTINCT_ENTRIES} distinct entries"
    #echo "We are missing episodes: ${MISSING_EPISODES}"
    echo "The last episode recorded is: ${LAST_EPISODE}"
    echo "We have had a total of ${TOTAL_VIEWS} views so far"
    echo "The episode with the highest views was episode ${HIGHEST_VIEWS_EPISODE} with ${HIGHEST_VIEWS} views"
    echo "The episode with the lowest views was episode ${LOWEST_VIEWS_EPISODE} with ${LOWEST_VIEWS} views"

    cp ${STATS_FILE} stats.tmp
    STMP="stats.tmp"
    sed -i 's/SMLR //g' ${STMP}

    # Plot the data
    echo "Plotting data with gnuplot..."
    echo -e "
        set term svg
        set output \"graph.svg\"
        set boxwidth 0.5
        set style fill solid border
        set datafile separator ','
        set grid
        set title 'Sunday Morning Linux Review: Episodes vs Views'
        set xrange [0:${LAST_EPISODE}+5]
        set xlabel 'Episode'
        set yrange [0:${HIGHEST_VIEWS}+500]
        set ylabel 'Episode Views'
        plot \"${STMP}\" using 2:1 with boxes
        exit" | gnuplot
    rm -f ${STMP}

    display graph.svg
else
    ia-mine --secure -s SMLR | jq -r '.response.docs[] | "\(.downloads),\(.title)"' > ${STATS_FILE}
fi
