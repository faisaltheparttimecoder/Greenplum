#!/bin/bash
#
#  run_database_info.sh
#  pivotal - 2014
#

# Main program starts here

# Script and log directories

echo "INFO - Generating the directories name / location where the output logs will saved / stored"

export script=$0
export script_basename=`basename $script`
export script_dir=`dirname $script`/..
cd $script_dir
export script_dir=`pwd`
export install_dir=`dirname $script_dir`
export logdir=$script_dir/log
export tmpdir=$script_dir/tmp
export fixdir=$script_dir/fix
export sqldir=$script_dir/sql
export rptdir=$script_dir/rpt

echo "INFO - Program ( ${script_basename} ) succesfully started at" `date`

# Creating tmp / log directory

echo "INFO - Creating the directories which will be used for storing logs / temp files ( if not available ) "

mkdir -p $script_dir/log
mkdir -p $script_dir/tmp
mkdir -p $script_dir/rpt

# Reading the parameter file to set the environment

echo "INFO - Reading the parameter file to set the environment"

export paramfile=$script_dir/bin/environment_parameters.env
export GPHOME=`grep -i ^gphome $paramfile | grep -v grep | cut -d: -f2`
source $GPHOME/greenplum_path.sh
export PGDATABASE=`grep -i ^pgdatabase $paramfile | grep -v grep | cut -d: -f2`
export PGPORT=`grep -i ^pgport $paramfile | grep -v grep | cut -d: -f2`
export MASTER_DATA_DIRECTORY=`grep -i ^master_data_directory $paramfile | grep -v grep | cut -d: -f2`

# Creating the logfiles that is needed for this script.

echo "INFO - Generating filenames needed for output logs"

export log_all=${logdir}/all_check_greenplum.out
export generate_report_general_info_rpt=${logdir}/generate_report_general_info.rpt
export generate_report_db_session_activity_rpt=${logdir}/generate_report_db_session_activity.rpt
export generate_report_database_info_rpt=${logdir}/generate_report_database_info.rpt

# Calling the dependant scripts to gather the checks of the cluster..

echo "INFO - Calling the dependant scripts to gather the checks of the cluster"

echo -e "\n \t \t \t \t \t X----- Report generated at: " `date` "-----X \n \n" > $log_all

echo "INFO - Calling script for general information on the cluster"

/bin/sh $script_dir/bin/run_general_info.sh $log_all

cat $generate_report_general_info_rpt >> $log_all

echo "INFO - Calling script for session activity on the cluster"

/bin/sh $script_dir/bin/run_db_session_activity.sh
cat $generate_report_db_session_activity_rpt >> $log_all

echo "INFO - Calling script for database activity on the cluster"

/bin/sh $script_dir/bin/run_database_info.sh
cat $generate_report_database_info_rpt >> $log_all

echo -e "\n \t \t \t \t \t X----- Report completed at: " `date` "-----X \n \n" >> $log_all

# Program ending messages.

echo "INFO - Program ( ${script_basename} ) succesfully completed at" `date`
echo "INFO - Program ( ${script_basename} ) report file available at" $log_all