SELECT     
    nspname ||'.'|| relname "Relation Name",
    nspname "Schema Name",
    case relkind when 'r' then 'Table'
                 when 'i' then 'Index'
                 when 'S' then 'Sequence'
                 when 't' then 'Toast Table'
                 when 'v' then 'View'
                 when 'c' then 'Composite Type'
                 when 'o' then 'Append-only Tables'
                 when 's' then 'Special'
    end "Object Type",
    pg_size_pretty(pg_total_relation_size(a.oid)) AS "size"
FROM 
    pg_class a , pg_namespace b 
WHERE 
      b.oid = a.relnamespace
      and nspname NOT IN ('pg_catalog', 'information_schema')
      and a.relkind!='i'
      and b.nspname !~ '^pg_toast'
ORDER BY pg_total_relation_size(a.oid) DESC
LIMIT 10;