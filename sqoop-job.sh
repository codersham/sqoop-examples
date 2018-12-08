#!/usr/bin/env bash

# Example 1: help for sqoop job
sqoop help job

# Example 2: List all sqoop jobs
sqoop job --list

# Example 3: View a sqoop job with job id
sqoop job --show <job id>

#############################################################################################################

# Example 4: Create and execute sqoop job for --incremental update. Sqoop job remembers the --last-value
# Step 1: Create a new job
sqoop job \
--create incremental-job \
-- \
import \
--connect jdbc:mysql://172.31.20.247/retail_db \
--username sqoopuser \
-P \
--table order_items_csm \
--warehouse-dir retail_db \
--incremental append \
--check-column order_item_id \
--last-value 0

# Step 2: Execute the job for the first time
sqoop job \
--exec incremental-job

# Step 3: Insert new row into source table
sqoop eval --options-file connect.txt --query 'insert into order_items_csm values(102,5,502,10,1000,100,now())'

# Step 4: Execute the job again. This will import only the new record
sqoop job \
--exec incremental-job

# Step 5: Verify the correct number of records are imported
hadoop fs -cat retail_db/order_items_csm/part* | wc -l

#############################################################################################################

# Example 5: sqoop job for --incremental lastmodified
# Step 1: Create the sqoop job
sqoop job \
--create incremental-update \
-- \
import \
--connect jdbc:mysql://172.31.20.247/retail_db \
--username sqoopuser \
-P \
--table order_items_csm \
--target-dir retail_db/order_items_csm \
--incremental lastmodified \
--check-column modifieddate \
--last-value 0 \
--merge-key order_item_id

# Step 2: Execute the job for the first time
sqoop job \
--exec incremental-update

# Step 3: Insert new row into source table
sqoop eval --options-file connect.txt --query 'insert into order_items_csm values(103,5,502,10,1000,100,now())'

# Step 4: Update existing records in the source table
sqoop eval \
--options-file connect.txt \
--query "update order_items_csm set modifieddate=now() where order_item_id>50 and order_item_id<100"

# Step 5: Execute the job again. This will import new records and merge with the old record
sqoop job \
--exec incremental-job

# Step 6: Verify the correct number of records are imported
hadoop fs -cat retail_db/order_items_csm/part* | wc -l

#############################################################################################################

# Example 6: Delete a sqoop job
sqoop job \
--delete firstjob
