#!/usr/bin/env bash

# Replace [URL] with url of Mysql server

#Command 1a: --export-dir. Export from HDFS to MySQl
#Basic export to MySQl. MySQl table has to be exists for successful execution of this command. Note, the data to be loaded must be ',' separated, which is the sqoop default format.
sqoop export \
--connect  jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders_csm \
--export-dir retail_db/orders

# Check rowcount in mysql and HDFS are equal
hadoop fs -cat retail_db/orders/part* | wc -l # HDFS
select count(*) from orders_csm; #MySQl

#Command 1b: --export-dir. Export from hive to MySQl
#Default field separator for hive in NULL or ^A or '\001'. use --input-fields-terminated-by '\001'. Note, this is applicable if the hive table data is not formatted with any other types but by the default fields terminated
sqoop export \
--connect  jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders_csm \
--export-dir /apps/hive/warehouse/codersham.db/orders \
--input-fields-terminated-by '\001'

# Command 2: --batch
# By default, sqoop executes one insert statement at a time. For faster export, multiple insert in a batch, use --batch. With the --batch parameter, Sqoop can take advantage of this. This API is present in all JDBC drivers because it is required by the JDBC interface. The implementation may vary from database to database. Whereas some database drivers use the ability to send multiple rows to remote databases inside one request to achieve better performance, others might simply send each query separately. Some drivers cause even worse performance when running in batch mode due to the extra overhead in‐ troduced by serializing the row in internal caches before sending it row by row to the database server. Note, performance degrades with MySQl, as it sends each query separately.
sqoop export \
--connect  jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders_csm \
--export-dir retail_db/orders \
--batch

# Command 3: Update --update-id and --updare-mode
# For Update --update-key is mandatory and --update-mode is optional. By default --update-mode is updateonly.
#Note: This command works effectively only if the --update-key is primary key. If not, then this command will insert all data from HDSF. This command is observed to be extremely slow. Please note, one mapper was used to reduce the load on the RDBMS for concurrent connection by sqoop to make the processing faster.
sqoop export \
-Dsqoop.export.statements.per.transaction=10 \
--connect  jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders_csm_pk \
--export-dir retail_db/orders \
--update-key order_id \
--update-mode updateonly \
-m 1

# Command 4: Upsert --update-id and --update-mode
# For Upsert use both --update-key and --update-mode
#Note: This command works effectively only if the --update-key is primary key. If not, then this command will insert all data from HDFS, as in case of updateonly mode. This command is also observed to be slow but faster than updateonly mode. Please note, one mapper was used to reduce the load on the RDBMS for concurrent connection by sqoop to make the processing faster.
sqoop export \
-Dsqoop.export.statements.per.transaction=10 \
--connect  jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders_csm_pk \
--export-dir retail_db/orders \
--update-key order_id \
--update-mode allowinsert \
-m 1

# Command 5: --columns
# Use this command when either the number or order or  both number and order of destination columns are not same as in the HDFS data
sqoop export \
--connect jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders_csm \
--columns order_id,order_date,order_customer_id,order_status \
--export-dir retail_db/orders

# Command 6: --staging-table. --clear-staging-table (optional)
# You need to ensure that Sqoop will either export all data from Hadoop to your database or export no data (i.e., the target table will remain empty).
# Note, staging table should have the same schema as the final RDBMS table
sqoop export \
--connect jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders_csm \
--columns order_id,order_date,order_customer_id,order_status \
--staging-table orders_csm_stg \
--clear-staging-table \
--export-dir retail_db/orders

# Command 7: --validate
# Validate the data copied, either import or export by comparing the row counts from the source and the target post copy
#	a. Validator (--validator): org.apache.sqoop.validation.RowCountValidator
#	b. Threshold Specifier (--validation-threshold) : org.apache.sqoop.validation.AbsoluteValidationThreshold
# c. Failure Handler (--validation-failurehandler) : org.apache.sqoop.validation.AbortOnFailureHandler
sqoop export \
--connect jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders_csm \
--columns order_id,order_date,order_customer_id,order_status \
--staging-table orders_csm_stg \
--clear-staging-table \
--export-dir retail_db/orders \
--validate

# Command 8: --input-null-string and --input-null-non-string
sqoop export \
--connect jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders_csm \
--export-dir retail_db/orders \
--input-fields-terminated-by '|' \
--update-key order_id \
--update-mode allowinsert \
--input-null-string '\\N' \
--input-null-non-string '\\N' \
-m 1

# Command 9: --direct. Can be used for MySQl and PostgreSql only
sqoop export \
--connect jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders_csm \
--export-dir retail_db/orders \
--direct
