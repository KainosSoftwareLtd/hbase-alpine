#!/bin/bash

HOSTNAME=$(hostname)
DATA_DIR="/data"
LOGS_DIR="$DATA_DIR/logs"
HBASE_DIR="$DATA_DIR/hbase"

if [[ -z "${HBASE_REGIONSERVER_PORT}" ]]; then
  HBASE_REGIONSERVER_PORT=16020
fi
echo "HBASE_REGIONSERVER_PORT=$HBASE_REGIONSERVER_PORT"

if [[ -z "${ZOOKEEPER_CLIENT_PORT}" ]]; then
  ZOOKEEPER_CLIENT_PORT=2181
fi
echo "ZOOKEEPER_CLIENT_PORT=$ZOOKEEPER_CLIENT_PORT"

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
    <value>$HBASE_REGIONSERVER_PORT</value>
  </property>

  <property>
      <name>hbase.zookeeper.property.clientPort</name>
      <value>$ZOOKEEPER_CLIENT_PORT</value>
   </property>

</configuration>
EOF

cat << EOF > /opt/hbase/conf/zoo.cfg
clientPort=$ZOOKEEPER_CLIENT_PORT
clientPortAddress=$HOSTNAME
server.1=$HOSTNAME:$ZOOKEEPER_CLIENT_PORT
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
