#!/bin/bash
for i in $(ls -al | awk '{print $9}' | sed -e '/\./d' -e '/^$/d'); do
    pushd $i
    git pull
    popd
done
