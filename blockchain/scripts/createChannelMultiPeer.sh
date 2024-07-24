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
  setGlobals manager0
	which configtxgen
	if [ "$?" -ne 0 ]; then
		fatalln "configtxgen tool not found."
	fi
	local bft_true=$1
	set -x

	if [ $bft_true -eq 1 ]; then
		configtxgen -profile BeefSupplyChannelUsingBFT -outputBlock ./blockchain/channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
	else
		configtxgen -profile BeefSupplyChannelUsingRaft -outputBlock ./blockchain/channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
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
  FABRIC_CFG_PATH=$PWD/blockchain/config/
  setGlobals $ORG
   echo $ORG
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
  ${CONTAINER_CLI} exec cli ./blockchain/scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME 
}


## User attempts to use BFT orderer in Fabric network with CA
if [ $BFT -eq 1 ] && [ -d "organizations/fabric-ca/ordererOrg/msp" ]; then
  fatalln "Fabric network seems to be using CA. This sample does not yet support the use of consensus type BFT and CA together."
fi

## Create channel genesis block
FABRIC_CFG_PATH=$PWD/blockchain/configtx/
BLOCKFILE="./blockchain/channel-artifacts/${CHANNEL_NAME}.block"

infoln "Generating channel genesis block '${CHANNEL_NAME}.block'"
FABRIC_CFG_PATH=${PWD}/blockchain/configtx
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
joinChannel manager0
infoln "Joining regulator peer to the channel..."
joinChannel regulator0
infoln "Joining farmer0 peer to the channel..."
joinChannel farmer0
infoln "Joining breedor0 peer to the channel..."
joinChannel breeder0
infoln "Joining breeder1 peer to the channel..."
joinChannel breeder1
infoln "Joining processor0 peer to the channel..."
joinChannel processor0
infoln "Joining processor1 peer to the channel..."
joinChannel processor1
infoln "Joining processor2 peer to the channel..."
joinChannel processor2
infoln "Joining distributor0 peer to the channel..."
joinChannel distributor0
infoln "Joining distributor1 peer to the channel..."
joinChannel distributor1
infoln "Joining distributor2 peer to the channel..."
joinChannel distributor2
infoln "Joining distributor3 peer to the channel..."
joinChannel distributor3
infoln "Joining retailor0 peer to the channel..."
joinChannel retailor0
infoln "Joining retailor1 peer to the channel..."
joinChannel retailor1
infoln "Joining retailor2 peer to the channel..."
joinChannel retailor2
infoln "Joining retailor3 peer to the channel..."
joinChannel retailor3
infoln "Joining retailor4 peer to the channel..."
joinChannel retailor4
infoln "Joining consumer0 peer to the channel..."
joinChannel consumer0


## Set the anchor peers for each org in the channel
infoln "Setting anchor peer for manager..."
setAnchorPeer manager0
infoln "Setting anchor peer for regulator..."
setAnchorPeer regulator0
infoln "Setting anchor peer for farmer0..."
setAnchorPeer farmer0
infoln "Setting anchor peer for breeder0..."
setAnchorPeer breeder0
infoln "Setting anchor peer for breeder1..."
setAnchorPeer breeder1
infoln "Setting anchor peer for processor0..."
setAnchorPeer processor0
infoln "Setting anchor peer for processor1..."
setAnchorPeer processor1
infoln "Setting anchor peer for processor2..."
setAnchorPeer processor2
infoln "Setting anchor peer for distributor0..."
setAnchorPeer distributor0
infoln "Setting anchor peer for distributor1..."
setAnchorPeer distributor1
infoln "Setting anchor peer for distributor2..."
setAnchorPeer distributor2
infoln "Setting anchor peer for distributor3..."
setAnchorPeer distributor3
infoln "Setting anchor peer for retailor0..."
setAnchorPeer retailor0
infoln "Setting anchor peer for retailor1..."
setAnchorPeer retailor1
infoln "Setting anchor peer for retailor2..."
setAnchorPeer retailor2
infoln "Setting anchor peer for retailor3..."
setAnchorPeer retailor3
infoln "Setting anchor peer for retailor4..."
setAnchorPeer retailor4
infoln "Setting anchor peer for consumer0..."
setAnchorPeer consumer0


#echo "Checking who has joined channel here"
#setGlobalsCLI manager0
#peer channel list
#setGlobalsCLI regulator0
#peer channel list
#setGlobalsCLI rancher0
#peer channel list

successln "Channel '$CHANNEL_NAME' joined"
