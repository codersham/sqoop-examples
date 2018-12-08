#!/usr/bin/env bash

sqoop export \
--connections jdbc:mysql://172.31.20.247 \
--username sqoopuser \
-P \
--table orders_csm \
--export-dir retail_db/orders \
--input-fields-terminated-by '|' \
--update-key order_id \
--update-mode allowinsert \
--staging-table orders_csm_stg \
--clear-staging-table
