#!/bin/bash

export LOCKERROR="Error: cannot acquire lock: Lock FcntlFlock of /var/ipfsfb/repo.lock failed: resource temporarily unavailable"
#export PATH=$PATH:/usr/local/go/bin


result=$(docker exec manager.ipfs.com ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec manager.ipfs.com rm -rf /var/ipfsfb/repo.lock
    docker exec manager.ipfs.com rm -rf ~/.ipfs/repo.lock
    docker exec manager.ipfs.com rm -rf ~/repo.lock
    docker exec manager.ipfs.com ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi


result=$(docker exec regulator.ipfs.com ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec regulator.ipfs.com rm -rf /var/ipfsfb/repo.lock
    docker exec regulator.ipfs.com rm -rf ~/.ipfs/repo.lock
    docker exec regulator.ipfs.com rm -rf ~/repo.lock
    docker exec regulator.ipfs.com ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi

manager_address=$(docker exec manager.ipfs.com ipfs id -f='<addrs>') 
regulator_address=$(docker exec regulator.ipfs.com ipfs id -f='<addrs>') 

manageraddress=$(echo $manager_address | cut -d' ' -f2)
regulatoraddress=$(echo $regulator_address | cut -d' ' -f2)


#echo $PASSWORD | sudo -S docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $breederaddress  

docker exec -u 0 manager.ipfs.com ipfs bootstrap add $regulatoraddress

docker exec -u 0 regulator.ipfs.com ipfs bootstrap add $manageraddress


docker cp swarmkeygen/swarm.key manager.ipfs.com:/var/ipfs

docker cp swarmkeygen/swarm.key regulator.ipfs.com:/var/ipfs


#optional 
#docker-compose restart

docker cp test/test_file.txt manager.ipfs.com:/opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/test_file.txt

result=$(docker exec manager.ipfs.com ipfs add test_file.txt)

manageripfshash=$(echo $result | awk '{print $2}')

docker exec regulator.ipfs.com bash -c "ipfs cat $manageripfshash > retrieved_file.txt"

docker cp regulator.ipfs.com:/opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/retrieved_file.txt test/retrieved_file.txt


