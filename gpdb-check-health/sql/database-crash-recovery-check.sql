\echo Start time of the message
\echo
select logtime "Time",
	   substring(logmessage from 1 for 100) "Message"
from check_greenplum.gp_log_database_all
where (logmessage like '%Lost connection to one or more segments - fault detector checking for segment failures%' 
or logmessage like '%Dispatcher encountered connection error%')
and logtime between now() - interval '2 days' and now()
and logmessage not like '%gp_toolkit.gp_log_database%'
order by logtime
limit 5;

\echo Ending time of the message
\echo
select logtime "Time",
	   substring(logmessage from 1 for 100) "Message"
from check_greenplum.gp_log_database_all
where (logmessage like '%Lost connection to one or more segments - fault detector checking for segment failures%' 
or logmessage like '%Dispatcher encountered connection error%')
and logtime between now() - interval '2 days' and now()
and logmessage not like '%gp_toolkit.gp_log_database%'
order by logtime
limit 5;