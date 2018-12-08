#!/usr/bin/env bash

# Replace [URL] with the url of Mysql Server

# Importing MySQl order_items table into HDFS using target dir
#The following command will import all the records from order_items table into HDFS. It will create a new directory in HDFS #called order_items and put all the records. This command will result in error if the target dir exists
sqoop import \
--connect jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table order_items --target-dir order_items


 # Importing MySQl order_items table into HDFS using warehouse dir
#The following command will import all the records from order_items table into HDFS order_items-wr directory. Warehouse dir is #one level above the target dir
sqoop import \
--connect jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table order_items \
--warehouse-dir order_items-wr

# Importing MySQl order_items table into HDFS using --append and warehouse dir
sqoop import \
--options-file connect.txt \
--table order_items \
--warehouse-dir reatil_db \
--append

# Importing MySQl order_items table into HDFS using --append and target dir
sqoop import \
--options-file connect.txt \
--table order_items \
--target-dir order_item \
--append

# Import data and save as text file. By default, sqoop saves date as text files
sqoop import \
--connect jdbc:mysql://[URL]/retail_db --username sqoopuser -P \
--table order_items \
--targer-dir /user/codersham2286/order_items \
--as-textfile

# Import data and save as avro file.
#This command will create .avsc file in local file system which is the metadata (in json)of the avro file. Avro files can only #be read using avro-tools
sqoop import \
--connect jdbc:mysql://[URL]/retail_db --username sqoopuser -P \
--table order_items \
--targer-dir /user/codersham2286/order_items_avro \
--as-avrodatafile


# Import data and save as sequence file. Sequence file is hadoop compression technique, to reduce the file size
sqoop import \
--connect jdbc:mysql://[URL]/retail_db --username sqoopuser -P \
--table order_items \
--targer-dir /user/codersham2286/order_items_seq \
--as-sequencefile


# Import data and save as parquet file. Parquet file uses columnar compression technique, to reduce the file size
sqoop import \
--connect jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table order_items \
--targer-dir /user/codersham2286/order_items_pq \
--as-parquetfile

# Import data from table with no primary key.
#If there no primary key on the source RDBMS table, then sqoop can't determine how it can split data to send it to 4 mappers #(by default sqoop uses 4 mappers). There are 3 options to resolve this issue

# Option 1:Use 1 mapper explicitly-not a good option, can run into error for huge data
sqoop import \
--connect jdbc:mysql://[URL]/sqoopex --username sqoopuser -P \
--table order_items_no_pk \
-m 1

#						OR

sqoop import \
--connect jdbc:mysql://[URL]/sqoopex \
--username sqoopuser \
-P \
--table order_items_no_pk \
--num-mappers 1

# Option 2: Use split by and specify a column to be used in the split
sqoop import \
--connect jdbc:mysql://[URL]/sqoopex \
--username sqoopuser \
-P \
--table order_items_no_pk \
--split-by order_item_id

# Option 3: Auto reset to one mapper, whenever there are no primary key in source table
sqoop import \
--connect jdbc:mysql://[URL]/sqoopex \
--username sqoopuser \
-P \
--table order_items_no_pk \
--autoreset-to-one-mapper


# Increasing number of mappers to make the data transer faster by more parallel processing may not be a good idea. More mapper #will create more connection to the RDBMS and increase load, there by can make the RDBMS slower and even crash. To understand #what is the right number mappers for your sqoop job, you need to do analysis

# Import with boundary query. Boundary query is used to specify min and max value of the split column. Sqoop calculate the min #and max value by default to determine number of records in each split. However, junk values in split column may make sqoop to #determine this limit incorrectly and resulting into 0 record output files. Junk values can be excluded in boundary query #while importing data
sqoop import \
--connect jdbc:mysql://[URL]/sqoopex \
--username sqoopuser -P \
--table order_items_no_pk \
--split-by order_item_id \
--boundary-query "select min(order_item_id), max(order_item_id) from order_items_no_pk where order_item_id not in ([any junk value])"

# Compression
sqoop import \
--connect jdbc:mysql://[URL]/retail_db --username sqoopuser -P \
--table order_items \
--delete-target-dir --compress \
--compression-codec org.apache.hadoop.io.compress.SnappyCodec

# --direct
sqoop import \
--connect jdbc:mysql://[URL]/retail_db --username sqoopuser -P \
--table order_items \
--delete-target-dir \
--direct

# Importing into hive table from RDBMS table with no primary key
sqoop import \
--connect jdbc:mysql://[URL]/retail_db \
--username sqoopuser \
-P \
--table orders \
--split-by order_item_id \
--columns order_item_id,order_item_order_id,order_item_product_id,order_item_quantity,order_item_subtotal,order_item_product_price \
--fields-terminated-by "," \
--hive-import \
--create-hive-table \
--hive-database codersham \
--hive-table order_items
