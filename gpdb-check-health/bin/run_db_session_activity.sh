#!/bin/bash
#
#  run_db_session_activity.sh
#  pivotal - 2014
#

# Function : To gather the version of the postgres / greenplum 

session_info() {

echo "INFO - Generating report on the session activity in the database"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -Atf $sqldir/database-session-activity.sql > $collect_session_info
echo "        Database Session Activty                             |              Result              " > $collect_session_info_rpt
echo "-------------------------------------------------------------+----------------------------------" >> $collect_session_info_rpt
echo "Total connection in the greenplum cluster                    : " ` grep connection $collect_session_info | cut -d'|' -f2 ` >> $collect_session_info_rpt
echo "Total active statements in the cluster                       : " ` grep active $collect_session_info | cut -d'|' -f2 ` >> $collect_session_info_rpt
echo "Total idle statements in the cluster                         : " ` grep idle $collect_session_info | cut -d'|' -f2 ` >> $collect_session_info_rpt
echo "Total waiting statements in the cluster (waiting on master)  : " ` grep waiting $collect_session_info | cut -d'|' -f2 ` >> $collect_session_info_rpt
echo "Total orphan process in the cluster (no session on master)   : " ` grep orphan $collect_session_info | cut -d'|' -f2 ` >> $collect_session_info_rpt

                  	}

# Function : To gather orphan process information . 

check_orphan_info() {

echo "INFO - Generating the report of process and checking if the total segments = total sessions "

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-orphan-info.sql | egrep -v "rows\)|row\)"  > $collect_orphan_info

                    }


# Function : To gather longest connected session in the database. 

check_longest_conn() {

echo "INFO - Generating the report for top 10 longest connected sessions in the database "

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-longest-conn.sql | egrep -v "rows\)|row\)"  > $collect_longest_connected_session

                    }
# Function : To gather longest running query in the database. 

check_longest_query() {

echo "INFO - Generating the report for top 10 longest running query in the database "

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-longest-query.sql | egrep -v "rows\)|row\)"  > $collect_longest_query

                    }

# Function : To gather database lock information. 

check_dblocks() {

echo "INFO - Generating a report of database lock if any"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-lock-info.sql | egrep -v "rows\)|row\)"  > $collect_dblock_info

                    }

# Function : To gather database lock for locktype relation . 

check_relation_dblocks() {

echo "INFO - Generating the report of database lock with locktype = Relation "

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-relation-lock-info.sql | egrep -v "rows\)|row\)"  > $collect_relation_dblock_info

                    }


# Function : To gather database lock for locktype transaction . 

check_transaction_dblocks() {

echo "INFO - Generating the report of database lock with locktype = Transaction "

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-transaction-lock-info.sql | egrep -v "rows\)|row\)"  > $collect_transaction_dblock_info

                    }

# Function : To gather resource queue information . 

check_rq_info() {

echo "INFO - Generating the report of resource queue usage or if locktype = resource queue"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-rq-info.sql | egrep -v "rows\)|row\)"  > $collect_rq_info

				}

# Function : To gather orphan process lock information . 

check_orphan_lock_info() {

echo "INFO - Generating the report of locks if its related to orphan process"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-segments-orphan-locks.sql | egrep -v "rows\)|row\)"  > $collect_orphan_lock_info

                    }

# Function : To gather Workfile / Spill File / Processing skew information . 

check_processing_spillfiles() {

echo "INFO - Generating the report on Workfile / Spill File / Processing skew information"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-processing-skew.sql | egrep -v "rows\)|row\)"  > $collect_processing_skew

                    }

# Function : To generate the hostfile of the server. 

get_hostname_info() {

echo "INFO - Generating the hostfile of active segments"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -Atf $sqldir/database-hostname.sql | egrep -v "rows\)|row\)"  > $collect_hostname_info

                    }

# Function : To generate the hostfile of the server. 

check_vacuum_running_seg() {

echo "INFO - Generating the report of running VACUUM process"

$GPHOME/bin/gpssh -f $collect_hostname_info "ps aux|head -1;ps aux |grep -i vacuum | grep -v grep"  > $collect_vacuum_info
cat $collect_vacuum_info  | sed  's/\[//g' | awk '{print $1}' | uniq -c | while read line
do
export cnt=`echo $line | awk '{print $1}'`
export hst=`echo $line | awk '{print $2}'`
if [ $cnt -gt 2 ]
then 
cat $collect_vacuum_info | grep ${hst}
fi
done > $collect_vacuum_info_rpt

                    }

generate_report_general_info() {

echo "INFO - Generating the report for the program: " $script_basename

echo -e "\n \t \t \t \t \t \t    SESSION INFORMATION ON THE CLUSTER" > $generate_report_db_session_activity
echo -e "\t \t \t \t \t \t ---------------------------------------- \n " >> $generate_report_db_session_activity
echo -e " --> Session activity on the greeplum cluster \n" >> $generate_report_db_session_activity
cat $collect_session_info_rpt >> $generate_report_db_session_activity
echo -e "\n --> Information on the process and if its a orphan session in the greenplum cluster" >> $generate_report_db_session_activity
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_orphan_info | wc -l` -gt 2 ]
then 
echo -e " --> NOTE: From the below report total segments = total sessions, if not then the session is orphan or missing on one more segments " >> $generate_report_db_session_activity
echo -e " --> HINT: If total segments <> total sessions, check gp_segment_id under pg_locks where mppsessionid = < the session ID without suffix con > " >> $generate_report_db_session_activity
echo -e " --> KNOWN ISSUE: If there is a backup/restore (especially gp_dump/gp_restore) running, then to take of the parallel feature each " >> $generate_report_db_session_activity
echo -e " -->                 segments connects independently and issue COPY FROM/TO, so they are not Orphan Process as well \n" >> $generate_report_db_session_activity
	cat $collect_orphan_info >> $generate_report_db_session_activity
else
	echo -e "\nNo information of any orphan sessions in the greenplum cluster \n" >> $generate_report_db_session_activity
fi
echo -e " --> Information on IDLE session and when was it last activated on greenplum cluster (TOP 10) \n" >> $generate_report_db_session_activity
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_longest_connected_session | wc -l` -gt 2 ]
then 
	cat $collect_longest_connected_session >> $generate_report_db_session_activity
else
	echo -e "No information of any IDLE connection in the greenplum cluster \n" >> $generate_report_db_session_activity
fi
echo -e " --> Information of longest running query on greenplum cluster (TOP 10) " >> $generate_report_db_session_activity
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_longest_query | wc -l` -gt 2 ]
then 
echo -e " --> NOTE: Query is trimed to 100 characters \n" >> $generate_report_db_session_activity
	cat $collect_longest_query >> $generate_report_db_session_activity
else
	echo -e "\nNo information of any query running in the greenplum cluster \n" >> $generate_report_db_session_activity
fi
echo -e " --> Information of locks in the greenplum cluster. \n" >> $generate_report_db_session_activity
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_dblock_info | wc -l` -gt 2 ]
then 
	cat $collect_dblock_info >> $generate_report_db_session_activity
else
	echo -e "No information of any database lock in the greenplum cluster \n" >> $generate_report_db_session_activity
fi
echo -e " --> Information on blocker/holder in the database with locktype = Relation (These are Master process)" >> $generate_report_db_session_activity
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_relation_dblock_info | wc -l` -gt 2 ]
then 
echo -e " --> NOTE: Do check the orphan lock sections in the report ( if available ) , if the below sessionID are on waiters list \n" >> $generate_report_db_session_activity
	cat $collect_relation_dblock_info >> $generate_report_db_session_activity
else
	echo -e "\nNo information on blocker/holder in the database with locktype = Relation \n" >> $generate_report_db_session_activity
fi
echo -e " --> Information on blocker/holder in the database with locktype = Transaction (These are Master process)" >> $generate_report_db_session_activity
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_transaction_dblock_info | wc -l` -gt 2 ]
then 
echo -e " --> NOTE: Do check the orphan lock sections in the report ( if available ) , if the below sessionID are on waiters list \n" >> $generate_report_db_session_activity
	cat $collect_transaction_dblock_info >> $generate_report_db_session_activity
else
	echo -e "\nNo information on blocker/holder in the database with locktype = Transaction \n" >> $generate_report_db_session_activity
fi
echo -e " --> Information on resource queue usage or if locktype = resource queue \n" >> $generate_report_db_session_activity
cat $collect_rq_info >> $generate_report_db_session_activity
echo -e " --> Information on orphan locks ( i.e locks held by a segments process ) \n" >> $generate_report_db_session_activity
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_orphan_lock_info | wc -l` -gt 2 ]
then 
	cat $collect_orphan_lock_info >> $generate_report_db_session_activity
else
	echo -e "No information for orphan locks that is currently blocking current running queries\n" >> $generate_report_db_session_activity
fi
echo -e " --> Information on workfile / spill files / processing skew information \n" >> $generate_report_db_session_activity
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_processing_skew | wc -l` -gt 2 ]
then 
	cat $collect_processing_skew >> $generate_report_db_session_activity
else
	echo -e "No information for spill files generated or any processing skew\n" >> $generate_report_db_session_activity
fi
echo -e " --> Information of the vacuum process running on the segments \n" >> $generate_report_db_session_activity
if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_vacuum_info_rpt | wc -l` -gt 1 ]
then 
	cat $collect_vacuum_info_rpt >> $generate_report_db_session_activity
else
	echo -e "No information of any vacuum process running on the segments\n" >> $generate_report_db_session_activity
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

export collect_session_info=${tmpdir}/${script_basename}.sessioninfo.tmp
export collect_session_info_rpt=${tmpdir}/${script_basename}.sessioninforpt.tmp
export collect_dblock_info=${tmpdir}/${script_basename}.dblock.tmp
export collect_longest_connected_session=${tmpdir}/${script_basename}.longestconn.tmp
export collect_longest_query=${tmpdir}/${script_basename}.longestquery.tmp
export collect_relation_dblock_info=${tmpdir}/${script_basename}.relationdblock.tmp
export collect_transaction_dblock_info=${tmpdir}/${script_basename}.transactiondblock.tmp
export collect_rq_info=${tmpdir}/${script_basename}.rqinfo.tmp
export collect_orphan_info=${tmpdir}/${script_basename}.orphan.tmp
export collect_orphan_lock_info=${tmpdir}/${script_basename}.orphanlock.tmp
export collect_hostname_info=${tmpdir}/${script_basename}.hostfile.tmp
export collect_vacuum_info=${tmpdir}/${script_basename}.vacuum.tmp
export collect_vacuum_info_rpt=${tmpdir}/${script_basename}.vacuumrpt.tmp
export collect_processing_skew=${tmpdir}/${script_basename}.processingskew.tmp
export junkfile=${tmpdir}/${script_basename}.junk
export generate_report_db_session_activity=${logdir}/generate_report_db_session_activity.rpt
export old_generate_report_db_session_activity_1=${logdir}/generate_report_db_session_activity.rpt.1
export old_generate_report_db_session_activity_2=${logdir}/generate_report_db_session_activity.rpt.2

# Save old log files

echo "INFO - Checking / archiving the old log files from previous run"

if (test -f $old_generate_report_db_session_activity_1 )
then
mv -f $old_generate_report_db_session_activity_1 $old_generate_report_db_session_activity_2 > $junkfile 2>> $junkfile
fi

if (test -f $generate_report_general_info )
then
mv -f $generate_report_general_info $old_generate_report_db_session_activity_1 > $junkfile 2>> $junkfile
fi

# Calling the Function to confirm the script execution

session_info
check_orphan_info
check_longest_conn
check_longest_query
check_dblocks
check_relation_dblocks
check_transaction_dblocks
check_rq_info
check_orphan_lock_info
check_processing_spillfiles
get_hostname_info
check_vacuum_running_seg
generate_report_general_info

# Program ending messages.

echo "INFO - Program ( ${script_basename} ) succesfully completed at" `date`
echo "INFO - Program ( ${script_basename} ) report file available at" $generate_report_db_session_activity