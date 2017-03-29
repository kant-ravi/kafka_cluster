#!/bin/bash
#Check if kafka_cluster.config exists
if [ -f kafka_cluster.config ]
then
    echo "Found kafka_cluster.config"
else
    echo "Could not find kafka_cluster.config in local directory"
    echo "Exiting.."
    exit 1
fi
#Check if config.tmp exists; delete it if it exists
#This file is for security reason.
#As we will source everthing written in this file, we have to make sure that
#config.tmp contains only necessary command. Thus we select relevant properties from 
#kafka_cluster.config and paste it in config.tmp, which is then sourced         
if [ -f config.tmp ];
then 
    rm -f config.tmp
fi    
grep cluster_size kafka_cluster.config >> config.tmp
grep ^host_names=[\s\S]* kafka_cluster.config >> config.tmp
grep ^ips=[\s\S]* kafka_cluster.config >> config.tmp
grep ^kafka_download_url=[\s\S]* kafka_cluster.config >> config.tmp

source config.tmp
cat config.tmp
echo ${#host_names[*]} ${#ips[*]}
#sanity check

if [ ${#host_names[*]} -ne $cluster_size ]
then
    echo "hostnames enetered not equal to number of instances, quitting"
    exit 1
fi

if [ ${#ips[*]} -ne $cluster_size ]
then
    echo "IP's not equal to the number of instances, quitting"
    exit 1
fi

#make sure if the host and ips are correct
for ((i=0;i<$cluster_size;++i)); do
    printf "%s ==> %s \n" "${ips[i]}" "${host_names[i]}"
done

echo "Do you want to proceed with Kafka installation on above instances?(y/n)"
read choice
if [ "$choice" != "y" ]
then 
    echo "Quitting..."
    exit 1
fi

# iterate over the cluster nodes to complete installation
for ((i=0;i<cluster_size;++i)); do

    # if it is localhost, we dont have to copy config files nor do we have to ssh into it.
    if [ $i -ne 0 ]
    then
        scp install_subRoutine.sh root@${host_names[i]}:/root/
        scp config.tmp root@${host_names[i]}:/root/
        ssh ${host_names[i]} ./install_subRoutine.sh $i
    else
        echo "Configuring hosts file on" ${host_names[i]}
        # this loop adds the hosts and ips to /etc/hosts file 
        for((j=0;j<cluster_size;++j));do
            sed -i '/[0-9.]*[ ]'${host_names[j]}'[ ]##Added by KAFKA_INSTALLER/d' /etc/hosts
            echo "${ips[j]} ${host_names[j]} ##Added by KAFKA_INSTALLER" >> /etc/hosts
        done
        service network restart
        cp config.tmp /root/ 
        ./install_subRoutine.sh $i
    fi 
    
done
echo "Installation Completed for Cluster"
echo "==================================="
echo "Do you want to start zookeeper and kafka brokers now?(y/n)"
read choice
if [ $choice != "y" ]
then
    echo "exiting..."
    exit 0
fi

for ((i=0;i<cluster_size;++i));do
    scp startServices.sh root@${ips[i]}:/root/
    ssh root@${ips[i]} ./startServices.sh $i
done            
            
