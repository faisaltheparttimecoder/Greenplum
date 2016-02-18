SELECT bdirelid "Relation OID",
	bdinspname ||'.'|| bdirelname "Relation Name",
	bdirelpages "Allocated Pages",
	bdiexppages "Pages Needed",
	bdidiag "Message"
FROM gp_toolkit.gp_bloat_diag;



