select 'connection|' || count(*)
from pg_stat_activity where procpid not in ( select pg_backend_pid() )
union
select 'active|' || count(*)
from pg_stat_activity
where current_query<>'<IDLE>' and procpid not in ( select pg_backend_pid() )
union
select 'idle|' || count(*)
from pg_stat_activity
where current_query='<IDLE>'
union
select 'waiting|' || count(*)
from pg_stat_activity
where waiting='t'
union
select 'orphan|'|| count(DISTINCT connection)
from (select 
         hostname ,
         port ,
         pl.gp_segment_id as segment ,
         'con'||mppsessionid as connection ,
         relation::oid::regclass ,  granted  
       from 
         pg_locks pl ,
         gp_segment_configuration gsc 
       where 
         pl.gp_segment_id=gsc.content 
       and gsc.role='p'
       and mppsessionid not in (select sess_id from pg_stat_activity )
     ) as q1
;