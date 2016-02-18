#!/bin/bash
#
#  get_distribution_policy.sh
#  pivotal - 2014
#  
#
#

# Function : To extract all the user tables.

extract_table() {

# echo "INFO - Extracting all the table names, schema name and oid's"
# echo

 psql -d $PGDATABASE -p $PGPORT -Atc "SELECT 
                                      a.oid , nspname , relname
                                      FROM pg_class a , pg_namespace b
                                      WHERE 
                                      relkind='r' 
                                      AND b.oid=a.relnamespace
                                      AND relname not in (select  partitiontablename from pg_partitions)
                                      AND relnamespace in ( select oid from pg_namespace 
                                                            where nspname not in ('gp_toolkit','pg_toast','pg_aoseg','information_schema','pg_catalog') and nspname not like 'pg_temp%') order by 3" > $extract_table
                    }


# Function : To extract all the distribution policy.

ext_parent_tb_dist_plcy() {

# echo "INFO - Extracting the distribution policy for the collected table "
# echo

 cat $extract_table | while read line
 do 
   export i=`echo $line | cut -d'|' -f1`
   export j=`echo $line | cut -d'|' -f2`
   export k=`echo $line | cut -d'|' -f3`
   psql -d $PGDATABASE -p $PGPORT -xtc "SELECT localoid , attrnums
                     FROM gp_distribution_policy 
                     where localoid=($i)" | tr -d '{}' | tr -d '|' | grep -v row  > $ext_tab_parent_dist_info
    
    export table_oid=`grep localoid $ext_tab_parent_dist_info | awk '{print $2}'`
    export table_dist_col=`grep attrnums $ext_tab_parent_dist_info | awk '{print $2}'`
    if [ "$table_dist_col" = "" ];
    then 
      echo $j " " $k " Random">> $random_info
     else  
       psql -d $PGDATABASE -p $PGPORT -Atc "SELECT attname 
                                            FROM pg_attribute
                                            WHERE attrelid in ($table_oid) and attnum in ($table_dist_col)" | awk  '{ printf $1 ","}' | sed s/.$// > $ext_tab_parent_dist_col_info
    
       echo $j " " $k " " `cat $ext_tab_parent_dist_col_info` >> $non_random_info                                     
    fi
done 

}

# Function : To Print all the all the user tables.

print_table_distribution() {

# echo "INFO - Priniting the distribution policy of the table in the database " $PGDATABASE
# echo
echo "----| Table Name - With Random Distribution Policy |----"  
echo

awk 'BEGIN { printf "%-30s %-30s %s\n", "SCHEMA-NAME","TABLE-NAME","DISTRIBUTION-POLICY" 
     printf "%-30s %-30s %s\n", "-----------","----------","-------------------" }
                { printf "%-30s %-30s %s\n", $1, $2 , $3 }' $random_info  

echo
echo "----| Table Name - With Distribution Policy |----" 
echo

awk 'BEGIN { printf "%-30s %-30s %s\n", "SCHEMA-NAME","TABLE-NAME","DISTRIBUTION-POLICY" 
     printf "%-30s %-30s %s\n", "-----------","----------","-------------------" }
                { printf "%-30s %-30s %s\n", $1, $2 , $3 }' $non_random_info 
               }

# Main program starts here

# Checking the parameter passed

echo
echo "INFO - Checking the parameter passed for the script: " $0
echo

if [ $# -lt 2 ]
then

echo "ERR  - Script cannot execute since one / more parameters is missing"
echo "ERR  - Usage: $0 { Please provide us the database name & port number }"
echo "INFO - Example to run is /bin/sh get_distribution_policy.sh template1 5432"
echo

exit 1

fi

# Acception of the parameters

# echo "INFO - Passing the parameters passed to variables "
# echo

export PGDATABASE=$1
export PGPORT=$2
export extract_table=/tmp/extract_table
export ext_tab_parent_dist_info=/tmp/ext_tab_parent_dist_info
export ext_tab_parent_dist_col_info=/tmp/ext_tab_parent_dist_col_info
export random_info=/tmp/random_info
export non_random_info=/tmp/non_random_info
export junkfile=/tmp/junkfile

# Remove old temporary files.

# echo "INFO - Removing the old / temporary files from previous run, if any"
# echo 

if (test -f $extract_table )
then
rm -r $extract_table > $junkfile 2>> $junkfile
fi

if (test -f $ext_tab_parent_dist_info)
then
rm -r $ext_tab_parent_dist_info > $junkfile 2>> $junkfile
fi

if (test -f $ext_tab_parent_dist_col_info)
then
rm -r $ext_tab_parent_dist_col_info > $junkfile 2>> $junkfile
fi

if (test -f $random_info)
then
rm -r $random_info > $junkfile 2>> $junkfile
fi

if (test -f $non_random_info)
then
rm -r $non_random_info > $junkfile 2>> $junkfile
fi


# Calling the Function to confirm the script execution 

extract_table
ext_parent_tb_dist_plcy
print_table_distribution
