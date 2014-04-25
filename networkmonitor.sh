#!/usr/bin/env bash

# Really really shitty test for a network monitor
# Don't use this, it's me playing around

while true
do
    let RX_BYTE1=$(cat /sys/class/net/eth0/statistics/rx_bytes)
    let TX_BYTE1=$(cat /sys/class/net/eth0/statistics/tx_bytes)
    let RX_BYTE2=$(cat /sys/class/net/eth0/statistics/rx_bytes)
    let TX_BYTE2=$(cat /sys/class/net/eth0/statistics/tx_bytes)
    

    RX_CUR=$(( $RX_BYTE2 - $RX_BYTE1 ))
    TX_CUR=$(( $TX_BYTE2 - $TX_BYTE1 ))
    RX_TOTAL=$(( $RX_TOTAL + $RX_CUR ))
    TX_TOTAL=$(( $TX_TOTAL + $TX_CUR ))
    RX_BPS=$( echo "scale=3 ; $RX_CUR / 1.024" | bc )
    TX_BPS=$( echo "scale=3 ; $TX_CUR / 1.024" | bc )

    echo "#-------------------#"
    echo "# Since script load #"
    echo "#-------------------#"
    echo "RX_TOTAL: $RX_TOTAL"
    echo "TX_TOTAL: $TX_TOTAL"
    echo "RX_SPEED: $RX_BPS KB/s"
    echo "TX_SPEED: $TX_BPS KB/s"
    sleep 2 && clear
done
