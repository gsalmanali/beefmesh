#!/bin/bash

# This file is meant to specfically automate building a particular type of collaboration group! 
# Change it for your needs before using! 


export PATH=$PATH:/usr/local/go/bin

STORAGE=$PWD/envvariables/

. custom_print.sh
#. scripts/utils.sh

#source blockchain/ports/orderer.sh


function env_save(){
    export -p > "$STORAGE/$1.sh"
}

function env_restore(){
    source "$STORAGE/$1.sh"
}

#env_save temp 
#eval $(egrep "^[^#;]" .env | xargs -d'\n' -n1 | sed 's/^/export /')
#export $(cat .env | egrep -v "(^#.*|^$)" | xargs)


#echo $PASSWORD | sudo -S <whatever you want to do that prompts for password>

function resetAll(){
# bringing the network down 
./network.sh down
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
#echo $PASSWORD | sudo -S docker network prune
#echo $PASSWORD | sudo -S docker volume prune
#echo $PASSWORD | sudo -S docker image prune
#echo $PASSWORD | sudo -S docker container prune
# Removing database might result in data loss!!!
#echo $PASSWORD | sudo -S service postgresql stop
#echo $PASSWORD | sudo -S service couchdb stop
# Restarting services!
#echo $PASSWORD | sudo -S systemctl stop docker
#echo $PASSWORD | sudo -S service docker stop
#echo $PASSWORD | sudo -S service docker restart
#echo $PASSWORD | sudo -S service docker restart
#echo $PASSWORD | sudo -S service docker restart


service postgresql stop -f
service couchdb stop -f 
service docker stop -f
service docker restart -f 
systemctl stop docker -f
docker network prune -f
docker volume prune -f
docker image prune -f
docker container prune -f
docker network rm beef_supply private_ipfs farmer breeder processor distributor retailer manager consumer regulator 
  
echo "network reset complete!"
# Remove exited containers
#echo $PASSWORD | sudo -S docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm
}

function blockchainNetworkDown(){
./network.sh down
docker network rm beef_supply farmer breeder processor distributor retailer manager consumer regulator     

}


function blockchainNetworkUp(){
# bringing up blockchain network 
#./network.sh up createChannel -c tracechannel -ca -s couchdb
docker network create -d bridge beef_supply
./network.sh up createChannel -c tracechannel -ca -s couchdb 
# create isolated bridge network for individual participants
./isolatedbridge.sh createbridge
./isolatedbridge.sh blockchainbridge

}

function individualChannelUp(){
# Create channels! 
./connections/farmerchannel.sh createChannel -c farmerchannel
./connections/breederchannel.sh createChannel -c breederchannel
./connections/consumerchannel.sh createChannel -c consumerchannel
./connections/distributorchannel.sh createChannel -c distributorchannel
./connections/processorchannel.sh createChannel -c processorchannel
./connections/managerchannel.sh createChannel -c managerchannel
./connections/regulatorchannel.sh createChannel -c regulatorchannel
./connections/retailerchannel.sh createChannel -c retailerchannel
./connections/breederprocessorchannel.sh createChannel -c breederprocessorchannel
./connections/farmerbreederchannel.sh createChannel -c farmerbreederchannel
./connections/distributorretailerchannel.sh createChannel -c distributorretailerchannel
./connections/farmerbreederprocessorchannel.sh createChannel -c farmerbreederprocessorchannel
./connections/processordistributorchannel.sh createChannel -c processordistributorchannel
./connections/regulatorfarmerchannel.sh createChannel -c regulatorfarmerchannel
./connections/retailerconsumerchannel.sh createChannel -c retailerconsumerchannel
./connections/farmer1channel.sh createChannel -c farmer1channel
./connections/interbeefsupplychainchannel.sh createChannel -c interbeefsupplychainchannel
}

function blockchainExplorerUp(){

# Creating blockchain explorer

#echo $PASSWORD | sudo -S chmod -R a+rwx fabricexplorer
#sleep 1s
echo $PASSWORD | sudo -S rm -d -r fabricexplorer/organizations
#sleep 1s
echo $PASSWORD | sudo -S cp -R $PWD/organizations $PWD/fabricexplorer/
echo $PASSWORD | sudo -S chmod -R a+rwx fabricexplorer
#sleep 1s

# Use jq to replace keys in bulk!
key_value=$(ls $PWD/organizations/peerOrganizations/manager.beefsupply.com/users/User1@manager.beefsupply.com/msp/keystore/)
echo $key_value
export key_value

cd fabricexplorer && docker-compose up -d
cd ..

echo "Blockchain exlorer is up for farmer with following credentials" 
echo "interface is running at localhost:8090"
echo "username:exploreradmin"
echo "password:exploreradminpw"

}


function blockchainExplorerDown(){

#docker compose -f $COMPOSE_FILE_BASE -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE_CA down --volumes --remove-orphans
# clear container 
# docker rm -f $(docker ps -aq --filter label=service=hyperledger-fabric name='dev-peer*') 2>/dev/null || true
# remove image
# docker image rm -f $(docker images -aq --filter reference='dev-peer*') 2>/dev/null || true
# reset container 
# docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/farmer/msp organizations/fabric-ca/farmer/tls-cert.pem organizations/fabric-ca/farmer/ca-cert.pem organizations/fabric-ca/farmer/IssuerPublicKey organizations/fabric-ca/farmer/IssuerRevocationPublicKey organizations/fabric-ca/farmer/fabric-ca-server.db'
docker stop explorerdb.beefnetwork.com
docker rm explorerdb.beefnetwork.com
docker stop explorer.beefnetwork.com
docker rm explorer.beefnetwork.com
#echo $PASSWORD | sudo -S chmod -r a+rwx fabricexplorer
#sleep 1s
echo $PASSWORD | sudo -S rm -d -r fabricexplorer/organizations
#sleep 1s
echo $PASSWORD | sudo -S fuser -k 8090/tcp
}


function blockchainNewUser(){

# adding rancher organziation 
echo "adding rancher organziation"
./addrancher/addRancher.sh up -c tracechannel -s couchdb -ca 

}

function blockchainNewUserDown(){

# adding rancher organziation 
echo "removing rancher organziation"
./addrancher/addRancher.sh remove -c tracechannel 
#./addrancher/addRancher.sh remove -c tracechannel 
}

function blockchainNewCredential(){

echo "removing rancher organziation"
./addcredentials/addCredentials.sh add

}

function blockchainaddCustomOrg(){

echo "removing rancher organziation"
./addcustom/addCustom.sh up -c tracechannel -ca -s couchdb 

}



function ipfsNetworkUp(){

# bringing up ipfs network 
LOCKERROR="Error: cannot acquire lock: Lock FcntlFlock of /var/ipfsfb/repo.lock failed: resource temporarily unavailable"

#rm /Users/name/.ipfs/repo.lock
#ipfs daemon
cd ipfsnetwork/p2p && docker-compose up -d

#killall ipfs
#sudo systemctl stop ipfs
#ipfs daemon shutdown
#ipfs shutdown
sleep 5s # Needed to remove locked repositories from daemon
#docker exec farmer.ipfs.com rm /var/ipfsfb/repo.lock
#docker exec farmer.ipfs.com rm /var/ipfsfb/datastore/LOCK
result=$(docker exec farmer.ipfs.com ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec farmer.ipfs.com rm -rf /var/ipfsfb/repo.lock
    docker exec farmer.ipfs.com rm -rf ~/.ipfs/repo.lock
    docker exec farmer.ipfs.com rm -rf ~/repo.lock
    docker exec farmer.ipfs.com ipfs bootstrap rm --all
else
    echo ""
fi

farmer_address=$(docker exec farmer.ipfs.com ipfs id -f='<addrs>') 

#docker exec breeder.ipfs.com rm /var/ipfsfb/repo.lock
#docker exec breeder.ipfs.com rm /var/ipfsfb/datastore/LOCK
result=$(docker exec  breeder.ipfs.com ipfs bootstrap rm --all)
if [ "$result" == "$LOCKERROR" ] ;then
    sudo systemctl status docker|grep tasks
    docker exec breeder.ipfs.com rm -rf /var/ipfsfb/repo.lock
    docker exec breeder.ipfs.com rm -rf ~/.ipfs/repo.lock
    docker exec breeder.ipfs.com rm -rf ~/repo.lock
    docker exec breeder.ipfs.com ipfs bootstrap rm --all
else
    echo ""
fi

breeder_address=$(docker exec breeder.ipfs.com ipfs id -f='<addrs>')

 
#docker exec processor.ipfs.com rm /var/ipfsfb/repo.lock
docker exec  processor.ipfs.com ipfs bootstrap rm --all
docker exec  distributor.ipfs.com ipfs bootstrap rm --all
docker exec  retailer.ipfs.com ipfs bootstrap rm --all
docker exec  consumer.ipfs.com ipfs bootstrap rm --all
docker exec  manager.ipfs.com ipfs bootstrap rm --all
docker exec  regulator.ipfs.com ipfs bootstrap rm --all


#docker exec processor.ipfs.com rm /var/ipfsfb/repo.lock
processor_address=$(docker exec processor.ipfs.com ipfs id -f='<addrs>') 
#docker exec distributor.ipfs.com rm /var/ipfsfb/repo.lock
distributor_address=$(docker exec distributor.ipfs.com ipfs id -f='<addrs>') 
#docker exec retailer.ipfs.com rm /var/ipfsfb/repo.lock
retailer_address=$(docker exec retailer.ipfs.com ipfs id -f='<addrs>') 
#docker exec consumer.ipfs.com rm /var/ipfsfb/repo.lock
consumer_address=$(docker exec consumer.ipfs.com ipfs id -f='<addrs>') 
#docker exec manager.ipfs.com rm /var/ipfsfb/repo.lock
manager_address=$(docker exec manager.ipfs.com ipfs id -f='<addrs>') 
#docker exec regulator.ipfs.com rm /var/ipfsfb/repo.lock
regulator_address=$(docker exec regulator.ipfs.com ipfs id -f='<addrs>') 

#docker exec farmer.ipfs.com rm /var/ipfsfb/repo.lock
#docker exec farmer.ipfs.com rm /var/ipfsfb/datastore/LOCK
#farmer_address=$(docker exec farmer.ipfs.com ipfs id -f='<addrs>') 
#docker exec breeder.ipfs.com rm /var/ipfsfb/repo.lock
#docker exec breeder.ipfs.com rm /var/ipfsfb/datastore/LOCK
#breeder_address=$(docker exec breeder.ipfs.com ipfs id -f='<addrs>') 


farmeraddress=$(echo $farmer_address | cut -d' ' -f2)
breederaddress=$(echo $breeder_address | cut -d' ' -f2)
processoraddress=$(echo $processor_address | cut -d' ' -f2)
distributoraddress=$(echo $distributor_address | cut -d' ' -f2)
retaileraddress=$(echo $retailer_address | cut -d' ' -f2)
consumeraddress=$(echo $consumer_address | cut -d' ' -f2)
manageraddress=$(echo $manager_address | cut -d' ' -f2)
regulatoraddress=$(echo $regulator_address | cut -d' ' -f2)


echo "**************************************************"

echo $farmeraddress
echo $breederaddress
echo $processoraddress
echo $distributoraddress
echo $retaileraddress
echo $consumeraddress
echo $manageraddress
echo $regulatoraddress

export farmeraddress breederaddress processoraddress distributoraddress retaileraddress consumeraddress manageraddress regulatoraddress  

echo "**************************************************"

# move two directories back 
#cd ../..
cd ..

./bootstrapadd.sh

docker pull mattjtodd/ipfs-swarm-key-gen
result=$(docker run --rm  mattjtodd/ipfs-swarm-key-gen)
echo "${result}" > swarm.key

docker cp swarm.key farmer.ipfs.com:/var/ipfs
docker cp swarm.key breeder.ipfs.com:/var/ipfs
docker cp swarm.key processor.ipfs.com:/var/ipfs
docker cp swarm.key distributor.ipfs.com:/var/ipfs
docker cp swarm.key retailer.ipfs.com:/var/ipfs
docker cp swarm.key consumer.ipfs.com:/var/ipfs
docker cp swarm.key manager.ipfs.com:/var/ipfs
docker cp swarm.key regulator.ipfs.com:/var/ipfs

cd ..

./isolatedbridge.sh ipfsbridge

}

function ipfsNetworkDown(){
# removing ipfs network 
docker network disconnect
docker stop ipfscli
docker stop farmer.ipfs.com
docker stop breeder.ipfs.com
docker stop processor.ipfs.com
docker stop distributor.ipfs.com
docker stop retailer.ipfs.com
docker stop consumer.ipfs.com
docker stop manager.ipfs.com
docker stop regulator.ipfs.com
docker rm -v farmer.ipfs.com
docker rm -v breeder.ipfs.com
docker rm -v processor.ipfs.com
docker rm -v distributor.ipfs.com
docker rm -v retailer.ipfs.com
docker rm -v consumer.ipfs.com
docker rm -v manager.ipfs.com
docker rm -v regulator.ipfs.com
docker rm -v ipfscli
docker network rm private_ipfs    
}

function bringupTSA(){

# docker build - < Dockerfile
#docker pull nicholasamorim/uts-server:latest

cd utsaserver && docker-compose up -d 
cd ..
./isolatedbridge.sh utsabridge

#docker run -d --add-host=localhost:0.0.0.0 -p 2020:2020 uts-test2
#cd utsaserver && ./tests/cfg/pki/create_tsa_certs 
#konsole --noclose --new-tab -e ./uts-server -c tests/cfg/uts-server.cnf -D &
#./goodies/timestamp-file.sh -i rfc3161.xlsx -u http://localhost:2020 -r -O "-cert";
#openssl ts -verify -in farmer.xlsx.tsr -data farmer.xlsx -CAfile ./tests/cfg/pki/tsaca.pem
#openssl ts -reply -in farmer.xlsx.tsr -text

#cd ..

}

function bringdownTSA(){

docker stop beef.utsa.com
docker rm beef.utsa.com 
docker network rm utsa_utsa-server
sudo fuser -k 2020/tcp

}

function bringupAll(){

blockchainNetworkUp
individualChannelUp
blockchainExplorerUp
ipfsNetworkUp
bringupTSA
bringupIoT

}



function manageBlockChain(){
# removing ipfs network 

PS3='Enter your choice: '
options=("Bringup Blockchain" "Create Individual Channels" "Bringup Blockchain Explorer" "Bringdown Blockchain Network" "Bringdown Blockchain Explorer" "Bringup New User" "Bringdown New User" "Createnew Credentials" "Go to Main Menu")
select opt in "${options[@]}"
do
    
    case $opt in
        "Bringup Blockchain")
            blockchainNetworkUp
            ;;
        "Create Individual Channels")
            individualChannelUp
            ;;
        "Bringup Blockchain Explorer")
            blockchainExplorerUp
            ;;
        "Bringdown Blockchain Network")
            blockchainNetworkDown
            ;;
        "Bringdown Blockchain Explorer")
            blockchainExplorerDown
            ;;
        "Bringup New User")
            blockchainNewUser
            ;;
        "Bringdown New User")
            blockchainNewUserDown
            ;;
        "Createnew Credentials")
            blockchainNewCredential
            ;;
        "Go to Main Menu")
            break
            ;;
        *) echo "invalid selection $REPLY";;
    esac
    echo "
     1) Bringup Blockchain
     2) Create Individual Channels
     3) Bringup Blockchain Explorer
     4) Bringdown Blockchain Network
     5) Bringdown Blockchain Explorer
     6) Bringup New User
     7) Bringdown New User
     8) Createnew Credentials
     9) Go to Main Menu "
done

}


function manageIPFSNetwork(){
# removing ipfs network 

PS3='Enter your choice: '
options=("Bringup IPFS Network" "Bringdown IPFS Network" "Go to Main Menu")
select opt in "${options[@]}"
do
    
    case $opt in
        "Bringup IPFS Network")
            ipfsNetworkUp
            ;;
        "Bringdown IPFS Network")
            ipfsNetworkDown
            ;;
        "Go to Main Menu")
            break
            ;;
        *) echo "invalid selection $REPLY";;
    esac
    echo "
     1) Bringup IPFS Network
     2) Bringdown IPFS Network
     3) Go to Main Menu "
done

}


function bringupIoT(){
#
# Make sure to copy .env from docker folder to addons folders
cp iotnetwork/docker/.* iotnetwork/docker/addons/mongodb-writer/
cp iotnetwork/docker/.* iotnetwork/docker/addons/mongodb-reader/
docker network create --driver bridge beefchain-base-net
docker-compose -f iotnetwork/docker/docker-compose.yml -f iotnetwork/docker/addons/mongodb-writer/docker-compose.yml -f iotnetwork/docker/addons/mongodb-reader/docker-compose.yml up -d
./isolatedbridge.sh iotnetworkbridge

}

function bringdownIoT(){

docker stop mainflux-nginx    
docker stop mainflux-mqtt         
docker stop mainflux-http         
docker stop mainflux-coap       
docker stop mainflux-things      
docker stop mainflux-users       
docker stop mainflux-auth        
docker stop mainflux-keto         
docker stop mainflux-jaeger      
docker stop mainflux-vernemq     
docker stop mainflux-nats        
docker stop mainflux-auth-redis   
docker stop mainflux-es-redis     
docker stop mainflux-things-db   
docker stop mainflux-users-db     
docker stop mainflux-keto-db      
docker stop mainflux-auth-db 
docker stop mainflux-mongodb
docker stop mainflux-mongodb-writer
docker stop mainflux-mongodb-reader
docker stop mainflux-influxdb
docker stop mainflux-influxdb-writer
docker stop mainflux-influxdb-reader
docker stop mainflux-keto-migrate
# extras from UI
docker stop mainflux-bootstrap
docker stop mainflux-twins
docker stop mainflux-certs
docker stop mainflux-opcua
docker stop mainflux-grafana
docker stop mainflux-opcua-redis
docker stop mainflux-provision 
docker stop mainflux-twins-db 
docker stop mainflux-bootstrap-db 
docker stop mainflux-vault 
docker stop mainflux-certs-db
docker stop mainflux-ui
docker rm mainflux-nginx    
docker rm mainflux-mqtt         
docker rm mainflux-http         
docker rm mainflux-coap       
docker rm mainflux-things      
docker rm mainflux-users       
docker rm mainflux-auth        
docker rm mainflux-keto         
docker rm mainflux-jaeger      
docker rm mainflux-vernemq     
docker rm mainflux-nats        
docker rm mainflux-auth-redis   
docker rm mainflux-es-redis     
docker rm mainflux-things-db   
docker rm mainflux-users-db     
docker rm mainflux-keto-db      
docker rm mainflux-auth-db
docker rm mainflux-keto-migrate
docker rm mainflux-mongodb
docker rm mainflux-mongodb-writer
docker rm mainflux-mongodb-reader
docker rm mainflux-influxdb
docker rm mainflux-influxdb-writer
docker rm mainflux-influxdb-reader 
# extras from UI
docker rm mainflux-bootstrap
docker rm mainflux-twins
docker rm mainflux-certs
docker rm mainflux-opcua
docker rm mainflux-grafana
docker rm mainflux-opcua-redis
docker rm mainflux-provision 
docker rm mainflux-twins-db 
docker rm mainflux-bootstrap-db 
docker rm mainflux-vault 
docker rm mainflux-certs-db
docker rm mainflux-ui

docker network rm beefchain-base-net 
echo $PASSWORD | sudo -S docker network prune
echo $PASSWORD | sudo -S docker volume prune
echo $PASSWORD | sudo -S docker image prune
echo $PASSWORD | sudo -S docker container prune

}


function createSensorChannel(){

# If using UI, ca certificate would be at: iotnetwork/ui/docker/ssl/certs/ca.crt 
# Either change the certificate paths for curl or sync certificte files! 

curl -s -S -i --cacert iotnetwork/docker/ssl/certs/ca.crt -X POST -H "Content-Type: application/json" https://localhost/users -d '{"email":"farmer1@email.com", "password":"12345678"}' > iotnetwork/logs/log.txt
http_code1=$(grep "HTTP/2" iotnetwork/logs/log.txt)
farmer1_ID=$(grep "location" iotnetwork/logs/log.txt)
farmer1_ID=$(echo $farmer1_ID | awk -F 'location: /users/' '{print $2}')
http_code1=$(echo $http_code1 | sed 's/[^0-9]*//g')
http_code1="${http_code1:1}"

#http_code1=$(echo $code1 | grep "HTTP/2")
#http_code1=$(echo $http_code1 | sed -e 's/^[[:space:]]*//')
#size=${#http_code1}

if  [ "$http_code1" == "201"  ] ;then   
    echo "Successfully created user farmer1 to manage farmer1 IoT devices! Farmer1 ID is: $farmer1_ID"
else
    echo "Unable to create user farmer1 to manage farmer1 IoT devices! Error details are: $(grep "error" iotnetwork/logs/log.txt)"
fi

curl -s -S -i --cacert iotnetwork/docker/ssl/certs/ca.crt -X POST -H "Content-Type: application/json" https://localhost/users -d '{"email":"farmer2@email.com", "password":"12345678"}' > iotnetwork/logs/log.txt
http_code2=$(grep "HTTP/2" iotnetwork/logs/log.txt)
farmer2_ID=$(grep "location" iotnetwork/logs/log.txt)
farmer2_ID=$(echo $farmer2_ID | awk -F 'location: /users/' '{print $2}')
http_code2=$(echo $http_code2 | sed 's/[^0-9]*//g')
http_code2="${http_code2:1}"

if  [ "$http_code2" == "201"  ] ;then   
    echo "Successfully created user farmer2 to manage farmer2 IoT devices! Farmer2 ID is: $farmer2_ID"
else
    echo "Unable to create user farmer2 to manage farmer1 IoT devices! Error details are: $(grep "error" iotnetwork/logs/log.txt)"
fi

curl -s -S -i --cacert iotnetwork/docker/ssl/certs/ca.crt -X POST -H "Content-Type: application/json" https://localhost/users -d '{"email":"farmer3@email.com", "password":"12345678"}' > iotnetwork/logs/log.txt
http_code3=$(grep "HTTP/2" iotnetwork/logs/log.txt)
farmer3_ID=$(grep "location" iotnetwork/logs/log.txt)
farmer3_ID=$(echo $farmer3_ID | awk -F 'location: /users/' '{print $2}')
http_code3=$(echo $http_code3 | sed 's/[^0-9]*//g')
http_code3="${http_code3:1}"

if  [ "$http_code3" == "201"  ] ;then   
    echo "Successfully created user farmer3 to manage farmer3 IoT devices! Farmer3 ID is: $farmer3_ID"
else
    echo "Unable to create user farmer3 to manage farmer1 IoT devices!Error details are: $(grep "error" iotnetwork/logs/log.txt)"
fi


farmer1_TOKEN=$(curl -s -S -i --cacert iotnetwork/docker/ssl/certs/ca.crt -X POST -H "Content-Type: application/json" https://localhost/tokens -d '{"email":"farmer1@email.com", "password":"12345678"}')
farmer1_TOKEN=$(echo $farmer1_TOKEN | grep -o '"token":"[^"]*' | grep -o '[^"]*$')
echo "Farmer 1 is logged in with token: $farmer1_TOKEN"
echo "Checking farmer1 details:"
url=http://localhost/users/$farmer1_ID
# removing \r from end
url=${url%$'\r'}
response=$(curl -s -S -i -X GET -H "Authorization: $farmer1_TOKEN" $url)
echo $reponse

echo "Checking all other users in the Network:"
response=$(curl -s -S -i -X GET -H "Authorization: $farmer1_TOKEN" http://localhost/users)
echo $reponse

echo "Creating 3 sensor devices for farmer1"
response=$(curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_TOKEN" http://localhost/things/bulk -d '[{"name": "sensor1"}]')
farmer1_sensor1_ID=$(echo $response | grep -o '"id":"[^"]*' | grep -o '[^"]*$')
farmer1_sensor1_KEY=$(echo $response | grep -o '"key":"[^"]*' | grep -o '[^"]*$')
response=$(curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_TOKEN" http://localhost/things/bulk -d '[{"name": "sensor2"}]')
farmer1_sensor2_ID=$(echo $response | grep -o '"id":"[^"]*' | grep -o '[^"]*$')
farmer1_sensor2_KEY=$(echo $response | grep -o '"key":"[^"]*' | grep -o '[^"]*$')
response=$(curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_TOKEN" http://localhost/things/bulk -d '[{"name": "sensor3"}]')
farmer1_sensor3_ID=$(echo $response | grep -o '"id":"[^"]*' | grep -o '[^"]*$')
farmer1_sensor3_KEY=$(echo $response | grep -o '"key":"[^"]*' | grep -o '[^"]*$')

echo "Creating 2 channels for farmer1 devices to communicate with"
response=$(curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_TOKEN" http://localhost/channels/bulk -d '[{"name": "channel12"}]')
farmer1_channel12_ID=$(echo $response | grep -o '"id":"[^"]*' | grep -o '[^"]*$')
response=$(curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_TOKEN" http://localhost/channels/bulk -d '[{"name": "channel23"}]')
farmer1_channel23_ID=$(echo $response | grep -o '"id":"[^"]*' | grep -o '[^"]*$')


echo "Connecting devices with channels to communciate!"
payload="{\"channel_ids\": [\"${farmer1_channel12_ID}\"], \"thing_ids\": [\"${farmer1_sensor1_ID}\"]}"
curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_TOKEN" http://localhost/connect -d "$payload"
payload="{\"channel_ids\": [\"${farmer1_channel12_ID}\"], \"thing_ids\": [\"${farmer1_sensor2_ID}\"]}"
curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_TOKEN" http://localhost/connect -d "$payload"
payload="{\"channel_ids\": [\"${farmer1_channel23_ID}\"], \"thing_ids\": [\"${farmer1_sensor2_ID}\"]}"
curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_TOKEN" http://localhost/connect -d "$payload"
payload="{\"channel_ids\": [\"${farmer1_channel23_ID}\"], \"thing_ids\": [\"${farmer1_sensor3_ID}\"]}"
curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_TOKEN" http://localhost/connect -d "$payload"

echo "sensor1 sending messages over channel12!"
url=http://localhost/http/channels/$farmer1_channel12_ID/messages
# removing \r from end
url=${url%$'\r'}
#echo $url
#echo $farmer1_sensor1_KEY
curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_sensor1_KEY" $url -d '[{"bn":"some-base-name:","bt":1.276020076001e+09,"bu":"A","bver":5,"n":"voltage","u":"V","v":120.1}, {"n":"current","t":-5,"v":1.2}, {"n":"current","t":-4,"v":1.3}]'

echo "sensor2 sending messages over channel12"
url=http://localhost/http/channels/$farmer1_channel12_ID/messages
# removing \r from end
url=${url%$'\r'}

curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_sensor2_KEY" $url -d '[{"bn":"some-base-name:","bt":1.276020076001e+09,"bu":"A","bver":5,"n":"voltage","u":"V","v":120.1}, {"n":"current","t":-5,"v":1.2}, {"n":"current","t":-4,"v":1.3}]'

echo "sensor1 sending messages from farmers file on channel12!"
i=1
url=http://localhost/http/channels/$farmer1_channel12_ID/messages
# removing \r from end
url=${url%$'\r'}
echo $url
echo $farmer1_sensor1_KEY
FILE=organizations/farmer/energy.csv
#FILE=organizations/farmer/weights.csv
while IFS="," read row
do
 # skip column names
 test $i -eq 1 && ((i=i+1)) && continue
 IFS=, 
 read c1 c2 c3 c4 c5 c6 c7 <<<$row
 echo $c2
 #curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_sensor1_KEY" $url -d '[{"bn":"some-base-name:","bt":1.276020076001e+09,"bu":"A","bver":5,"n":"voltage","u":"V","v":120.1}, {"n":"current","t":-5,"v":'"$c2"'}, {"n":"current","t":-4,"v":'"$c3"'}]'
 curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: $farmer1_sensor1_KEY" $url -d '[{"bn":"urn:dev:DEVEUI:farmersensor:", "bt": 1.58565075E9},{"n": "electricity", "v": '"$c2"', "u": "kWh"},{"n": "diesel", "v": '"$c3"', "u": "lb"},{"n": "fossil", "v": '"$c4"', "u": "lb"},{"n": "petroleum", "v": '"$c5"', "u": "lb"},{"n": "naturalgas", "v": '"$c6"', "u": "cubicfeet"},{"n": "steam", "v": '"$c7"', "u": "lb"}]'
done < $FILE

echo "Reading back messages stored in db for sensor1!" 
# Reader service port can change depending upon the db type! 
service_port=8904
url=http://localhost:$service_port/channels/$farmer1_channel12_ID/messages?offset=0&limit=5
#curl -s -S -i -H "Authorization: $farmer1_sensor1_KEY" $url
#url=http://localhost:8904/channels/41d6967e-9938-426e-8690-2e453ad4e929/messages?offset=0&limit=5
echo "Reading back messages stored in db for sensor2!"
service_port=8904
url=http://localhost:$service_port/channels/$farmer1_channel23_ID/messages?offset=0&limit=5
#curl -s -S -i -H "Authorization: $farmer1_sensor2_KEY" $url
#curl -s -S -i -H "Authorization: 292653c0-24b0-4f6c-87f4-678338a8eb19" url=http://localhost:8904/channels/41d6967e-9938-426e-8690-2e453ad4e929/messages?offset=0&limit=5
#
echo "Reading back all messages stored in db!"
docker exec mainflux-mongodb sh -c "mongoexport --db mainflux --collection messages" > organizations/farmer/iotdump1.txt

}



function bringupIoTUI(){

cp iotnetwork/ui/docker/.* iotnetwork/docker/addons/mongodb-writer/
cp iotnetwork/ui/docker/.* iotnetwork/docker/addons/mongodb-reader/
docker-compose -f iotnetwork/ui/docker/docker-compose.yml up -d
docker stop mainflux-influxdb
docker stop mainflux-influxdb-writer
docker stop mainflux-influxdb-reader  
docker rm mainflux-influxdb
docker rm mainflux-influxdb-writer
docker rm mainflux-influxdb-reader  
docker-compose -f iotnetwork/docker/addons/mongodb-writer/docker-compose.yml -f iotnetwork/docker/addons/mongodb-reader/docker-compose.yml up -d
./isolatedbridge.sh iotnetworkbridge

echo "IoI Main UI is running at http://localhost:3000/explorer/"
echo "User: admin@example.com"
echo "Pass: 12345678"
echo "User and pass for IoT UI can be changed by changing .env file under UI settings or by creating new users with API"
echo "variables to change: MF_USERS_ADMIN_EMAIL and MF_USERS_ADMIN_PASSWORD"
echo "Grafana for IoT data visualization is running at http://localhost:3001"
echo "User: admin"
echo "Pass: admin"
echo "User and pass for grafana can be changed in grafana-defaults.ini in configs folder or a new user and pass created altogether at runtime"

}

function iotTests(){

total_tests=0
failed_count=0
success_count=0
failed_info=""
success_info=""

if ! docker info >/dev/null 2>&1; then
    #echo "Docker is not running, run it first and retry"
    failed_info+=" (Docker not Running!)"
    total_tests=$((total_tests+1))
    failed_count=$((failed_count+1))
    #exit 1
else
    total_tests=$((total_tests+1))
    #((i=i+1))
    #let "i=i+1"
    success_count=$((success_count+1))
    success_info+=" (Docker Running!)"
fi

if [ "$( docker container inspect -f '{{.State.Running}}' mainflux-mongodb )" == "true" ]; then 
    success_info+=" (Mongodb Running!)"
    total_tests=$((total_tests+1))
    success_count=$((success_count+1)) 
else
    failed_info+=" (Mongodb not Running!)"
    total_tests=$((total_tests+1))
    failed_count=$((failed_count+1))  
fi

echo "Total tests run: $total_tests"
echo "Total passed tests: $success_count"
echo $success_info
echo "Total failed tests: $failed_count"
echo $failed_info

}


function runTests(){

PS3='Enter your choice: '
options=("Run Blockchain Tests" "Run IoT Tests" "Run IPFS Tests" "Run Timestamp Tests" "Go to Main Menu")
select opt in "${options[@]}"
do
    
    case $opt in
        "Run Blockchain Tests")
            #blockchainTests
            ;;
        "Run IoT Tests")
            iotTests
            ;;
        "Run IPFS Tests")
            #ipfsTests
            ;;
        "Run Timestamp Tests")
            #tsaTests
            ;;
        "Go to Main Menu")
            break
            ;;
        *) echo "invalid selection $REPLY";;
    esac
    echo "
     1) Run Blockchain Tests
     2) Run IoT Tests
     3) Run IPFS Tests
     4) Run Timestamp Tests
     5) Go to Main Menu "
done

}



function manageIoTs(){

PS3='Enter your choice: '
options=("Bringup IoT Network" "Bringdown IoT Network" "Create Sensors and Channels" "Bringup IoT User Interface" "Go to Main Menu")
select opt in "${options[@]}"
do
    
    case $opt in
        "Bringup IoT Network")
            bringupIoT
            ;;
        "Bringdown IoT Network")
            bringdownIoT
            ;;
        "Create Sensors and Channels")
            createSensorChannel
            ;;
        "Bringup IoT User Interface")
            bringupIoTUI
            ;;
        "Go to Main Menu")
            break
            ;;
        *) echo "invalid selection $REPLY";;
    esac
    echo "
     1) Bringup IoT Network
     2) Bringdown IoT Network
     3) Create Sensors and Channels
     4) Bringup IoT User Interface
     5) Go to Main Menu "
done

}

function processorbreederExample(){

./examples/processorbreederExample.sh

}

function traceabilityExample(){

#blockchainNetworkUp
#ipfsNetworkUp
#bringupTSA
./examples/traceabilityExample.sh

}

function carbonEmissionsExample(){

#resetAll
#blockchainNetworkUp
#ipfsNetworkUp
#bringupTSA
#bringupIoT
./network.sh createChannel -c emissionschannel 

./examples/carbonEmissionExample.sh
# source ./examples/carbonEmissionExample.sh

}


function manageCredentials(){

PS3='Enter your choice: '
options=("Create and Login Example Users" "Logout Example Users" "Create User/Password" "Add User to Session (Login)" "Remove User from Session (Logout)" "Remove User/Password" "Change User/Password" "Dump Loggedin Users"  "Dump All Listed Users" "Info on GPG key and Pass-Store" "Go to Main Menu") 
select opt in "${options[@]}"
do
    
    case $opt in
    
        
        "Create and Login Example Users")
            loginExampleUsers
            ;;           
        "Logout Example Users")
            logoutExampleUsers
            ;; 
        "Create User/Password")
            createUserPassword
            ;;
        "Add User to Session (Login)")
            addUserSession
            ;;   
        "Remove User from Session (Logout)")
            removeUserSession
            ;;              
        "Remove User/Password")
            removeUserPassword
            ;;
        "Change User/Password")
            changeUserPassword
            ;;
        "Dump Loggedin Users")
            dumpLoggedIn 
            ;; 
        "Dump All Listed Users")
            dumpAllUsers 
            ;;    
        "Info on GPG key and Pass-Store")
            infoGPGKeys
            ;;     
        "Go to Main Menu")
            break
            ;;
        *) echo "invalid selection $REPLY";;
    esac
    echo "
     1) Create and Login Example Users
     2) Logout Example Users
     3) Create User/Password
     4) Add User to Session (Login)
     5) Remove User from Session (Logout)
     6) Remove User/Password
     7) Change User/Password
     8) Dump Loggedin Users
     9) Dump All Listed Users
     10) Info on GPG key and Pass-Store
     11) Go to Main Menu  "
     
done


}


function runExamples(){
#
#docker-compose -f examples/docker/docker-compose.yml up -d
PS3='Enter your choice: '
options=("Run Processor Breeder Example" "Run Traceability Example" "Run CarbonEmissions Example" "Go to Main Menu")
select opt in "${options[@]}"
do
    
    case $opt in
        "Run Processor Breeder Example")
            processorbreederExample
            ;;
        "Run Traceability Example")
            traceabilityExample
            ;;
        "Run CarbonEmissions Example")
            carbonEmissionsExample
            ;;
        "Go to Main Menu")
            break
            ;;
        *) echo "invalid selection $REPLY";;
    esac
    echo "
     1) Run Processor Breedeer Example
     2) Run Traceability Example
     3) Run CarbonEmissions Example
     4) Go to Main Menu "
done
#
}

function manageTimeStampAuthority(){
# removing ipfs network 

PS3='Enter your choice: '
options=("Bringup TSA" "Bringdown TSA" "Go to Main Menu")
select opt in "${options[@]}"
do
    
    case $opt in
        "Bringup TSA")
            bringupTSA
            ;;
        "Bringdown TSA")
            bringdownTSA
            ;;
        "Go to Main Menu")
            break
            ;;
        *) echo "invalid selection $REPLY";;
    esac
    echo "
     1) Bringup TSA
     2) Bringdown TSA
     3) Go to Main Menu "
done

}


PS3='Enter your choice:'
options=("Reset All Containers/Services" "Manage User Credentials" "Manage Blockchain" "Manage IPFS Network" "Manage Time Stamp Authority" "Manage Internet of Things" "Run Tests" "Run Examples" "Bringup All Components" "Quit")
select opt in "${options[@]}"
do
     
     case $opt in
        "Reset All Containers/Services")
            resetAll
            ;;
        "Manage User Credentials")
            manageCredentials
            ;;
        "Manage Blockchain")
            manageBlockChain   
            ;;
        "Manage IPFS Network")
            manageIPFSNetwork
            ;;
        "Manage Time Stamp Authority")
            manageTimeStampAuthority
           # echo "you chose $REPLY which is $opt"
            ;;
        "Manage Internet of Things")
            manageIoTs
           # echo "you chose $REPLY which is $opt"
            ;;
        "Run Tests")
            runTests
            ;;	
        "Run Examples")
            runExamples
            ;;	
        "Bringup All Components")
            bringupAll
            ;;
        #"Bringup SQLServer Databases"     
        #"Bringup PostreSQL Databases"     
        "Quit")
            break
            ;;
        *) echo "invalid selection $REPLY";;
    esac
    echo " Welcome to Main Menu for BeefChain App!
     1) Reset Network (Containers/Services)
     2) Manage User Credentials 
     3) Manage Blockchain
     4) Manage IPFS Network
     5) Manage Time Stamp Authority
     6) Manage Internet of Things
     7) Run Tests
     8) Run Examples
     9) Bringup All Components
     10) Quit "

done




