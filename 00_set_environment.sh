#!/usr/bin/sh -vx
#
# This script is part of performing Oracle Incremental Merge and Live Mount with Data Domain Fastcopy with Data Domain BoostFS
#
# Script: 00_set_environment.sh
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
# - This script allows to capture all the environment variable used with all the scripts
#
#
HOSTNAME=`hostname`; export HOSTNAME
ORACLE_SID=BOOST; export ORACLE_SID
ORACLE_BASE=${ORACLE_BASE}; export ORACLE_BASE
ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1; export ORACLE_HOME
MTREE=boostfsu; export MTREE
DATA_DOMAIN=ddt.local; export DATA_DOMAIN
BOOSTFS_MOUNT=/boostfs; export BOOSTFS_MOUNT
TEST_ORACLE_SID=TEST; export TEST_ORACLE_SID
TEST_DIR=TEST; export TEST_DIR
SCRIPTS_DIR=/home/oracle/scripts/boostfs; export SCRIPTS_DIR
TAG="INCR_MERGE"; export TAG
TEMP_DIR=/tmp/TEST; export TEMP_DIR
DB_FILE_EXTN=bkp; export DB_FILE_EXTN
ARCH_FILE_EXTN=arlog; export ARCH_FILE_EXTN
DB_COMPATIBILITY=12.1.0.2.0; export DB_COMPATIBILITY
REDO_LOG_SIZE=5M; export REDO_LOG_SIZE
RMAN_PARALLELISM=4; export RMAN_PARALLELISM
RMAN_RETENTION_DAYS=14; export RMAN_RETENTION_DAYS
DD_FASTCOPY_USER=fastcopy; export DD_FASTCOPY_USER
# 
# Default Directory structure used for backup files under ${BOOSTFS_MOUNT}/$HOSTNAME}/${ORACLE_SID}  directory)
#
# - DB       - Directory to store Oracle Databases backup (LEVEL 0)
# - INCR     - Directory to store LEVEL 1 Incremental backup prior to merge with LEVEL 0
# - ARCH     - Directory to store ArchiveLog backups
# - CONTROL  - Directory to store Controlfile AUTOBACKUPs
# - FASTCOPY - Directory to create space efficient snapshots of Daily merged backup using Data Domain Fastcopy
# - TEST     - Temporary Directory name used to create a Fastcopy of a previous fastcopy backup to test live-mount on DD
#
DB_DIR=DB; export DB_DIR
INCR_DIR=INCR; export INCR_DIR
ARCH_DIR=ARCH; export ARCH_DIR
CONTROL_DIR=CONTROL; export CONTROL_DIR
FASTCOPY_DIR=FASTCOPY; export FASTCOPY_DIR
TEST_FASTCOPY_DIR=TEST; export TEST_FASTCOPY_DIR
#
# Setup various locations based on default directory structure
#
BACKUP_LOCATION="${BOOSTFS_MOUNT}/${HOSTNAME}/${ORACLE_SID}"
DB_BACKUP_LOCATION="${BACKUP_LOCATION}/${DB_DIR}"; export DB_BACKUP_LOCATION
INCR_BACKUP_LOCATION="${BACKUP_LOCATION}/${INCR_DIR}"; export DB_BACKUP_LOCATION
ARCH_BACKUP_LOCATION="${BACKUP_LOCATION}/${ARCH_DIR}"; export DB_BACKUP_LOCATION
CONTROL_BACKUP_LOCATION="${BACKUP_LOCATION}/${CONTROL_DIR}"; export DB_BACKUP_LOCATION
FASTCOPY_LOCATION="${BACKUP_LOCATION}/${FASTCOPY_DIR}"; export FASTCOPY_LOCATION
FASTCOPY_TEST_DIR="${FASTCOPY_LOCATION}/${TEST_DIR}"; export FASTCOPY_TEST_DIR
DD_DB_BACKUP_LOCATION="${HOSTNAME}/${ORACLE_SID}/${DB_DIR}"; export DD_BACKUP_LOCATION
DD_FASTCOPY_LOCATION="${HOSTNAME}/${ORACLE_SID}/${FASTCOPY_DIR}"; export DD_FASTCOPY_LOCATION
DD_FASTCOPY_DIR="${HOSTNAME}/${ORACLE_SID}/${FASTCOPY_DIR}/`date +'%Y-%m-%d-%H%M%S'`"; export DD_FASTCOPY_DIR
DD_FASTCOPY_TEST_DIR="${HOSTNAME}/${ORACLE_SID}/${FASTCOPY_DIR}/${TEST_FASTCOPY_DIR}"; export FASTCOPY_TEST_DIR
TEST_TABLE_NAME="${HOSTNAME}_${ORACLE_SID}"; export TEST_TABLE_NAME
