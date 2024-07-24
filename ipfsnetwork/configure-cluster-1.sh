#!/bin/bash

export LOCKERROR="Error: cannot acquire lock: Lock FcntlFlock of /var/ipfsfb/repo.lock failed: resource temporarily unavailable"
#export PATH=$PATH:/usr/local/go/bin


result=$(docker exec manager.ipfs.node ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec manager.ipfs.node rm -rf /var/ipfsfb/repo.lock
    docker exec manager.ipfs.node rm -rf ~/.ipfs/repo.lock
    docker exec manager.ipfs.node rm -rf ~/repo.lock
    docker exec manager.ipfs.node ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi

manager_address=$(docker exec manager.ipfs.node ipfs id -f='<addrs>') 

echo "export manageraddress=$(echo $manager_address | cut -d' ' -f2)" > p2p/secrets/cluster.sh

manager_cluster_info=$(docker exec manager.ipfs.cluster ipfs-cluster-ctl id) 
ip4_substrings=$(echo "$manager_cluster_info" | grep -o '/ip4/[^ ]*')
echo "export MANAGER_CLUSTER_ADDRESS=$(echo $ip4_substrings | cut -d' ' -f2)" >> p2p/secrets/cluster.sh


#docker exec -u 0 regulator.ipfs.cluster ipfs-cluster-service daemon --bootstrap $MANAGER_CLUSTER_ADDRESS


#echo $PASSWORD | sudo -S docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $breederaddress  

#docker exec -u 0 manager.ipfs.node ipfs bootstrap add $regulatoraddress

#docker exec -u 0 regulator.ipfs.node ipfs bootstrap add $manageraddress


docker cp swarmkeygen/swarm.key manager.ipfs.node:/var/ipfs

#docker cp swarmkeygen/swarm.key regulator.ipfs.node:/var/ipfs


#optional 
#docker-compose restart



