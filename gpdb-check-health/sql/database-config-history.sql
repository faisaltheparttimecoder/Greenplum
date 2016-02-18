select h.time "Time",
h.dbid||':'||content||':'||hostname||':'||port||':'||preferred_role "dbid:content:hostname:port:role",
"desc" "Description"
from gp_configuration_history h, gp_segment_configuration c
where "desc" like '%DOWN%' 
and c.dbid=h.dbid
order by time desc limit 10;