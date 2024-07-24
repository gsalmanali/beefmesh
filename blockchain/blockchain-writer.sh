#!/bin/bash


export PATH=$PATH:/usr/local/go/bin

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ENV_STORAGE=$SCRIPT_DIR/../environment/


address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
echo "declare -x ipaddress=$address" > $SCRIPT_DIR/../environment/hostip.sh  
  
. $SCRIPT_DIR/../utilities/custom_print.sh
. $SCRIPT_DIR/scripts/envVar.sh
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
. $SCRIPT_DIR/scripts/utils.sh

source ${PWD}/blockchain/OrgConfigurations/configtx_path.sh
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export PATH=$PATH:/usr/local/go/bin
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/blockchain/configtx/$CONFIGTX_FOLDER_PATH
export VERBOSE=false

function env_save(){
    export -p > "$ENV_STORAGE/$1.sh"
}

function env_restore(){
    source "$ENV_STORAGE/$1.sh"
}


createanimal()  {


       if [ "$#" -ne 5 ]; then
	        provided_org=$1 
	        provided_orderer=$2 
	        provided_channel=$3 
	        provided_program=$4 
	        provided_properties_file=$5
	        provided_text=$6
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "adding rancher with  channel $provided_channel"
	        
	        setGlobals $provided_org
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
                
                source $SCRIPT_DIR/../examples/animalrecords/$provided_properties_file
	        
	        peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS  --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c '{"function":"CreateAnimal","Args":["'$provided_text'", "na", "na", "na", "na", "na", "na", "na", "na", "na", "na", "na", "na", "na", "na"]}' --transient "{\"animal_properties\":\"$ANIMAL_PROPERTIES\"}" &> $SCRIPT_DIR/../examples/animalrecords/logs.txt
	        
	        ANIMAL_ID=$(grep -o '".*"' $SCRIPT_DIR/../examples/animalrecords/logs.txt | tr -d '"')
	        echo $provided_properties_file > $SCRIPT_DIR/../examples/animalrecords/$ANIMAL_ID.txt
	        echo $ANIMAL_ID >> $SCRIPT_DIR/../examples/animalrecords/$ANIMAL_ID.txt
	        
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi

}


readanimal()  {


       if [ "$#" -ne 4 ]; then
	        provided_org=$1 
	        provided_orderer=$2 
	        provided_channel=$3 
	        provided_program=$4 
	        provided_animalid=$5
	        #provided_text=$6
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "adding rancher with  channel $provided_channel"
	        
	        setGlobals $provided_org
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
                
                #source $SCRIPT_DIR/../examples/animalrecords/$provided_properties_file
	        
	       peer chaincode query -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"ReadAnimal\",\"Args\":[\"$provided_animalid\"]}" 
	       
	        
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi

}


readprivate()  {


       if [ "$#" -ne 4 ]; then
	        provided_org=$1 
	        provided_orderer=$2 
	        provided_channel=$3 
	        provided_program=$4 
	        provided_animalid=$5
	        #provided_text=$6
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "adding rancher with  channel $provided_channel"
	        
	        setGlobals $provided_org
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
                
                #source $SCRIPT_DIR/../examples/animalrecords/$provided_properties_file
	        
	      peer chaincode query -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"GetAnimalPrivateProperties\",\"Args\":[\"$provided_animalid\"]}"
#'{"function":"GetAnimalPrivateProperties","Args":["59e7d83fa7aa6714ef4c7510742d248e4f36d12c0f61bd68021376eb54cfaacc"]}' 
	       
	        
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi

}



changedescription()  {


       if [ "$#" -ne 5 ]; then
	        provided_org=$1 
	        provided_orderer=$2 
	        provided_channel=$3 
	        provided_program=$4 
	        provided_animalid=$5
	        provided_text=$6
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "adding rancher with  channel $provided_channel"
	        
	        setGlobals $provided_org
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
                
                #source $SCRIPT_DIR/../examples/animalrecords/$provided_properties_file
	        
	      #peer chaincode query -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"GetAnimalPrivateProperties\",\"Args\":[\"$provided_animalid\"]}"
              peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS  --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program  -c "{\"function\":\"ChangeOpenDescription\",\"Args\":[\"$provided_animalid\",\"$provided_text\"]}"
	       
	        
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi

}


recorddata()  {


       if [ "$#" -ne 6 ]; then
	        provided_org=$1 
	        provided_orderer=$2 
	        provided_channel=$3 
	        provided_program=$4 
	        provided_animalid=$5
	        provided_data=$6
	        provided_function=$7
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "adding rancher with  channel $provided_channel"
	        
	        setGlobals $provided_org
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
                
                #source $SCRIPT_DIR/../examples/animalrecords/$provided_properties_file
	        
	     
              peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"$provided_function\",\"Args\":[\"$provided_animalid\",\"$provided_data\"]}"
	       
	        
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi

}




agreetosell()  {


       if [ "$#" -ne 6 ]; then
	        provided_org=$1 
	        provided_orderer=$2 
	        provided_channel=$3 
	        provided_program=$4 
	        provided_animalid=$5
	        provided_animaltradeid=$6
	        provided_price=$7
	        #provided_function=$7
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "adding rancher with  channel $provided_channel"
	        
	        setGlobals $provided_org
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
                
                #source $SCRIPT_DIR/../examples/animalrecords/$provided_properties_file
	        
	     
              #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"$provided_function\",\"Args\":[\"$provided_animalid\",\"$provided_data\"]}"
              
              ANIMAL_PRICE=$(echo -n "{\"animal_id\":\"$provided_animalid\",\"trade_id\":\"$provided_animaltradeid\",\"price\":$provided_price}" | base64 | tr -d \\n)
              
	      peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS  --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"AgreeToSell\",\"Args\":[\"$provided_animalid\"]}" --transient "{\"animal_price\":\"$ANIMAL_PRICE\"}"
	       
	        
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi

}

agreetobuy() {


        if [ "$#" -ne 6 ]; then
	        provided_org=$1 
	        provided_orderer=$2 
	        provided_channel=$3 
	        provided_program=$4 
	        provided_animalid=$5
	        provided_properties_file=$6
	        provided_price=$7
	        #provided_function=$7
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "adding rancher with  channel $provided_channel"
	        
	        setGlobals $provided_org
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
                
                source $SCRIPT_DIR/../examples/animalrecords/$provided_properties_file
	        
	     
              #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"$provided_function\",\"Args\":[\"$provided_animalid\",\"$provided_data\"]}"
              
              ANIMAL_PRICE=$(echo -n "{\"animal_id\":\"$provided_animalid\",\"trade_id\":\"$provided_animaltradeid\",\"price\":$provided_price}" | base64 | tr -d \\n)
              
	      #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS  --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"AgreeToSell\",\"Args\":[\"$provided_animalid\"]}" --transient "{\"animal_price\":\"$ANIMAL_PRICE\"}"
	      
	      peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"AgreeToBuy\",\"Args\":[\"$provided_animalid\"]}" --transient "{\"animal_price\":\"$ANIMAL_PRICE\", \"animal_properties\":\"$ANIMAL_PROPERTIES\"}"
	       
	        
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi



}


checksaleprice() {

        if [ "$#" -ne 4 ]; then
	        provided_org=$1 
	        provided_orderer=$2 
	        provided_channel=$3 
	        provided_program=$4 
	        provided_animalid=$5
	        #provided_animaltradeid=$6
	        #provided_price=$7
	        #provided_function=$7
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "adding rancher with  channel $provided_channel"
	        
	        setGlobals $provided_org
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
                
                #source $SCRIPT_DIR/../examples/animalrecords/$provided_properties_file
	        
	     
              #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"$provided_function\",\"Args\":[\"$provided_animalid\",\"$provided_data\"]}"
              
              ANIMAL_PRICE=$(echo -n "{\"animal_id\":\"$provided_animalid\",\"trade_id\":\"$provided_animaltradeid\",\"price\":$provided_price}" | base64 | tr -d \\n)
              
	      #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS  --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"AgreeToSell\",\"Args\":[\"$provided_animalid\"]}" --transient "{\"animal_price\":\"$ANIMAL_PRICE\"}"
	      
	      #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"AgreeToBuy\",\"Args\":[\"$provided_animalid\"]}" --transient "{\"animal_price\":\"$ANIMAL1_PRICE\", \"animal_properties\":\"$ANIMAL_PRICE\"}"
	      
	      
	      peer chaincode query -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"GetAnimalSalesPrice\",\"Args\":[\"$provided_animalid\"]}"

	       
	        
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi



}



checkbidprice() {

        if [ "$#" -ne 4 ]; then
	        provided_org=$1 
	        provided_orderer=$2 
	        provided_channel=$3 
	        provided_program=$4 
	        provided_animalid=$5
	        #provided_animaltradeid=$6
	        #provided_price=$7
	        #provided_function=$7
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "adding rancher with  channel $provided_channel"
	        
	        setGlobals $provided_org
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
                
                #source $SCRIPT_DIR/../examples/animalrecords/$provided_properties_file
	        
	     
              #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"$provided_function\",\"Args\":[\"$provided_animalid\",\"$provided_data\"]}"
              
              ANIMAL_PRICE=$(echo -n "{\"animal_id\":\"$provided_animalid\",\"trade_id\":\"$provided_animaltradeid\",\"price\":$provided_price}" | base64 | tr -d \\n)
              
	      #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS  --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"AgreeToSell\",\"Args\":[\"$provided_animalid\"]}" --transient "{\"animal_price\":\"$ANIMAL_PRICE\"}"
	      
	      #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"AgreeToBuy\",\"Args\":[\"$provided_animalid\"]}" --transient "{\"animal_price\":\"$ANIMAL1_PRICE\", \"animal_properties\":\"$ANIMAL_PRICE\"}"
	      
	      
	      peer chaincode query -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"GetAnimalBidPrice\",\"Args\":[\"$provided_animalid\"]}"

	       
	        
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi



}



transferanimal() {

        if [ "$#" -ne 7 ]; then
	        seller_org=$1 
	        provided_orderer=$2 
	        provided_channel=$3 
	        provided_program=$4 
	        provided_animalid=$5
	        provided_animaltradeid=$6
	        buyer_org=$7
	        provided_price=$8
	        #provided_function=$7
	        # bringing up blockchain network  
	        #./network.sh up createChannel -c tracechannel -ca -s couchdb 
	        #docker network rm beef_supply
	        #docker network create -d bridge beef_supply 
	        #echo "adding rancher with  channel $provided_channel"
	        
	        setGlobals $seller_org
	        source $SCRIPT_DIR/scripts/blockchainEnvVar/$seller_org/PeerOrgEnv.sh
	        SELLER_PEER_ADDRESS=$CORE_PEER_ADDRESS
	        SELLER_ROOT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE
	       
	        
	        setGlobals $buyer_org
	        source $SCRIPT_DIR/scripts/blockchainEnvVar/$buyer_org/PeerOrgEnv.sh
	        BUYER_PEER_ADDRESS=$CORE_PEER_ADDRESS
	        BUYER_ROOT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE
	        BUYER_MSP=$CORE_PEER_LOCALMSPID
	        
	        
	        setGlobals $seller_org
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
                source $SCRIPT_DIR/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
                
                #source $SCRIPT_DIR/../examples/animalrecords/$provided_properties_file
	        
	     
              #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"$provided_function\",\"Args\":[\"$provided_animalid\",\"$provided_data\"]}"
              
              ANIMAL_PRICE=$(echo -n "{\"animal_id\":\"$provided_animalid\",\"trade_id\":\"$provided_animaltradeid\",\"price\":$provided_price}" | base64 | tr -d \\n)
              
	      #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS  --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"AgreeToSell\",\"Args\":[\"$provided_animalid\"]}" --transient "{\"animal_price\":\"$ANIMAL_PRICE\"}"
	      
	      #peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program -c "{\"function\":\"AgreeToBuy\",\"Args\":[\"$provided_animalid\"]}" --transient "{\"animal_price\":\"$ANIMAL1_PRICE\", \"animal_properties\":\"$ANIMAL_PRICE\"}"
	      
	      
	      peer chaincode invoke -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile $ORDERER_CA -C $provided_channel -n $provided_program  -c "{\"function\":\"TransferAnimal\",\"Args\":[\"$provided_animalid\",\"$BUYER_MSP\"]}" --transient "{\"animal_price\":\"$ANIMAL_PRICE\"}" --peerAddresses $SELLER_PEER_ADDRESS --tlsRootCertFiles $SELLER_ROOT_FILE --peerAddresses $BUYER_PEER_ADDRESS --tlsRootCertFiles $BUYER_ROOT_FILE

	       
	        
	        # create isolated bridge network for individual participants #./isolatedbridge.sh createbridge 
	        #./isolatedbridge.sh blockchainbridge
	else 
		echo "channel name not provided!"
	fi



}



# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [function_name]"
    exit 1
fi

# Case statement to handle different inputs
case "$1" in
    createanimal) createanimal $2 $3 $4 $5 $6 $7 ;;   
    readanimal) readanimal $2 $3 $4 $5 $6 $7 ;;      
    readprivate) readprivate $2 $3 $4 $5 $6 $7 ;;   
    changedescription) changedescription $2 $3 $4 $5 $6 $7 ;;  
    recorddata) recorddata $2 $3 $4 $5 $6 $7 $8 ;;
    agreetosell) agreetosell $2 $3 $4 $5 $6 $7 $8 ;;
    checkprice) checkprice $2 $3 $4 $5 $6 $7 $8 ;;
    agreetobuy) agreetobuy $2 $3 $4 $5 $6 $7 $8 ;;
    checksaleprice) checksaleprice $2 $3 $4 $5 $6 ;;
    checkbidprice) checkbidprice $2 $3 $4 $5 $6 ;;
    transferanimal) transferanimal $2 $3 $4 $5 $6 $7 $8 $9 ;;
    *) echo "Invalid input. Please provide a function name as an argument." && exit 1 ;;
esac

