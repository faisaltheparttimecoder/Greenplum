select 'toast|' ||count(*)
from pg_class where relname like 'pg_toast%' and relkind='t' and relstorage='h'
union
select 'tostindx|' ||count(*)
from pg_class where relname like 'pg_toast%index' and relkind='i' and relstorage='h'
union
select 'view|' ||count(*)
from pg_class where relkind='v' and relstorage='v'
union
select 'composite|' ||count(*)
from pg_class where relkind='c' and relstorage='v'
union 
select 'external|' ||count(*)
from pg_class where relkind='r' and relstorage='x'
union 
select 'heap|' ||count(*)
from pg_class where relkind='r' and relstorage='h' and relname not in (select partitiontablename from pg_partitions)
union 
select 'partition|' ||count(*)
from pg_class where relkind='r' and relstorage='h' and relname in (select partitiontablename from pg_partitions)
union
select 'appendindx|' ||count(*)
from pg_class where relname like 'pg_ao%index' and relkind='i' and relstorage='h'
union
select 'appendtab|' ||count(*)
from pg_class where relkind='o' and relstorage='h'
union
select 'appendobjrow|' ||count(*)
from pg_class where relkind='r' and relstorage='a' and oid in ( select relid from pg_appendonly where columnstore='f')
union
select 'appendobjcolumn|' ||count(*)
from pg_class where relkind='r' and relstorage='c' and oid in ( select relid from pg_appendonly where columnstore='t')
union
select 'sequence|' ||count(*)
from pg_class where relkind='S' and relstorage='h'
union
select 'index|' ||count(*)
from pg_class where relkind='i' and relstorage='h' and relname not like 'pg_toast%' and relname not like 'pg_ao%'
union
select 'AOblkdir|' ||count(*)
from pg_class where relkind='b' and relstorage='h' and relname ~ 'pg_ao'
;
select 'proc|'||count(*) 
from pg_proc
;
select 'trigger|'||count(*) 
from pg_trigger
;
select 'ckconst|'|| count(*) 
from pg_constraint where contype='c'
union
select 'pkconst|'|| count(*) 
from pg_constraint where contype='p'
union
select 'fkconst|'|| count(*) 
from pg_constraint where contype='f'
union
select 'ukconst|'|| count(*) 
from pg_constraint where contype='u'
;
select 'randomly|'||count(*) 
from gp_distribution_policy where attrnums is NULL
union
select 'distributed|'||count(*) 
from gp_distribution_policy where attrnums is NOT NULL
;
select 'namespace|'||count(*)
from pg_namespace
union
select 'temp|'||count(*)
from pg_namespace where nspname like 'pg_temp%'
union 
select 'orphanmasttmp|' || case count(*) when 0 then 'no' else 'yes' end
from (select nspname from pg_namespace where nspname like 'pg_temp%' except  select 'pg_temp_' || sess_id::varchar from pg_stat_activity) as foo
union
select 'orphansegtmp|' || case count(*) when 0 then 'no' else 'yes' end 
from (select nspname from gp_dist_random('pg_namespace') where nspname like 'pg_temp%' except  select 'pg_temp_' || sess_id::varchar from pg_stat_activity) as foo
;