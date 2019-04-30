#!/usr/bin/sh -vx
#
# This parameter file is part of performing Oracle Incremental Merge and Live Mount with Data Domain snapshot with Data Domain BoostFS
#
# 00_set_environment.inc
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
# - none
#
# Function:
#
# - This file allows to capture all of the environment variables used with all the OIM scripts
#
#
SCRIPTS_DIR=/home/oracle/scripts/boostfs; export SCRIPTS_DIR
HOSTNAME=`hostname`; export HOSTNAME
ORACLE_SID=BOOST; export ORACLE_SID
ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1; export ORACLE_HOME
MTREE=boostfsu; export MTREE
DATA_DOMAIN=prd-ddve01.dps.local; export DATA_DOMAIN
BOOSTFS_MOUNT=/boostfs; export BOOSTFS_MOUNT
TEST_ORACLE_SID=TEST; export TEST_ORACLE_SID
NAME_DATE_TIME=`date +'%Y-%m-%d-%H%M%S'`; export NAME_DATA_TIME
INCR_MERGE_TAG="INCR_MERGE"; export INCR_MERGE_TAG
SNAPSHOT_TAG="FULL_${NAME_DATE_TIME}"; export SNAPSHOT_TAG
TEMP_DIR=/tmp/${ORACLE_SID}_TEMP; export TEMP_DIR
DB_FILE_EXTN=bkp; export DB_FILE_EXTN
ARCH_FILE_EXTN=arlog; export ARCH_FILE_EXTN
DB_COMPATIBILITY=12.1.0.2.0; export DB_COMPATIBILITY
REDO_LOG_SIZE=5M; export REDO_LOG_SIZE
RMAN_PARALLELISM=4; export RMAN_PARALLELISM
RMAN_RETENTION_DAYS=14; export RMAN_RETENTION_DAYS
DD_SNAPSHOT_USER=fastcopy; export DD_SNAPSHOT_USER
# 
# Default Directory structure used for backup files under ${BOOSTFS_MOUNT}/$HOSTNAME}/${ORACLE_SID}  directory)
#
# - L0       - Directory to store New Oracle Database L0 backup 
# - INCR     - Directory to store LEVEL 1 Incremental backup prior to merge with previous FULL
# - ARCH     - Directory to store ArchiveLog backups
# - CONTROL  - Directory to store Controlfile AUTOBACKUPs
# - SNAPSHOT - Directory to create space efficient snapshots of L0 and Daily merged backup using Data Domain snapshot
# - TEST     - Temporary Directory name used to create a Snapshot of a previous Snapshot backup to test live-mount on DD
#
L0_DIR=FULL; export L0_DIR
INCR_DIR=INCR; export INCR_DIR
ARCH_DIR=ARCH; export ARCH_DIR
CONTROL_DIR=CONTROL; export CONTROL_DIR
SNAPSHOT_DIR=SNAPSHOT; export SNAPSHOT_DIR
TEST_DIR=TEST; export TEST_DIR
#
# Setup various locations based on default directory structure
#
BACKUP_LOCATION="${BOOSTFS_MOUNT}/${HOSTNAME}/${ORACLE_SID}"
L0_BACKUP_LOCATION="${BACKUP_LOCATION}/${L0_DIR}"; export L0_BACKUP_LOCATION
INCR_BACKUP_LOCATION="${BACKUP_LOCATION}/${INCR_DIR}"; export INCR_BACKUP_LOCATION
ARCH_BACKUP_LOCATION="${BACKUP_LOCATION}/${ARCH_DIR}"; export ARCH_BACKUP_LOCATION
CONTROL_BACKUP_LOCATION="${BACKUP_LOCATION}/${CONTROL_DIR}"; export CONTROL_BACKUP_LOCATION
SNAPSHOT_LOCATION="${BACKUP_LOCATION}/${SNAPSHOT_DIR}"; export SNAPSHOT_LOCATION
SNAPSHOT_TEST_DIR="${SNAPSHOT_LOCATION}/${TEST_DIR}"; export SNAPSHOT_TEST_DIR
DD_L0_BACKUP_LOCATION="${HOSTNAME}/${ORACLE_SID}/${L0_DIR}"; export DD_L0_BACKUP_LOCATION
DD_SNAPSHOT_LOCATION="${HOSTNAME}/${ORACLE_SID}/${SNAPSHOT_DIR}"; export DD_SNAPSHOT_LOCATION
DD_SNAPSHOT_DIR="${HOSTNAME}/${ORACLE_SID}/${SNAPSHOT_DIR}/${NAME_DATE_TIME}"; export DD_SNAPSHOT_DIR
DD_SNAPSHOT_TEST_DIR="${HOSTNAME}/${ORACLE_SID}/${SNAPSHOT_DIR}/${TEST_DIR}"; export DD_SNAPSHOT_TEST_DIR
TEST_TABLE_NAME="TEST_TABLE"; export TEST_TABLE_NAME

