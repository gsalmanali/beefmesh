#!/bin/bash


export PATH=$PATH:/usr/local/go/bin

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ENV_STORAGE=$SCRIPT_DIR/../environment/


address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
echo "declare -x ipaddress=$address" > $SCRIPT_DIR/../environment/hostip.sh  
  
. $SCRIPT_DIR/../utilities/custom_print.sh

function env_save(){
    export -p > "$ENV_STORAGE/$1.sh"
}

function env_restore(){
    source "$ENV_STORAGE/$1.sh"
}

function blockchaindown(){

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
$SCRIPT_DIR/../network.sh down
docker network rm beef_supply 
#docker network rm farmer breeder processor distributor retailer manager consumer regulator     

}


function addrancher() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "adding rancher with  channel $provided_channel"
	        $SCRIPT_DIR/../addrancher/addRancher.sh up -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}


function addcustomorg() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "adding new org with  channel $provided_channel"
	        $SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/addCustomOrg.sh up -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}


function removecustomorg() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "adding rancher with  channel $provided_channel"
	        $SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/addCustomOrg.sh remove -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}




function addcustomorderer() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "adding new org with  channel $provided_channel"
	        $SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/addCustomOrderer.sh up -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}


function removecustomorderer() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "adding rancher with  channel $provided_channel"
	        $SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/addCustomOrderer.sh remove -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}



function addcustompeer() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "adding new org with  channel $provided_channel"
	        $SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/addCustomPeer.sh up -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}


function removecustompeer() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "adding rancher with  channel $provided_channel"
	        $SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/addCustomPeer.sh remove -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}



function removerancher() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "adding rancher with  channel $provided_channel"
	        $SCRIPT_DIR/../addrancher/addRancher.sh remove -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}



function addregulatorpeer() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "adding a regulator peer  with  channel $provided_channel"
	        $SCRIPT_DIR/../addregulatorpeer/addRegulatorPeer.sh up -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}



function removeregulatorpeer() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "removing the regulator peer with  channel $provided_channel"
	        $SCRIPT_DIR/../addregulatorpeer/addRegulatorPeer.sh remove -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}



function addrancherorderer() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "adding a rancher orderer  with  channel $provided_channel"
	        $SCRIPT_DIR/../addrancherorderer/addRancherOrderer.sh up -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}



function removerancherorderer() {

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        echo "removing the rancher orderer from  channel $provided_channel"
	        $SCRIPT_DIR/../addrancherorderer/addRancherOrderer.sh remove -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi


}




function downloadfabric() {
		
	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	fabric_directory=$SCRIPT_DIR/../fabric-samples
	echo "downloading binary for fabric 2.5.3 files in the directory $fabric_directory"
	sudo $SCRIPT_DIR/../utilities/install-fabric.sh --fabric-version 2.5.3 docker binary
}



function blockchainreset(){
# bringing the network down 
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
.$SCRIPT_DIR/../network.sh down

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


#service postgresql stop -f
#service couchdb stop -f 
#service docker stop -f
#service docker restart -f 
#systemctl stop docker -f
docker network prune -f
docker volume prune -f
#docker image prune -f
#docker container prune -f
docker network rm beef_supply 
#private_ipfs farmer breeder processor distributor retailer manager consumer regulator 
  
echo "network reset complete!"
# Remove exited containers
#echo $PASSWORD | sudo -S docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm
}


function blockchainup(){

	if [ "$#" -ne 0 ]; then
	        provided_channel=$1 
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        docker network rm beef_supply
	        docker network create -d bridge beef_supply 
	        echo "starting  a manager and regulator with initial channel $provided_channel"
	        $SCRIPT_DIR/../network.sh up createChannel -c $provided_channel -ca -s couchdb 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi

}


function createchannel(){

	if [ "$#" -ne 0 ]; then
	        #provided_parameter=$1 
	        provided_channel=$1
	        echo "creating a channel with name: $1"
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "starting  a manager and regulator with initial channel $provided_channel"
	        $SCRIPT_DIR/../network.sh createChannelCustom -c $provided_channel 
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi

}


function installcontract(){

	if [ "$#" -ne 2 ]; then
	        provided_channel=$1 
	        provided_package_name=$2
	        provided_program_location=$3
	        provided_program_language=$4
	        provided_organizations=$5
	        echo "creating a joint channel within the organizational group: $2"
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "starting  a manager and regulator with initial channel $provided_channel"
	        #$SCRIPT_DIR/../network.sh createRancherChannel -c $provided_channel 
	        $SCRIPT_DIR/../network.sh deployChaincodeCustom -c $provided_channel -ccn $provided_package_name -ccp $provided_program_location -ccl $provided_program_language -ccep $provided_organizations

	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi

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


function setparamcustomorg() {


SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

#source source $CUSTOM_ORG_FOLDER_PATH/env/env.sh
source $CUSTOM_ORG_FOLDER_PATH/env/env.sh

sed -e "s/\REPLACE_ORG/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/compose/docker/docker-compose-custom-template.yaml" > "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/compose/docker/docker-compose-custom.yaml" 

sed -e "s/\REPLACE_COUCHDB/$CUSTOM_COUCHDB_CONTAINER_NAME/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/compose/docker/docker-compose-couch-custom-template.yaml" > "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/compose/docker/docker-compose-couch-custom.yaml"

cp -r $CUSTOM_ORG_FOLDER_PATH/custom0_0 $CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0 

echo $customOrg
echo $CUSTOM_CORE_PEER_ADDRESS_PORT

sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh" 

sed -i "s/CUSTOM_CORE_PEER_ADDRESS_PORT/$CUSTOM_CORE_PEER_ADDRESS_PORT/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh" 


#sed -i "s/CustomOrg/$customOrg/g" "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh"
#sed -i "s/CUSTOM_CORE_PEER_ADDRESS_PORT/$CUSTOM_CORE_PEER_ADDRESS_PORT/g" "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh"


sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 

sed -i "s/CUSTOM_CORE_PEER_ADDRESS_PORT/$CUSTOM_CORE_PEER_ADDRESS_PORT/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 

sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerCAEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerCAEnv.sh" 

sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerOrgEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerOrgEnv.sh" 

sed -i "s/customORG/$customORG/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerOrgEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerOrgEnv.sh" 

sed -i "s/CUSTOM_CORE_PEER_ADDRESS_PORT/$CUSTOM_CORE_PEER_ADDRESS_PORT/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerOrgEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerOrgEnv.sh" 


if [ -d "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/custom0_0" ]; then
  # Remove the folder and its contents
  FOLDER_TO_REMOVE="$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/custom0_0"
  rm -rf "$FOLDER_TO_REMOVE"
  echo "Folder removed: $FOLDER_TO_REMOVE"
else
  echo "Folder does not exist: $FOLDER_TO_REMOVE"
fi

cp -r "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0" "$SCRIPT_DIR/scripts/blockchainEnvVar/${customOrg}0_0" 

if [ -d "$SCRIPT_DIR/scripts/blockchainEnvVar/${customOrg}0_0/${customOrg}0_0" ]; then
  # Remove the folder and its contents
  FOLDER_TO_REMOVE="$SCRIPT_DIR/scripts/blockchainEnvVar/${customOrg}0_0/${customOrg}0_0"
  rm -rf "$FOLDER_TO_REMOVE"
  echo "Folder removed: $FOLDER_TO_REMOVE"
else
  echo "Folder does not exist: $FOLDER_TO_REMOVE"
fi

 
echo "customOrg: $customOrg"
echo "customORG: $customORG"
echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "CUSTOM_ORG_FOLDER_PATH: $CUSTOM_ORG_FOLDER_PATH"

sed -e "s/customOrg/$customOrg/g" -e "s/customORG/$customORG/g" "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx-template.yaml" > $SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx.yaml
#sed -i "s/CustomORG/$CustomORG/g" $SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx.yaml


#awk -v customOrg="$CustomOrg" -v customORG="$CustomORG" '
#{
#    gsub(/CustomOrg/, customOrg);
#    gsub(/CustomORG/, customORG);
#    print
#}' "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx-template.txt" > "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx.yaml"


mkdir $SCRIPT_DIR/../organizations/fabric-ca/$customOrg
cp $SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/fabric-ca-server-config.yaml $SCRIPT_DIR/../organizations/fabric-ca/$customOrg/fabric-ca-server-config.yaml 




echo "done fixing variables and files!"

echo "customOrg=" $customOrg
echo "customORG=" $customORG
echo "CUSTOM_CA_SERVER_PORT=" $CUSTOM_CA_SERVER_PORT
echo "CUSTOM_CA_SERVER_OPERATIONS_LISTENADDRESS_PORT=" $CUSTOM_CA_SERVER_OPERATIONS_LISTENADDRESS_PORT
echo "CUSTOM_COUCHDB_CONTAINER_NAME=" $CUSTOM_COUCHDB_CONTAINER_NAME
echo "CUSTOM_COUCHDB_PORT=" $CUSTOM_COUCHDB_PORT
echo "CUSTOM_CORE_PEER_ADDRESS_PORT=" $CUSTOM_CORE_PEER_ADDRESS_PORT
echo "CUSTOM_CHAINCODE_PORT=" $CUSTOM_CHAINCODE_PORT
echo "CUSTOM_OPERATIONS_PORT=" $CUSTOM_OPERATIONS_PORT
echo "CUSTOM_ORG_FOLDER_PATH=" $CUSTOM_ORG_FOLDER_PATH

}



function setparamcustomorderer() {


SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

#source source $CUSTOM_ORG_FOLDER_PATH/env/env.sh

sed -e "s/\REPLACE_ORG/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/compose/docker/docker-compose-custom-template.yaml" > "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/compose/docker/docker-compose-custom.yaml" 


sed -e "s/\REPLACE_ORG/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/compose/docker/docker-compose-ca-custom-template.yaml" > "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/compose/docker/docker-compose-ca-custom.yaml" 

#sed -e "s/\REPLACE_COUCHDB/$CUSTOM_COUCHDB_CONTAINER_NAME/g"  "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/compose/docker/docker-compose-couch-custom-template.yaml" > "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/compose/docker/docker-compose-couch-custom.yaml"

cp -r $CUSTOM_ORDERER_FOLDER_PATH/customorderer $CUSTOM_ORDERER_FOLDER_PATH/${customOrg}

echo $customOrg
echo $CUSTOM_ORDERER_FOLDER_PATH

sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/${customOrg}/OrdererCertEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh" 

#sed -i "s/CUSTOM_CORE_PEER_ADDRESS_PORT/$CUSTOM_CORE_PEER_ADDRESS_PORT/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/PeerAddressCLI.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh" 


#sed -i "s/CustomOrg/$customOrg/g" "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh"
#sed -i "s/CUSTOM_CORE_PEER_ADDRESS_PORT/$CUSTOM_CORE_PEER_ADDRESS_PORT/g" "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh"


sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/${customOrg}/OrdererCommEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 


sed -i "s/customORG/$customORG/g"  "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/${customOrg}/OrdererCommEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 

sed -i "s/CUSTOM_ORDERER_GENERAL_LISTEN_PORT/$CUSTOM_ORDERER_GENERAL_LISTEN_PORT/g"  "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/${customOrg}/OrdererCommEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 



sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/${customOrg}/OrdererEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 


sed -i "s/CUSTOM_ORDERER_GENERAL_LISTEN_PORT/$CUSTOM_ORDERER_GENERAL_LISTEN_PORT/g"  "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/${customOrg}/OrdererEnv.sh" 


sed -i "s/CUSTOM_ORDERER_ADMIN_LISTEN_PORT/$CUSTOM_ORDERER_ADMIN_LISTEN_PORT/g"  "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/${customOrg}/OrdererEnv.sh" 


#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 




if [ -d "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/${customOrg}/customorderer" ]; then
  # Remove the folder and its contents
  FOLDER_TO_REMOVE="$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/${customOrg}/customorderer"
  rm -rf "$FOLDER_TO_REMOVE"
  echo "Folder removed: $FOLDER_TO_REMOVE"
else
  echo "Folder does not exist: $FOLDER_TO_REMOVE"
fi

cp -r "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/${customOrg}" "$SCRIPT_DIR/scripts/blockchainEnvVar/orderers/${customOrg}" 

if [ -d "$SCRIPT_DIR/scripts/blockchainEnvVar/orderers/${customOrg}/${customOrg}" ]; then
  # Remove the folder and its contents
  FOLDER_TO_REMOVE="$SCRIPT_DIR/scripts/blockchainEnvVar/orderers/${customOrg}/${customOrg}"
  rm -rf "$FOLDER_TO_REMOVE"
  echo "Folder removed: $FOLDER_TO_REMOVE"
else
  echo "Folder does not exist: $FOLDER_TO_REMOVE"
fi


echo "customOrg: $customOrg"
echo "customORG: $customORG"
echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "CUSTOM_ORDERER_FOLDER_PATH: $CUSTOM_ORDERER_FOLDER_PATH"

sed -e "s/customOrg/$customOrg/g" -e "s/customORG/$customORG/g" -e "s/port/$CUSTOM_ORDERER_GENERAL_LISTEN_PORT/g" "$SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/configtx-template.yaml" > $SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/configtx.yaml
#sed -i "s/CustomORG/$CustomORG/g" $SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx.yaml


#awk -v customOrg="$CustomOrg" -v customORG="$CustomORG" '
#{
#    gsub(/CustomOrg/, customOrg);
#    gsub(/CustomORG/, customORG);
#    print
#}' "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx-template.txt" > "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx.yaml"


mkdir $SCRIPT_DIR/../organizations/fabric-ca/$customOrg
cp $SCRIPT_DIR/../$CUSTOM_ORDERER_FOLDER_PATH/fabric-ca/custom/fabric-ca-server-config.yaml $SCRIPT_DIR/../organizations/fabric-ca/$customOrg/fabric-ca-server-config.yaml 

echo "done fixing variables and files!"

echo "customOrg=" $customOrg
echo "customORG=" $customORG
echo "CUSTOM_CA_SERVER_PORT=" $CUSTOM_CA_SERVER_PORT
echo "CUSTOM_CA_SERVER_OPERATIONS_LISTENADDRESS_PORT=" $CUSTOM_CA_SERVER_OPERATIONS_LISTENADDRESS_PORT
echo "CUSTOM_COUCHDB_CONTAINER_NAME=" $CUSTOM_COUCHDB_CONTAINER_NAME
echo "CUSTOM_COUCHDB_PORT=" $CUSTOM_COUCHDB_PORT
echo "CUSTOM_CORE_PEER_ADDRESS_PORT=" $CUSTOM_CORE_PEER_ADDRESS_PORT
echo "CUSTOM_CHAINCODE_PORT=" $CUSTOM_CHAINCODE_PORT
echo "CUSTOM_OPERATIONS_PORT=" $CUSTOM_OPERATIONS_PORT
echo "CUSTOM_ORG_FOLDER_PATH=" $CUSTOM_ORG_FOLDER_PATH

}



function setparamcustompeer() {


SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

#source source $CUSTOM_PEER_FOLDER_PATH/env/env.sh

sed -e "s/\REPLACE_ORG/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/compose/docker/docker-compose-custom-template.yaml" > "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/compose/docker/docker-compose-custom.yaml" 

sed -e "s/\REPLACE_COUCHDB/$CUSTOM_COUCHDB_CONTAINER_NAME/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/compose/docker/docker-compose-couch-custom-template.yaml" > "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/compose/docker/docker-compose-couch-custom.yaml"

cp -r $CUSTOM_PEER_FOLDER_PATH/custom0_1 $CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1

echo $customOrg
echo $CUSTOM_CORE_PEER_ADDRESS_PORT

sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/PeerAddressCLI.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh" 

sed -i "s/CUSTOM_CORE_PEER_ADDRESS_PORT/$CUSTOM_CORE_PEER_ADDRESS_PORT/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/PeerAddressCLI.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh" 


#sed -i "s/CustomOrg/$customOrg/g" "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh"
#sed -i "s/CUSTOM_CORE_PEER_ADDRESS_PORT/$CUSTOM_CORE_PEER_ADDRESS_PORT/g" "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAddressCLI.sh"


sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/PeerAnchor.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 

sed -i "s/CUSTOM_CORE_PEER_ADDRESS_PORT/$CUSTOM_CORE_PEER_ADDRESS_PORT/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/PeerAnchor.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerAnchor.sh" 

sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/PeerCAEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerCAEnv.sh" 

sed -i "s/customOrg/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/PeerOrgEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerOrgEnv.sh" 

sed -i "s/customORG/$customORG/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/PeerOrgEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerOrgEnv.sh" 

sed -i "s/CUSTOM_CORE_PEER_ADDRESS_PORT/$CUSTOM_CORE_PEER_ADDRESS_PORT/g"  "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/PeerOrgEnv.sh" 
#> "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/${customOrg}0_0/PeerOrgEnv.sh" 


if [ -d "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/0_1" ]; then
  # Remove the folder and its contents
  FOLDER_TO_REMOVE="$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1/custom0_1"
  rm -rf "$FOLDER_TO_REMOVE"
  echo "Folder removed: $FOLDER_TO_REMOVE"
else
  echo "Folder does not exist: $FOLDER_TO_REMOVE"
fi

cp -r "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/${customOrg}0_1" "$SCRIPT_DIR/scripts/blockchainEnvVar/${customOrg}0_1" 

if [ -d "$SCRIPT_DIR/scripts/blockchainEnvVar/${customOrg}0_1/${customOrg}0_1" ]; then
  # Remove the folder and its contents
  FOLDER_TO_REMOVE="$SCRIPT_DIR/scripts/blockchainEnvVar/${customOrg}0_1/${customOrg}0_1"
  rm -rf "$FOLDER_TO_REMOVE"
  echo "Folder removed: $FOLDER_TO_REMOVE"
else
  echo "Folder does not exist: $FOLDER_TO_REMOVE"
fi



echo "customOrg: $customOrg"
echo "customORG: $customORG"
echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "CUSTOM_PEER_FOLDER_PATH: $CUSTOM_PEER_FOLDER_PATH"

#sed -e "s/customOrg/$customOrg/g" -e "s/customORG/$customORG/g" "$SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/configtx-template.yaml" > $SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/configtx.yaml
#sed -i "s/CustomORG/$CustomORG/g" $SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx.yaml


#awk -v customOrg="$CustomOrg" -v customORG="$CustomORG" '
#{
#    gsub(/CustomOrg/, customOrg);
#    gsub(/CustomORG/, customORG);
#    print
#}' "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx-template.txt" > "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/configtx.yaml"


#mkdir $SCRIPT_DIR/../organizations/fabric-ca/$customOrg


if [[ -d "$SCRIPT_DIR/../organizations/fabric-ca/$customOrg" ]]; then
  echo "Directory exists."
else
  echo "Error! Directory does not exist for $customOrg! Cant add peer to non-existent org"
  exit 1
fi
#cp $SCRIPT_DIR/../$CUSTOM_PEER_FOLDER_PATH/fabric-ca-server-config.yaml $SCRIPT_DIR/../organizations/fabric-ca/$customOrg/fabric-ca-server-config.yaml 

echo "done fixing variables and files!"

echo "customOrg=" $customOrg
echo "customORG=" $customORG
echo "CUSTOM_CA_SERVER_PORT=" $CUSTOM_CA_SERVER_PORT
echo "CUSTOM_CA_SERVER_OPERATIONS_LISTENADDRESS_PORT=" $CUSTOM_CA_SERVER_OPERATIONS_LISTENADDRESS_PORT
echo "CUSTOM_COUCHDB_CONTAINER_NAME=" $CUSTOM_COUCHDB_CONTAINER_NAME
echo "CUSTOM_COUCHDB_PORT=" $CUSTOM_COUCHDB_PORT
echo "CUSTOM_CORE_PEER_ADDRESS_PORT=" $CUSTOM_CORE_PEER_ADDRESS_PORT
echo "CUSTOM_CHAINCODE_PORT=" $CUSTOM_CHAINCODE_PORT
echo "CUSTOM_OPERATIONS_PORT=" $CUSTOM_OPERATIONS_PORT
echo "CUSTOM_ORG_FOLDER_PATH=" $CUSTOM_PEER_FOLDER_PATH

}

<<COMMENT



function setparamcustomorderer() {


SCRIPT_DIR=$(dirname "$(readlink -f "$0")")



sed -e "s/\REPLACE_ORG/$customOrg/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/compose/docker/docker-compose-custom-template.yaml" > "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/compose/docker/docker-compose-custom.yaml" 

sed -e "s/\REPLACE_COUCHDB/$CUSTOM_COUCHDB_CONTAINER_NAME/g"  "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/compose/docker/docker-compose-couch-custom-template.yaml" > "$SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/compose/docker/docker-compose-couch-custom.yaml"

mkdir $SCRIPT_DIR/../organizations/fabric-ca/$customOrg
cp $SCRIPT_DIR/../$CUSTOM_ORG_FOLDER_PATH/fabric-ca-server-config.yaml $SCRIPT_DIR/../organizations/fabric-ca/$customOrg/fabric-ca-server-config.yaml 

echo "done fixing variables and files!"

echo "customOrg=" $customOrg
echo "customORG=" $customORG
echo "CUSTOM_CA_SERVER_PORT=" $CUSTOM_CA_SERVER_PORT
echo "CUSTOM_CA_SERVER_OPERATIONS_LISTENADDRESS_PORT=" $CUSTOM_CA_SERVER_OPERATIONS_LISTENADDRESS_PORT
echo "CUSTOM_COUCHDB_CONTAINER_NAME=" $CUSTOM_COUCHDB_CONTAINER_NAME
echo "CUSTOM_COUCHDB_PORT=" $CUSTOM_COUCHDB_PORT
echo "CUSTOM_CORE_PEER_ADDRESS_PORT=" $CUSTOM_CORE_PEER_ADDRESS_PORT
echo "CUSTOM_CHAINCODE_PORT=" $CUSTOM_CHAINCODE_PORT
echo "CUSTOM_OPERATIONS_PORT=" $CUSTOM_OPERATIONS_PORT
echo "CUSTOM_ORG_FOLDER_PATH=" $CUSTOM_ORG_FOLDER_PATH

}
COMMENT

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


# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [function_name]"
    exit 1
fi

# Case statement to handle different inputs
case "$1" in
    copyenv) copyenv $2 ;;
    blockchainup) blockchainup $2 ;;
    blockchaindown) blockchaindown ;;
    addrancher) addrancher $2 ;;
    addcustomorg) addcustomorg $2 ;;
    removecustomorg) removecustomorg $2 ;;
    removerancher) removerancher $2 ;;
    addregulatorpeer) addregulatorpeer $2 ;;
    removeregulatorpeer) removeregulatorpeer $2 ;;
    addrancherorderer) addrancherorderer $2 ;;
    removerancherorderer) removerancherorderer $2 ;;
    addcustompeer) addcustompeer $2 ;;
    removecustompeer) removecustompeer $2 ;;
    addcustomorderer) addcustomorderer $2 ;;
    removecustomorderer) removecustomorderer $2 ;;
    setparamcustomorg) setparamcustomorg ;;
    setparamcustompeer) setparamcustompeer ;;
    setparamcustomorderer) setparamcustomorderer ;;
    setparamcustomorderer) setparamcustomorderer ;;
    createchannel) createchannel $2 ;;
    installcontract) installcontract $2 $3 $4 $5 $6 ;;
    downloadfabric) downloadfabric ;;
    *) echo "Invalid input. Please provide a function name as an argument." && exit 1 ;;
esac

