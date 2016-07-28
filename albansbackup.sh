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
source albans.conf
summary
#echo "The folder configured to backup is $DIRTOBACKUP press [ENTER] to continue without changes or insert a new folder"
echo -e 'Insert a new configuration information or press [ENTER] to continue without changes\n'
echo -e '\n\n'

read -p "Folder to backup is $DIRTOBACKUP define a new one or press ENTER to continue: " DIRTOBACKUPNEW
if [ "$DIRTOBACKUPNEW" == "" ] ; then
  echo > /dev/null #Just proceed please...
else
  sed -i "/DIRTOBACKUP/c \DIRTOBACKUP=$DIRTOBACKUPNEW			# Folder to backup" albans.conf
fi

read -p "Folder to store your backup is $BACKUPDESTINATION define a new one or press ENTER to continue: " BACKUPDESTINATIONNEW
if [ "$BACKUPDESTINATIONNEW" == "" ] ; then
  echo > /dev/null #Just proceed please...
else
  sed -i "/BACKUPDESTINATION/c \BACKUPDESTINATION=$BACKUPDESTINATIONNEW		# Storage path" albans.conf
fi

read -p "Snapshot file is $SNAPSHOTFILE define a new one or press ENTER to continue: " SNAPSHOTFILENEW
if [ "$SNAPSHOTFILENEW" == "" ] ; then
  echo > /dev/null #Just proceed please...
else
  sed -i "/SNAPSHOTFILE/c \SNAPSHOTFILE=$SNAPSHOTFILENEW			# This file can be changed, but cannot be deleted" albans.conf
fi

read -p "Name to be used by system as a reference is $REFERENCE define a new one or press ENTER to continue: " REFERENCENEW
if [ "$REFERENCENEW" == "" ] ; then
  echo > /dev/null #Just proceed please...
else
  sed -i "/REFERENCE/c \REFERENCE=$REFERENCENEW			# This reference name will be used to create the file name, can be changed to another one" albans.conf
fi

read -p "Folder that will be used to restore everything is $DIRTORESTORE define a new one or press ENTER to continue: " DIRTORESTORENEW
if [ "$DIRTORESTORENEW" == "" ] ; then
  echo > /dev/null #Just proceed please...
else
  sed -i "/DIRTORESTORE/c \DIRTORESTORE=$DIRTORESTORENEW			# Folder to restore our tar files. Can be a TAPE, or network file" albans.conf
fi

read -p "Press [Enter] key to continue..."
menu

}

showvars () {
source albans.conf
summary
echo "The folder configured to backup is $DIRTOBACKUP"
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
read -p "Select the Index file until you want to restore (included) or press ENTER to exit: " index
#Check if the variable index is lesser or equal than the number of lines of /tmp/albansbackup.tmp.1
if [ $index -le "$(wc -l /tmp/albansbackup.tmp.1|awk {'print $1'})" ];
then
    sleep 1
echo -e 'Building the list of files to restore\n'
sleep 2
cat /tmp/albansbackup.tmp.1 | awk '{print $5}' | head -n $index > /tmp/albansbackup.tmp.until
mkdir -p $DIRTORESTORE
sleep 1
  while read line; do
        tar -v --extract --listed-incremental=$BACKUPDESTINATION/$SNAPSHOTFILE --file $line -C $DIRTORESTORE
  done < /tmp/albansbackup.tmp.until
rm -f /tmp/albansbackup.tm* #Activate to clean logs
read -p "Press [Enter] key to continue..."
menu
else
menu
fi
}

findcontent () {
#Not ready yet
exit 0
}

listdiferences () {
#Not ready yet
exit 0
}

summary () {
clear
echo "************************"
echo "* Albans Backup System *"
echo "************************"
}

menu () { 
clear
while :
do
echo "***************************"
echo "* Albans Backup System    *"
echo "***************************"
echo "* [c] Config System       *"
echo "* [s] Show configuration  *"
echo "* [b] Backup 	        *"
echo "* [r] Restore	        *"
echo "* [u] Restore Until       *"
echo "* [x] Exit 	        *"
echo "***************************"
echo -n "Select: "
read yourch
case $yourch in
c) config ;;
s) showvars ;;
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
