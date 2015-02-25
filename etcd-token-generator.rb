#!/usr/bin/env ruby

puts "TOKEN SHOULD BE BELOW"
print "=>" + `curl -s https://discovery.etcd.io/new | awk -F'/' '{printf $4}'` + "<="
