NOTE #1: Make sure passwordless ssh is enabled from master to all nodes
NOTE #2: Make sure PermitRootLogin is set to yes in sshd_config
NOTE #3: Make sure exp_install.sh and install_subRoutine.sh have exute permission

TODO: autostart broker; currently only zookeper is started by script and kafka brokers have to started manually
    
1) Copy exp+install.sh, install_subRoutine.sh, kafka_cluster.config to master node
2) Edit kafka_cluster.config
    2.1) Enter cluster size
    2.2) Enter host names
    2.3) Enter IP Addresses
3) ./exp_install
