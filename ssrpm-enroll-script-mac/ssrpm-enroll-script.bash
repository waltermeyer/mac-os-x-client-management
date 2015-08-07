#!/bin/bash

# This script queries a web page to check if a user is enrolled in a password management system and opens a webpage for enrollment if they are not.
# It should be called/launched by something that runs in the user's context on login. e.g. a LaunchAgent.

##
user=$(whoami) # Who is logging in.
enrollment_user_check_url="https://ssrpm.purchase.edu/purchase_verify.asp?user=$user"
enrollment_redirect_url="https://ssrpm.purchase.edu/purchase_welcome.asp"
enrollment_server_url="https://ssrpm.purchase.edu/purchase_mac_active.asp"

user_is_enrolled=$(curl $enrollment_user_check_url) # Check if the user is enrolled
enrollment_server_active=$(curl $enrollment_server_url) # Get server status 
##

if [ "$enrollment_server_active" == "True" ]; then # Enrollment server is active
	## and user is not enrolled...
	if [ "$user_is_enrolled" = "False" ]; then
		echo "User is NOT enrolled in SSRPM, opening the enrollment webpage."
		open $enrollment_redirect_url
		exit 0
	## and user is enrolled...
	elif [ "$user_is_enrolled" == "True" ]; then 
		echo "The user is already enrolled in SSRPM, exiting."
		exit 0
	fi
	
elif [ "$enrollment_server_active" == "False" ]; then # Enrollment server is inactive
	echo "The enrollment server is reporting that it is inactive or it is not responding appropriately, exiting."
	exit 1

else # Something unexpected happened
	echo "A non-specific error occurred, exiting."
	exit 2
fi	
