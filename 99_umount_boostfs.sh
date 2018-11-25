#!/usr/bin/sh -vx
#
# This script is part of performing Oracle Incremental Merge and Live Mount with Data Domain Fastcopy with Data Domain BoostFS
#
# Script: 99_umount_boostfs.sh
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
# - BoostFS is mounted to a filesystem using 10_mount_boostfs.sh
#
# Function:
#
# - This script allows to  unmount a previously mounted boostfs filesystem using 10_mount_boostfs.sh
#
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
# check if boostfs is already mounted.. else mount it
#
df -k | grep "${BOOSTFS_MOUNT}"  > /dev/null
rs=$?

if [ $rs = 0 ];
then
   /opt/emc/boostfs/bin/boostfs umount ${BOOSTFS_MOUNT}
else 
   echo " "
   echo "${BOOSTFS_MOUNT} is not mounted "
   echo " "
   exit 1
fi


if [ $rs = 0 ];
then
   echo " "
   echo "${BOOSTFS_MOUNT} successfully unmounted "
   echo " "
else 
   exit 1
fi
