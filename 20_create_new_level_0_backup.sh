#!/usr/bin/sh -vx
#
# This script is part of performing Oracle Incremental Merge and Live Mount with Data Domain Fastcopy with Data Domain BoostFS
#
# Script: 20_create_new_level_0_backup.sh
#
# Author: Trichy Premkumar, prem@acslink.net.au
#
# Disclaimer: Scripts have been developed for testing Oracle incremental merge with Data Domain fastcopy
#             No support or warranty is included
#
#             #IWork4DELL
#
# Pre-requisites:
#
# - BoostFS setup and mounted.  10_mount_boostfs.sh has been executed and BoostFS has been setup
#
# Function:
#
# - Script to create a new Level 0 backup.  It will delete old Level 0 backup, on Data Domain, it does not affect previous backups using this copy
#

#
# Read environment varibles
#
if [ -z ${SCRIPTS_DIR} ]
then
  echo " "
  echo "Location of scripts is not know - please set environment variable SCRIPTS_DIR to the location of scripts"
  echo " "
  exit 1
else
  if [ -f ${SCRIPTS_DIR}/00_set_environment.sh ]
  then
      . ${SCRIPTS_DIR}/00_set_environment.sh
  else
      echo " "
      echo "Environment variable script cannot be located.. exiting."
      echo " "
      exit 1
  fi
fi
#
#
if [ -d ${DB_BACKUP_LOCATION} ];
then
   if [ `ls -l ${DB_BACKUP_LOCATION}/* 2>/dev/null | wc -l ` = 0 ];
   then
      echo " "
      echo "Dir ${DB_BACKUP_LOCATION} is empty"
      echo " "
   else
      echo " "
      echo "List of Level 0 files for deletion in directory: ${DB_BACKUP_LOCATION}/*"
      echo " "
      ls ${DB_BACKUP_LOCATION}/* 
      echo " "
      echo "About to clean old Level 0 backup for a new Level 0"
      echo " "
      echo "About to execute rm -f ${DB_BACKUP_LOCATION}/*" 
      echo " "
      echo "Press Control+C to abort, return to continue"
      echo " "
      read x
      rm -f ${DB_BACKUP_LOCATION}/* 
   fi
else
   echo "Unable to locate Backup Location for Level 0.. Environment not setup.. exiting.."
   exit 1
fi

echo " "
echo "Proceeding to create Level 0 backup at ${DB_BACKUP_LOCATION}"
echo " "

rman target / << LEVEL0-BACKUP

SET ECHO ON
CONFIGURE DEFAULT DEVICE TYPE TO DISK;
CONFIGURE BACKUP OPTIMIZATION ON;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE ENCRYPTION FOR DATABASE OFF;
CONFIGURE COMPRESSION ALGORITHM 'BASIC'; 
CONFIGURE DEVICE TYPE DISK BACKUP TYPE TO COPY PARALLELISM ${RMAN_PARALLELISM};
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF ${RMAN_RETENTION_DAYS} DAYS;
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '${CONTROL_BACKUP_LOCATION}/%d_%F.ctl';

run {

sql 'ALTER SYSTEM SWITCH LOGFILE';

BACKUP AS COPY INCREMENTAL LEVEL 0 TAG "${TAG}" DATABASE format '${DB_BACKUP_LOCATION}/%d_TS_%N_FNO_%f.${DB_FILE_EXTN}';

sql 'ALTER SYSTEM ARCHIVE LOG CURRENT';

backup archivelog all format '${ARCH_BACKUP_LOCATION}/%d_Archive_%u.${ARCH_FILE_EXTN}' not backed up 1 times;

}

LEVEL0-BACKUP

echo " "
echo "About to perform Snapshot (fastcopy) of backup.. Press any key to start "
echo " "
read x

echo " "
echo "Fastcopy dir = ${BOOSTFS_MOUNT}/${DD_FASTCOPY_DIR}"
echo " "

ssh ${DD_FASTCOPY_USER}@${DATA_DOMAIN} filesys fastcopy source /data/col1/${MTREE}/${DD_DB_BACKUP_LOCATION} destination /data/col1/${MTREE}/${DD_FASTCOPY_DIR}

echo " "

#
# Enable if you need to Catalog the completed fastcopy of backup into RMAN catalog
#

# rman target / << !END-CMD
#
# catalog start with '${BOOSTFS_MOUNT}/${DD_FASTCOPY_DIR}/' noprompt;
#
# !END-CMD

