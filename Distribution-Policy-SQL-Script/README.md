# Goal

The distribution policy on any Pivotal Greenplum Database can be easily found with "\d <TableName>" , or can be retrieved from gp_distribution_policy table and matching with pg_attributes, but there is no direct SQL query that is available which can be queried to obtain distribution policy on each table from catalog tables.

In this document we will create a function that can help you create a simple SQL to retrieve information of the tables distribution policy.

# Execution 

+ Create the ddl on the database

```
psql -d <database-name> -f create_ddl.sql
```

+ Execute the query to extract the information 

```
psql -d <database-name> -f distribution-policy.sql
```
