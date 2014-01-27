#!/bin/sh

TODAY=`date +%Y%m%d`
SCPSEND="/Volumes/Server HD/Library/WebServer/Documents/Count Day/RunningLogs"

`scp -q USER@XXX.XXX.XXX.XXX:"/Volumes/FirstClass\ HD/Master/Statistics/${TODAY}.txt" "$SCPSEND"`

FILE="/Volumes/Server HD/Library/WebServer/Documents/Count Day/RunningLogs/${TODAY}.txt"
OUTPUT="/Volumes/Server HD/Library/WebServer/Documents/Count Day/Districts/Logs/${TODAY}_count.txt"

if [ -e "$FILE" ]
    then
         grep -vE 'admin|999999|1000000000|18850040' "$FILE" > /tmp/${TODAY}_count.a.txt
         grep -w 'Login' /tmp/${TODAY}_count.a.txt | awk '{$1=$1; print}' OFS="," > /tmp/${TODAY}_cdls.txt 
	     awk -F, '{if(NF==7 && $6 !~ /^[a-zA-Z]/)print $1,$2,$3,$4,$5,"NA","NA",$6,$7;
else if(NF==8 && $6 !~ /^[0-9]/)print $1,$2,$3,$4,$5,"NA",$6,$7,$8;
else if(NF==8 && $7 !~ /^[a-zA-Z]/)print $1,$2,$3,$4,$5,$6,"NA",$7,$8;
else print $0}' OFS=, /tmp/${TODAY}_cdls.txt > "$OUTPUT"
fi

rm /tmp/${TODAY}_cdls.txt
rm /tmp/${TODAY}_count.a.txt

##############################################
##############################################

FILE2="/Volumes/Server HD/Library/WebServer/Documents/Count Day/Districts/Logs/${TODAY}_count.txt"
INPUT2="/tmp/${TODAY}_cdrg.txt"
OUTPUT2="/Volumes/Server HD/Library/WebServer/Documents/Count Day/Districts/"

#Removes experts and mentors because they will never have a team name in field 7
awk -F, '{if($7 !~ /^NA/)print $1,$2,$5,$7}' OFS=, "$FILE2" > "$INPUT2"

for TEAM in X Y Z P Clio04 WISD01 WISD02 WISD03 WISD04 WISD05 WISD06 WISD07 GISD01 GISD02 LISD01 Hale01 WTRV01 OISD01 NWST01 Niles01 MAISD01 Lakeview01 OISD02 Niles02
do
awk -F, -v TEAM="$TEAM" '{if($4 == TEAM)print $1,$3}' OFS="     " "$INPUT2" > "$OUTPUT2""$TEAM"/"$TODAY"_"$TEAM"_Count.txt.tmp
sort -k3 "$OUTPUT2""$TEAM"/"$TODAY"_"$TEAM"_Count.txt.tmp > "$OUTPUT2""$TEAM"/"$TODAY"_"$TEAM"_Count.txt
rm "$OUTPUT2""$TEAM"/"$TODAY"_"$TEAM"_Count.txt.tmp
done 
rm "$INPUT2"  
