SELECT datname "Database Name",
	procpid "Process ID",
	sess_id "Session ID",
	sum(size)/1024::float "Total Spill Size(KB)",
	sum(numfiles) "Total Spill Files"
FROM  gp_toolkit.gp_workfile_usage_per_query
WHERE sess_id not in (select sess_id from pg_stat_activity where procpid=pg_backend_pid())
GROUP BY 1,2,3
ORDER BY 4 DESC;