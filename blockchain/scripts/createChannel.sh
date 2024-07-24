#!/bin/bash

# imports  
. blockchain/scripts/envVar.sh
. blockchain/scripts/utils.sh


CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
BFT="$5"
: ${CHANNEL_NAME:="tracechannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}
: ${BFT:=0}

: ${CONTAINER_CLI:="docker"}
: ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}
infoln "Using ${CONTAINER_CLI} and ${CONTAINER_CLI_COMPOSE}"

if [ ! -d "blockchain/channel-artifacts" ]; then
	mkdir blockchain/channel-artifacts
fi

createChannelGenesisBlock() {
  setGlobals manager0_0
	which configtxgen
	if [ "$?" -ne 0 ]; then
		fatalln "configtxgen tool not found."
	fi
	local bft_true=$1
	SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
	source $SCRIPT_DIR/../OrgConfigurations/channel_path.sh
        echo $CHANNEL_FOLDER_PATH
        readarray -t lines < $SCRIPT_DIR/../OrgConfigurations/ChannelOrgConfig/$CHANNEL_FOLDER_PATH/createChannelOrgs.txt
        # Display the lines
        export USE_CHANNEL_CONFIG=${lines[0]}
        #source $PWD/blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
	
	
	set -x
	if [ $bft_true -eq 1 ]; then
		configtxgen -profile BeefSupplyChannelUsingBFT -outputBlock ./blockchain/channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
	else
		configtxgen -profile $USE_CHANNEL_CONFIG -outputBlock ./blockchain/channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
	fi
	res=$?
	{ set +x; } 2>/dev/null
  verifyResult $res "Failed to generate channel configuration transaction..."
}

createChannel() {
	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	local bft_true=$1
	infoln "Adding orderers"
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		
        
    . blockchain/scripts/orderer.sh ${CHANNEL_NAME}> /dev/null 2>&1
    if [ $bft_true -eq 1 ]; then
      . blockchain/scripts/orderer2.sh ${CHANNEL_NAME}> /dev/null 2>&1
      . blockchain/scripts/orderer3.sh ${CHANNEL_NAME}> /dev/null 2>&1
      . blockchain/scripts/orderer4.sh ${CHANNEL_NAME}> /dev/null 2>&1
    fi
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
}

# joinChannel ORG
joinChannel() {
  ORG=$1
  #FABRIC_CFG_PATH=$PWD/blockchain/config/
  source ${PWD}/blockchain/OrgConfigurations/configtx_path.sh
  FABRIC_CFG_PATH=$PWD/blockchain/configtx/$CONFIGTX_FOLDER_PATH
  setGlobals $ORG
   echo $ORG
   echo $ORDERER_CA
   echo $ORDERER_ADMIN_TLS_SIGN_CERT
   echo $ORDERER_ADMIN_TLS_PRIVATE_KEY
   echo $CORE_PEER_ADDRESS
    echo $CORE_PEER_MSPCONFIGPATH
    echo $CORE_PEER_LOCALMSPID
    echo $CORE_PEER_TLS_ROOTCERT_FILE
    echo $FABRIC_CFG_PATH
    
  
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    
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
  echo $PWD
  #${CONTAINER_CLI} exec cli ./blockchain/scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME 
  ./blockchain/scripts/setAnchorPeerNoCLI.sh $ORG $CHANNEL_NAME 
  #${CONTAINER_CLI} exec cli ./blockchain/scripts/setAnchorPeerNoCLI.sh $ORG $CHANNEL_NAME 
}


## User attempts to use BFT orderer in Fabric network with CA
if [ $BFT -eq 1 ] && [ -d "organizations/fabric-ca/ordererOrg/msp" ]; then
  fatalln "Fabric network seems to be using CA. This sample does not yet support the use of consensus type BFT and CA together."
fi

## Create channel genesis block
source ${PWD}/blockchain/OrgConfigurations/configtx_path.sh
FABRIC_CFG_PATH=$PWD/blockchain/configtx/$CONFIGTX_FOLDER_PATH
BLOCKFILE="./blockchain/channel-artifacts/${CHANNEL_NAME}.block"

infoln "Generating channel genesis block '${CHANNEL_NAME}.block'"
source ${PWD}/blockchain/OrgConfigurations/configtx_path.sh
FABRIC_CFG_PATH=$PWD/blockchain/configtx/$CONFIGTX_FOLDER_PATH
if [ $BFT -eq 1 ]; then
  FABRIC_CFG_PATH=${PWD}/blockchain/bft-config
fi
createChannelGenesisBlock $BFT


## Create channel
infoln "Creating channel ${CHANNEL_NAME}"
createChannel $BFT
successln "Channel '$CHANNEL_NAME' created"

## Join all the peers to the channel
infoln "Joining manager peer to the channel..."
joinChannel manager0_0
infoln "Joining regulator peer to the channel..."
joinChannel regulator0_0


## Set the anchor peers for each org in the channel
infoln "Setting anchor peer for manager..."
setAnchorPeer manager0_0
infoln "Setting anchor peer for regulator..."
setAnchorPeer regulator0_0

#echo "Checking who has joined channel here"
#setGlobalsCLI manager0
#peer channel list
#setGlobalsCLI regulator0
#peer channel list
#setGlobalsCLI rancher0
#peer channel list

successln "Channel '$CHANNEL_NAME' joined"
