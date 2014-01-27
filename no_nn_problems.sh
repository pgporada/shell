#!/usr/bin/env bash

# This script is for my work laptop and takes care of starting our ticket notifier script nn.sh
# I get really tired of having more than one of the nn.sh script load so here's my engineered way
# of dealing with that. OSX 10.8 doesn't offer file locking and I didn't feel like perling it up

NNPATH="/Users/$(whoami)/.nsak/common/bin/nn.sh"

if [ ! -f "${NNPATH}" ] ; then
   echo "nn.sh does not exist in "${NNPATH}""
   exit 1
fi

N=0
for i in $( ps -ef | grep -v grep | grep nn.sh | awk '{print $2}' ) ; do
   array[$N]=${i}
   let "N=$N+1"
done

if [ $N -gt 1 ]; then
   # This is pretty cool, shows all the elements of the array except the first one
   echo "Killing off the following nn.sh's: $( echo ${array[@]:1} )"
   sudo kill -9 ${array[@]:1}
elif [ $N -eq 0 ] ; then
   echo "Loading the notifier in the background"
   "${NNPATH}" &
else
   echo "No nn.sh's to kill off"
fi
