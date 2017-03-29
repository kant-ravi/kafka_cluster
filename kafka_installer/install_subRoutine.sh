#!/bin/bash
source /root/config.tmp
i=$1
echo "Configuring hosts file on" ${host_names[i]}
echo "CONTINUE?"
read ch
# this loop adds the hosts and ips to /etc/hosts file 
for((j=0;j<cluster_size;++j));do
    sed -i '/[0-9.]*[ ]'${host_names[j]}'[ ]##Added by KAFKA_INSTALLER/d' /etc/hosts
    echo "${ips[j]} ${host_names[j]} ##Added by KAFKA_INSTALLER" >> /etc/hosts
done
service network restart 
    
echo "============================================"
echo "Installing OracleJDK on instance" "${host_names[i]}" 
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-linux-x64.rpm"
yum -y localinstall jdk-8u60-linux-x64.rpm
printf "OracleJDK 1.8 installation completed on %s \n" "${host_names[i]}"
echo "==================================================="    
printf "Installing Kafka on %s \n" "${host_names[i]}"
rm -rf /opt/kafka*
cd /opt
wget $kafka_download_url
kafka_base_name=$(basename "$kafka_download_url")
tar -xzf /opt/$kafka_base_name
kafka_untarred_folder=$(basename $kafka_base_name .tgz)
mv $kafka_untarred_folder kafka
cd /opt/kafka
printf "Created zookeeper and kafka data directories\n"
printf "Kafka Installation completed\n"
printf "============================================\n"  
printf "Now configuring zookeeper\n"
mkdir -p /var/zookeeper/data
mkdir -p /data/kafka/kafka-logs
echo $i > /var/zookeeper/data/myid
for ((j=0;j<cluster_size;++j)); do
    echo "server.$j=${host_names[j]}:2888:3888" >> /opt/kafka/config/zookeeper.properties  
done
echo "initLimit=5" >> /opt/kafka/config/zookeeper.properties
echo "syncLimit=2" >> /opt/kafka/config/zookeeper.properties
sed -i 's/\(dataDir=\).*/\1\/var\/zookeeper\/data/' /opt/kafka/config/zookeeper.properties
     
printf "Configuring Kafka\n" 
echo "advertised.host.name=${ips[i]}" >> /opt/kafka/config/server.properties
echo "advertised.port=9092" >> /opt/kafka/config/server.properties

    
connect_string=""
for((j=0;j<cluster_size-1;++j));do
   connect_string+="${host_names[j]}:2181,"
done
connect_string+="${host_names[i+1]}:2181"
#echo $connect_string
sed -i 's/\(zookeeper.connect=\).*/\1'$connect_string'/' /opt/kafka/config/server.properties
sed -i 's/\(broker.id=\).*/\1'$i'/' /opt/kafka/config/server.properties
sed -i 's/\(log.dirs=\).*/\1\/data\/kafka\/kafka-logs/' /opt/kafka/config/server.properties
printf "All configurations compelte for %s \n" "${host_names[i]}"
echo "== == == == == == == == == == == == == == == == == == == == =="
exit
