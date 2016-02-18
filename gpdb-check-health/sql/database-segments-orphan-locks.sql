SELECT 
    w.relation::regclass AS "Table",
    w.mode               AS "Waiters Mode",
    w.pid                AS "Waiters PID",
    w.mppsessionid       AS "Waiters SessionID",
    b.mode               AS "Blockers Mode",
    b.pid                AS "Blockers PID",
    b.mppsessionid       AS "Blockers SessionID",
    (select 'Hostname: ' || c.hostname ||' Content: '|| c.content || ' Port: ' || port from gp_segment_configuration c where c.content=b.gp_segment_id and role='p') AS "Blocking Segment"
FROM pg_catalog.pg_locks AS w, pg_catalog.pg_locks AS b 
Where ((w."database" = b."database" AND w.relation  = b.relation)
OR w.transactionid = b.transaction)
AND w.granted='f'
AND b.granted='t'
AND w.mppsessionid <> b.mppsessionid
AND w.mppsessionid in (SELECT l.mppsessionid FROM pg_locks l WHERE l.granted = true AND relation in ( select relation from pg_locks where granted='f'))
AND w.gp_segment_id = b.gp_segment_id
ORDER BY 1;