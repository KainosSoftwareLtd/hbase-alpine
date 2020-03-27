#!/bin/bash

HOSTNAME=$(hostname)
DATA_DIR="/data"
LOGS_DIR="$DATA_DIR/logs"
HBASE_DIR="$DATA_DIR/hbase"

echo "Configuring HBase to use container hostname"
cat << EOF > /opt/hbase/conf/hbase-site.xml
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>

  <property>
     <name>hbase.zookeeper.quorum</name>
     <value>$HOSTNAME</value>
  </property>

  <property>
    <name>hbase.master.info.bindAddress</name>
    <value>$HOSTNAME</value>
  </property>

  <property>
    <name>hbase.regionserver.info.bindAddress</name>
    <value>$HOSTNAME</value>
  </property>

  <property>
    <name>hbase.rootdir</name>
    <value>file:///$HBASE_DIR</value>
  </property>

  <property>
    <name>hbase.regionserver.port</name>
    <value>16020</value>
  </property>

</configuration>
EOF

cat << EOF > /opt/hbase/conf/zoo.cfg
clientPort=2181
clientPortAddress=$HOSTNAME
server.1=$HOSTNAME:2181
EOF

if [ -d $DATA_DIR ]; then
    echo "Writing HBase state and logs to directory mounted at: $DATA_DIR."
else
    echo "No directory mounted at $DATA_DIR, HBase state will not be persisted on the host."
fi
mkdir -p $LOGS_DIR $HBASE_DIR

echo "Starting HBase REST Server - Logging to $LOGS_DIR/rest.log"
hbase thrift start > $LOGS_DIR/thrift.log 2>&1 &

echo "Starting HBase REST Server - Logging to $LOGS_DIR/rest.log"
hbase rest start > $LOGS_DIR/rest.log 2>&1 &

echo "Starting HBase Master - Logging to $LOGS_DIR/master.log"
hbase master start > $LOGS_DIR/master.log 2>&1
