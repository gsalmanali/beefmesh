#!/bin/bash

export LOCKERROR="Error: cannot acquire lock: Lock FcntlFlock of /var/ipfsfb/repo.lock failed: resource temporarily unavailable"
#export PATH=$PATH:/usr/local/go/bin


result=$(docker exec regulator.ipfs.node ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec regulator.ipfs.node rm -rf /var/ipfsfb/repo.lock
    docker exec regulator.ipfs.node rm -rf ~/.ipfs/repo.lock
    docker exec regulator.ipfs.node rm -rf ~/repo.lock
    docker exec regulator.ipfs.node ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi


regulator_address=$(docker exec regulator.ipfs.node ipfs id -f='<addrs>') 

regulatoraddress=$(echo $regulator_address | cut -d' ' -f2)


#docker exec -u 0 regulator.ipfs.cluster ipfs-cluster-service daemon --bootstrap $manager_cluster_address


#echo $PASSWORD | sudo -S docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $breederaddress  

docker exec -u 0 manager.ipfs.node ipfs bootstrap add $regulatoraddress

docker exec -u 0 regulator.ipfs.node ipfs bootstrap add $manageraddress


#docker cp swarmkeygen/swarm.key manager.ipfs.node:/var/ipfs

docker cp swarmkeygen/swarm.key regulator.ipfs.node:/var/ipfs


#optional 
#docker-compose restart

docker cp test/test_file.txt manager.ipfs.node:/tmp/test_file.txt

result=$(docker exec manager.ipfs.node ipfs add tmp/test_file.txt)

manageripfshash=$(echo $result | awk '{print $2}')

docker exec regulator.ipfs.node sh -c "ipfs cat $manageripfshash > /tmp/retrieved_file.txt"

docker cp regulator.ipfs.node:/tmp/retrieved_file.txt test/retrieved_file.txt

# Or directly copy file to host from bash terminal
docker exec regulator.ipfs.node ipfs cat $manageripfshash > test/retrieved_file_direct.txt


#docker cp regulator.ipfs.com:/opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/retrieved_file.txt test/retrieved_file.txt


