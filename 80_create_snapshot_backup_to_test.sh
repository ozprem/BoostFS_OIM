#!/usr/bin/sh +vx
#
# This script is part of performing Oracle Incremental Merge and Live Mount with Data Domain snapshot with Data Domain BoostFS
#
# Script: 80_create_snapshot_backup_to_test.sh
#
# Author: Trichy Premkumar, prem@acslink.net.au
#
# Disclaimer: Scripts have been developed for testing Oracle incremental merge with Data Domain snapshot
#             No support or warranty is included
#
#             #IWork4DELL
#
# Pre-requisites:
#
# - Either a Level 0 and/or a Level 1 backup has been run (20_create_new_level_0_backup.sh / 30_create_incr_merge_backup_and_snapshot.sh )
#
# Function:
#
# - Script to do a snapshot of a previously made full backup snapshot that can be used with Live Mount
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
  if [ -f ${SCRIPTS_DIR}/00_set_environment.inc ]
  then
      . ${SCRIPTS_DIR}/00_set_environment.inc
  else
      echo " "
      echo "Environment variable script cannot be located.. exiting."
      echo " "
      exit 1
  fi
fi
#
if [ -d ${SNAPSHOT_TEST_DIR} ];
then
   lsof | grep ${SNAPSHOT_TEST_DIR} > /dev/null 2>&1
   rs=$?
   if [ $rs = 0 ];
   then
     echo " "
     echo "Test Directory ${SNAPSHOT_TEST_DIR} exists and is in use "
     echo "Please shutdown Oracle Database: ${TEST_ORACLE_SID} "
     echo " "
     exit 1
   else 
     echo " "
     echo "Test Directory ${SNAPSHOT_TEST_DIR} exists and not in use "
     echo " "
   fi
fi
#
if [ -d ${SNAPSHOT_LOCATION} ];
then
   if [ `ls -ld ${SNAPSHOT_LOCATION}/* 2>/dev/null | grep -v TEST | wc -l ` = 0 ];
   then
      echo " "
      echo "No snapshot backups found at ${SNAPSHOT_LOCATION} "
      echo " "
   else
      echo " "
      echo "List of snapshot backups available in : ${SNAPSHOT_LOCATION} "
      echo " "
      ls ${SNAPSHOT_LOCATION} | grep -v ${TEST_DIR} | more
      echo " "
      echo "Choose a Directory to snapshot..."
      read DIR
      echo " "
      if [ -d ${SNAPSHOT_LOCATION}/${DIR} ];
      then
           if [ -d ${SNAPSHOT_TEST_DIR} ];
           then
              echo " "
              echo "Deleting OLD TEST directory with rm -rf ${SNAPSHOT_TEST_DIR} "
              echo " "
              echo "Press any key to confirm, Control+c to abort"
              echo " "
              read x
              rm -rf ${SNAPSHOT_TEST_DIR}
           fi
     else
           echo " "
           echo "Incorrect Selection.. Please choose an available snapshot backup..exiting "
           echo " "
           exit 1
     fi
   fi
else
   echo "Unable to locate snapshot Backup Location .. Environment not setup properly.. exiting.."
   exit 1
fi

echo " "
echo "Creating Snapshot of ${SNAPSHOT_LOCATION}/$DIR as ${SNAPSHOT_TEST_DIR}"
echo " "
echo "Press any key to continue.."
read x

ssh ${DD_SNAPSHOT_USER}@${DATA_DOMAIN} filesys fastcopy source /data/col1/${MTREE}/${DD_SNAPSHOT_LOCATION}/${DIR} destination /data/col1/${MTREE}/${DD_SNAPSHOT_TEST_DIR}

echo " "

ls -l ${SNAPSHOT_TEST_DIR}/* > /dev/null 2>&1
rs=$?
while [ $rs -ne 0 ]; 
do
   echo "Waiting for snapshot directory ${SNAPSHOT_TEST_DIR} to be ready.. "
   sleep 2
   ls -l ${SNAPSHOT_TEST_DIR}/* > /dev/null 2>&1
   rs=$?
done

echo " "
echo "Snapshot of ${SNAPSHOT_TEST_DIR} complete"
echo " "

