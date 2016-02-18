#!/bin/bash
#
#  gpperfmon_maintenance.sh
#  pivital - 2014
#  
#
#

# Function : To extract the history partition name which is less than retention period.

extract_partition_information() {

echo "INFO - Extracting information of partition older than retention period: "$Retention" Months"
echo

psql -d $PGDATABASE -p $PGPORT -c "SELECT
                    				schemaname||'.'||tablename as \"Parent Table\",
                     				partitionschemaname||'.'||partitiontablename as \"Partition Name\",
                    				age(substring(partitionrangestart from 2 for 19)::timestamp) \"Partition Age\",
                    				substring(partitionrangestart from 2 for 19)::timestamp as \"Partition Start\",
                    				substring(partitionrangeend from 2 for 19)::timestamp as \"Partition End\",
                    				partitionrank as \"Parition Rank\",
                    				(select pg_size_pretty(pg_total_relation_size(b.partitiontablename)) from pg_partitions b where p.partitiontablename=b.partitiontablename ) as \"Partition Size\"
                    			   FROM
                    				pg_partitions p
                    			   WHERE
                    				partitionrangestart < current_timestamp::timestamp without time zone  - interval '${Retention}  months'
                    				and tablename like '%history'
                    			   ORDER BY 3 desc;" 
                    }

# Function : To extract the sql to drop those older partition, but it ignores if that is the only partition of the table.

generate_sql_to_drop() {

echo "INFO - Generating SQL to drop partiton older than retention period: "$Retention" Months"
echo

psql -d $PGDATABASE -p $PGPORT -Atc "SELECT
 								'ALTER TABLE ' ||schemaname||'.'||tablename || ' DROP PARTITION FOR (RANK(' || partitionrank|| '));'
							   FROM
								pg_partitions
							   WHERE
								partitionrangestart < current_timestamp::timestamp without time zone  - interval '${Retention}  months'
								and tablename in ( select a.tablename from pg_partitions a where a.tablename like '%history' group by a.tablename having count(*) > 1 )
							   ORDER BY partitionrank desc; "  > $sql_file
                    }

# Function : To drop the partition.

execute_drop_sql() {

echo "INFO - Excecuting the sql file generated to drop the partition with retention older than: " $Retention" Months"
echo

psql -d $PGDATABASE -p $PGPORT -ef $sql_file > $drop_output

                    }

# Function : To extract the history partition name after executing the drop.

extract_partition_info_after_drop() {

echo "INFO - Extracting information of partition after dropping the partition more than the retention period: "$Retention" Months"
echo 
echo "MESG - If any partition left after drop, the partition could be the last partition of the table"
echo "MESG - Drop script ignore the last partition , to avoid the below error \"cannot drop partition for rank 1 of relation \"<table-name>\" -- only one remains\" "
echo 

psql -d $PGDATABASE -p $PGPORT -c "SELECT
                    				schemaname||'.'||tablename as \"Parent Table\",
                     				partitionschemaname||'.'||partitiontablename as \"Partition Name\",
                    				age(substring(partitionrangestart from 2 for 19)::timestamp) \"Partition Age\",
                    				substring(partitionrangestart from 2 for 19)::timestamp as \"Partition Start\",
                    				substring(partitionrangeend from 2 for 19)::timestamp as \"Partition End\"
                    			FROM
                    				pg_partitions p
                    			WHERE
                    			     partitionrangestart < current_timestamp::timestamp without time zone  - interval '${Retention}  months'
                    				and tablename like '%history'
                    			ORDER BY 3 desc;"
                    }

# Main program starts here

# Script and log directories

echo "INFO - Generating the directories name / location where the output logs will saved / stored"
echo 

export script=$0
export script_basename=`basename $script`
export script_dir=`dirname $script`
cd $script_dir
export script_dir=`pwd`
export install_dir=`dirname $script_dir`
export logdir=$script_dir/log
export tmpdir=$script_dir/tmp
export fixdir=$script_dir/fix

# Creating tmp / log directory

echo "INFO - Creating the directories which will be used for storing logs / temp files ( if not available ) "
echo 

mkdir -p $script_dir/log
mkdir -p $script_dir/tmp
mkdir -p $script_dir/fix

# Reading the parameter file to set the environment

echo "INFO - Reading the parameter file to set the environment"
echo 

export paramfile=$script_dir/environment_parameters.env
export GPHOME=`grep -i gphome $paramfile | grep -v grep | cut -d: -f2`
source $GPHOME/greenplum_path.sh
export PGDATABASE=`grep -i pgdatabase $paramfile | grep -v grep | cut -d: -f2`
export PGPORT=`grep -i pgport $paramfile | grep -v grep | cut -d: -f2`
export MASTER_DATA_DIRECTORY=`grep -i master_data_directory $paramfile | grep -v grep | cut -d: -f2`
export Retention=`grep -i retention $paramfile | grep -v grep | cut -d: -f2`

# Script and log filenames

echo "INFO - Generating filenames needed for output logs"
echo 

export logfile=${logdir}/${script_basename}.${PGDATABASE}.${PGPORT}.log
export oldlog1=${logdir}/${script_basename}.${PGDATABASE}.${PGPORT}.log.1
export oldlog2=${logdir}/${script_basename}.${PGDATABASE}.${PGPORT}.log.2
export junkfile=${tmpdir}/${script_basename}.${PGDATABASE}.${PGPORT}.junk
export sql_file=${fixdir}/${script_basename}.${PGDATABASE}.${PGPORT}.dropping_older_partition.sql
export drop_output=${tmpdir}/${script_basename}.${PGDATABASE}.${PGPORT}.drop_output.tmp

# Save old log files

echo "INFO - Checking / archiving the old log files from previous run"
echo 

if (test -f $oldlog1 )
then
mv -f $oldlog1 $oldlog2 > $junkfile 2>> $junkfile
fi

if (test -f $logfile )
then
mv -f $logfile $oldlog1 > $junkfile 2>> $junkfile
fi

# Remove old temporary files.

echo "INFO - Removing the old / temporary files from previous run, if any"
echo 

if (test -f $extract_table )
then
rm -r $sql_file > $junkfile 2>> $junkfile
fi

# Direct messages to logfile

echo "INFO - All the log / output messages are being moved to logfile: " $logfile
echo "INFO - Please use a different session to view the progress / logfile: " $logfile
echo "INFO - Do not press ctrl + c or kill the session unless its needed , allow the program to complete"
echo 

exec > $logfile 2>> $logfile

# Printing the message on the environment that will be used by this script 

echo "INFO - Program succesfully started" 
echo "INFO - Program started at" `date`
echo
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo
echo "MESG - GreenPlum Database Cluster Environment: "
echo
echo "       INFO - Software Location:" $GPHOME 
echo "       INFO - Database:" $PGDATABASE
echo "       INFO - Port:" $PGPORT
echo "       INFO - Master Data Directory:" $MASTER_DATA_DIRECTORY
echo "       INFO - Retention:"$Retention" Months"
echo
echo "MESG - The script logs name / location" 
echo
echo "       INFO - Logfile Destination:" $logdir
echo "       INFO - Logfile Name:" $logfile
echo
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo


# Calling the Function to confirm the script execution 

extract_partition_information
generate_sql_to_drop
execute_drop_sql
extract_partition_info_after_drop

# Program ending messages.

echo "INFO - Progam succesfully completed" 
echo "INFO - Program ended at" `date`
echo