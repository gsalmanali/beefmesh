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

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source $SCRIPT_DIR/../OrgConfigurations/channel_path.sh
echo $CHANNEL_FOLDER_PATH
readarray -t lines < $SCRIPT_DIR/../OrgConfigurations/ChannelOrgConfig/$CHANNEL_FOLDER_PATH/createChannelOrgsCustom.txt
# Display the lines
export USE_CHANNEL_PROFILE=${lines[0]}
export USE_ORDERER=${lines[1]}
export USE_MAIN_ORG=${lines[2]}
export USE_ORGANIZATIONS=${lines[3]}
echo $USE_CHANNEL_NAME
echo $USE_ORDERER
echo $USE_MAIN_ORG
echo $USE_ORGANIZATIONS

  setGlobals $USE_MAIN_ORG 
	which configtxgen
	if [ "$?" -ne 0 ]; then
		fatalln "configtxgen tool not found."
	fi
	local bft_true=$1
	set -x

	if [ $bft_true -eq 1 ]; then
		configtxgen -profile BeefSupplyChannelUsingBFT -outputBlock ./blockchain/channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
	else
		echo "using profile: $USE_PROFILE"
		configtxgen -profile $USE_CHANNEL_PROFILE -outputBlock ./blockchain/channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
		#configtxgen -profile BeefSupplyChannelUsingRaft -outputBlock ./blockchain/channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
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
    
    SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
    source $SCRIPT_DIR/../OrgConfigurations/channel_path.sh
    echo $CHANNEL_FOLDER_PATH
     readarray -t lines < $SCRIPT_DIR/../OrgConfigurations/ChannelOrgConfig/$CHANNEL_FOLDER_PATH/createChannelOrgsCustom.txt
     # Display the lines
     #export USE_CHANNEL_PROFILE=${lines[0]}
     export USE_ORDERER=${lines[1]}
     source $PWD/blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
     source $PWD/blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
     
     osnadmin channel join --channelID ${CHANNEL_NAME} --config-block ./blockchain/channel-artifacts/${CHANNEL_NAME}.block -o $CORE_ORDERER_ADMIN_LISTEN_ADDRESS --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" >> log.txt 2>&1
    
    #. blockchain/scripts/orderercustom.sh ${CHANNEL_NAME} ${USE_ORDERER}> /dev/null 2>&1
       
    #. blockchain/scripts/orderer.sh ${CHANNEL_NAME}> /dev/null 2>&1
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
  #${CONTAINER_CLI} exec cli ./blockchain/scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME 
  ./blockchain/scripts/setAnchorPeerNoCLICustomChannel.sh $ORG $CHANNEL_NAME 
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
#source ${PWD}/blockchain/OrgConfigurations/configtx_path.sh
FABRIC_CFG_PATH=$PWD/blockchain/configtx/$CONFIGTX_FOLDER_PATH
if [ $BFT -eq 1 ]; then
  FABRIC_CFG_PATH=${PWD}/blockchain/bft-config
fi


<<comment
# Handle the comma-separated values in the third line
IFS=',' read -r -a array <<< "${lines[2]}"
echo "Third line separated values:"
for element in "${array[@]}"; do
    echo "$element"
done
comment


createChannelGenesisBlock $BFT


## Create channel
infoln "Creating channel ${CHANNEL_NAME}"
createChannel $BFT
successln "Channel '$CHANNEL_NAME' created"

## Join all the peers to the channel
# Handle the comma-separated values in the third line
readarray -t lines < ${PWD}/blockchain/OrgConfigurations/ChannelOrgConfig/$CHANNEL_FOLDER_PATH/createChannelOrgsCustom.txt
IFS=',' read -r -a array <<< "${lines[3]}"
echo "Third line separated values:"
for element in "${array[@]}"; do
    infoln "Joining $element peer to the channel..."
    #echo "$element"
    joinChannel $element
done

#infoln "Joining manager peer to the channel..."
#joinChannel manager0_0
#infoln "Joining regulator peer to the channel..."
#joinChannel regulator0_0

readarray -t lines < ${PWD}/blockchain/OrgConfigurations/ChannelOrgConfig/$CHANNEL_FOLDER_PATH/createChannelOrgsCustom.txt
IFS=',' read -r -a array <<< "${lines[3]}"
echo "Third line separated values:"
for element in "${array[@]}"; do
    infoln "Setting anchor peer for $element..."
    #echo "$element"
    setAnchorPeer $element
done

## Set the anchor peers for each org in the channel
#infoln "Setting anchor peer for manager..."
#setAnchorPeer manager0_0
#infoln "Setting anchor peer for regulator..."
#setAnchorPeer regulator0_0

#echo "Checking who has joined channel here"
#setGlobalsCLI manager0
#peer channel list
#setGlobalsCLI regulator0
#peer channel list
#setGlobalsCLI rancher0
#peer channel list

successln "Channel '$CHANNEL_NAME' joined"
