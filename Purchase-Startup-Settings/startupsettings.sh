#!/bin/sh

# (c) 2009 Walter Meyer SUNY Purchase College

# System startup script that should be a Launchd startup item, the script deletes itself and the launchd item after completion.
# See comments for what this script does.

# Define 'kickstart' variable for ARD configuration.
kickstart="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

# Don't continue the script until DS scripts are done running and we have network access.
while [ -f /Library/LaunchAgents/com.deploystudio.finalizeScript.plist ]; do sleep 3; done
until ping -c 1 8.8.8.8; do sleep 3; done # Ping DNS server to check for network.

### Begin Settings ###
### Begin Remote Access ###
# Set options and activate ARD for only ctstech user with all privelages and to allow for directory controlled ARD access.
# First we have to define specified users with ARD privelages in a separate command.
$kickstart -activate -configure -users ctstech -access -on -privs -all
# The next command configures the other ARD options.
$kickstart -activate -configure -allowAccessFor -specifiedUsers -clientopts -setmenuextra -menuextra  yes -setdirlogins -dirlogins -yes -setreqperm -reqperm yes
# Activate and restrict SSH access to a specific group and the local admin.
/usr/sbin/systemsetup -setremotelogin on
localadminUID=`/usr/bin/dscl localhost -read /Local/Default/Users/admin | grep GeneratedUID | awk '{print $2}'`
/usr/bin/dscl localhost -create /Local/Default/Groups/com.apple.access_ssh
/usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh GroupMembers "$localadminUID"
/usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh GroupMembership "admin"
# /usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh NestedGroups "00000000-0000-0000-0000-28D8E3AA4EF8" # some AD group GUID
# /usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh RealName 'Remote Login ACL'
# /usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh PrimaryGroupID 403
### End Remote Access ###

### Begin Power ###
# Set system sleep setting to 140 minutes. And wake or start daily at 2AM to run updates if needed.
/usr/bin/pmset sleep 140
/usr/bin/pmset repeat wakeorpoweron MTWRFSU 02:00:00
# Activate WakeOnLAN.
/usr/sbin/systemsetup -setwakeonnetworkaccess on
### End Power ###

### Begin Network ###
# Set computername, localhostname, and hostname based on Active Directory name the machine is bound with.
name=$(dsconfigad -show | grep "Computer Account" | awk '{print$4}')
/usr/sbin/scutil --set ComputerName $name
/usr/sbin/scutil --set LocalHostName $name
/usr/sbin/scutil --set HostName $name.purchase.edu
# Enable Firewall.
/usr/bin/defaults write /Library/Preferences/com.apple.alf globalstate -int 1
/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist
/bin/launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist
/bin/launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
/bin/launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist
# Disable Guest Folder Sharing
/usr/bin/defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool no
/usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool no
### End Network ###

### Begin Misc ###
# Allow users to set DVD Region Code
/usr/libexec/PlistBuddy -c "Set :rights:system.device.dvd.setregion.initial:class allow" /private/etc/authorization
# Delete iMove (Previous Version) Directory if it exists, because we don't need it.
/bin/rm -R /Applications/iMovie\ \(previous\ version\).localized/
### End Misc ###
### End Settings ###

### Cleanup ###
# Delete the script and the launchd item.
/usr/bin/srm /Library/LaunchDaemons/edu.purchase.startupsettings.plist
/usr/bin/srm "$0"
