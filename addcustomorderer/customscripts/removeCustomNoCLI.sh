#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# This script is designed to be run in the cli container as the
# first step of the EYFN tutorial.  It creates and submits a
# configuration transaction to add org3 to the test network
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
CHANNEL=${CHANNEL_NAME}

OUTPUT="blockchain/channel-artifacts/config.json"


# imports
. blockchain/scripts/envVar.sh
. blockchain/scripts/configUpdate.sh
. blockchain/scripts/utils.sh

infoln "Creating config transaction to add org3 to network"


SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source $SCRIPT_DIR/../../blockchain/OrgConfigurations/channel_path.sh
echo $CHANNEL_FOLDER_PATH
readarray -t lines < $SCRIPT_DIR/../../blockchain/OrgConfigurations/ChannelOrgConfig/$CHANNEL_FOLDER_PATH/removeChannelOrgsOrderer.txt
# Display the lines
export USE_CHANNEL_NAME=${lines[0]}
export USE_ORDERER=${lines[1]}
export USE_MAIN_ORG=${lines[2]}
export USE_ORGANIZATIONS=${lines[3]}
export USE_ORDERERS=${lines[4]}
echo $USE_CHANNEL_NAME
echo $USE_ORDERER
echo $USE_MAIN_ORG
echo $USE_ORGANIZATIONS
echo $USE_ORDERERS



#setGlobals manager0
#setGlobalsCLI rancher0
# Fetch the config for the channel, writing it to config.json
#fetchChannelConfig rancher0 ${CHANNEL_NAME} config.json

 setGlobals $USE_MAIN_ORG
  #docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/config_block.pb blockchain/channel-artifacts/config_block.pb
  
   source $SCRIPT_DIR/../../blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
  source $SCRIPT_DIR/../../blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
   set -x
  peer channel fetch config blockchain/channel-artifacts/config_block.pb -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS  -c $CHANNEL_NAME --tls --cafile "$ORDERER_CA"
  { set +x; } 2>/dev/null
  
  infoln "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  #configtxlator proto_decode --input blockchain/channel-artifacts/config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  configtxlator proto_decode --input blockchain/channel-artifacts/config_block.pb --type common.Block --output blockchain/channel-artifacts/config_block.json
  jq ".data.data[0].payload.data.config" blockchain/channel-artifacts/config_block.json > blockchain/channel-artifacts/config.json
  { set +x; } 2>/dev/null

  [ -f blockchain/channel-artifacts/modified_config.json ] && rm file blockchain/channel-artifacts/modified_config.json
# Modify the configuration to remove the new org


set -x
 export temp=$(if [ "$(uname -s)" == "Linux" ]; then echo "-w 0"; else echo "-b 0"; fi)
 cert=$(cat ./organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/tls/server.crt | base64 $temp)

cat blockchain/channel-artifacts/config.json | jq '.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters -= [{"client_tls_cert": "'$cert'", "host": "'$customOrg'.beefsupply.com", "port": '${CUSTOM_ORDERER_GENERAL_LISTEN_PORT}', "server_tls_cert": "'$cert'"}] ' > blockchain/channel-artifacts/modified_config1.json
#cat blockchain/channel-artifacts/config.json | jq 'del(.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters. [{"client_tls_cert": "'$cert'", "host": "rancherorderer.beefsupply.com", "port": 7049, "server_tls_cert": "'$cert'"}])' > blockchain/channel-artifacts/modified_config1.json

#LENGTH=$(jq '.channel_group.values.OrdererAddresses.value.addresses | length' blockchain/channel-artifacts/modified_config2.json)
  #jq '.channel_group.values.OrdererAddresses.value.addresses['${LENGTH}'] |= "rancherorderer.beefsupply.com:7049"' blockchain/channel-artifacts/modified_config2.json > blockchain/channel-artifacts/modified_config3.json
  
jq '.channel_group.values.OrdererAddresses.value.addresses -= ["'$customOrg'.beefsupply.com:'${CUSTOM_ORDERER_GENERAL_LISTEN_PORT}'"] ' blockchain/channel-artifacts/modified_config1.json > blockchain/channel-artifacts/modified_config2.json
#jq 'del(.channel_group.values.OrdererAddresses.value.addresses.["rancherorderer.beefsupply.com:7049"])' blockchain/channel-artifacts/modified_config1.json > blockchain/channel-artifacts/modified_config2.json


jq 'del(.channel_group.groups.Orderer.groups.'${customORG}'Org)' blockchain/channel-artifacts/modified_config2.json > blockchain/channel-artifacts/modified_config.json 


 ORIGINAL="blockchain/channel-artifacts/config.json"
  MODIFIED="blockchain/channel-artifacts/modified_config.json"
  OUTPUT="blockchain/channel-artifacts/${customOrg}_update_in_envelope.pb"
  echo $CHANNEL_NAME
  echo $CHANNEL
   set -x
  #configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config --output blockchain/channel-artifacts/config.pb
  #configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config --output blockchain/channel-artifacts/modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original blockchain/channel-artifacts/config.pb --updated blockchain/channel-artifacts/modified_config.pb --output blockchain/channel-artifacts/${customOrg}_update.pb
  configtxlator proto_decode --input blockchain/channel-artifacts/${customOrg}_update.pb --type common.ConfigUpdate --output blockchain/channel-artifacts/${customOrg}_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL}'", "type":2}},"data":{"config_update":'$(cat blockchain/channel-artifacts/${customOrg}_update.json)'}}}' | jq . > blockchain/channel-artifacts/${customOrg}_update_in_envelope.json
  configtxlator proto_encode --input blockchain/channel-artifacts/${customOrg}_update_in_envelope.json --type common.Envelope --output blockchain/channel-artifacts/${customOrg}_update_in_envelope.pb
  { set +x; } 2>/dev/null


#jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"RancherMSP":.[1]}}}}}' config.json ./organizations/peerOrganizations/rancher.beefsupply.com/rancher.json > modified_config.json


# Compute a config update, based on the differences between config.json and modified_config.json, write it as a transaction to org3_update_in_envelope.pb
echo $CHANNEL_NAME

#createConfigUpdate ${CHANNEL_NAME} config.json modified_config.json rancher_update_in_envelope.pb


infoln "Signing config transaction"
#signConfigtxAsPeerOrg manager0 rancher_update_in_envelope.pb


IFS=',' read -ra ORG_ARRAY <<< "$USE_ORGANIZATIONS"
for org in "${ORG_ARRAY[@]}"; do
    echo "Processing organization: $org"
    # Add your processing logic here
   infoln "Signing config transaction"
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   
  setGlobals $org
  CONFIGTXFILE="blockchain/channel-artifacts/${customOrg}_update_in_envelope.pb"
  set -x
  peer channel signconfigtx -f "${CONFIGTXFILE}"
  { set +x; } 2>/dev/null
  LAST_ORG=$org
done


  
IFS=',' read -ra ORG_ARRAY <<< "$USE_ORDERERS"
for org in "${ORG_ARRAY[@]}"; do
    echo "Processing organization: $org"
    # Add your processing logic here
   infoln "Signing config transaction"
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   
  #setGlobals $org
  CONFIGTXFILE="blockchain/channel-artifacts/${customOrg}_update_in_envelope.pb"
  
  
  source blockchain/scripts/blockchainEnvVar/orderers/$org/OrdererCertEnv.sh
  source blockchain/scripts/blockchainEnvVar/orderers/$org/OrdererCommEnv.sh
  set -x
  peer channel signconfigtx -f "${CONFIGTXFILE}"
  { set +x; } 2>/dev/null
  LAST_ORDERER=$org
done


  source blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
  source blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCommEnv.sh
   source blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
   
   
   # peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c ${CHANNEL_NAME} -f blockchain/channel-artifacts/rancher_orderer_update_in_envelope.pb --tls --cafile "$ORDERER_CA"
    
    peer channel update -c ${CHANNEL_NAME} -f blockchain/channel-artifacts/${customOrg}_update_in_envelope.pb -o $CORE_ORDERER_PEER_ADDRESS --ordererTLSHostnameOverride $CORE_ORDERER_CONTAINER_ADDRESS --tls --cafile "$ORDERER_CA"



<<COMMENT
setGlobals manager0
CONFIGTXFILE="blockchain/channel-artifacts/${customOrg}_update_in_envelope.pb"
set -x
peer channel signconfigtx -f "${CONFIGTXFILE}"
{ set +x; } 2>/dev/null
setGlobals regulator0
#CONFIGTXFILE="blockchain/channel-artifacts/rancher_update_in_envelope.pb"
set -x
peer channel signconfigtx -f "${CONFIGTXFILE}"
{ set +x; } 2>/dev/null
echo "Executing osnadmin command!"
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.crt 
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.key 
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/tlsca/tlsca.beefsupply.com-cert.pem

   
source blockchain/scripts/blockchainEnvVar/orderers/OrdererEnv.sh
  
  set -x
  peer channel signconfigtx -f "${CONFIGTXFILE}"
  { set +x; } 2>/dev/null
  

  
  echo "Executing osnadmin command!"
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/${customOrg}.beefsupply.com/orderers/${customOrg}.beefsupply.com/tls/server.crt 
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/${customOrg}.beefsupply.com/orderers/${customOrg}.beefsupply.com/tls/server.key 
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/${customOrg}.beefsupply.com/tlsca/tlsca.${customOrg}.beefsupply.com-cert.pem


#source blockchain/scripts/blockchainEnvVar/orderers/RancherOrdererEnv.sh

  set -x
  peer channel signconfigtx -f "${CONFIGTXFILE}"
  { set +x; } 2>/dev/null
   

   set -x
    
   echo "Executing osnadmin command!"
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.crt 
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.key 
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/tlsca/tlsca.beefsupply.com-cert.pem
   
   source blockchain/scripts/blockchainEnvVar/orderers/OrdererEnv.sh
   
   
#peer channel update -f blockchain/channel-artifacts/rancher_update_in_envelope.pb -c ${CHANNEL_NAME} -o localhost:7050 --ordererTLSHostnameOverride orderer.beefsupply.com --tls --cafile "$ORDERER_CA"
 peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c ${CHANNEL_NAME} -f blockchain/channel-artifacts/rancher_orderer_update_in_envelope.pb --tls --cafile "$ORDERER_CA"
 
 #peer channel update -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f envelope.pb --tls --cafile "$ORDERER_CA"

{ set +x; } 2>/dev/null
infoln "Signing config transaction"
#signConfigtxAsPeerOrg regulator0 rancher_update_in_envelope.pb




echo "Executing osnadmin command!"
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/${customOrg}.beefsupply.com/orderers/${customOrg}.beefsupply.com/tls/server.crt 
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/${customOrg}.beefsupply.com/orderers/${customOrg}.beefsupply.com/tls/server.key 
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/${customOrg}.beefsupply.com/tlsca/tlsca.${customOrg}.beefsupply.com-cert.pem
COMMENT


  source blockchain/scripts/blockchainEnvVar/orderers/$customOrg/OrdererCertEnv.sh
  source blockchain/scripts/blockchainEnvVar/orderers/$customOrg/OrdererCommEnv.sh
   source blockchain/scripts/blockchainEnvVar/orderers/$customOrg/OrdererEnv.sh
   

#source blockchain/scripts/blockchainEnvVar/orderers/RancherOrdererEnv.sh


osnadmin channel remove -o $CORE_ORDERER_ADMIN_LISTEN_ADDRESS --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" --channelID ${CHANNEL_NAME}


<<comment
echo "Executing osnadmin command!"
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.crt 
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.key 
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/tlsca/tlsca.beefsupply.com-cert.pem
#export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/tlsca/tlsca.beefsupply.com-cert.pem

#osnadmin channel join --channelID ${channel_name} --config-block ./blockchain/channel-artifacts/${channel_name}.block -o localhost:7043--ca-file "$RANCHER_ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" 
comment


  source blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh
  source blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCommEnv.sh
   source blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererEnv.sh
   
#>> log.txt 2>&1

osnadmin channel list -o $CORE_ORDERER_ADMIN_LISTEN_ADDRESS --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" --channelID ${CHANNEL_NAME}


#infoln "Submitting transaction from a different peer (peer0.org2) which also signs it"
#setGlobals regulator0
#set -x
#peer channel update -f rancher_update_in_envelope.pb -c ${CHANNEL_NAME} -o orderer.beefsupply.com:7050 --ordererTLSHostnameOverride orderer.beefsupply.com --tls --cafile "$ORDERER_CA"
#{ set +x; } 2>/dev/null



#echo "Checking who has joined channel here"
#setGlobalsCLI manager0
#peer channel list
#setGlobalsCLI regulator0
#peer channel list
#setGlobalsCLI rancher0
#peer channel list