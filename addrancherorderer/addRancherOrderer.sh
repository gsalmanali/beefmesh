#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script extends the Hyperledger Fabric test network by adding
# adding a third organization to the network
#

# prepending $PWD/../bin to PATH to ensure we are picking up the correct binaries
# this may be commented out to resolve installed version of tools if desired
#export PATH=${PWD}/../../bin:${PWD}:$PATH
#export FABRIC_CFG_PATH=${PWD}
#export VERBOSE=false


export PATH=${PWD}/blockchain/bin:$PATH
#export FABRIC_CFG_PATH=${PWD}/configtx
export FABRIC_CFG_PATH=${PWD}/addrancherorderer
export VERBOSE=false

. $PWD/blockchain/scripts/utils.sh

: ${CONTAINER_CLI:="docker"}
: ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}
infoln "Using ${CONTAINER_CLI} and ${CONTAINER_CLI_COMPOSE}"

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  addRancher.sh up|down|generate [-c <channel name>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-s <dbtype>]"
  echo "  addRancher.sh -h|--help (print this message)"
  echo "    <mode> - one of 'up', 'down', or 'generate'"
  echo "      - 'up' - add rancher to the sample network. You need to bring up the test network and create a channel first."
  echo "      - 'down' - bring down the test network and rancher nodes"
  echo "      - 'generate' - generate required certificates and org definition"
  echo "    -c <channel name> - test network channel name (defaults to \"tracechannel\")"
  echo "    -ca <use CA> -  Use a CA to generate the crypto material"
  echo "    -t <timeout> - CLI timeout duration in seconds (defaults to 10)"
  echo "    -d <delay> - delay duration in seconds (defaults to 3)"
  echo "    -s <dbtype> - the database backend to use: goleveldb (default) or couchdb"
  echo "    -i <imagetag> - the tag to be used to launch the network (defaults to \"latest\")"
  echo "    -cai <ca_imagetag> - the image tag to be used for CA (defaults to \"${CA_IMAGETAG}\")"
  echo "    -verbose - verbose mode"
  echo
  echo "Typically, one would first generate the required certificates and "
  echo "genesis block, then bring up the network. e.g.:"
  echo
  echo "	addRancher.sh generate"
  echo "	addRancher.sh up"
  echo "	addRancher.sh up -c tracechanel -s couchdb"
  echo "	addRancher.sh down"
  echo
  echo "Taking all defaults:"
  echo "	addRancher.sh up"
  echo "	addRancher.sh down"
}

# We use the cryptogen tool to generate the cryptographic material
# (x509 certs) for the new org.  After we run the tool, the certs will
# be put in the organizations folder with org1 and org2

# Create Organziation crypto material using cryptogen or CAs
function generateRancherOrderer() {

  # Create crypto material using cryptogen
  if [ "$CRYPTO" == "cryptogen" ]; then
    which cryptogen
    if [ "$?" -ne 0 ]; then
      echo "cryptogen tool not found. exiting"
      exit 1
    fi
    echo
    echo "##########################################################"
    echo "##### Generate certificates using cryptogen tool #########"
    echo "##########################################################"
    echo

    echo "##########################################################"
    echo "############ Create Rancher Identities ######################"
    echo "##########################################################"

    set -x
    cryptogen generate --config=rancher-crypto.yaml --output="./organizations"
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
      echo "Failed to generate certificates..."
      exit 1
    fi

  fi

  # Create crypto material using Fabric CAs
  if [ "$CRYPTO" == "Certificate Authorities" ]; then

    fabric-ca-client version > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
      echo "ERROR! fabric-ca-client binary not found.."
      echo
      echo "Follow the instructions in the Fabric docs to install the Fabric Binaries:"
      echo "https://hyperledger-fabric.readthedocs.io/en/latest/install.html"
      exit 1
    fi

    echo
    echo "##########################################################"
    echo "##### Generate certificates using Fabric CA's ############"
    echo "##########################################################"

    #IMAGE_TAG=${CA_IMAGETAG} docker-compose -f $COMPOSE_FILE_CA_RANCHER up -d 2>&1
    docker-compose -f $COMPOSE_FILE_CA_RANCHER_ORDERER up -d 2>&1
    #. fabric-ca/registerEnroll.sh
    . addrancherorderer/fabric-ca/registerEnroll.sh

    sleep 10

    echo "##########################################################"
    echo "############ Create Rancher Identities ######################"
    echo "##########################################################"

    createRancherOrderer

  fi

  echo
  echo "Generate CCP files for Rancher"
  #$PWD/addrancher/ccp-generate.sh
  #. addrancher/ccp-generate.sh
}

function generateRancherOrdererDefinition() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi
  echo "##########################################################"
  echo "#######  Generating Rancher organization definition #########"
  echo "##########################################################"
   export FABRIC_CFG_PATH=$PWD/addrancherorderer
   set -x
   configtxgen -printOrg RancherOrdererMSP > ./organizations/ordererOrganizations/rancherorderer.beefsupply.com/rancherorderer.json
   res=$?
   { set +x; } 2>/dev/null
   if [ $res -ne 0 ]; then
     echo "Failed to generate Rancher config material..."
     exit 1
   fi
  echo
}


function removeRancherOrderer(){ 
  echo "removing rancher organziation"

  #docker stop Ranchercli
  
  #path="/opt/gopath/src/github.com/hyperledger/fabric/peer"
  
  #${CONTAINER_CLI} cp ./addrancherorderer/rancherordererscripts cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/rancherordererscripts/
  infoln "Generating and submitting config tx to add Org3"
  #${CONTAINER_CLI} exec cli ./rancherscripts/removeRancher.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
 ./addrancherorderer/rancherordererscripts/removeRancherNoCLI.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  #./addrancher/rancherscripts/updateChannelConfigNoCLI.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  if [ $? -ne 0 ]; then
    #fatalln "ERROR !!!! Unable to create config tx"
    echo "ERROR !!!! Unable to create config tx"
  fi
  
  #docker rm Ranchercli

  if [ "${CONTAINER_CLI}" == "docker" ]; then
    DOCKER_SOCK=$DOCKER_SOCK ${CONTAINER_CLI_COMPOSE} -f ${COMPOSE_FILE_RANCHER_ORDERER} -f ${COMPOSE_FILE_CA_RANCHER_ORDERER} down --volumes -remove-orphans
    echo "removing rancher"
  elif [ "${CONTAINER_CLI}" == "podman" ]; then
  
    ${CONTAINER_CLI_COMPOSE} ${COMPOSE_FILES} -f ${COMPOSE_FILE_RANCHER} -f ${COMPOSE_FILE_COUCH_RANCHER} down --volumes --remove-orphans
  else
    fatalln "Container CLI  ${CONTAINER_CLI} not supported"
  fi
  
  
  ${CONTAINER_CLI} volume stop docker_peer0.rancherorderer.beefsupply.com
  ${CONTAINER_CLI} volume stop peer0.rancherorderer.beefsupply.com
  ${CONTAINER_CLI} volume stop docker_rancherorderer.beefsupply.com
  
  ${CONTAINER_CLI} volume rm docker_peer0.rancherorderer.beefsupply.com
  ${CONTAINER_CLI} volume rm peer0.rancherorderer.beefsupply.com
  ${CONTAINER_CLI} volume rm docker_rancherorderer.beefsupply.com

  ${CONTAINER_CLI} stop ca_rancherorderer
  ${CONTAINER_CLI} rm ca_rancherorderer
  ${CONTAINER_CLI} stop rancherorderer.beefsupply.com
  ${CONTAINER_CLI} rm rancherorderer.beefsupply.com
 

  echo "removing rancher organziation"
  #${CONTAINER_CLI} run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf addrancher/fabric-ca/rancher/msp addrancher/fabric-ca/rancher/tls-cert.pem addrancher/fabric-ca/rancher/ca-cert.pem addrancher/fabric-ca/rancher/IssuerPublicKey addrancher/fabric-ca/rancher/IssuerRevocationPublicKey addrancher/fabric-ca/rancher/fabric-ca-server.db'

  ${CONTAINER_CLI} run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/rancherorderer/msp organizations/fabric-ca/rancherorderer/tls-cert.pem organizations/fabric-ca/rancherorderer/ca-cert.pem organizations/fabric-ca/rancherorderer/IssuerPublicKey organizations/fabric-ca/rancherorderer/IssuerRevocationPublicKey organizations/fabric-ca/rancherorderer/fabric-ca-server.db'
  
  #${CONTAINER_CLI} run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf channel-artifacts log.txt *.tar.gz'
  ${CONTAINER_CLI} volume stop docker_peer0.rancherorderer.beefsupply.com 
  ${CONTAINER_CLI} volume rm docker_peer0.rancherorderer.beefsupply.com 
  

  rm -R $PWD/organizations/ordererOrganizations/rancherorderer.beefsupply.com
  ${CONTAINER_CLI} system prune 
  ${CONTAINER_CLI} volume prune 
}

function RancherOrdererUp () {
  # start rancher nodes
  
  #if [ "$CONTAINER_CLI" == "podman" ]; then
   # cp ../podman/core.yaml ../../organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/
  #fi

  #if [ "${DATABASE}" == "couchdb" ]; then
   # IMAGE_TAG=${IMAGETAG} docker-compose -f $COMPOSE_FILE_RANCHER -f $COMPOSE_FILE_COUCH_RANCHER up -d 2>&1
  #else
    #IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE_RANCHER up -d 2>&1
 # fi
<<comment  
  if [ "${DATABASE}" == "couchdb" ]; then
    COMPOSE_FILES="${COMPOSE_FILES} -f $PWD/addrancher/compose/docker/${COMPOSE_FILE_COUCH_RANCHER}"
    #DOCKER_SOCK=${DOCKER_SOCK} ${CONTAINER_CLI_COMPOSE} -f ${COMPOSE_FILE_BASE} -f $COMPOSE_FILE_ORG3 -f ${COMPOSE_FILE_COUCH_BASE} -f $COMPOSE_FILE_COUCH_ORG3 up -d 2>&1
  else
    DOCKER_SOCK=${DOCKER_SOCK} ${CONTAINER_CLI_COMPOSE} -f ${COMPOSE_FILE_BASE} -f $COMPOSE_FILE_ORG3 up -d 2>&1
  fi
  

  if [ "${DATABASE}" == "couchdb" ]; then
    DOCKER_SOCK=${DOCKER_SOCK} ${CONTAINER_CLI_COMPOSE} -f ${COMPOSE_FILE_RANCHER} -f ${COMPOSE_FILE_COUCH_RANCHER} up -d
    2>&1
  fi
comment
  
  
  if [ "${CONTAINER_CLI}" == "docker" ]; then
    #DOCKER_SOCK=$DOCKER_SOCK ${CONTAINER_CLI_COMPOSE} -f ${COMPOSE_FILE_RANCHER} -f ${COMPOSE_FILE_COUCH_RANCHER} up -d 2>&1
    DOCKER_SOCK=$DOCKER_SOCK ${CONTAINER_CLI_COMPOSE} -f ${COMPOSE_FILE_RANCHER_ORDERER} up -d 2>&1
  elif [ "${CONTAINER_CLI}" == "podman" ]; then
    ${CONTAINER_CLI_COMPOSE} ${COMPOSE_FILES} ${COMPOSE_ORG3_FILES} down --volumes
  else
    fatalln "Container CLI  ${CONTAINER_CLI} not supported"
  fi
  #docker-compose -f ${COMPOSE_FILE_RANCHER} -f ${COMPOSE_FILE_COUCH_RANCHER} up -d 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start RANCHER network"
    exit 1
  fi
}

# Generate the needed certificates, the genesis block and start the network.
function addRancherOrderer () {

  # If the beefchain network is not up, abort
  if [ ! -d ./organizations/ordererOrganizations ]; then
    echo
    echo "ERROR: Please, run ./network.sh up createChannel first."
    echo
    exit 1
  fi

  # generate artifacts if they don't exist
  if [ ! -d "./organizations/ordererOrganizations/rancherorderer.beefsupply.com" ]; then
    generateRancherOrderer
    generateRancherOrdererDefinition
    
  fi
  
  
  infoln "Bringing up Rancher peer"
  RancherOrdererUp
<<comment
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /fabric-tools/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "Bringing up network"
    RancherUp
  fi
comment

  # Use the CLI container to create the configuration transaction needed to add
  # Rancher to the network
  echo
  echo "###############################################################"
  echo "####### Generate and submit config tx to add Rancher #############"
  echo "###############################################################"
  #docker exec Ranchercli ./scripts/rancher-scripts/updateChannelConfig.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE

<<comment  
  . $PWD/blockchain/scripts/envVar.sh
  . $PWD/blockchain/scripts/configUpdate.sh
  . $PWD/blockchain/scripts/utils.sh
  DELAY="3"
  TIMEOUT="10"
  VERBOSE="false"
  COUNTER=1
  MAX_RETRY=5
  OUTPUT="blockchain/channel-artifacts/config.json"
  
  infoln "Creating config transaction to add rancher to network"

  # Fetch the config for the channel, writing it to config.json

<<comment  
  #fetchChannelConfig farmer0 ${CHANNEL_NAME} config.json
  setGlobals farmer0
  path="/opt/gopath/src/github.com/hyperledger/fabric/peer"
  docker cp cli:$path/config_block.pb $PWD/blockchain/channel-artifacts/config_block.pb
  #docker cp cli:config_block.pb /blockchain/channel-artifacts/config_block.pb
  infoln "Fetching the most recent configuration block for the channel"
  set -x
  peer channel fetch config blockchain/channel-artifacts/config_block.pb -o orderer.beefsupply.com:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c $CHANNEL --tls --cafile "$ORDERER_CA"
  { set +x; } 2>/dev/null

  infoln "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  configtxlator proto_decode --input blockchain/channel-artifacts/config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  { set +x; } 2>/dev/null

  # Modify the configuration to append the new org
  set -x
  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"RancherMSP":.[1]}}}}}' blockchain/channel-artifacts/config.json ./organizations/peerOrganizations/rancher.example.com/rancher.json > blockchain/channel-artifacts/modified_config.json
  { set +x; } 2>/dev/null

  # Compute a config update, based on the differences between config.json and modified_config.json, write it as a transaction to rancher_update_in_envelope.pb
  #createConfigUpdate ${CHANNEL_NAME} config.json modified_config.json rancher_update_in_envelope.pb
  ORIGINAL="blockchain/channel-artifacts/config.json"
  MODIFIED="blockchain/channel-artifacts/modified_config.json"
  OUTPUT="blockchain/channel-artifacts/rancher_update_in_envelope.pb"
  set -x
  #configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config --output blockchain/channel-artifacts/config.pb
  #configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config --output blockchain/channel-artifacts/modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original config.pb --updated blockchain/channel-artifacts/modified_config.pb --output blockchain/channel-artifacts/rancher_update.pb
  configtxlator proto_decode --input rancher_update.pb --type common.ConfigUpdate --output rancher_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat rancher_update.json)'}}}' | jq . > blockchain/channel-artifacts/rancher_update_in_envelope.json
  configtxlator proto_encode --input blockchain/channel-artifacts/rancher_update_in_envelope.json --type common.Envelope --output blockchain/channel-artifacts/rancher_update_in_envelope.pb
  { set +x; } 2>/dev/null

  
  #
  infoln "Signing config transaction"
  #signConfigtxAsPeerOrg farmer0 rancher_update_in_envelope.pb
  setGlobals farmer0
  CONFIGTXFILE="blockchain/channel-artifacts/rancher_update_in_envelope.pb"
  set -x
  peer channel signconfigtx -f "${CONFIGTXFILE}"
  { set +x; } 2>/dev/null

  infoln "Submitting transaction from a different peer (peer0.breeder) which also signs it"
  setGlobals breeder0
  set -x
  peer channel update -f blockchain/channel-artifacts/rancher_update_in_envelope.pb -c ${CHANNEL_NAME} -o orderer.beefsupply.com:7050 --ordererTLSHostnameOverride orderer.beefsupply.com --tls --cafile "$ORDERER_CA"
  { set +x; } 2>/dev/null

  successln "Config transaction to add rancher to network submitted"


  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to create config tx"
    exit 1
  fi

  echo
  echo "###############################################################"
  echo "############### Have Rancher peers join network ##################"
  echo "###############################################################"
  #docker exec cli ./scripts/rancher-scripts/joinChannel.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  #./scripts/rancher-scripts/joinChannel.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  setGlobals rancher0
  peer channel fetch 0 $BLOCKFILE -o orderer.beefsupply.com:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c ${CHANNEL_NAME} --tls --cafile "$ORDERER_CA" >&log.txt
  res=$?
  { set +x; } 2>/dev/null
  cat log.txt
  verifyResult $res "Fetching config block from orderer has failed"
  
  
  infoln "Joining rancher peer to the channel..."
  #setGlobals rancher0
  FABRIC_CFG_PATH=$PWD/blockchain/configtx/
  BLOCKFILE="./blockchain/channel-artifacts/${CHANNEL_NAME}.block"
  COUNTER=1
  MAX_RETRY=5
  #CHANNEL_NAME"tracechannel"
  DELAY="3"
  TIMEOUT="10"
  VERBOSE="false"
  ORG="breeder0"
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
  
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to have Rancher peers join network"
    exit 1
  fi
  #setAnchorPeer rancher0
  ORG="rancher0"
  ./blockchain/scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME
comment
  #path="/opt/gopath/src/github.com/hyperledger/fabric/peer"
  
  #${CONTAINER_CLI} cp $PWD/blockchain/channel-artifacts/${CHANNEL_NAME}.block cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/${CHANNEL_NAME}.block
  #${CONTAINER_CLI} cp ./addrancherorderer/rancherordererscripts cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/rancherordererscripts/
  infoln "Generating and submitting config tx to add Org3"
  #${CONTAINER_CLI} exec cli ./rancherscripts/updateChannelConfig.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  ./addrancherorderer/rancherordererscripts/modifyChannelConfigNoCLI.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  if [ $? -ne 0 ]; then
    fatalln "ERROR !!!! Unable to create config tx"
  fi
  
  #setGlobals rancher0
  #setGlobalsCLI rancher0

  infoln "Joining Rancher peers to network"
  #${CONTAINER_CLI} exec cli ./rancherscripts/joinChannel.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  #./addrancherorderer/rancherordererscripts/joinChannelNoCLI.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  #if [ $? -ne 0 ]; then
  #  fatalln "ERROR !!!! Unable to join Org3 peers to network"
  #fi
  #sleep 5
  #read -p "Press enter to continue"
  #./addrancherorderer/rancherordererscripts/onboardChannelConfigNoCLI.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  #if [ $? -ne 0 ]; then
   # fatalln "ERROR !!!! Unable to join Org3 peers to network"
  #fi
  

}

# Tear down running network
function networkDown () {

    cd ..
    ./network.sh down
}


. blockchain/scripts/envVar.sh
. blockchain/scripts/configUpdate.sh
. blockchain/scripts/utils.sh

# Obtain the OS and Architecture string that will be used to select the correct
# native binaries for your platform
OS_ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up

# Using crpto vs CA. default is cryptogen

#CRYPTO="cryptogen"

CRYPTO="Certificate Authorities"

CLI_TIMEOUT=10
#default for delay
CLI_DELAY=3
# channel name defaults to "tracechannel"
CHANNEL_NAME="tracechannel"
# use this as the docker compose couch file
#COMPOSE_FILE_COUCH_RANCHER=$PWD/addrancher/compose/docker/docker-compose-couch-rancher.yaml
# use this as the default docker-compose yaml definition
COMPOSE_FILE_RANCHER_ORDERER=$PWD/addrancherorderer/compose/docker/docker-compose-rancher.yaml
# certificate authorities compose file
COMPOSE_FILE_CA_RANCHER_ORDERER=$PWD/addrancherorderer/compose/docker/docker-compose-ca-rancher.yaml
# default image tag
IMAGETAG="latest"
# default ca image tag
CA_IMAGETAG="latest"
# database
#DATABASE="leveldb"
DATABASE="couchdb"
# Parse commandline args

## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  shift
fi

# parse flags

while [[ $# -ge 1 ]] ; do
  key="$1"
  case $key in
  -h )
    printHelp
    exit 0
    ;;
  -c )
    CHANNEL_NAME="$2"
    shift
    ;;
  -ca )
    CRYPTO="Certificate Authorities"
    ;;
  -t )
    CLI_TIMEOUT="$2"
    shift
    ;;
  -d )
    CLI_DELAY="$2"
    shift
    ;;
  -s )
    DATABASE="$2"
    shift
    ;;
  -i )
    IMAGETAG=$(go env GOARCH)"-""$2"
    shift
    ;;
  -cai )
    CA_IMAGETAG="$2"
    shift
    ;;
  -verbose )
    VERBOSE=true
    shift
    ;;
  * )
    echo
    echo "Unknown flag: $key"
    echo
    printHelp
    exit 1
    ;;
  esac
  shift
done


: ${CONTAINER_CLI:="docker"}
: ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}
infoln "Using ${CONTAINER_CLI} and ${CONTAINER_CLI_COMPOSE}"



# Determine whether starting, stopping, restarting or generating for announce
if [ "$MODE" == "up" ]; then
  echo "Add Rancher to channel '${CHANNEL_NAME}' with '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds and using database '${DATABASE}'"
  echo
elif [ "$MODE" == "down" ]; then
  EXPMODE="Stopping network"
elif [ "$MODE" == "remove" ]; then
  EXPMODE="Removing network"
elif [ "$MODE" == "generate" ]; then
  EXPMODE="Generating certs and organization definition for Rancher"
else
  printHelp
  exit 1
fi

#Create the network using docker compose
if [ "${MODE}" == "up" ]; then
  addRancherOrderer
elif [ "${MODE}" == "down" ]; then ## Clear the network
  networkDown
elif [ "${MODE}" == "remove" ]; then ## Generate Artifacts
  removeRancherOrderer
elif [ "${MODE}" == "generate" ]; then ## Generate Artifacts
  generateRancherOrderer
  generateRancherOrdererDefinition
else
  printHelp
  exit 1
fi
