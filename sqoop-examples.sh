#!/usr/bin/env bash

# Command 1: Get help in sqoop
sqoop help


# Command 2: Detail help one command
sqoop help import

# Command 3: List databases. Note, Port# 3306 is not mandatory
sqoop list-databases \
--connect jdbc:mysql://172.31.20.247:3306 --username sqoopuser -P

# Produce sqoop output and log to separate file in local file system
sqoop list-databases \
--connect jdbc:mysql://172.31.20.247 --username sqoopuser -password [password] \
1>output.txt 2>error.txt


#  Command 4: List tables within retail_db database
sqoop list-tables \
--connect jdbc:mysql://172.31.20.247/retail_db --username sqoopuser -P


#  Command 5: Options-file command can be used to input any parameter in sqoop command. In the following example, connect.txt stores the connection string '--connect jdbc:mysql://172.31.20.247/retail_db --username sqoopuser -P'
sqoop list-tables --options-file connect.txt


#  Command 6: Eval command to evaluate a query
sqoop eval \
--connect jdbc:mysql://172.31.20.247/sqoopex --username sqoopuser -P \
--query 'SELECT cs_normcities.id, cs_countries.country,cs_normcities.city from cs_normcities JOIN cs_countries USING(country_id)'

#  Command 7: Import all tables in HDFS
sqoop import-all-tables
--connect jdbc:mysql://172.31.20.247/retail_db \
--username sqoopuser \
-P \
--warehouse-dir retail_db


# Command 8: Codegen
sqoop codegen \
--connect jdbc:mysql://172.31.20.247/sqoopex --username sqoopuser -P \
--query 'SELECT cs_normcities.id, cs_countries.country,cs_normcities.city from cs_normcities JOIN cs_countries USING(country_id) WHERE $CONDITIONS'

# Command 9: Import all tables
sqoop import-all-tables \
--options-file connect.txt \
--exclude-tables Bottom_5_category,Bottom_5_page_views,Bottom_5_subcategory,Top_5_category \
--autoreset-to-one-mapper \
--warehouse-dir retaildb \
--as-sequencefile -z

# Command 10: Merge
