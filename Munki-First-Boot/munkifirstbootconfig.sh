#!/bin/sh

# (c) 2010 Walter Meyer SUNY Purchase College
# Sets our munki settings based on various variables.
# Script is meant to be run on first boot using launchd.

while [ -f /Library/LaunchDaemons/edu.purchase.startupsettings.plist ]; do /bin/sleep 3; done # Wait until our first-boot image setting script is done running.

## Munki Client Configuration
/bin/echo '/usr/local/munki' >> "$3/etc/paths" # Echo the munki tools path to the end of the path file.

## Set ClientIdentifier
# Let's find out who we are. Our client needs a ClientIdentifier set in order to get the right manifest.
# We need to get some information to set it automatically and properly.

# See if this is a faculty/staff machine based on the InstaDMG log.
computer_name=$(/usr/libexec/PlistBuddy -c "Print System:System:ComputerName" $3/Library/Preferences/SystemConfiguration/preferences.plist)
typecheck=$(/bin/cat /private/var/log/AutoDMG* | /usr/bin/grep "facstaff")

if [ -n "$typecheck" ]; then # if this variable is not null, we are a facstaff machine.
	type=facstaff
	dept=$(defaults read  $3/Library/Preferences/com.apple.RemoteDesktop Text1) # Dept code HAD to be set during DS workflow in Computer Information Field #1 otherwise this will fail.
	building=$(/bin/echo $computer_name | cut -c 1-2)

	get_computeraccount_length=$(/bin/echo $computer_name | awk '{print length}')
	if [ "$get_computeraccount_length" = 12 ]; then
		room=$(/bin/echo $computer_name | cut -c 3-7)
		workstation=$(/bin/echo $computer_name | cut -c 9-12)
	else
		room=$(/bin/echo $computer_name | cut -c 3-6)
		workstation=$(/bin/echo $computer_name | cut -c 8-11)
	fi
	ClientIdentifier=$(/bin/echo groups/all-$type-$dept-$building-$room-$workstation) # Faculty staff primary manifests are defined to the workstation number "level".
	/usr/bin/defaults write "$3/Library/Preferences/ManagedInstalls" ClientIdentifier $ClientIdentifier
else
	type=labs
	dept=$(defaults read  $3/Library/Preferences/com.apple.RemoteDesktop Text1) # Dept code HAD to be set during DS workflow in Computer Information Field #1 otherwise this will fail.
	building=$(/bin/echo $computer_name | cut -c 1-2)

	get_computeraccount_length=$(/bin/echo $computer_name | awk '{print length}')
	if [ "$get_computeraccount_length" = 12 ]; then
		room=$(/bin/echo $computer_name | cut -c 3-7)
	else
		room=$(/bin/echo $computer_name | cut -c 3-6)
	fi
	ClientIdentifier=$(/bin/echo groups/all-$type-$dept-$building-$room)
	/usr/bin/defaults write "$3/Library/Preferences/ManagedInstalls" ClientIdentifier $ClientIdentifier
	/usr/bin/defaults write "$3/Library/Preferences/ManagedInstalls" SuppressUserNotification -bool TRUE # We don't want to prompt users in a lab setting.
fi

## Generate Manifests

# Generate manifests if we are a Faculty/Staff machine.
if [ -n "$typecheck" ]; then
/usr/bin/curl -F "dept=$dept" -F "building=$building" -F "room=$room" -F "workstation=$workstation" -user:password --digest http://munkiserver.yourorg.com/generate/generate.php
fi

# Run our first boot update check script.
/etc/hooks/munkifirstbootrun.sh

exit 0
