#!/usr/bin/sh -vx
#
# This script is part of performing Oracle Incremental Merge and Live Mount with Data Domain Fastcopy with Data Domain BoostFS
#
# Script: 99_shutdown_test_db.sh
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
# - must have executed 90_create_controlfile_and_startup_test.sh and started test database
#
# Function:
#
# - Script to shutdown the live mount database running on BoostFS filesystem
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
# Check if test database is running
#
ps -ef | grep ora_pmon_${TEST_ORACLE_SID} | grep -v grep > /dev/null
rs=$?

if [ $rs = 1 ];
then
   echo " "
   echo "Test databse ${TEST_ORACLE_SID} is not running"
   echo " "
   exit 0
fi

#
# shutdown the running database
#

ORACLE_SID=${TEST_ORACLE_SID}; export ORACLE_SID

sqlplus / as sysdba << EOSQL

shutdown abort;
exit

EOSQL


echo " "
echo "Oracle instance ${TEST_ORACLE_SID} shutdown"
echo " "

