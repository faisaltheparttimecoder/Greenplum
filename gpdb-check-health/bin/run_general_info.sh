#!/bin/bash
#
#  run_general_info.sh
#  pivotal - 2014
#

# Function : To gather the version of the postgres / greenplum 

version_info() {

echo "INFO - Getting the version of Postgres / Greenplum / DCA"

export postgresversion=`$GPHOME/bin/postgres --version| cut -d' ' -f4` 
export greenplumversion=`$GPHOME/bin/postgres --gp-version| cut -d' ' -f4`
if (test -f /etc/gpdb-appliance-version)
then
	export dcaversion=`cat /etc/gpdb-appliance-version`
else
	export dcaversion="N/A"
fi    
awk 'BEGIN {  printf "%-24s %-30s %-33s %-20s \n", "", "Postgres" ,"Greenplum","DCA"
              printf "%-20s %-30s %-30s %-20s \n", "","----------------","----------------","----------------"
              printf "%-24s %-30s %-31s %-20s \n", "Version","'$postgresversion'","'$greenplumversion'","'$dcaversion'"}' 2>&1 > $collect_version

                  	}


# Function : To gather information on the segment configuration and the cluster status. 

seg_config_info() {

echo "INFO - Generating the information on the segment configuration and the cluster status"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -Atf $sqldir/database-seg-config.sql  > $collect_seg_configuration
echo "        Cluster configuration           |              Result              " > $collect_segrpt_configuration
echo "----------------------------------------+----------------------------------" >> $collect_segrpt_configuration
echo "Uptime of the greenplum database        | " ` grep uptime $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total segments in the cluster           | " ` grep totalcount $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total primary segments in the cluster   | " ` grep primary $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total mirror segments in the cluster    | " ` grep mirror $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Is master standby configured            | " ` grep standby $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total segments hosts in the cluster     | " ` grep seghost $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total master hosts in the cluster       | " ` grep masterhost $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total segments down in the cluster      | " ` grep down $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total segments not in preferred role    | " ` grep preferred $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total segments in sync mode             | " ` grep ^sync $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total segments in changetracking mode   | " ` grep changetracking $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total segments in resync mode           | " ` grep resync $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total roles/users in the cluster        | " ` grep role $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration
echo "Total roles/users with superuser access | " ` grep superuser $collect_seg_configuration | cut -d'|' -f2 ` >> $collect_segrpt_configuration

                    }

# Function : To gather grenplum coniguration history on last time they were down. 

seg_config_hist() {

echo "INFO - Generating the report on when the segments was marked down last"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-config-history.sql | egrep -v "rows\)|row\)"  > $collect_config_history 

                    }

# Function : To gather master / standby master status. 

master_stndby_info() {

echo "INFO - Generating the report on master / standby master status"

$GPHOME/bin/gpstate -f > $collect_master_standby

                    }

# Function : Collect FATAL / PANIC / ERROR messages on the database logs. 

get_error_info() {

echo "INFO - Generating the report to gather FATAL/PANIC/ERROR messages in the cluster in the last 3 days (Might take time based on the size of the log file)"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-create-log-collection-view.sql > $junkfile 2>&1 
$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-fatal-error-panic-occurrence.sql | egrep -v "rows\)|row\)"  > $collect_fatal_panic_error 

                    }

# Function : To gather top 10 FATAL messages in the greenplum cluster. 

fatal_occurrence() {

echo "INFO - Generating the report to gather FATAL messages in the cluster"

head -2 $collect_fatal_panic_error > $collect_fatal ; grep FATAL $collect_fatal_panic_error | head -10 >> $collect_fatal

                    }

# Function : To gather top 10 PANIC messages in the greenplum cluster. 

panic_occurrence() {

echo "INFO - Generating the report to gather PANIC messages in the cluster"

head -2 $collect_fatal_panic_error > $collect_panic ; grep PANIC $collect_fatal_panic_error | head -10  >> $collect_panic

                    }

# Function : To gather top 10 ERROR messages in the greenplum cluster. 

error_in_db_occurrence() {

echo "INFO - Generating the report to gather ERROR messages in the cluster"

head -2 $collect_fatal_panic_error > $collect_error_in_db ; grep ERROR $collect_fatal_panic_error | head -10 >> $collect_error_in_db

                    }

# Function : To gather information if master lost connection with segments. 

crash_recovery_occurrence() {

echo "INFO - Generating the report if master lost connection with segments in the last 2 days (Might take time based on the size of the log file) "

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-crash-recovery-check.sql | egrep -v "rows\)|row\)" > $collect_crash_recovery_info

                    }

# Function : Collect all the information generated above to a single report file.

generate_report_general_info() {

echo "INFO - Generating the report for the program: " $script_basename

echo -e "\t \t \t \t \t \t    GENERAL INFORMATION ON THE CLUSTER" > $generate_report_general_info
echo -e "\t \t \t \t \t \t ----------------------------------------\n " >> $generate_report_general_info
echo -e " --> Version of the greenplum cluster \n" >> $generate_report_general_info
cat $collect_version >> $generate_report_general_info
echo -e "\n --> Information of the cluster configuration in the greenplum cluster \n" >> $generate_report_general_info
cat $collect_segrpt_configuration >> $generate_report_general_info
echo -e "\n --> Information of when the segments in cluster configuration was marked down (Last 10 entries)" >> $generate_report_general_info
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_config_history | wc -l` -gt 2 ]
then 
	echo -e " --> NOTE: The below shown information is the time when the coniguration history table was updated, so not the exact start time" >> $generate_report_general_info
	echo -e " --> HINT: 1. If role=p , then FTS Probe process running on master marked the primary segment down after it couldn't communicate" >> $generate_report_general_info
	echo -e " -->          so check the logs of master (with search similar to \"grep FTS <logfile> | grep dbid=<dbid below> | head -10\") for start time and then check primary logs " >> $generate_report_general_info
	echo -e " -->       2. If role=m , then Primary segments of the content marked it down after it couldn't reach mirror" >> $generate_report_general_info
	echo -e " -->          so check the logs of primary segment (with search similar \"grep \"mirror transition\" <logfile> | head -10\") for start time and then check mirror logs \n " >> $generate_report_general_info
	cat $collect_config_history >> $generate_report_general_info
else
	echo -e "\nNo information on the configuration history of any segments marked down \n" >> $generate_report_general_info
fi
echo -e " --> Master / Standby master sync status  \n" >> $generate_report_general_info
cat $collect_master_standby >> $generate_report_general_info
echo -e " \n --> Information of top occurrence FATAL messages in the greenplum cluster in the last 3 days (Top 10)" >> $generate_report_general_info
echo -e " --> PLEASE NOTE: This information depends on the availability of the master logs at location" $MASTER_DATA_DIRECTORY "\n" >> $generate_report_general_info
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_fatal | wc -l` -gt 2 ]
then 
	cat $collect_fatal >> $generate_report_general_info
else
	echo -e "No information on the master log of any occurrence of FATAL message" >> $generate_report_general_info
fi
echo -e " \n--> Information of top occurrence PANIC messages in the greenplum cluster in the last 3 days (Top 10)" >> $generate_report_general_info
echo -e " --> PLEASE NOTE: This information depends on the availability of the master logs at location" $MASTER_DATA_DIRECTORY/pg_log "\n" >> $generate_report_general_info
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_panic | wc -l` -gt 2 ]
then 
	cat $collect_panic >> $generate_report_general_info
else
	echo -e "No information on the master log of any occurrence of PANIC message" >> $generate_report_general_info
fi
echo -e " \n--> Information of top occurrence ERROR messages in the greenplum cluster in the last 3 days (Top 10)" >> $generate_report_general_info
echo -e " --> PLEASE NOTE: This information depends on the availability of the master logs at location" $MASTER_DATA_DIRECTORY/pg_log "\n" >> $generate_report_general_info
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_error_in_db | wc -l` -gt 2 ]
then 
	cat $collect_error_in_db >> $generate_report_general_info
else
	echo -e "No information on the master log of any occurrence of ERROR message" >> $generate_report_general_info
fi
echo -e " \n--> Information of when the master lost connection to the segments aka segment crashed in the last 2 days from master logs" >> $generate_report_general_info
echo -e " --> PLEASE NOTE: This information depends on the availability of the master logs at location" $MASTER_DATA_DIRECTORY/pg_log >> $generate_report_general_info
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_crash_recovery_info | wc -l` -gt 8 ]
then 
	echo -e " --> NOTE: The information in the messages column is limited to 100 characters \n" >> $generate_report_general_info
	cat $collect_crash_recovery_info >> $generate_report_general_info
else
	echo -e "\nNo information on the master log of master losing connection with segments \n" >> $generate_report_general_info
fi
}

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

echo "INFO - Creating the directories which will be used for storing logs / temp files (if not available)"

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

export collect_dblist=${tmpdir}/${script_basename}.dblist.tmp
export collect_version=${tmpdir}/${script_basename}.version.tmp
export collect_seg_configuration=${tmpdir}/${script_basename}.config.tmp
export collect_segrpt_configuration=${tmpdir}/${script_basename}.configrpt.tmp
export collect_config_history=${tmpdir}/${script_basename}.confighistory.tmp
export collect_fatal=${tmpdir}/${script_basename}.fatal.tmp
export collect_panic=${tmpdir}/${script_basename}.panic.tmp
export collect_crash_recovery_info=${tmpdir}/${script_basename}.crashrecovery.tmp
export collect_error_in_db=${tmpdir}/${script_basename}.errorindb.tmp
export collect_master_standby=${tmpdir}/${script_basename}.masterstndby.tmp
export collect_fatal_panic_error=${tmpdir}/${script_basename}.fatalpanicerror.tmp
export junkfile=${tmpdir}/${script_basename}.junk
export generate_report_general_info=${logdir}/generate_report_general_info.rpt
export old_generate_report_general_info_1=${logdir}/generate_report_general_info.rpt.1
export old_generate_report_general_info_2=${logdir}/generate_report_general_info.rpt.2

# Save old log files

echo "INFO - Checking / archiving the old log files from previous run"

if (test -f $old_generate_report_general_info_1 )
then
mv -f $old_generate_report_general_info_1 $old_generate_report_general_info_2 > $junkfile 2>> $junkfile
fi

if (test -f $generate_report_general_info )
then
mv -f $generate_report_general_info $old_generate_report_general_info_1 > $junkfile 2>> $junkfile
fi

# Calling the Function to confirm the script execution

version_info
seg_config_info
seg_config_hist
master_stndby_info
get_error_info
fatal_occurrence
panic_occurrence
error_in_db_occurrence
crash_recovery_occurrence
generate_report_general_info

# Program ending messages.

echo "INFO - Program ( ${script_basename} ) succesfully completed at" `date`
echo "INFO - Program ( ${script_basename} ) report file available at" $generate_report_general_info