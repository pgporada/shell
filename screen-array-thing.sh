#!/usr/bin/env bash

screen -list
arr=($(screen -list | sed '1d;$d' | sed -e '$d' -e 's/\t//') )
for X in "${arr[@]}"; do
      if [[ "$X" = "(Detached)" ]]; then
	   echo "Screen $Previous is $X"
      elif [[ "$X" = "(Attached)" ]]; then
	   echo "Screen $Previous is $X"
      fi
      Previous=$X
done
