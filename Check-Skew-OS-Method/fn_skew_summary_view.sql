CREATE OR REPLACE FUNCTION fn_create_db_files() RETURNS void AS
$$
DECLARE 
        v_function_name text := 'fn_create_db_files';
        v_location int;
        v_sql text;
        v_db_oid text;
        v_num_segments numeric;
        v_skew_amount numeric;
BEGIN
        v_location := 1000;
        SELECT oid INTO v_db_oid 
        FROM pg_database 
        WHERE datname = current_database();

        v_location := 2000;
        v_sql := 'DROP VIEW IF EXISTS vw_file_skew';

        v_location := 2100;
        EXECUTE v_sql;
        
        v_location := 2200;
        v_sql := 'DROP EXTERNAL TABLE IF EXISTS db_files';

        v_location := 2300;
        EXECUTE v_sql;

        v_location := 3000;
        v_sql := 'CREATE EXTERNAL WEB TABLE db_files ' ||
                '(segment_id int, relfilenode text, filename text, ' ||
                'size numeric) ' ||
                'execute E''ls -l $GP_SEG_DATADIR/base/' || v_db_oid || 
                ' | ' ||
                'grep gpadmin | ' ||
                E'awk {''''print ENVIRON["GP_SEGMENT_ID"] "\\t" $9 "\\t" ' ||
                'ENVIRON["GP_SEG_DATADIR"] "/' || v_db_oid || 
                E'/" $9 "\\t" $5''''}'' on all ' || 'format ''text''';

        v_location := 3100;
        EXECUTE v_sql;

        v_location := 4000;
        SELECT count(*) INTO v_num_segments 
        FROM gp_segment_configuration 
        WHERE preferred_role = 'p' 
        AND content >= 0;

        v_location := 4100;
        v_skew_amount := 1.2*(1/v_num_segments);
        
        v_location := 4200;
        v_sql := 'CREATE OR REPLACE VIEW vw_file_skew AS ' ||
                 'SELECT schema_name, ' ||
                 'table_name, ' ||
                 'max(size)/sum(size) as largest_segment_percentage, ' ||
                 'sum(size) as total_size ' ||
                 'FROM	( ' ||
                 'SELECT n.nspname AS schema_name, ' ||
                 '      c.relname AS table_name, ' ||
                 '      sum(db.size) as size ' ||
                 '      FROM db_files db ' ||
                 '      JOIN pg_class c ON ' ||
                 '      split_part(db.relfilenode, ''.'', 1) = c.relfilenode::text ' ||
                 '      JOIN pg_namespace n ON c.relnamespace = n.oid ' ||
                 '      WHERE c.relkind = ''r'' ' ||
                 '      GROUP BY n.nspname, c.relname, db.segment_id ' ||
                 ') as sub ' ||
                 'GROUP BY schema_name, table_name ' ||
                 'HAVING sum(size) > 0 and max(size)/sum(size) > ' || 
                 v_skew_amount::text || ' ' || 
                 'ORDER BY largest_segment_percentage DESC, schema_name, ' ||
                 'table_name';

        v_location := 4300;
        EXECUTE v_sql; 

EXCEPTION
        WHEN OTHERS THEN
                RAISE EXCEPTION '(%:%:%)', v_function_name, v_location, sqlerrm;
END;
$$
language plpgsql;
