#!/bin/bash
# usage: vhost_off.sh 192.168.1.1
cd /etc/httpd/vhosts.d ; grep ${1} * | awk -F":" '{print "mv " $1 " " $1".OFF"}' | uniq
