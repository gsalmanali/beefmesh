#!/bin/bash


#export PATH=$PATH:/usr/local/go/bin

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

result=$(docker exec farmer.ipfs.com ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec farmer.ipfs.com rm -rf /var/ipfsfb/repo.lock
    docker exec farmer.ipfs.com rm -rf ~/.ipfs/repo.lock
    docker exec farmer.ipfs.com rm -rf ~/repo.lock
    docker exec farmer.ipfs.com ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi

result=$(docker exec breeder.ipfs.com ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec breeder.ipfs.com rm -rf /var/ipfsfb/repo.lock
    docker exec breeder.ipfs.com rm -rf ~/.ipfs/repo.lock
    docker exec breeder.ipfs.com rm -rf ~/repo.lock
    docker exec breeder.ipfs.com ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi



result=$(docker exec processor.ipfs.com ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec processor.ipfs.com rm -rf /var/ipfsfb/repo.lock
    docker exec processor.ipfs.com rm -rf ~/.ipfs/repo.lock
    docker exec processor.ipfs.com rm -rf ~/repo.lock
    docker exec processor.ipfs.com ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi

result=$(docker exec retailer.ipfs.com ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec retailer.ipfs.com rm -rf /var/ipfsfb/repo.lock
    docker exec retailer.ipfs.com rm -rf ~/.ipfs/repo.lock
    docker exec retailer.ipfs.com rm -rf ~/repo.lock
    docker exec retailer.ipfs.com ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi



result=$(docker exec consumer.ipfs.com ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec consumer.ipfs.com rm -rf /var/ipfsfb/repo.lock
    docker exec consumer.ipfs.com rm -rf ~/.ipfs/repo.lock
    docker exec consumer.ipfs.com rm -rf ~/repo.lock
    docker exec consumer.ipfs.com ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi


result=$(docker exec distributor.ipfs.com ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec distributor.ipfs.com rm -rf /var/ipfsfb/repo.lock
    docker exec distributor.ipfs.com rm -rf ~/.ipfs/repo.lock
    docker exec distributor.ipfs.com rm -rf ~/repo.lock
    docker exec distributor.ipfs.com ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi



manager_address=$(docker exec manager.ipfs.com ipfs id -f='<addrs>') 
regulator_address=$(docker exec regulator.ipfs.com ipfs id -f='<addrs>') 
farmer_address=$(docker exec farmer.ipfs.com ipfs id -f='<addrs>') 
breeder_address=$(docker exec breeder.ipfs.com ipfs id -f='<addrs>') 
processor_address=$(docker exec processor.ipfs.com ipfs id -f='<addrs>') 
distributor_address=$(docker exec distributor.ipfs.com ipfs id -f='<addrs>') 
consumer_address=$(docker exec consumer.ipfs.com ipfs id -f='<addrs>') 
retailer_address=$(docker exec retailer.ipfs.com ipfs id -f='<addrs>') 

echo "before"
echo $manager_address 
echo $regulator_address 
echo $farmer_address 
echo $breeder_address
echo $processor_address
echo $distributor_address
echo $consumer_address
echo $retailer_address

export manageraddress=$(echo $manager_address | cut -d' ' -f2)
export regulatoraddress=$(echo $regulator_address | cut -d' ' -f2)
export farmeraddress=$(echo $farmer_address | cut -d' ' -f2)
export breederaddress=$(echo $breeder_address | cut -d' ' -f2)
export consumeraddress=$(echo $consumer_address | cut -d' ' -f2)
export retaileraddress=$(echo $retailer_address | cut -d' ' -f2)
export processoraddress=$(echo $processor_address | cut -d' ' -f2)
export distributoraddress=$(echo $distributor_address | cut -d' ' -f2)

echo "after"
echo $manageraddress 
echo $regulatoraddress 
echo $farmeraddress 
echo $breederaddress
echo $processoraddress
echo $distributoraddress
echo $consumeraddress
echo $retaileraddress

./bootstrapadd.sh


docker cp swarmkeygen/swarm.key manager.ipfs.com:/var/ipfs
docker cp swarmkeygen/swarm.key regulator.ipfs.com:/var/ipfs
docker cp swarmkeygen/swarm.key farmer.ipfs.com:/var/ipfs
docker cp swarmkeygen/swarm.key breeder.ipfs.com:/var/ipfs
docker cp swarmkeygen/swarm.key processor.ipfs.com:/var/ipfs
docker cp swarmkeygen/swarm.key distributor.ipfs.com:/var/ipfs
docker cp swarmkeygen/swarm.key consumer.ipfs.com:/var/ipfs
docker cp swarmkeygen/swarm.key retailer.ipfs.com:/var/ipfs


#optional 
#docker-compose restart

docker cp test/test_file.txt manager.ipfs.com:/opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/test_file.txt

result=$(docker exec manager.ipfs.com ipfs add test_file.txt)

manageripfshash=$(echo $result | awk '{print $2}')

docker exec regulator.ipfs.com bash -c "ipfs cat $manageripfshash > retrieved_file.txt"

docker cp regulator.ipfs.com:/opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/retrieved_file.txt test/retrieved_file.txt




