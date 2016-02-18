#!/bin/bash
#
#  run_database_info.sh
#  pivotal - 2014
#

# Function : To gather genertic database information. 

generic_db_info() {

echo "INFO - Generating the report on the list of database"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-list.sql | egrep -v "rows\)|row\)" > $collect_dblist

                    }

# Function : To collect relevant information with specific to database . 

db_info() {

# The below line gathers all the relations with reference to specific type.

echo "INFO - Generating the report specific to database"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -Atc "select datname from pg_database where datallowconn='t' and datname not in ('template1','template0','postgres') order by 1" | while read line
do 
echo "INFO - Generating the report for relation information in the database" $line
$GPHOME/bin/psql -d $line -p $PGPORT -Atf $sqldir/database-relation-list.sql  > $collect_db_relation_info
echo -e "\n --------------------------------- " >> $collect_dbrpt_relation_info
echo -e " DATABASE:" $line >> $collect_dbrpt_relation_info
echo -e " --------------------------------- \n" >> $collect_dbrpt_relation_info
echo -e " ==> Relation count in the database \n"  >> $collect_dbrpt_relation_info
echo "        Relation Information                          |              Result              " >> $collect_dbrpt_relation_info
echo "------------------------------------------------------+----------------------------------" >> $collect_dbrpt_relation_info
echo "Relation - Heap                                       | " ` grep heap $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Index                                      | " ` grep index $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Append Only (Row)                          | " ` grep appendobjrow $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Append Only (Column)                       | " ` grep appendobjcolumn $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Append Only (AO Table)                     | " ` grep appendtab $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Append Only (AO Table Index)               | " ` grep appendindx $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Toast Table                                | " ` grep toast $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Toast Table Index                          | " ` grep tostindx $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Partition Table                            | " ` grep partition $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - External Table                             | " ` grep external $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - View                                       | " ` grep view $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Composite Type                             | " ` grep composite $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Sequence                                   | " ` grep sequence $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relation - Index (on top of AO table)                 | " ` grep AOblkdir $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Constraint - Primary                                  | " ` grep pkconst $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Constraint - Unique                                   | " ` grep ukconst $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Constraint - Foriegn                                  | " ` grep fkconst $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Constraint - Check                                    | " ` grep ckconst $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Functions                                             | " ` grep proc $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Triggers                                              | " ` grep trigger $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Schema                                                | " ` grep namespace $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Temp Schema                                           | " ` grep temp $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Are Orphan temp shema available on Master             | " ` grep orphanmasttmp $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Are Orphan temp shema available on Segments           | " ` grep orphansegtmp $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relations with random distribution                    | " ` grep randomly $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info
echo "Relations with distribution policy                    | " ` grep distributed $collect_db_relation_info | cut -d'|' -f2 ` >> $collect_dbrpt_relation_info

# The below line gathers the database transaction age to avoid wraparounds.

echo -e "\n ==> Database transaction age > 150000000 (TOP 10) \n"  >> $collect_dbrpt_relation_info 

$GPHOME/bin/psql -d $line -p $PGPORT -f $sqldir/database-transaction-age.sql| egrep -v "rows\)|row\)" > $collect_db_trans_age_info 

if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_db_trans_age_info | wc -l` -gt 2 ]
then 
	cat $collect_db_trans_age_info >> $collect_dbrpt_relation_info
else
	echo -e "No segments has the database transaction age greater than 150000000 for this database \n" >> $collect_dbrpt_relation_info
fi

# The below line gathers the relation transaction age.

echo -e " ==> Relation transaction age > 150000000 (TOP 10) \n"  >> $collect_dbrpt_relation_info 

$GPHOME/bin/psql -d $line -p $PGPORT -f $sqldir/database-transaction-relation-age.sql| egrep -v "rows\)|row\)" > $collect_relation_trans_age_info 

if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_relation_trans_age_info | wc -l` -gt 2 ]
then 
	cat $collect_relation_trans_age_info >> $collect_dbrpt_relation_info
else
	echo -e "No segments has the relation transaction age greater than 150000000 for this database \n" >> $collect_dbrpt_relation_info
fi

# The below line bloat information of the relation in the database.

echo -e " ==> Identifying relations that has bloat on the database"  >> $collect_dbrpt_relation_info  
echo -e " ==> NOTE: The query needs upto date statistics (analyze) for the relations \n"  >> $collect_dbrpt_relation_info

$GPHOME/bin/psql -d $line -p $PGPORT -f $sqldir/database-relation-bloat.sql | egrep -v "rows\)|row\)" > $collect_db_relation_bloat

if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_db_relation_bloat | wc -l` -gt 2 ]
then 
	cat $collect_db_relation_bloat >> $collect_dbrpt_relation_info  
else
	echo -e "No relation with bloat detected on this database \n" >> $collect_dbrpt_relation_info 
fi

# The below line gathers the database skew information.

echo -e " ==> Database skew information (The values are in bytes)."  >> $collect_dbrpt_relation_info
echo -e " ==> NOTE: This approach check for file sizes for each table for each segment, " >> $collect_dbrpt_relation_info
echo -e " ==>       It then will output only the tables that have at least one segment with more than 20% more byte"  >> $collect_dbrpt_relation_info    

$GPHOME/bin/psql -d $line -p $PGPORT -f $sqldir/database-create-skew-function.sql > $junkfile 2>&1 
$GPHOME/bin/psql -d $line -p $PGPORT -f $sqldir/database-get-skew-info.sql | egrep -v "rows\)|row\)" > $collect_db_skew

if [ `sed '/^$/d;s/[[:blank:]]//g' $collect_db_skew | wc -l` -gt 2 ]
then 
echo -e " ==> HINT: largest_segment_percentage is calculated using max(size)/sum(size) for the relation i.e  sum(size) = size of the relation on all segments," >> $collect_dbrpt_relation_info	
echo -e " ==>        max(size) = max size on a single segment ( if it has multiple files like xxx.1, xxx.2,.... then it adds them up.) \n" >> $collect_dbrpt_relation_info	
	cat $collect_db_skew >> $collect_dbrpt_relation_info  
else
	echo -e "\n No database skew found for any relation \n" >> $collect_dbrpt_relation_info 
fi

# The below line gathers all the relations and sorts the objects with highest size.

echo -e " ==> Relation size in the database - Index inclusive (TOP 10) \n"  >> $collect_dbrpt_relation_info  

$GPHOME/bin/psql -d $line -p $PGPORT -f $sqldir/database-relation-size.sql | egrep -v "rows\)|row\)" > $collect_db_relation_size 

cat $collect_db_relation_size >> $collect_dbrpt_relation_info 

done
			}

# Function : To gather GUC that is currently being set in the database. 

db_parameter_info() {

echo "INFO - Generating the report on the parameter values of the cluster"

$GPHOME/bin/psql -d $PGDATABASE -p $PGPORT -f $sqldir/database-parameter-list.sql | egrep -v "rows\)|row\)" > $collect_guc_value

                    }

# Function : Collect all the information generated above to a single report file.

generate_report_general_info() {

echo "INFO - Generating the report for the program: " $script_basename

echo -e "\n \t \t \t \t \t \t     GREENPLUM DATABASE WIDE INFORMATION" > $generate_report_database_info
echo -e "\t \t \t \t \t \t  -----------------------------------------\n " >> $generate_report_database_info
echo -e " --> Information of the database in the greenplum cluster \n" >> $generate_report_database_info
cat $collect_dblist >> $generate_report_database_info
echo -e " --> Information with specific to database" >> $generate_report_database_info
cat $collect_dbrpt_relation_info >> $generate_report_database_info
echo -e " --> The values of GUC in the cluster" >> $generate_report_database_info
echo -e " --> NOTE: 1. The column \"parameter value\" is trimmed to 30 characters" >> $generate_report_database_info
echo -e " -->       2. The column \"parameter desc\" is trimmed to 100 characters \n" >> $generate_report_database_info
cat $collect_guc_value >> $generate_report_database_info

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

export collect_dblist=${tmpdir}/${script_basename}.dblist.tmp
export collect_db_trans_age_info=${tmpdir}/${script_basename}.dbage.tmp
export collect_relation_trans_age_info=${tmpdir}/${script_basename}.relationage.tmp
export collect_db_relation_bloat=${tmpdir}/${script_basename}.dbrelationbloat.tmp
export collect_db_relation_info=${tmpdir}/${script_basename}.dbrelationcount.tmp
export collect_db_relation_size=${tmpdir}/${script_basename}.dbrelationsize.tmp
export collect_dbrpt_relation_info=${tmpdir}/${script_basename}.dbrelationcountreport.tmp
export collect_guc_value=${tmpdir}/${script_basename}.gucvalue.tmp
export collect_db_skew=${tmpdir}/${script_basename}.dbskew.tmp
export junkfile=${tmpdir}/${script_basename}.junk
export generate_report_database_info=${logdir}/generate_report_database_info.rpt
export old_generate_report_database_info_1=${logdir}/generate_report_database_info.rpt.1
export old_generate_report_database_info_2=${logdir}/generate_report_database_info.rpt.2

# Save old log files

echo "INFO - Checking / archiving the old log files from previous run"

if (test -f $old_generate_report_database_info_1 )
then
mv -f $old_generate_report_database_info_1 $old_generate_report_database_info_2 > $junkfile 2>> $junkfile
fi

if (test -f $generate_report_general_info )
then
mv -f $generate_report_general_info $old_generate_report_database_info_1 > $junkfile 2>> $junkfile
fi

if (test -f $collect_dbrpt_relation_info )
then
rm -rf $collect_dbrpt_relation_info > $junkfile 2>> $junkfile
fi

# Calling the Function to confirm the script execution

generic_db_info
db_info
db_parameter_info
generate_report_general_info

# Program ending messages.

echo "INFO - Program ( ${script_basename} ) succesfully completed at" `date`
echo "INFO - Program ( ${script_basename} ) report file available at" $generate_report_database_info