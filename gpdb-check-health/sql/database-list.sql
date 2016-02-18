select
	d.oid "Database OID",
    d.datname "Database Name", 
    r.rolname "Database Owner",
    pg_catalog.pg_encoding_to_char(d.encoding) as "Database Encoding",
    d.datallowconn "Connections Allowed",
    d.datconnlimit "Connection Limit",
    pg_size_pretty(pg_database_size(d.datname)) "Database Size"
from 
    pg_catalog.pg_database d , pg_catalog.pg_roles r
where
	d.datdba=r.oid
order by 2 ;
