#!/usr/bin/sh -vx
#
# This script is part of performing Oracle Incremental Merge and Live Mount with Data Domain Fastcopy with Data Domain BoostFS
#
# Script: 30_create_incr_merge_backup_and_fastcopy.sh
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
# - 20_create_new_level_0_backup.sh has been run before to create a level 0 backup
#
# Function:
#
# - Script to create incremental backup to _INCR directory, merge with previous full and create a fastcopy virtual image for future use.
# - Also backs up archive logs
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
      echo "Unable to find any full backup at ${DB_BACKUP_LOCATION} ..exiting"
      echo " "
      exit 1
   fi
else
   echo "Unable to locate Backup Location for Level 0.. Environment not setup.. exiting.."
   exit 1
fi

rman target / << LEVEL1-BACKUP

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

BACKUP INCREMENTAL LEVEL 1 FOR RECOVER OF COPY WITH TAG "${TAG}" DATABASE format '${INCR_BACKUP_LOCATION}/%d_ARCH_%U.${DB_FILE_EXTN}' ;

RECOVER COPY OF DATABASE WITH TAG "${TAG}" ;

sql 'ALTER SYSTEM ARCHIVE LOG CURRENT';

backup archivelog all format '${ARCH_BACKUP_LOCATION}/%d_Archive_%u.${ARCH_FILE_EXTN}' not backed up 1 times;

}

LEVEL1-BACKUP

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
