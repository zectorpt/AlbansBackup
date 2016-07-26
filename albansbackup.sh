#!/bin/bash
#
# This script will backup and restore folders using the incremental option of TAR
# You don't need to create a full backup each time
# The second backup will be a diferencial backup. You will save time and space.
# You just need to change the variables DIRTOBACKUP, BACKUPDESTINATION and DIRTORESTORE
#
# josemedeirosdealmeida@gmail.com
# Jose Almeida

#Load Variables
source albans.conf

config () {
summary
#echo "The folder configured to backup is $DIRTOBACKUP press [ENTER] to continue without changes or insert a new folder"
echo "Folder to backup  $DIRTOBACKUP"
echo "Folder to store your backup $BACKUPDESTINATION"
echo "Snapshot file: $SNAPSHOTFILE"
echo "Name to be used by system as a reference: $REFERENCE"
echo "Folder that will be used to restore everything: $DIRTORESTORE"
echo -e '\n\n'
read -p "Press [Enter] key to continue..."
menu
}

backup () {
summary
echo "This will backup your $DIRTOBACKUP folder using as snapshot file $BACKUPDESTINATION/$SNAPSHOTFILE. You can run the script several times."
echo -e '\n\n'
mkdir -p $BACKUPDESTINATION
tar -v --create --file=$BACKUPDESTINATION/back_$(echo $REFERENCE)_$(date +\%Y\%m\%d_\%H\%M\%S).tar --listed-incremental=$BACKUPDESTINATION/$SNAPSHOTFILE $DIRTOBACKUP
read -p "Press [Enter] key to continue..."
menu
}

restore () {
summary
echo "All files will be restored to: $DIRTORESTORE"
mkdir -p $DIRTORESTORE
ls -ltr $BACKUPDESTINATION/back_$REFERENCE* | awk '{print $9}' > /tmp/albansbackup.tmp
sleep 1
  while read line; do
        tar -v --extract --listed-incremental=$BACKUPDESTINATION/$SNAPSHOTFILE --file $line -C $DIRTORESTORE
  done < /tmp/albansbackup.tmp
rm -f /tmp/albansbackup.tmp
read -p "Press [Enter] key to continue..."
menu
}

restoreuntil () {
summary
echo "All files will be restored to: $DIRTORESTORE"
ls -ltr $BACKUPDESTINATION/back_$REFERENCE* | awk '{print $5,"\t\t",$6,"\t\t",$7,"\t",$8,"\t",$9}' > /tmp/albansbackup.tmp
cp /tmp/albansbackup.tmp /tmp/albansbackup.tmp.1
echo -e 'Index\tSize\t\tTimestamp\t\t\tFilename' > /tmp/albansbackup.tmp
awk '$0=((NR-1)?NR-0:"1")"      "$0' /tmp/albansbackup.tmp.1 >> /tmp/albansbackup.tmp
cat /tmp/albansbackup.tmp
echo -e '\n'
read -p "Select the Index file until you want to restore (included) or press 0 to exit: " index
#Check if is integer
if ! [ "$index" -eq "$index" ] 2> /dev/null
then
    echo "Select a value from Index"
    sleep 3
    clear
    restoreuntil
fi
#Build the list of files to restore
cat /tmp/albansbackup.tmp.1 | awk '{print $5}' | head -n $index > /tmp/albansbackup.tmp.until
mkdir -p $DIRTORESTORE
sleep 1
  while read line; do
        tar -v --extract --listed-incremental=$BACKUPDESTINATION/$SNAPSHOTFILE --file $line -C $DIRTORESTORE
  done < /tmp/albansbackup.tmp.until
rm -f /tmp/albansbackup.tm*
read -p "Press [Enter] key to continue..."
menu
}

findcontent () {
exit 0
}

listdiferences () {
exit 0
}

summary () {
clear
echo "************************"
echo "* Albans Backup System *"
echo "************************"
echo -e '\n'
}

menu () { 
clear
while :
do
echo "************************"
echo "* Albans Backup System *"
echo "************************"
echo "* [c] Config System    *"
echo "* [b] Backup 	     *"
echo "* [r] Restore	     *"
echo "* [u] Restore Until    *"
echo "* [x] Exit 	     *"
echo "************************"
echo -n "Select: "
read yourch
case $yourch in
c) config ;;
b) backup ;;
r) restore ;;
u) restoreuntil ;;
x) exit 0;;
*) echo "Menu: ";
echo "Press Enter to continue. . ." ; read ;;
esac
done
}

menu
