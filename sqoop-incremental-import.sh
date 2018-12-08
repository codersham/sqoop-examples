#!/usr/bin/env bash

# Incremental import
# This command uses 3 mandatroy fields:
#					1.  --incremental : Allowed modes are of 2 types
#							a.	append : To append new rows.
#							b.	lastmodified : To update records that changed in source database after the import.
#					2.  --check-cloumn : Specify cloumns on which changes are expected
#					3.	--last-value : The last imported value of the --check-cloumn
# Incremental import in append mode will allow you to transfer only the newly created rows. One downside is the need to know the value of the last imported row so that next time Sqoop can start off where it ended.

# Command 1: Incremental append. You have to note the last value before using the append mode
sqoop import \
--connect jdbc:mysql://172.31.20.247/retail_db \
--username=sqoopuser \
-P \
--table order_items_csm \
--target-dir retail_db/order_items_csm \
--incremental append \
--check-column order_item_id \
--last-value 0

# Command 2: Incremental lastmodified. You have note the last value of the --check-column before using the lastmodified mode
# Note, the target directory is a new location rather than the old address which will have the newly added and updated records.To merge the old and new records use --merge command
sqoop import \
--connect jdbc:mysql://172.31.20.247/retail_db \
--username=sqoopuser \
-P \
--table order_items_csm \
--target-dir retail_db/order_items_csm_delta \
--incremental lastmodified \
--check-column modifieddate \
--last-value '<last modified date>'
