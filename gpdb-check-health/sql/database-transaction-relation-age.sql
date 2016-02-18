SELECT 'Hostname: '|| hostname ||' Content: '|| Content || ' Port: ' || port "Segment Information",
		n.nspname||'.'|| r.relname "Relation Name", 
		age(r.relfrozenxid) "Relation Age"
FROM pg_class r, gp_segment_configuration c , pg_namespace n
WHERE r.relkind ='r' 
AND r.relstorage != 'x' 
AND age(r.relfrozenxid)>150000000
AND r.gp_segment_id=c.content
AND n.oid=r.relnamespace
union
SELECT 'Hostname: '|| hostname ||' Content: '|| Content || ' Port: ' || port "Segment Information",
		n.nspname||'.'||r.relname "Relation Name", 
		age(r.relfrozenxid)  "Relation Age"
FROM gp_dist_random('pg_class') r, gp_segment_configuration c , pg_namespace n
WHERE r.relkind ='r' 
AND r.relstorage != 'x' 
AND age(r.relfrozenxid)>150000000
AND r.gp_segment_id=c.content
AND n.oid=r.relnamespace
ORDER BY 3 DESC
LIMIT 10;
