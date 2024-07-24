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

# imports
. blockchain/scripts/envVar.sh
. blockchain/scripts/configUpdate.sh
. blockchain/scripts/utils.sh

  DELAY="3"
  TIMEOUT="10"
  VERBOSE="false"
  COUNTER=1
  MAX_RETRY=5
  OUTPUT="blockchain/channel-artifacts/config.json"
  

infoln "Creating config transaction to add org3 to network"

# Fetch the config for the channel, writing it to config.json
#fetchChannelConfig farmer0 ${CHANNEL_NAME} config.json

  setGlobals manager0_0
  #setGlobalsCLI farmer0
  #docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/config_block.pb blockchain/channel-artifacts/config_block.pb
  infoln "Fetching the most recent configuration block for the channel"
  
  
  [ -f blockchain/channel-artifacts/config_block.pb ] && rm file blockchain/channel-artifacts/config_block.pb
  set -x
  peer channel fetch config blockchain/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c $CHANNEL --tls --cafile "$ORDERER_CA"
  { set +x; } 2>/dev/null
  
  
  #echo $customOrg
  #echo $CUSTOM_ORDERER_ADMIN_LISTEN_PORT
  echo $ORDERER_CA
  echo $ORDERER_ADMIN_TLS_PRIVATE_KEY
  echo $ORDERER_ADMIN_TLS_SIGN_CERT
  

  echo "Executing osnadmin command!"
  export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
  export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.crt 
  export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.key 
  export ORDERER_CA=${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/tlsca/tlsca.rancherorderer.beefsupply.com-cert.pem
  
  
  echo $ORDERER_CA
  echo $ORDERER_ADMIN_TLS_PRIVATE_KEY
  echo $ORDERER_ADMIN_TLS_SIGN_CERT
  
  #{PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  
  osnadmin channel join --channelID $CHANNEL --config-block blockchain/channel-artifacts/config_block.pb -o localhost:7043 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY > blockchain/channel-artifacts/logs.txt

  
  infoln "Decoding config block to JSON and isolating config to ${OUTPUT}"
  #set -x
  #configtxlator proto_decode --input blockchain/channel-artifacts/config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  configtxlator proto_decode --input blockchain/channel-artifacts/config_block.pb --type common.Block --output blockchain/channel-artifacts/config_block.json
  jq ".data.data[0].payload.data.config" blockchain/channel-artifacts/config_block.json > blockchain/channel-artifacts/config.json
  
  [ -f blockchain/channel-artifacts/modified_config.json ] && rm file blockchain/channel-artifacts/modified_config.json
  #cp blockchain/channel-artifacts/config.json blockchain/channel-artifacts/modified_config.json
  
  #python3 $PWD/blockchain/scripts/add_new_orderer_to_config.py blockchain/channel-artifacts/config.json blockchain/channel-artifacts/modified_config.json \
#-a rancherorderer.beefsupply.com:7049 \
#-i ./organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/msp/signcerts/cert.pem \
#-s ./organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/msp/tlscacerts/tlsca.rancherorderer.beefsupply.com-cert.pem \
#-c ./organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/msp/tlscacerts/tlsca.rancherorderer.beefsupply.com-cert.pem
  
  
  #jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"RancherOrdererOrg":.[1]}}}}}' blockchain/channel-artifacts/config.json organizations/ordererOrganizations/rancherorderer.beefsupply.com/rancherorderer.json > blockchain/channel-artifacts/modified-config1.json 

  
  jq -s '.[0] * {"channel_group":{"groups":{"Orderer":{"groups": {"RancherOrdererOrg":.[1]}}}}}' blockchain/channel-artifacts/config.json organizations/ordererOrganizations/rancherorderer.beefsupply.com/rancherorderer.json > blockchain/channel-artifacts/modified_config2.json
  
  
  LENGTH=$(jq '.channel_group.values.OrdererAddresses.value.addresses | length' blockchain/channel-artifacts/modified_config2.json)
  echo "LENGTH: $LENGTH"
  jq '.channel_group.values.OrdererAddresses.value.addresses['${LENGTH}'] |= "rancherorderer.beefsupply.com:7049"' blockchain/channel-artifacts/modified_config2.json > blockchain/channel-artifacts/modified_config3.json

  
  
  export temp=$(if [ "$(uname -s)" == "Linux" ]; then echo "-w 0"; else echo "-b 0"; fi)
  cert=$(cat ./organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.crt | base64 $temp)
  #cert=$(cat ./organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/msp/tlscacerts/tlsca.rancherorderer.beefsupply.com-cert.pem | base64 $temp)
  identity=$(cat ./organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/msp/signcerts/cert.pem | base64 $temp)
  
  #cat blockchain/channel-artifacts/modified_config3.json | jq '.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [{"client_tls_cert": "'$cert'", "host": "rancherorderer.beefsupply.com", "id": 2, "identity": "'$identity'",  "msp_id": "RancherOrdererMSP", "port": 7049, "server_tls_cert": "'$cert'"}] ' > blockchain/channel-artifacts/modified_config.json
  
  cat blockchain/channel-artifacts/modified_config3.json | jq '.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [{"client_tls_cert": "'$cert'", "host": "rancherorderer.beefsupply.com", "port": 7049, "server_tls_cert": "'$cert'"}] ' > blockchain/channel-artifacts/modified_config.json
  
  #cat blockchain/channel-artifacts/modified_config3.json | jq '.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [{"client_tls_cert": "'$cert'", "host": "rancherorderer.beefsupply.com", "port": 7049, "server_tls_cert": "'$cert'"}] ' > blockchain/channel-artifacts/modified_config.json
 
  
  #LENGTH=$(jq '.channel_group.values.OrdererAddresses.value.addresses | length' modified-config2.json)
  #jq '.channel_group.values.OrdererAddresses.value.addresses['${LENGTH}'] |= "'${KL_NEW_ORDERER_URL}'"' modified-config2.json > modified-config3.json

  #cert=`base64 /hl-material/mk01-orderer/crypto-config/ordererOrganizations/${KL_DOMAIN}/orderers/orderer.mk01.${KL_DOMAIN}/tls/server.crt | sed ':a;N;$!ba;s/\n//g'`
  #cat modified-config3.json | jq '.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [{"client_tls_cert": "'$cert'", "host": "raft0.mk01.'${KL_DOMAIN}'", "port": 32050, "server_tls_cert": "'$cert'"}] ' > modified-config4.json

  
  #jq -s '.[0] * {"channel_group":{"groups":{"Consortiums":{"groups":{"'${KL_CONSORTIUM_NAME}'":{"groups": {"Orderermk01MSP":.[1]}}}}}}}' modified-config1.json  ${KL_NEW_ORDERER_NAME}.json > modified-config2.json  
  
  
  #jq -s '.[0] * {"channel_group":{"groups":{"Orderer":{"groups": {"Org3":.[1]}}}}}' config.json org3org.json > config1.json
  #{ set +x; } 2>/dev/null

# Modify the configuration to append the new org
#set -x
#jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"RancherMSP":.[1]}}}}}' blockchain/channel-artifacts/config.json ./organizations/peerOrganizations/rancher.beefsupply.com/rancher.json > blockchain/channel-artifacts/modified_config.json
#{ set +x; } 2>/dev/null

  ORIGINAL="blockchain/channel-artifacts/config.json"
  MODIFIED="blockchain/channel-artifacts/modified_config.json"
  OUTPUT="blockchain/channel-artifacts/rancher_orderer_update_in_envelope.pb"
  echo $CHANNEL_NAME
  echo $CHANNEL
   set -x
  #configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config --output blockchain/channel-artifacts/config.pb
  #configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config --output blockchain/channel-artifacts/modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original blockchain/channel-artifacts/config.pb --updated blockchain/channel-artifacts/modified_config.pb --output blockchain/channel-artifacts/rancher_orderer_update.pb
  configtxlator proto_decode --input blockchain/channel-artifacts/rancher_orderer_update.pb --type common.ConfigUpdate --output blockchain/channel-artifacts/rancher_orderer_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL}'", "type":2}},"data":{"config_update":'$(cat blockchain/channel-artifacts/rancher_orderer_update.json)'}}}' | jq . > blockchain/channel-artifacts/rancher_orderer_update_in_envelope.json
  configtxlator proto_encode --input blockchain/channel-artifacts/rancher_orderer_update_in_envelope.json --type common.Envelope --output blockchain/channel-artifacts/rancher_orderer_update_in_envelope.pb
  { set +x; } 2>/dev/null


# Compute a config update, based on the differences between config.json and modified_config.json, write it as a transaction to org3_update_in_envelope.pb
#createConfigUpdate ${CHANNEL_NAME} config.json modified_config.json rancher_update_in_envelope.pb
  sleep 5
  infoln "Signing config transaction"
#signConfigtxAsPeerOrg farmer0 rancher_update_in_envelope.pb
#signConfigtxAsPeerOrg farmer0 rancher_update_in_envelope.pb
  echo "Executing osnadmin command!"
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.crt 
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.key 
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/tlsca/tlsca.beefsupply.com-cert.pem
  setGlobals manager0_0
  #source $PWD/blockchain/scripts/blockchainEnvVar/orderers/OrdererEnvironment.sh
  CONFIGTXFILE="blockchain/channel-artifacts/rancher_orderer_update_in_envelope.pb"
  set -x
  peer channel signconfigtx -f "${CONFIGTXFILE}"
  { set +x; } 2>/dev/null
  
  setGlobals regulator0_0
  #source $PWD/blockchain/scripts/blockchainEnvVar/orderers/RancherOrdererEnv.sh
  CONFIGTXFILE="blockchain/channel-artifacts/rancher_update_in_envelope.pb"
  set -x
  peer channel signconfigtx -f "${CONFIGTXFILE}"
  { set +x; } 2>/dev/null
  
  infoln "Submitting transaction from a different peer (peer0.org2) which also signs it"
  #setGlobals regulator0
  source blockchain/scripts/blockchainEnvVar/orderers/OrdererEnv.sh
  #set -x
  #peer channel update -f blockchain/channel-artifacts/rancher_orderer_update_in_envelope.pb -c ${CHANNEL_NAME} -o localhost:7050 --ordererTLSHostnameOverride     orderer.beefsupply.com --tls --cafile "$ORDERER_CA"
  
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c ${CHANNEL_NAME} -f blockchain/channel-artifacts/rancher_orderer_update_in_envelope.pb --tls --cafile "$ORDERER_CA"

  #{ set +x; } 2>/dev/null

  successln "Config transaction to add rancher to network submitted"
  
 

  sleep 5
  
echo "Executing osnadmin command!"
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.crt 
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.key 
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/tlsca/tlsca.rancherorderer.beefsupply.com-cert.pem
#export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/tlsca/tlsca.beefsupply.com-cert.pem

#osnadmin channel join --channelID ${channel_name} --config-block ./blockchain/channel-artifacts/${channel_name}.block -o localhost:7043--ca-file "$RANCHER_ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" 
#>> log.txt 2>&1

osnadmin channel list -o localhost:7043 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" --channelID ${CHANNEL_NAME}

sleep 5

osnadmin channel list -o localhost:7043 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" --channelID ${CHANNEL_NAME}

sleep 5

osnadmin channel list -o localhost:7043 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" --channelID ${CHANNEL_NAME}



echo "Executing osnadmin command!"
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.crt 
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.key 
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/tlsca/tlsca.beefsupply.com-cert.pem

osnadmin channel list -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" --channelID ${CHANNEL_NAME}

