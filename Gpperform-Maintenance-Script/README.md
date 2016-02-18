# Goal

Is to provide a simple shell scripts to help administrator schedule a maintenance task to drop historical partition on gpperfom database greater than specific retention period (This script takes in months as retention period).

This script might be needed to control the size of the gpperfmon database or to eliminate the historical data that is not needed anymore.

# Execution

+ Copy the two files (provided as attachment in this documents) "environment_parameters.env" & "gpperfmon_maintenance.sh" to any directory of your choice ( both should be on the same directory like)

```
gpadmin:Fullrack@mdw $ pwd
/data1/gpadmin
gpadmin:Fullrack@mdw $ ls -ltr
total 56
-rw------- 1 gpadmin gpadmin 7485 Aug 21 02:18 gpperfmon_maintenance.sh
-rw------- 1 gpadmin gpadmin  127 Aug 21 02:29 environment_parameters.env
```

+ open the "environment_parameters.env" and edit the parameters that reflects to your database environment.
+ Run the shell script using

```
/bin/sh gpperfmon_maintenance.sh
