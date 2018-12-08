#!/usr/bin/env bash

# Free-form Query Import: In free-form query, Sqoop can't read RDBMS table metadata to determine primary key of the table and the boundary (min and max) value of it. Therefore, it is required to tell sqoop which is the primary of the source table by specifying --split-by clause or just use -m (or --num-mappers) 1 to ignore split and hence the parellelism of sqoop.
# For free-form query mandatory files are:
#                 1. --query clause and a WHERE $CONDITIONS inside the Query
#                 2. --target-dir
#                 3. Either --num-mappers (or -m) 1
#                 4. OR --split-by with optional --boundary-query (althoug it is optional, if not specified sqoop will try to determine the min, max value. Therefore, performance will degrade)

# Example 1: free-form query with --split-by
sqoop import \
--connect jdbc:mysql://172.31.20.247/sqoopex \
--username sqoopuser \
-P \
--query 'SELECT cs_normcities.id,cs_countries.country,cs_normcities.city from cs_normcities JOIN cs_countries USING(country_id) WHERE $CONDITIONS'  \
--split-by id \
--target-dir /user/codersham2286/cities

# Example 2: free-form query with --num-mappers (or -m)
sqoop import \
--connect jdbc:mysql://172.31.20.247/sqoopex --username sqoopuser -P \
--query 'SELECT cs_normcities.id,cs_countries.country,cs_normcities.city from cs_normcities JOIN cs_countries USING(country_id) WHERE $CONDITIONS' \
--target-dir /user/codersham2286/cities1 \
--num-mappers 1


# Example 3: Free-form Query Import with --split-by and --boundary-query
sqoop import \
--connect jdbc:mysql://172.31.20.247/sqoopex --username sqoopuser -P \
--query 'SELECT cs_normcities.id, cs_countries.country,cs_normcities.city from cs_normcities JOIN cs_countries USING(country_id) WHERE $CONDITIONS' \
--split-by id \
--target-dir /user/codersham2286/cities-boundary \
--boundary-query 'select min(id), max(id) from cs_normcities'


# Example 4: Free-form Query Import with Boundaries specified
sqoop import \
--connect jdbc:mysql://172.31.20.247/sqoopex --username sqoopuser -P \
--query 'SELECT cs_normcities.id, cs_countries.country,cs_normcities.city from cs_normcities JOIN cs_countries USING(country_id) WHERE $CONDITIONS' \
--split-by id \
--target-dir /user/codersham2286/cities-boundary1 \
--boundary-query 'select 1, 3'


# Example 5: Free-form Query Import- Rename sqoop job instance to cs_normcities.java
sqoop import \
--connect jdbc:mysql://172.31.20.247/sqoopex \
--username sqoopuser \
-P \
--query 'SELECT cs_normcities.id, cs_countries.country,cs_normcities.city from cs_normcities JOIN cs_countries USING(country_id) WHERE $CONDITIONS' \
--split-by id \
--target-dir /user/codersham2286/cities-boundary3 \
--boundary-query 'select 1, 3' \
--class-name cs_normcities


# Example 6: Free-form Query Import with hive table creation and additonal where clause with $CONDITIONS
sqoop import \
--connect jdbc:mysql://172.31.20.247/retail_db \
--username sqoopuser \
-P \
 --query 'select order_id,order_date,customer_fname,customer_lname from orders JOIN customers ON (orders.order_customer_id=customers.customer_id) WHERE $CONDITIONS and orders.order_id>60000' \
 --target-dir retail_db/transactions \
 --hive-import \
 --hive-database codersham \
 --hive-table transactions \
 --m 1
