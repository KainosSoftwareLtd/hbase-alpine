#!/bin/bash

# Go to HBase bin directory
cd /opt/hbase/bin

# Get all the rows in HBase shell and save them to a text file
echo "scan 'clerical_matching:matching_task'" | ./hbase shell > scan_output

# 1. Remove rows from the list that do not contain a json document
# 2. Remove rows from the list that contain a residents element
# 3. Only keep the rowkeys of the remaining rows
# 4. Map these rowkeys into an HBase deleteall command
sed '/.*value={.*/!d; /.*"residents".*/d' scan_output | cut -d ' ' -f2 | sed "s/\(.*\)/deleteall 'clerical_matching:matching_task', '\1'/" > row_delete_commands

# Execute the delete commands in HBase shell
cat row_delete_commands | ./hbase shell
