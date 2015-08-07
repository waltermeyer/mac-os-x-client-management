#!/bin/bash

#
# Script to restore or create a Windows XP NTFS formatted dmg.
# (c) Walter Meyer Purchase College SUNY
# Inspired and some code ideas taken from the WinClone perl script. http://www.twocanoes.com/winclone/
#

# Make sure we are root first.
rootcheck() {
	if [ $EUID != 0 ]; then
		echo "You must run this script using sudo or as root!"
		exit 1
	fi
}
rootcheck

# Put ourselves in the directory our script is running from.
cd "`dirname "$0"`"

# Find out what we are going to do.
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "Welcome to WinRip. What do you want to do?"
echo "Select 1 or 2 and press [Enter]"
echo ""
echo "1) Create a Windows NTFS Image"
echo "2) Restore a Windows NTFS Image"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo ""
read SELECTION
case $SELECTION in


########### Begin Create a Windows NTFS Image ###########
# Option 1 was selected.
"1")
echo ""
echo "Creating a Windows NTFS Image..."

# Find what we are creating our image from.
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "Partitions on this System:"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
diskutil list
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "What partition do you want to create the Windows image from? (Specify the disk AND the slice. e.g. /dev/disk1s2)"
echo "Type in the disk device and slice e.g. /dev/disk1s2 and press [Enter]"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo ""
read CLONE_SOURCE

# Resize our source partition to the smallest possible size plus 2GB. This gives us a little breathing room and restore flexibility.
# But first check if a Windows.dmg file exists in our script directory.
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "1/3 Shrinking source disk..."
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
if [ -f ./Windows.dmg ];
then
	echo "A file named Windows.dmg already exists in the output directory. Move it or lose it! Exiting."
	exit 1
else 
	/usr/sbin/diskutil unmount $CLONE_SOURCE
	MIN_SIZE=$(./ntfstools/ntfsresize -i -f $CLONE_SOURCE | grep "You might resize" | awk '{print $5}')
	SHRINK_SIZE=$[$MIN_SIZE + 2000000000]
	./ntfstools/ntfsresize -f -f -s $SHRINK_SIZE $CLONE_SOURCE
fi


# Start restore.
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "2/3 Cloning source disk..."
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/usr/bin/hdiutil create -puppetstrings -srcdevice $CLONE_SOURCE Windows.dmg

# Expand our source disk back to the maximum size of the partition.
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "3/3 Expanding source disk..."
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
./ntfstools/ntfsresize -f -f $CLONE_SOURCE

echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "Windows image creation complete!"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
exit 0

;;
########### End Create a Windows NTFS Image ###########


########### Begin Restore a Windows NTFS Image ###########
# Option 2 was selected.
"2")
echo ""
echo "Restoring a Windows NTFS Image..."

# Find out where we are restoring our image to.
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "Disks on this System:"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
diskutil list
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "Where do you want to restore the Windows image to?"
echo "If you want to restore the image to an entire disk specify the disk ONLY. e.g. /dev/disk1"
echo "If you want to restore the image to a partition or volume specify the disk AND the slice. e.g. /dev/disk1s2 "
echo "Then press [Enter]"
echo "****THIS WILL ERASE ALL DATA ON THE TARGET BE VERY CAREFUL!****"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo ""
read FORMAT_TARGET

# Check if Windows.dmg is in the WinRip directory. Attach our Windows image, but don't mount it so it is ready to be our source.
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "1/5 Attaching the Windows Image..."
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
if [ ! -f ./Windows.dmg ]; 
then 
	echo "Can't find a Windows.dmg file to restore in the WinRip directory. One should be there if you want me to work! Bye for now."
	exit 1
else
	RESTORE_SOURCE=$(/usr/bin/hdiutil attach -nomount -noverify ./Windows.dmg | grep "/dev/disk")
fi

# Find out if we are restoring to a Voume or a Disk, then format the target, name it and unmount it.
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "2/5 Erasing and renaming the target disk..."
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
VOLUME=12
RESTORE_TARGET_TYPE=$(echo $FORMAT_TARGET | awk '{print length}') # See if the target is a Volume or an entire Disk based on the length of the string.
if [ "$RESTORE_TARGET_TYPE" -eq "$VOLUME" ];
then
	RESTORE_TARGET=/dev/$(/usr/sbin/diskutil eraseVolume MS-DOS WINDISK $FORMAT_TARGET | grep "Finished erase" | awk '{print $4}') # Volume erase
else
	RESTORE_TARGET=/dev/$(/usr/sbin/diskutil eraseDisk MS-DOS WINDISK GPT $FORMAT_TARGET | grep "Formatting disk" | awk '{print $2}') # Disk erase
fi
/usr/sbin/diskutil rename $RESTORE_TARGET WINDISK
/usr/sbin/diskutil unmount $RESTORE_TARGET

# Use ntfsclone to restore the image. Expand the NTFS partition to the size of the underlying device. Then mount it when the operation is done.
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "3/5 Starting restore..."
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo ""
./ntfstools/ntfsclone --rescue -f -f -f -O $RESTORE_TARGET $RESTORE_SOURCE
./ntfstools/ntfsresize -f -f $RESTORE_TARGET
/usr/sbin/diskutil mount $RESTORE_TARGET

# Get our restored volume name even if it has spaces, the partition number for our boot.ini, then update the boot.ini on our target partition.
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "4/5 Updating boot.ini..."
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
PARTITION_NUMBER=$(echo $RESTORE_TARGET | sed 's/...........\(.*\)/\1/')
RESTORED_VOL=$(diskutil info $RESTORE_TARGET | grep 'Escaped with Unicode:     /Volumes/' | awk '{print $4}' | sed s/%FF%FE%20%00/' '/)
cat "$RESTORED_VOL"/boot.ini | sed 's/partition(.*)/partition('$PARTITION_NUMBER')/' > /tmp/boot.ini
/usr/sbin/diskutil unmount $RESTORE_TARGET
./ntfstools/ntfscp -f $RESTORE_TARGET /tmp/boot.ini /boot.ini

# Use gptrefresh to update the mbr on our target disk appropriately, set it as bootable, and restore the boot sector.
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "5/5 Syncing Partition Tables..."
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
DISK_DEVICE=/dev/$(/usr/sbin/diskutil info $FORMAT_TARGET | grep "Part Of Whole" | awk '{print $4}') # Get our target disk device for gptrefresh
/usr/sbin/diskutil mount $RESTORE_TARGET
/bin/dd if="$RESTORED_VOL"/WINDOWS/system32/dmadmin.exe of=/tmp/mbr skip=216616 count=446 bs=1
/usr/sbin/diskutil unmount $RESTORE_TARGET
./ntfstools/gptrefresh -v -w -f -u -m /tmp/mbr -a $PARTITION_NUMBER -i 0x07 $DISK_DEVICE

echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "Windows restore complete!"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/usr/sbin/diskutil mount $RESTORE_TARGET
exit 0
;;
########### End Restore a Windows NTFS Image ###########

esac
