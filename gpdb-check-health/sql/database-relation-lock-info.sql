SELECT
    l.locktype AS "Blocker locktype",
    d.datname AS "Database",
    l.relation::regclass  AS "Blocking Table",
    a.usename AS "Blocking user",
    l.pid AS "Blocker pid",
    l.mppsessionid AS "Blockers SessionID",
    l.mode AS "Blockers lockmode",
    now()-a.query_start AS "Blocked duration",
    substring(a.current_query from 1 for 40) AS "Blocker Query"
FROM
    pg_locks l,
    pg_stat_activity a,
    pg_database d
WHERE l.pid=a.procpid
AND l.database=d.oid
AND l.granted = true
AND relation in ( select relation from pg_locks where granted='f')
ORDER BY 3;