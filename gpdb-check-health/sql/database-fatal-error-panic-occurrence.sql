SELECT logseverity "Severity",
	   logdatabase "Database name",
	   substring(logmessage from 1 for 80) "Message",
	   count(*) "# of occurance"  
FROM check_greenplum.gp_log_database_all 
WHERE logseverity in ('ERROR','FATAL','PANIC') 
AND logtime between now() - interval '3 days' and now()
AND logmessage not like '%check_greenplum%'
GROUP BY logseverity,logdatabase,logmessage 
ORDER BY 4 DESC ;