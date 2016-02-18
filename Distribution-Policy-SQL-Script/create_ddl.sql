-- Create "commacat" functions

CREATE or replace FUNCTION commacat(acc text, instr text) RETURNS text AS $$
BEGIN
IF acc IS NULL OR acc = '' THEN
RETURN instr;
ELSE
RETURN acc || ',' || instr;
END IF;
END;
$$ LANGUAGE plpgsql
;

-- Create "textcat_all" Aggregate

CREATE AGGREGATE textcat_all(
basetype    = text,
sfunc       = commacat,stype       = text,
initcond    = ''
);

