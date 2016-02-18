select 
   rsqname as "RQname",
   rsqcountlimit as "RQActivestmt-Limit",
   rsqcountvalue as "RQActivestmt-Current",
   rsqcostlimit as "RQCost-Limit",
   rsqcostvalue as "RQCost-Current",
   rsqmemorylimit::integer as "RQMemory-Limit",
   rsqmemoryvalue::integer "RQMemory-Current",
   rsqholders as "RQHolders",
   rsqwaiters as "RQWaiters"
from gp_toolkit.gp_resqueue_status;