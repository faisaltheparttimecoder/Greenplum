# Purpose

Often time the DBA has concerns like

+ When was the table / index etc was was last used or touched.
+ If there is a need for analyzing the table.
+ Or if there is any data added to the table so that the relation can be analyzed
+ Which partition table has the data added and which partition table need a analyze.

# Execution

+ Execute the function to create the external table and the view.

```
select fn_ident_table_last_change();
```

+ Now use the view to obtain the information

```
select * from v_ident_table_last_change;
