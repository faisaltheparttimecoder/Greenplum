SELECT
    (select datname from pg_database where oid=a.database) AS "Database Name",
    a.locktype AS "Lock Type",
    a.relation::regclass AS "Relation Name",
    (select rsqname from pg_resqueue where oid=a.objid) AS "Resource Queue",
    count(*) AS "Total Waiters"
FROM pg_locks a 
WHERE a.granted='f'
GROUP BY 1,2,3,4
;