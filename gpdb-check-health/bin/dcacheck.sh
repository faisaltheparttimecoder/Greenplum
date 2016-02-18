
# Function : Checking if the server is a DCA / DCA Version / Firmware Version

check_if_dca() {

echo "INFO - Checking if GPDB is run on a DCA / Non-DCA"
echo

if (test -f /etc/gpdb-appliance-version)
then
	echo "DCA Version: " `cat /etc/gpdb-appliance-version` > $collect_dcainfo
else
	echo "This is a software-only install , ignoring the DCA check " > $collect_dcainfo
fi
                    }