#!/bin/bash
# Scrapes myfitnesspal.com food diaries for information. I made this because it gave me some practice bash scripting.

usage () {
	echo -e "Usage: ${BT}mfpscraper.sh ${RT}[${BT}-d${RT}] [${BT}-h${RT}] [${BT}-i${RT}] [${BT}-u${RT}] [${BT}-w${RT}]\n
	${BT}-d #${RT} 	    : Specify a number to decrement X days and a print a single entry
	${BT}-h${RT}	    : Show this usage message
	${BT}-i #${RT}        : Specify a number to increment X days and print a range of entries
	${BT}-u username${RT} : Defaults to breakdancingcat
	${BT}-w${RT}          : Print entries for the past week\n
	----Examples----
	To run with defaults for the current day: ${BT}mfpscraper.sh${RT}
	To run yesterdays date with a different user: ${BT}mfpscraper.sh -d 1 -u username${RT}
	To get the range from 5 days ago to yesterday: ${BT}mfpscraper.sh -d 5 -i 5${RT}
	To print the past week: ${BT}mfpscraper -w${RT}"
	exit
}

getsite () {
	SITE="http://www.myfitnesspal.com/food/diary/${MFPUSER}?date=$DATE"
	wget -q "${SITE}" -O "${TEMP}"
}

# Defaults
IFS=$'\x0a'    #newline char
BT='\033[1m'
RT='\033[0m'
MFPUSER="breakdancingcat"
DATE=$(date +%Y-%m-%d)
RANGE=1
DATENUM=0
TEMP="$(mktemp)"

while getopts "hwd:i:u:" opt; do
  case $opt in
    d)
       case $OPTARG in 
            ''|*[!1-9]+$) echo "-d argument must be >0"; exit;;
	    *) DATE=$(date +%Y-%m-%d -d "$OPTARG days ago");;
       esac;;
    h) usage;;
    i)
       case $OPTARG in
           ''|*[!2-9]+$) echo "-i argument must be >1"; exit;;
           *) RANGE=$OPTARG;;
       esac;;
    w) DATE=$(date +%Y-%m-%d -d "1 week ago"); 
       RANGE=8;;
    u)
       MFPUSER=$OPTARG;;
    ?) usage;;
  esac
done

getsite
echo -e "Link: $SITE
For more usage, run ${BT}mfpscraper.sh -h${RT}\n"

if grep -qi "This Food Diary is Private" ${TEMP}
then
	echo "This food diary is private."
	unset $IFS
	rm ${TEMP}
	exit
else
	while [[ "$DATENUM" -lt "$RANGE" ]]
	do
		# Gets amount of columns between the two html tags 
		COLTOTAL=( $(sed -n '/<td class="first">Totals<\/td>/,/<td class="empty"><\/td>/p' "${TEMP}" | wc -l) )
		
		# Based on the amount of columns we have, gets us the number of lines to grep the source for the rest of the information
		SIZE=$(((5*(COLTOTAL-2))+32))
		
		# Loads wget results into an array and strips said lines of any html tags
		ARRAY=( $(grep -A${SIZE} "<td class=\"first\">Totals</td>" ${TEMP} | sed  -e '/^$/d' -e 's/<[^>]*>//g' -e 's/^[ \t]*//') )
		
		# If these fields are 0 then there is no information for that day. Kinda crude but it works
		if [[ "${ARRAY[1]}" -eq "0" && "${ARRAY[2]}" -eq "0" ]]; then
			echo -e "There is no data for $DATE\n"
		else [[ "${#ARRAY[@]}" -ne 0 ]]
			COUNT=0	
	
			# Prints out what date the following output is for
			if [[ "$DATE" = "$(date +%Y-%m-%d)" ]]; then
				echo "Printing data for today: $DATE"
			else
				echo "Printing data for: $DATE"
			fi
		
			for X in "${ARRAY[@]}"
			do
				# Prints the giant space on the 4th line to shift the words underneath the numbers
				if [[ "$X" = "Calories" ]]; then
					printf "%$((${#MFPUSER}+13))s" ""
				fi

				# Prints and formats the first 3 lines because they dont need to be shifted over like the 4th line
				if [[ "$X" != "Calories" && $(($COUNT%$((COLTOTAL-1)))) = 0 ]]; then
					printf "%${#ARRAY[$((COLTOTAL-1))]}s" "${X}"
				else
					printf "%8s" "${X}"
				fi
			
				# Prints a newline at the end of each row
				if [[ $(($COUNT%$((COLTOTAL-1)))) -eq $((COLTOTAL-2)) ]]; then
					echo
				fi
				((COUNT++))
			done
		echo -e "\n"
		fi

		((DATENUM++))
		NEWDATE=$DATE
		DATE=$(date +%Y-%m-%d -d "$NEWDATE + 1 day")
		getsite
	done
	unset $IFS
	rm ${TEMP}
fi
