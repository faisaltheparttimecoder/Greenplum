select now()-query_start AS "Running Time",
	datname as "Database name",
	usename as "Username",
	procpid as "PID",
	sess_id as "Session ID",
    substring(current_query from 1 for 100) AS "Query"
from pg_stat_activity
where procpid not in (select pg_backend_pid())
and current_query not like '<IDLE>'
order by 1 desc
limit 10;
