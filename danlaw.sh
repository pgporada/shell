#!/bin/bash
# PGP - based on the Panamax.io installer

BLU="\033[0;31;34m"
WHT="\033[0m\033[31;37m"
END="\033[0m"

function displayLogo1 {
    tput clear
    echo -e "\033[0;31;34m█████╗   ██████╗  ███████╗  \033[0m\033[31;37m ██╗     ██████╗  ██║╔██ ╔██\033[0m"
    echo -e "\033[0;31;34m██╔═ ██╗  ╚═══██╗ ███╗  ███╗\033[0m\033[31;37m ██║      ╚═══██╗ ██║╔██ ║██\033[0m"
    echo -e "\033[0;31;34m██║ ║██║ ███████║ ███║  ███║\033[0m\033[31;37m ██║     ███████║ ██║╔██ ║██\033[0m"
    echo -e "\033[0;31;34m██╚═ ██║ ██╔═╗██║ ███║  ███║\033[0m\033[31;37m ██╚═══╗ ██╔═╗██║ ██║╔██ ║██\033[0m"
    echo -e "\033[0;31;34m█████╗   ███████║ ███║  ███║\033[0m\033[31;37m ██████║ ███████║ ██████████\033[0m"
    echo ""
    echo "Danlaw Labs - http://www.danlawinc.com/"
}

function displayLogo2 {
    echo -e "   $BLU█████    ██████   ███████    ██      ██████   ██  ██  ██$END"
    echo -e "$WHT ╔═$BLU██$WHT═══$BLU██$WHT═══════$BLU██$WHT══$BLU█████████$WHT══$BLU██$WHT═══════════$BLU██$WHT══$BLU██$WHT══$BLU██$WHT══$BLU██$END"
    echo -e "$WHT╔  $BLU██   ██  ███████  ███   ███  ██      ███████  ██  ██  ██$END"
    echo -e "$WHT║  $BLU██   ██  ██   ██  ███   ███  ██      ██   ██  ██  ██  ██$END"
    echo -e "$WHT╚  $BLU█████    ███████  ███   ███  ██████  ███████  ██████████$END"
    echo -e "$WHT ╚═══════════════════════════╗$END"
    echo -e "$WHT                     ╚═══════╗$END"
    echo -e "$WHT                       ╚═════╗ $END"
    echo -e "$WHT                         ╚═══╗ $END"
    echo -e "$WHT                           ╚═╗ $END"
    echo ""
    echo "Danlaw Labs - http://www.danlawinc.com/"
}

displayLogo1
echo
displayLogo2
