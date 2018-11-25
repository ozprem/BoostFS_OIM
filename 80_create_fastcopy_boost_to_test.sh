#!/usr/bin/sh -vx
#
# This script is part of performing Oracle Incremental Merge and Live Mount with Data Domain Fastcopy with Data Domain BoostFS
#
# Script: 80_create_fastcopy_boost_to_test.sh
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
# - Either a Level 0 and/or a Level 1 backup has been run (20_create_new_level_0_backup.sh / 30_create_incr_merge_backup_and_fastcopy.sh )
#
# Function:
#
# - Script to do a fastcopy of a previously made full backup fastcopy that can be used with Live Mount
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
if [ -d ${FASTCOPY_LOCATION} ];
then
   if [ `ls -ld ${FASTCOPY_LOCATION}/* 2>/dev/null | grep -v TEST | wc -l ` = 0 ];
   then
      echo " "
      echo "No Fastcopy backups found at ${FASTCOPY_LOCATION} "
      echo " "
      exit 1
   else
      echo " "
      echo "List of Fastcopy backups available in : ${FASTCOPY_LOCATION} "
      echo " "
      ls ${FASTCOPY_LOCATION} | grep -v ${TEST_FASTCOPY_DIR} | more
      echo " "
      echo "Choose a Directory to Fastcopy..."
      read DIR
      echo " "
      if [ -d ${FASTCOPY_LOCATION}/${DIR} ];
      then
           if [ -d ${FASTCOPY_TEST_DIR} ];
           then
              echo " "
              echo "Deleting OLD TEST directory with rm -rf ${FASTCOPY_TEST_DIR} "
              echo " "
              echo "Press any key to confirm, Control+c to abort"
              echo " "
              read x
              rm -rf ${FASTCOPY_TEST_DIR}
           fi
     else
           echo " "
           echo "Incorrect Selection.. Please choose an available fastcopy backup..exiting "
           echo " "
           exit 1
     fi
   fi
else
   echo "Unable to locate Fastcopy Backup Location .. Environment not setup properly.. exiting.."
   exit 1
fi

echo " "
echo "Fastcopying ${FASTCOPY_LOCATION}/$DIR to ${FASTCOPY_TEST_DIR}"
echo " "

ssh ${DD_FASTCOPY_USER}@${DATA_DOMAIN} filesys fastcopy source /data/col1/${MTREE}/${DD_FASTCOPY_LOCATION}/${DIR} destination /data/col1/${MTREE}/${DD_FASTCOPY_TEST_DIR}

echo " "
echo "Fastcopy of ${FASTCOPY_TEST_DIR} complete"
echo " "
echo "Please allow a few minutes for files to be available "
echo " "

