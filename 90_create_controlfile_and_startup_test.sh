#!/usr/bin/sh -vx
#
# This script is part of performing Oracle Incremental Merge and Live Mount with Data Domain Fastcopy with Data Domain BoostFS
#
# Script: 90_create_controlfile_and_startup_test.sh
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
# - must have executed 80_create_fastcopy_boost_to_test.sh to fastcopy a backup to test
#
# Function:
#
# - Script to create a init.ora file, controlfile and start fastcopy database on Data Domain
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
   if [ -d ${FASTCOPY_TEST_DIR} ];
   then
      echo " "
      echo "Mounting TEST database using files in directory ${FASTCOPY_TEST_DIR} "
      echo " "
   else
      echo " "
      echo "${FASTCOPY_TEST_DIR} does not exist, ensure you have run 80_create_fastcopy_boost_to_test.sh"
      echo " "
      exit 1
   fi
else
   echo "Unable to locate Fastcopy Backup Location ${FASTCOPY_LOCATION} / Environment not setup properly.. exiting.."
   exit 1
fi

echo " "
echo "Using Temporary directory location : ${TEMP_DIR}"
mkdir -p ${TEMP_DIR}
echo " "

cat > ${TEMP_DIR}/init${TEST_ORACLE_SID}.ora << INIT-ORA
#
# Generated Init.ora file with min parameters to startup ${TEST_ORACLE_SID}
#
*.db_block_size=8192
*.db_domain=''
*.db_name='${TEST_ORACLE_SID}'
*.control_files='${TEMP_DIR}/${TEST_ORACLE_SID}_control01.ctl'
*.audit_file_dest='${TEMP_DIR}/'
*.audit_trail='db'
*.db_create_file_dest='${TEMP_DIR}/'
*.db_recovery_file_dest='${FASTCOPY_TEST_DIR}/'
*.diagnostic_dest='${TEMP_DIR}/'
*.db_recovery_file_dest_size=8589934592
*._allow_resetlogs_corruption=TRUE
*.remote_login_passwordfile='EXCLUSIVE'
*.compatible='${DB_COMPATIBILITY}'

INIT-ORA

#
# Set ORACLE_SID to TEST_ORACLE_SID and start database within the FASTCOPY TEST directory
#
ORACLE_SID=${TEST_ORACLE_SID}; export ORACLE_SID

cat > ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh << STARTUP-001 

set -vx

ORACLE_SID=${TEST_ORACLE_SID}; export ORACLE_SID

sqlplus / as sysdba << END-SQL

SET ECHO ON

STARTUP NOMOUNT PFILE=${TEMP_DIR}/init${TEST_ORACLE_SID}.ora 

CREATE CONTROLFILE REUSE SET DATABASE "${TEST_ORACLE_SID}" RESETLOGS NOARCHIVELOG
    MAXLOGFILES 16
    MAXLOGMEMBERS 3
    MAXDATAFILES 512
    MAXINSTANCES 8
    MAXLOGHISTORY 292
LOGFILE
  GROUP 1 '${TEMP_DIR}/${TEST_ORACLE_SID}_redo01.log'  SIZE ${REDO_LOG_SIZE} BLOCKSIZE 512,
  GROUP 2 '${TEMP_DIR}/${TEST_ORACLE_SID}_redo02.log'  SIZE ${REDO_LOG_SIZE} BLOCKSIZE 512,
  GROUP 3 '${TEMP_DIR}/${TEST_ORACLE_SID}_redo03.log'  SIZE ${REDO_LOG_SIZE} BLOCKSIZE 512
DATAFILE
STARTUP-001

#
# Generate list of datafile from ${FASTCOPY_TEST_DIR} 
#

ls ${FASTCOPY_TEST_DIR}/*.${DB_FILE_EXTN}* > ${TEMP_DIR}/file_list.out
lc=`cat ${TEMP_DIR}/file_list.out | wc -l`
declare -i curr_lc=0

for file in `cat ${TEMP_DIR}/file_list.out`
do
  curr_lc=$(($curr_lc+1))

  if [ $curr_lc -eq $lc ];
  then
    echo "'${file}';" >> ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh
    echo " " >> ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh
    echo "ALTER DATABASE OPEN RESETLOGS;" >> ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh
    echo " " >> ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh
    echo "exit; " >> ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh
    echo " " >> ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh
    echo "END-SQL" >> ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh
    echo " " >> ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh
    break
  else 
    echo "'${file}'," >> ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh
  fi
done

chmod 750 ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh

echo " "
echo "Init.ora script and script to start database has been created."
echo " "
echo "Please run ${TEMP_DIR}/startup_${TEST_ORACLE_SID}.sh manually to start the database "
echo " "

