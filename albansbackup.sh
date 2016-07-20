#!/bin/sh
#
# This script will backup and restore folders using the incremental option of TAR
# You don't need to create a full backup each time
# The second backup will be a diferencial backup. You will save time and space.
# You just need to change the variables DIRTOBACKUP, BACKUPDESTINATION and DIRTORESTORE
#
# josemedeirosdealmeida@gmail.com
# Jose Almeida

DIRTOBACKUP=/var/log			# Folder to backup
BACKUPDESTINATION=/mnt/aaaa		# Storage path
SNAPSHOTFILE=snap.db			# This file can be changed, but cannot be deleted
REFERENCE=mydata			# This reference name will be used to create the file name, can be changed to another word
DIRTORESTORE=/mnt/restore		# Folder to restore our tar files

backup () {
echo "This will backup your $DIRTOBACKUP folder using as snapshot file $BACKUPDESTINATION/$SNAPSHOTFILE. You can run the script several times.\n\n"
mkdir -p $BACKUPDESTINATION
tar --create --file=$BACKUPDESTINATION/back_$(echo $REFERENCE)_$(date +\%Y\%m\%d_\%H\%M\%S).tar --listed-incremental=$BACKUPDESTINATION/$SNAPSHOTFILE $DIRTOBACKUP
exit 0
}

restore () {
mkdir -p $DIRTORESTORE
ls -ltr $BACKUPDESTINATION/back_$REFERENCE* | awk '{print $9}' > /tmp/albansbackup.tmp
sleep 1
  while read line; do
        tar --extract --listed-incremental=$BACKUPDESTINATION/$SNAPSHOTFILE --file $line -C $DIRTORESTORE
  done < /tmp/albansbackup.tmp
rm -f /tmp/albansbackup.tmp
exit 0
}

restoreuntil () {
ls -ltr $BACKUPDESTINATION/back_$REFERENCE* > /tmp/albansbackup.tmp


exit 0
}
 
while :
do
echo "************************"
echo "* Albans Backup System *"
echo "************************"
echo "* [b] Backup 	     *"
echo "* [r] Restore	     *"
echo "* [u] Restore Until    *"
echo "* [q] Exit 	     *"
echo "************************"
echo -n "Select: "
read yourch
case $yourch in
b) backup ;;
r) restore ;;
u) restoreuntil ;;
q) exit 0;;
*) echo "Menu: ";
echo "Press Enter to continue. . ." ; read ;;
esac
done
