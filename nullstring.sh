#!/usr/bin/env bash

#create table from orders
sqoop eval \
--options-file connect.txt \
--query "CREATE TABLE orders_csm as SELECT * from orders"

#Alter table to add column with NULL fields table from orders
sqoop eval \
--options-file connect.txt \
--query "ALTER TABLE orders_csm add(cust_id int(11), cust_name varchar(20))"

#Import data to HDFS, replacing NULL with \N
sqoop import \
--options-file connect.txt \
--table orders_csm \
--delete-target-dir \
--warehouse-dir retail_db \
--fields-terminated-by '|' \
--null-string '\\N' \
--null-non-string '\\N' \
--split-by order_id \
--boundary-query "select min(order_id), max(order_id) from orders_csm"

#Create empty table to export database
sqoop eval \
--options-file connect.txt \
--query "create table orders_test as select * from orders_csm where 1=2"

#Export data from HDFS to retail_db, replacing '\N' with NULL for both cust_id and cust_name fields
sqoop export \
--options-file connect.txt \
--table orders_test \
--export-dir retail_db/orders_csm \
--input-fields-terminated-by '|' \
--input-null-string '\\N' \
--input-null-non-string '\\N'
