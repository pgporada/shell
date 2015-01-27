#!/usr/bin/env bash
for LOG_NAME in "$@"; do

echo "${LOG_NAME}"
sleep 10

awk '/(18|19|2.)\/Sep/ 				{ 	# First pattern I used was /somefile.css/ and then just /.css/ and then matching dates 
  ts=substr($4,2,14); 					# 14 = hour ; 16 = 10 minutes ; 17 = minutes
							# $4 = "[22/Sep/2014:09:01:49"
							#        2            H TM
							# H = substr($4,2,14) = 22/Sep/2014:09
							# T = substr($4,2,16) = 22/Sep/2014:09:0
							# M = substr($4,2,17) = 22/Sep/2014:09:01
  if (ts != prevts) {
    printf("\n%s ", ts);				# Print timestamp ever hour/10 minutes/minute depending on above substr length
    prevts=ts;
  };
  if ($9 == 200) {                  printf("."); } 	# OK
  else if ($9 == 500) {             printf("!"); }	# Error
  else if ($9 == 404) {             printf("?"); } 	# Not found
  else if (substr($9,1,1) == "3") { printf(">"); } 	# Redirect
  else {                            printf(substr($9, 1,1)); } # Unknown, print first number of status code
}' "${LOG_NAME}" | sort -k1 ; echo
done;
