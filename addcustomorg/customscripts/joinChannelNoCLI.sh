#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# This script is designed to be run in the cli container as the
# second step of the EYFN tutorial. It joins the org3 peers to the
# channel previously setup in the BYFN tutorial and install the
# chaincode as version 2.0 on peer0.org3.
#

CHANNEL_NAME="$1"
DELAY="$2"
TIMEOUT="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="tracechannel"}
: ${DELAY:="3"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
COUNTER=1
MAX_RETRY=5
CHANNEL=$CHANNEL_NAME

# import environment variables
. ./blockchain/scripts/envVar.sh
. ./blockchain/scripts/utils.sh

#: ${customOrg:="salman"}
#: ${CustomOrg:="Salman"}

# joinChannel ORG
joinChannel() {
  ORG=$1
  
  
  setGlobals $ORG
  #setGlobalsCLI $ORG
  local rc=1
  local COUNTER=1
  ## Sometimes Join takes time, hence retry
  while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    echo $ORG
    echo $CORE_PEER_ADDRESS
    echo $CORE_PEER_MSPCONFIGPATH
    echo $CORE_PEER_LOCALMSPID
    echo $CORE_PEER_TLS_ROOTCERT_FILE
    echo $FABRIC_CFG_PATH
    echo $BLOCKFILE
    echo $CHANNEL_NAME
    echo $CHANNEL
    echo $path
    #CORE_PEER_ADDRESS=localhost:11051
    #CORE_PEER_MSPCONFIGPATH=/home/ali/Desktop/BeefChain/organizations/peerOrganizations/rancher.beefsupply.com/users/Admin@rancher.beefsupply.com/msp
    #CORE_PEER_TLS_ROOTCERT_FILE=/home/ali/Desktop/BeefChain/organizations/peerOrganizations/rancher.beefsupply.com/peers/peer0.rancher.beefsupply.com/tls/ca.crt
    #CORE_PEER_MSPCONFIGPATH=/home/ali/Desktop/BeefChain/organizations/peerOrganizations/rancher.beefsupply.com/users/Admin@rancher.beefsupply.com/msp
    #FABRIC_CFG_PATH=/home/ali/Desktop/BeefChain/blockchain/configtx/
    #peer channel list
    peer channel join -b $BLOCKFILE >&log.txt
    res=$?
    { set +x; } 2>/dev/null
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
   done
	cat log.txt
	verifyResult $res "After $MAX_RETRY attempts, peer0.${ORG} has failed to join channel '$CHANNEL_NAME' "
}

setAnchorPeer() {
  ORG=$1
  setGlobals $ORG
  #setGlobalsCLI $ORG
  #CORE_PEER_ADDRESS=localhost:11051
  ./blockchain/scripts/setAnchorPeerNoCLICustom.sh $ORG $CHANNEL_NAME
}


setGlobals ${customOrg}0_0
#SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source ${PWD}/blockchain/OrgConfigurations/configtx_path.sh   
#setGlobalsCLI rancher0
#FABRIC_CFG_PATH=$PWD/blockchain/configtx/
export FABRIC_CFG_PATH=${PWD}/blockchain/configtx/$CONFIGTX_FOLDER_PATH

BLOCKFILE="./blockchain/channel-artifacts/${CHANNEL_NAME}.block"
#docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/tracechannel.block ./blockchain/channel-artifacts/tracechannel.block
echo "Fetching channel config block from orderer..."
#rm ./blockchain/channel-artifacts/${CHANNEL_NAME}.block


 echo $CORE_PEER_ADDRESS
    echo $CORE_PEER_MSPCONFIGPATH
    echo $CORE_PEER_LOCALMSPID
    echo $CORE_PEER_TLS_ROOTCERT_FILE
    echo $FABRIC_CFG_PATH
    
    
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source $SCRIPT_DIR/../../blockchain/OrgConfigurations/channel_path.sh
echo $CHANNEL_FOLDER_PATH
readarray -t lines < $SCRIPT_DIR/../../blockchain/OrgConfigurations/ChannelOrgConfig/$CHANNEL_FOLDER_PATH/joinChannelOrgs.txt
# Display the lines
export USE_CHANNEL_NAME=${lines[0]}
export USE_ORDERER=${lines[1]}
export USE_MAIN_ORG=${lines[2]}
export USE_ORGANIZATIONS=${lines[3]}
echo $USE_CHANNEL_NAME
echo $USE_ORDERER
echo $USE_MAIN_ORG
echo $USE_ORGANIZATIONS

source $SCRIPT_DIR/../../blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
source $SCRIPT_DIR/../../blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
  
    
set -x
#peer channel fetch 0 $BLOCKFILE -o localhost:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c $CHANNEL_NAME --tls --cafile "$ORDERER_CA" >&log.txt

peer channel fetch 0 $BLOCKFILE -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS -c $CHANNEL_NAME --tls --cafile "$ORDERER_CA" >&log.txt
res=$?
{ set +x; } 2>/dev/null
cat log.txt
verifyResult $res "Fetching config block from orderer has failed"

infoln "Joining ${customOrg} peer to the channel..."
joinChannel ${customOrg}0_0

infoln "Setting anchor peer for org3..."
setAnchorPeer ${customOrg}0_0

successln "Channel '$CHANNEL_NAME' joined"
successln "${customOrg} peer successfully added to network"
