#!/usr/bin/sh +vx
#
# This script is part of performing Oracle Incremental Merge and Live Mount with Data Domain snapshot with Data Domain BoostFS
#
# Script: 25_create_new_table.sh
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
# - An Initial backup has been created using 20_create_new_level_0_backup.sh
#
# Function:
#
# - Optional script to create a new table before performing incremental merge backup
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
#
if [ -d ${L0_BACKUP_LOCATION} ];
then
   if [ `ls -l ${L0_BACKUP_LOCATION}/* 2>/dev/null | wc -l ` = 0 ];
   then
      echo " "
      echo "Dir ${L0_BACKUP_LOCATION} is empty and no backups have been performed"
      echo " "
      exit 1
   fi
else
   echo "Unable to locate Backup Location for Level 0.. Environment not setup.. exiting.."
   exit 1
fi

echo " "
echo "Creating a new table ${TEST_TABLE_NAME} and adding 1 row of data"
echo " "

#
# Inject a new table into current database
#

sqlplus -s / as sysdba << END-SQL

set pages 100 head off feedback off echo off
set sqlprompt ''
set sqlnumber off

select 'Dropping old ${TEST_TABLE_NAME}' from dual
/

drop table ${TEST_TABLE_NAME}
/

select 'Creating new ${TEST_TABLE_NAME}' from dual
/
create table ${TEST_TABLE_NAME} 
as select * from datathon.bigtab where rownum < 100001
/

set echo off feedback off ;

select 'New Table ${TEST_TABLE_NAME} added with '||count(*)||' rows' from ${TEST_TABLE_NAME}
/

select ' ' from dual
/

END-SQL
