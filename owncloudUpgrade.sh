#!/bin/bash
# This script automatically upgrades a owncloud installation and creates a backup of all important data before doing so
# Copyright (c) 2015 Pascal Wichmann

owncloudPath="/srv/http/owncloud/" # change to fit path of you owncloud installation
owncloudDataPath="/srv/webdata/owncloud/" # change to fit path of your owncloud data directory
backupDir="/backup" # change to fit path where your backup should be placed
backupVersions=5
mysqlBackup=false  # to enable mysql backup, your user needs to have a valid mysql client configuration (i.e. .my.cnf) in order to authenticate; it may be possible to authenticate interactively, however, the easiest way is to configure the mysql client correctly
mysqlBackup_database="owncloud"
webUser="www-data"
phpPath="/usr/bin/php"

if [ "$1" == "-h" ] || [ "$1" == "" ]; then
  echo "Usage: owncloudUpgrade.sh version"
  echo " version: You need to specify the version which should be installed (i.e. 8.2.2)"
  echo "Script written by Pascal Wichmann, Copyright (c) 2015"
  exit 0
fi

# check if temporary directory exists (Indicating a running process of this upgrade script)
if [ -d "/tmp/owncloudUpgrade" ]; then
  echo "Temporary directory /tmp/owncloudUpgrade is already existing. Remove it  and start the script again, but first make sure that there is NO OTHER INSTANCE of this script running."
  exit 0
fi

# validate backup versions parameter
if ! [ -z $(echo $backupVersions | tr -d 0-9) ] || [ -z "$backupVersions" ]; then  # check that the versions parameter for backups is a valid integer
  echo "The specified backup versions parameter is invalid."
  exit 0
fi

# TODO: create a dedicated script for backup which is executed separately (to have the ability to create automated owncloud backups withouth upgrade)

echo "Creating backup"

# move old backups
backupVersions=$((backupVersions-1))  # decrement backup versions count (indexing begins with 0)
# delete oldest backup (if exists)
rm -rf ${backupDir}/backup.${backupVersions} &> /dev/null
backupVersions=$((backupVersions-1))  # decrement backup versions count once again (oldest backup has already been deleted)

while [ $backupVersions -ge 0 ]
do
  mv ${backupDir}/backup.${backupVersions} ${backupDir}/backup.$((backupVersions+1)) &> /dev/null
  backupVersions=$((backupVersions-1))
done

# create directories for newest backup (and parents if backupDir does not exist yet)
mkdir -p ${backupDir}/backup.0/files

# create backup of files
rsync -a ${owncloudPath} ${backupDir}/backup.0/files

# create backup of database (if enabled)
if [ $mysqlBackup = true ]; then
  mysqldump --databases ${mysqlBackup_database} > ${backupDir}/backup.0/db.sql
fi

echo "backup finished"
echo "starting owncloud upgrade"

# create temporary directory
mkdir /tmp/owncloudUpgrade
cd /tmp/owncloudUpgrade

# download owncloud archive and extract it
curl https://download.owncloud.org/community/owncloud-${1}.tar.bz2 | tar -xj

# turn owncloud maintenance mode on
sudo -u $webUser $phpPath ${owncloudPath}occ maintenance:mode --on

# move new files
rsync -a owncloud/ $owncloudPath

# turn maintenance mode off
sudo -u $webUser $phpPath ${owncloudPath}occ maintenance:mode --off

# database upgrade
sudo -u $webUser $phpPath ${owncloudPath}occ upgrade

# remove temporary owncloud upgrade directory
rm -rf /tmp/owncloudUpgrade

echo "finished owncloud upgrade"
