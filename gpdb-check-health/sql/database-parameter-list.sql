SELECT name "Parameter Name",
	substring(setting from 1 for 30) "Parameter Value",
	substring(short_desc from 1 for 100) "Parameter Desc"
FROM pg_settings
order by 1;