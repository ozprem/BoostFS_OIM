#!/usr/bin/sh -vx
#
# This script is part of performing Oracle Incremental Merge and Live Mount with Data Domain Fastcopy with Data Domain BoostFS
#
# Script: 10_mount_boostfs.sh
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
# - Data Domain with Mtree setup to mount it as boostfs
# - BoostFS software installed with lockbox setup
#
# Function:
#
# - This script allows to capture all the environment variable used with all the scripts
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
df -k | grep ${BOOSTFS_MOUNT}  > /dev/null
rs=$?

if [ $rs != 0 ];
then
   /opt/emc/boostfs/bin/boostfs mount -d ${DATA_DOMAIN} -s ${MTREE} -o security=lockbox ${BOOSTFS_MOUNT}
fi

#
# chech if BOOSTFS_MOUNT dir exist to create various sub directories if they don't exist
#

df -k | grep ${BOOSTFS_MOUNT} > /dev/null
rs=$?

if [ $rs = 0 ];
then
    if [ ! -d ${DB_BACKUP_LOCATION} ];
    then
       mkdir -p ${DB_BACKUP_LOCATION} 
    fi

    if [ ! -d ${CONTROL_BACKUP_LOCATION} ];
    then
       mkdir -p ${CONTROL_BACKUP_LOCATION}
    fi

    if [ ! -d ${ARCH_BACKUP_LOCATION} ];
    then
       mkdir -p ${ARCH_BACKUP_LOCATION}
    fi

    if [ ! -d ${INCR_BACKUP_LOCATION} ];
    then
       mkdir -p ${INCR_BACKUP_LOCATION}
    fi

    if [ ! -d ${FASTCOPY_LOCATION} ];
    then
       mkdir -p ${FASTCOPY_LOCATION}
    fi
fi

echo " "
echo "list of directories for backup of Oracle Database ${BACKUP_LOCATION} "
echo " "
ls -ld ${BACKUP_LOCATION}/*
echo " "
