#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. blockchain/scripts/utils.sh

#: ${customOrg:="cedric"}
#: ${CustomOrg:="cedric"}


export CORE_PEER_TLS_ENABLED=true
#export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/tlsca/tlsca.beefsupply.com-cert.pem
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
#SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
source $SCRIPT_DIR/../OrgConfigurations/channel_path.sh
echo $CHANNEL_FOLDER_PATH
readarray -t lines < $SCRIPT_DIR/../OrgConfigurations/ChannelOrgConfig/$CHANNEL_FOLDER_PATH/generalOrderer.txt
#readarray -t lines < $SCRIPT_DIR/../OrgConfigurations/ChannelOrgConfig/$CHANNEL_FOLDER_PATH/createChannelOrgs.txt

# Display the lines
export USE_ORDERER=${lines[0]}

source $PWD/blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh

<<comment
#source $PWD/blockchain/scripts/blockchainEnvVar/orderers/RancherOrdererEnvironment.sh
#echo $ORDERER_CA
#export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/msp/tlscacerts/tlsca.beefsupply.com-cert.pem
#export PEER0_MANAGER_CA=${PWD}/organizations/peerOrganizations/manager.beefsupply.com/tlsca/tlsca.manager.beefsupply.com-cert.pem
source $PWD/blockchain/scripts/blockchainEnvVar/manager/CAEnvironment.sh
#export PEER0_REGULATOR_CA=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/tlsca/tlsca.regulator.beefsupply.com-cert.pem
export PEER0_REGULATOR_CA=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer0.regulator.beefsupply.com/tls/ca.crt
export PEER1_REGULATOR_CA=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls/ca.crt
#export PEER1_REGULATOR_CA=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/tlsca/tlsca.regulator.beefsupply.com-cert.pem
#export PEER1_REGULATOR_CA=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/tlsca/tlsca.regulator.beefsupply.com-cert.pem
#export PEER1_REGULATOR_CA=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls/tlscacerts/tls-localhost-8054-ca-regulator.pem
export PEER0_RANCHER_CA=${PWD}/organizations/peerOrganizations/rancher.beefsupply.com/tlsca/tlsca.rancher.beefsupply.com-cert.pem
#export PEER0_CUSTOM_CA=${PWD}/organizations/peerOrganizations/${customOrg}.beefsupply.com/tlsca/tlsca.${customOrg}.beefsupply.com-cert.pem
#export PEER0_RANCHER_CA=${PWD}/organizations/peerOrganizations/rancher.beefsupply.com/peers/peer0.rancher.beefsupply.com/tls/ca.crt
#
export PEER0_FARMER_CA=${PWD}/organizations/peerOrganizations/farmer.beefsupply.com/peers/peer0.farmer.beefsupply.com/tls/ca.crt
export PEER0_BREEDER_CA=${PWD}/organizations/peerOrganizations/breeder.beefsupply.com/peers/peer0.breeder.beefsupply.com/tls/ca.crt
export PEER0_BREEDER1_CA=${PWD}/organizations/peerOrganizations/breeder1.beefsupply.com/peers/peer0.breeder1.beefsupply.com/tls/ca.crt
export PEER0_PROCESSOR_CA=${PWD}/organizations/peerOrganizations/processor.beefsupply.com/peers/peer0.processor.beefsupply.com/tls/ca.crt
export PEER0_PROCESSOR1_CA=${PWD}/organizations/peerOrganizations/processor1.beefsupply.com/peers/peer0.processor1.beefsupply.com/tls/ca.crt
export PEER0_PROCESSOR2_CA=${PWD}/organizations/peerOrganizations/processor2.beefsupply.com/peers/peer0.processor2.beefsupply.com/tls/ca.crt
export PEER0_DISTRIBUTOR_CA=${PWD}/organizations/peerOrganizations/distributor.beefsupply.com/peers/peer0.distributor.beefsupply.com/tls/ca.crt
export PEER0_DISTRIBUTOR1_CA=${PWD}/organizations/peerOrganizations/distributor1.beefsupply.com/peers/peer0.distributor1.beefsupply.com/tls/ca.crt
export PEER0_DISTRIBUTOR2_CA=${PWD}/organizations/peerOrganizations/distributor2.beefsupply.com/peers/peer0.distributor2.beefsupply.com/tls/ca.crt
export PEER0_DISTRIBUTOR3_CA=${PWD}/organizations/peerOrganizations/distributor3.beefsupply.com/peers/peer0.distributor3.beefsupply.com/tls/ca.crt
export PEER0_RETAILOR_CA=${PWD}/organizations/peerOrganizations/retailor.beefsupply.com/peers/peer0.retailor.beefsupply.com/tls/ca.crt
export PEER0_RETAILOR1_CA=${PWD}/organizations/peerOrganizations/retailor1.beefsupply.com/peers/peer0.retailor1.beefsupply.com/tls/ca.crt
export PEER0_RETAILOR2_CA=${PWD}/organizations/peerOrganizations/retailor2.beefsupply.com/peers/peer0.retailor2.beefsupply.com/tls/ca.crt
export PEER0_RETAILOR3_CA=${PWD}/organizations/peerOrganizations/retailor3.beefsupply.com/peers/peer0.retailor3.beefsupply.com/tls/ca.crt
export PEER0_RETAILOR4_CA=${PWD}/organizations/peerOrganizations/retailor4.beefsupply.com/peers/peer0.retailor4.beefsupply.com/tls/ca.crt
export PEER0_CONSUMER_CA=${PWD}/organizations/peerOrganizations/consumer.beefsupply.com/peers/peer0.consumer.beefsupply.com/tls/ca.crt
export PEER0_CUSTOM_CA=${PWD}/organizations/peerOrganizations/${customOrg}.beefsupply.com/peers/peer0.${customOrg}.beefsupply.com/tls/ca.crt
export PEER1_CUSTOM_CA=${PWD}/organizations/peerOrganizations/${customOrg}.beefsupply.com/peers/peer1.${customOrg}.beefsupply.com/tls/ca.crt
comment

setEnvParameters() {

if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename=$1

# Check if the file exists
if [ ! -f "$filename" ]; then
    echo "Error: File $filename not found."
    exit 1
fi

# Read each line in the file and export as environment variable
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    if [[ $key != \#* && -n $key ]]; then
        export "$key"="$value"
        echo "Setting environment variable: $key=$value"
    fi
done < "$filename"

echo "Environment variables loaded from $filename."

}


# Set environment variables for the peer org
setGlobals() {
  
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  #USE_ORDERER=$2
  #source $PWD/blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
  echo "setting paramters for $USING_ORG"  
  echo "using path!"
  echo "$PWD/blockchain/scripts/blockchainEnvVar/$USING_ORG/PeerAddressCLI.sh"
  source $PWD/blockchain/scripts/blockchainEnvVar/$USING_ORG/PeerOrgEnv.sh
  source $PWD/blockchain/scripts/blockchainEnvVar/$USING_ORG/PeerCAEnv.sh
  echo "using variable values!"
  echo $CORE_PEER_TLS_ROOTCERT_FILE
  echo $CORE_PEER_LOCALMSPID
  echo $CORE_PEER_ADDRESS
  echo $CORE_PEER_MSPCONFIGPATH
  
<<comment  
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG = "manager0" ]; then  
    echo "setting paramters for manager0"
    setEnvParameters $PWD/blockchain/scripts/blockchainEnvVar/manager/Environment.txt
    #source $PWD/blockchain/scripts/blockchainEnvVar/manager/CAEnvironment.sh
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MANAGER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/$CORE_PEER_MSPCONFIGPATH
    #export CORE_PEER_LOCALMSPID
    #export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MANAGER_CA
    #export CORE_PEER_ADDRESS
  elif [ $USING_ORG = "regulator0" ]; then
    echo "setting paramters for regulator0"
    export CORE_PEER_LOCALMSPID="RegulatorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_REGULATOR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/users/Admin@regulator.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
  elif [ $USING_ORG = "regulator1" ]; then
    echo "setting paramters for regulator1"
    export CORE_PEER_LOCALMSPID="RegulatorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_REGULATOR_CA
    #export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/users/Admin@regulator.beefsupply.com/msp
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/users/Admin@regulator.beefsupply.com/msp   
    #export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:12051
  elif [ $USING_ORG = "rancher0" ]; then
    export CORE_PEER_LOCALMSPID="RancherMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RANCHER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/rancher.beefsupply.com/users/Admin@rancher.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:11051   
  elif [ $USING_ORG = "farmer0" ]; then
    echo "setting paramters for farmer0"
    export CORE_PEER_LOCALMSPID="FarmerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_FARMER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmer.beefsupply.com/users/Admin@farmer.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:8051       
  elif [ $USING_ORG = "breeder0" ]; then
    echo "setting paramters for breeder0"
    export CORE_PEER_LOCALMSPID="BreederMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BREEDER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/breeder.beefsupply.com/users/Admin@breeder.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:10051       
  elif [ $USING_ORG = "breeder1" ]; then
    echo "setting paramters for breeder1"
    export CORE_PEER_LOCALMSPID="Breeder1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BREEDER1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/breeder1.beefsupply.com/users/Admin@breeder1.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:13051       
  elif [ $USING_ORG = "processor0" ]; then
    echo "setting paramters for processor0"
    export CORE_PEER_LOCALMSPID="ProcessorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PROCESSOR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/processor.beefsupply.com/users/Admin@processor.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:14051      
  elif [ $USING_ORG = "processor1" ]; then
    echo "setting paramters for processor1"
    export CORE_PEER_LOCALMSPID="Processor1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PROCESSOR1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/processor1.beefsupply.com/users/Admin@processor1.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:15051      
  elif [ $USING_ORG = "processor2" ]; then
    echo "setting paramters for processor2"
    export CORE_PEER_LOCALMSPID="Processor2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PROCESSOR2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/processor2.beefsupply.com/users/Admin@processor2.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:16051      
  elif [ $USING_ORG = "distributor0" ]; then
    echo "setting paramters for distributor0"
    export CORE_PEER_LOCALMSPID="DistributorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DISTRIBUTOR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/distributor.beefsupply.com/users/Admin@distributor.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:17051      
  elif [ $USING_ORG = "distributor1" ]; then
    echo "setting paramters for distributor1"
    export CORE_PEER_LOCALMSPID="Distributor1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DISTRIBUTOR1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/distributor1.beefsupply.com/users/Admin@distributor1.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:18051      
  elif [ $USING_ORG = "distributor2" ]; then
    echo "setting paramters for distributor2"
    export CORE_PEER_LOCALMSPID="Distributor2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DISTRIBUTOR2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/distributor2.beefsupply.com/users/Admin@distributor2.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:19051      
  elif [ $USING_ORG = "distributor3" ]; then
    echo "setting paramters for distributor3"
    export CORE_PEER_LOCALMSPID="Distributor3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DISTRIBUTOR3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/distributor3.beefsupply.com/users/Admin@distributor3.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:20051     
  elif [ $USING_ORG = "retailor0" ]; then
    echo "setting paramters for retailor0"
    export CORE_PEER_LOCALMSPID="RetailorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILOR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/retailor.beefsupply.com/users/Admin@retailor.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:21051       
  elif [ $USING_ORG = "retailor1" ]; then
    echo "setting paramters for retailor1"
    export CORE_PEER_LOCALMSPID="Retailor1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILOR1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/retailor1.beefsupply.com/users/Admin@retailor1.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:22051      
  elif [ $USING_ORG = "retailor2" ]; then
    echo "setting paramters for retailor2"
    export CORE_PEER_LOCALMSPID="Retailor2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILOR1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/retailor2.beefsupply.com/users/Admin@retailor2.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:23051      
  elif [ $USING_ORG = "retailor3" ]; then
    echo "setting paramters for retailor3"
    export CORE_PEER_LOCALMSPID="Retailor3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILOR3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/retailor3.beefsupply.com/users/Admin@retailor3.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:24051      
  elif [ $USING_ORG = "retailor4" ]; then
    echo "setting paramters for retailor4"
    export CORE_PEER_LOCALMSPID="Retailor4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILOR4_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/retailor4.beefsupply.com/users/Admin@retailor4.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:25051     
  elif [ $USING_ORG = "consumer0" ]; then
    echo "setting paramters for consumer0"
    export CORE_PEER_LOCALMSPID="ConsumerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CONSUMER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/consumer.beefsupply.com/users/Admin@consumer.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:26051        
  elif [ $USING_ORG = "${customOrg}0" ]; then
    echo "setting paramters for ${customOrg}0"
    export CORE_PEER_LOCALMSPID="${customORG}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CUSTOM_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/${customOrg}.beefsupply.com/users/Admin@${customOrg}.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:${CUSTOM_CORE_PEER_ADDRESS_PORT}       
  elif [ $USING_ORG = "${customOrg}1" ]; then
    echo "setting paramters for ${customOrg}1"
    export CORE_PEER_LOCALMSPID="${customORG}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_CUSTOM_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/${customOrg}.beefsupply.com/users/Admin@${customOrg}.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:${CUSTOM_CORE_PEER_ADDRESS_PORT} 
  else
    errorln "ORG Unknown"
  fi
comment

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  
  echo "using path!"
  echo "$PWD/blockchain/scripts/blockchainEnvVar/$USING_ORG/PeerAddressCLI.sh"
  source $PWD/blockchain/scripts/blockchainEnvVar/$USING_ORG/PeerAddressCLI.sh
  
<<comment 
  if [ $USING_ORG = "manager0" ]; then
    #export CORE_PEER_ADDRESS=peer0.manager.beefsupply.com:7051
    source $PWD/blockchain/scripts/blockchainEnvVar/manager/PeerEnvironment.sh
  elif [ $USING_ORG = "regulator0" ]; then
    export CORE_PEER_ADDRESS=peer0.regulator.beefsupply.com:9051
  elif [ $USING_ORG = "rancher0" ]; then
    export CORE_PEER_ADDRESS=peer0.rancher.beefsupply.com:11051
  elif [ $USING_ORG = "regulator1" ]; then
    export CORE_PEER_ADDRESS=peer1.regulator.beefsupply.com:12051
  elif [ $USING_ORG = "farmer0" ]; then
    export CORE_PEER_ADDRESS=peer0.farmer.beefsupply.com:8051
  elif [ $USING_ORG = "breeder0" ]; then
    export CORE_PEER_ADDRESS=peer0.breeder.beefsupply.com:10051    
  elif [ $USING_ORG = "breeder1" ]; then
    export CORE_PEER_ADDRESS=peer0.breeder1.beefsupply.com:13051
  elif [ $USING_ORG = "processor0" ]; then
    export CORE_PEER_ADDRESS=peer0.processor.beefsupply.com:14051
  elif [ $USING_ORG = "processor1" ]; then
    export CORE_PEER_ADDRESS=peer0.processor1.beefsupply.com:15051
  elif [ $USING_ORG = "processor2" ]; then
    export CORE_PEER_ADDRESS=peer0.processor2.beefsupply.com:16051
  elif [ $USING_ORG = "distributor0" ]; then
    export CORE_PEER_ADDRESS=peer0.distributor.beefsupply.com:17051
  elif [ $USING_ORG = "distributor1" ]; then
    export CORE_PEER_ADDRESS=peer0.distributor1.beefsupply.com:18051
  elif [ $USING_ORG = "distributor2" ]; then
    export CORE_PEER_ADDRESS=peer0.distributor2.beefsupply.com:19051
  elif [ $USING_ORG = "distributor3" ]; then
    export CORE_PEER_ADDRESS=peer0.distributor3.beefsupply.com:20051
  elif [ $USING_ORG = "retailor0" ]; then
    export CORE_PEER_ADDRESS=peer0.retailor.beefsupply.com:21051
  elif [ $USING_ORG = "retailor1" ]; then
    export CORE_PEER_ADDRESS=peer0.retailor1.beefsupply.com:22051
  elif [ $USING_ORG = "retailor2" ]; then
    export CORE_PEER_ADDRESS=peer0.retailor2.beefsupply.com:23051
  elif [ $USING_ORG = "retailor3" ]; then
    export CORE_PEER_ADDRESS=peer0.retailor3.beefsupply.com:24051
  elif [ $USING_ORG = "retailor4" ]; then
    export CORE_PEER_ADDRESS=peer0.retailor4.beefsupply.com:25051
  elif [ $USING_ORG = "consumer0" ]; then
    export CORE_PEER_ADDRESS=peer0.consumer.beefsupply.com:26051
  elif [ $USING_ORG = "${customOrg}0" ]; then
    export CORE_PEER_ADDRESS=peer0.${customOrg}.beefsupply.com:${CUSTOM_CORE_PEER_ADDRESS_PORT}
  elif [ $USING_ORG = "${customOrg}1" ]; then
    export CORE_PEER_ADDRESS=peer1.${customOrg}.beefsupply.com:${CUSTOM_CORE_PEER_ADDRESS_PORT}   
  else
    errorln "ORG Unknown"
  fi
  
comment
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
   
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    if [ "$1" = "manager0_0" ]; then   
       source $PWD/blockchain/scripts/blockchainEnvVar/$1/PeerCAEnv.sh 
       PEER0_MANAGER_CA=$CORE_PEER_TLS_ROOTCERT_FILE
       CA=PEER0_MANAGER_CA
    elif [ "$1" = "regulator0_0" ]; then   
       source $PWD/blockchain/scripts/blockchainEnvVar/$1/PeerCAEnv.sh 
       PEER0_REGULATOR_CA=$CORE_PEER_TLS_ROOTCERT_FILE
       CA=PEER0_REGULATOR_CA
    else
       errorln "Issues with setting of CA directory"
    fi
        
    #else
    #  errorln "Issues with setting of CA directory"
    #fi
    #CA=PEER0_ORG$1_CA
    #CA=$CORE_PEER_TLS_ROOTCERT_FILE
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}


verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}




   


