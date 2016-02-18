SELECT 'Hostname: '|| hostname ||' Content: '|| Content || ' Port: ' || port "Segment Information",
	datname "Database name", 
	age(datfrozenxid) "Transaction age" 
FROM pg_database d , gp_segment_configuration c
WHERE d.gp_segment_id=c.content
AND d.datname=current_database()
AND age(datfrozenxid)>150000000
UNION
SELECT 'Hostname: '|| hostname ||' Content: '|| Content || ' Port: ' || port "Segment Information",
	datname "Database name", 
	age(datfrozenxid) "Transaction age" 
FROM gp_dist_random('pg_database') d , gp_segment_configuration c
WHERE d.gp_segment_id=c.content
AND d.datname=current_database() 
AND age(datfrozenxid)>150000000
order by 3 desc
LIMIT 10;