# Purpose

In this approach the view looks at the file sizes for each table for each segment. It then will output only the tables that have at least one segment with more than 20% more bytes than expected.

Two variation of the same script have been described below one that gives you a quick summary and other one detailed information of the OS file size distribution.

There are drawbacks using the above method ( i.e calculating the data skew using the OS file size ) , the major one being table bloat.

DML operation on the table doesn't release space back to OS, So the calculation above takes into consideration the size occupied by table bloat.

Please check the article on what is table bloat & the article on how to remove bloat. 

# Execution

+ Execute the function to create the external table and the view.

```
SELECT fn_create_db_files();
```

+ Now use the view to obtain the information

```
SELECT * FROM vw_file_skew ORDER BY 3 DESC;
```

+ To use the second function use 

```
select * from public.fn_get_skew();
```
