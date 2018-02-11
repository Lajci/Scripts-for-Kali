#!/bin/bash
# This script will change the MAC address of a Linux system. 
#
# require: adapter name

if [ $1 ] # Checks for argument
then
	oldmac=`ifconfig | grep 'HWaddr' | cut -c 39-`

	MAC=`echo -n 00; hexdump -n 5 -v -e '/1 ":%02X"' /dev/urandom;`
	
	# disables adapter, changes MAC, enables adapter
	ifconfig $1 down
	ifconfig $1 hw ether $MAC
	ifconfig $1 up

	newmac=`ifconfig | grep 'HWaddr' | cut -c 39-`

	echo "Old MAC: " $oldmac
	echo "New MAC: " $newmac
else
	echo "Usage: ./rand_mac.sh <adapter>"
fi