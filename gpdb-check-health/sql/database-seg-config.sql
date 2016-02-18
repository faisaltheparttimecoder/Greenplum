select 'uptime|' || now() - pg_postmaster_start_time()
union
select 'totalcount|' || count(*)
from gp_segment_configuration
union
select 'seghost|' || count(distinct hostname)
from gp_segment_configuration
where content<>'-1'
union
select 'masterhost|' || count(distinct hostname)
from gp_segment_configuration
where content='-1'
union
select 'primary|' || count(*)
from gp_segment_configuration
where role='p' and content<>'-1'
union
select 'mirror|' || count(*)
from gp_segment_configuration
where role='m' and content<>'-1'
union
select 'standby|' || case count(*) when 1 then 'no' else 'yes' end
from gp_segment_configuration
where content='-1'
union
select 'down|' || count(*)
from gp_segment_configuration
where status='d'
union
select 'preferred|' || count(*)
from gp_segment_configuration
where role<>preferred_role
union
select 'sync|' || count(*)
from gp_segment_configuration
where mode='s'
union
select 'changetracking|' || count(*)
from gp_segment_configuration
where mode='c'
union
select 'resync|' || count(*)
from gp_segment_configuration
where mode='r'
union
select 'role|' || count(*)
from pg_roles
union
select 'superuser|' || count(*)
from pg_roles
where rolsuper='t'; 
