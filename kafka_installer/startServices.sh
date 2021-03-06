#!/bin/bash
i=$1
source /root/config.tmp
echo "Starting zookeeper on" ${server_hosts[i]}
/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties > /dev/null &
echo "Starting Kafka Broker on" ${server_hosts[i]}
/opt/kafka/bin/server-start.sh /opt/kafka/config/server.properties > /dev/null &
rm /root/config.tmp
exit
