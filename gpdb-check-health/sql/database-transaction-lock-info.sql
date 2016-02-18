SELECT
    l.locktype AS "Blocker locktype",
    l.relation::regclass  AS "Blocking Table",
    a.usename AS "Blocking user",
    l.pid AS "Blocker pid",
    l.mppsessionid AS "Blockers SessionID",
    l.mode AS "Blockers lockmode",
    now()-a.query_start AS "Blocked duration",
    substring(a.current_query from 1 for 40) AS "Blocker Query"
FROM
    pg_locks l,
    pg_locks w,
    pg_stat_activity a
WHERE l.pid=a.procpid
AND l.transaction=w.transactionid
AND l.granted = true
AND w.granted = false
AND l.transactionid is not NULL
ORDER BY 3;