#!/bin/bash
# http://mywiki.wooledge.org/BashGuide/Arrays
set -o pipefail
set -u

declare RUN_REFRESH=""
declare RUN_DETAILS=""
declare DETAILS=""
declare -a TAGS

while getopts ":a:b:c:" opt; do
  case $opt in
    a) RUN_REFRESH="${OPTARG:-}";;
    b) RUN_DETAILS="${OPTARG:-}";;
    c) DETAILS="${OPTARG:-}";;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ ! -z "${RUN_REFRESH}" ]; then
    echo "Running refresh"
	TAGS=("sdt_import")
else
    echo "Not running refresh"
fi

if [ ! -z "${RUN_DETAILS}" ]; then
    echo "Running details"
	TAGS+=("sdt_refresh")
else
    echo "Not running details"
fi

if [ ! -z "${DETAILS}" ]; then
    echo "Details are ${DETAILS}"
else
    echo "No details chosen"
fi

( IFS=,; echo "Tags are ${TAGS[*]}" )
