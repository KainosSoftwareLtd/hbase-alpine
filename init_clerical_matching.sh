#!/bin/sh
#
# Create the clerical matching table in hbase
# This is run in the hbase container by docker exec
#
echo "

  create_namespace 'clerical_matching'
  create 'clerical_matching:matching_task', 'task_info'
  exit" | hbase shell
