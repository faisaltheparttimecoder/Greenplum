select nspname||'.'||relname as "Table Name",
  textcat_all(attname) as " Distribution Policy"
from pg_attribute 
join (SELECT pg_class.oid,nspname,relname,unnest(attrnums) as col 
    from gp_distribution_policy  
    join  pg_class  on localoid=oid 
    join pg_namespace nsp on relnamespace=nsp.oid) def on def.col=attnum and oid=attrelid group by 1
union
select nspname||'.'||relname as "Table Name",
       'Random' as " Distribution Policy"
from pg_class c 
join pg_namespace n on n.oid=c.relnamespace
join gp_distribution_policy d on d.localoid=c.oid
and d.attrnums is NULL;
