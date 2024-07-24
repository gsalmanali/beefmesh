#!/bin/bash

# imports  
. scripts/envVar.sh
. scripts/utils.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="tracechannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

if [ ! -d "channel-artifacts" ]; then
	mkdir channel-artifacts
fi

createChannelGenesisBlock() {
	which configtxgen
	if [ "$?" -ne 0 ]; then
		fatalln "configtxgen tool not found."
	fi
	set -x
	configtxgen -profile BeefSupplyOrdererGenesis -outputBlock ./channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
	res=$?
	{ set +x; } 2>/dev/null
  verifyResult $res "Failed to generate channel configuration transaction..."
}

createChannel() {
	setGlobals farmer0
	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		osnadmin channel join --channelID $CHANNEL_NAME --config-block ./channel-artifacts/${CHANNEL_NAME}.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" >&log.txt
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
  FABRIC_CFG_PATH=$PWD/configtx/
  ORG=$1
  setGlobals $ORG
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
  docker exec cli ./scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME 
}

FABRIC_CFG_PATH=${PWD}/configtx

## Create channel genesis block
infoln "Generating channel genesis block '${CHANNEL_NAME}.block'"
createChannelGenesisBlock

FABRIC_CFG_PATH=$PWD/configtx/
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

## Create channel
infoln "Creating channel ${CHANNEL_NAME}"
createChannel
successln "Channel '$CHANNEL_NAME' created"

## Join all the peers to the channel
infoln "Joining farmer peer to the channel..."
joinChannel farmer0
infoln "Joining breeder peer to the channel..."
joinChannel breeder0
infoln "Joining processor peer to the channel..."
joinChannel processor0
#infoln "Joining processor peer to the channel..."
#joinChannel processor1
infoln "Joining distributor peer to the channel..."
joinChannel distributor0
infoln "Joining retailer peer to the channel..."
joinChannel retailer0
infoln "Joining consumer peer to the channel..."
joinChannel consumer0
infoln "Joining regulator peer to the channel..."
joinChannel regulator0
infoln "Joining farmer1 peer to the channel..."
joinChannel farmer1
infoln "Joining manager peer to the channel..."
joinChannel manager0

## Set the anchor peers for each org in the channel
infoln "Setting anchor peer for farmer..."
setAnchorPeer farmer0
infoln "Setting anchor peer for breeder..."
setAnchorPeer breeder0
infoln "Setting anchor peer for processor..."
setAnchorPeer processor0
#infoln "Setting anchor peer for processor..."
#setAnchorPeer processor1
infoln "Setting anchor peer for distributor..."
setAnchorPeer distributor0
infoln "Setting anchor peer for retailer..."
setAnchorPeer retailer0
infoln "Setting anchor peer for consumer0..."
setAnchorPeer consumer0
infoln "Setting anchor peer for regulator..."
setAnchorPeer regulator0
infoln "Setting anchor peer for farmer1..."
setAnchorPeer farmer1
infoln "Setting anchor peer for manager..."
setAnchorPeer manager0


successln "Channel '$CHANNEL_NAME' joined"