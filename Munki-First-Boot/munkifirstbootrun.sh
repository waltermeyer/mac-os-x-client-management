#!/bin/sh

# (c) 2010 Walter Meyer SUNY Purchase College
# This script runs munki and installs all available updates until none are available.
# Meant to be run in a post-image first boot scenario.

until /sbin/ping -c 1 munkiserver.yourorg.com; do /bin/sleep 3; done # Make sure we can talk to the server before running.

updates=1 # Set updates to equal 1 so we check for updates atleast once.

until [ $updates = 0 ] # Run this loop until there aren't any updates available.
do
	/usr/local/munki/managedsoftwareupdate --quiet --munkistatusoutput
	updates=$(/usr/bin/defaults read /Library/Preferences/ManagedInstalls LastCheckResult)
	apple_updates=$(/usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate LastResultCode)
	require_restart=$(/usr/bin/defaults read /Library/Managed\ Installs/ManagedInstallReport RestartRequired)

	if [ "$apple_updates" -eq "0" ] || [ -n "$require_restart" ] ; then # If updates are available and a restart is required or if there are Apple Updates.
		/bin/echo "Found updates to install that require a reboot..."
		/usr/local/munki/managedsoftwareupdate --installonly --munkistatusoutput
		# We need to make sure launchd starts this script again because we are rebooting.
		/usr/bin/defaults write "$3/Library/LaunchDaemons/edu.purchase.munkifirstboot" ProgramArguments /Library/Scripts/Purchase/munkifirstbootrun.sh
		/sbin/shutdown -r now
		exit 0

	elif [ "$updates" -eq "1" ] ; then # If updates are available and a restart is NOT required.
		/bin/echo "Found updates to install..."
		/usr/local/munki/managedsoftwareupdate --installonly --munkistatusoutput
		updates=1 # Set updates to equal 1 again so we check for updates again.
	else
		/bin/echo "No new updates were found. Munki first boot execution complete."
	fi
done

# Cleanup. I'm finished!
/usr/bin/srm /Library/LaunchDaemons/edu.purchase.munkifirstboot.plist
/usr/bin/srm /Library/Scripts/Purchase/munkifirstbootconfig.sh
/usr/bin/srm "$0"
