select
   'con'|| a.mppsessionid AS "Session ID",
   b.total_seg as "Total Segments",
   count(a.*) AS "Total Sessions"
from
  (select distinct mppsessionid,gp_segment_id 
   from pg_locks
   where mppsessionid not in (select sess_id from pg_stat_activity where procpid!=pg_backend_pid() OR current_query!='<IDLE>' OR waiting='t')
   and mppsessionid != 0
  ) a,
  (select count(*) as total_seg
   from gp_segment_configuration 
   where role='p'
  ) b
group by 1,2
having count(a.*) < b.total_seg
order by 3;