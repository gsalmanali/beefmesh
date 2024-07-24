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
  set -x
  peer channel fetch config blockchain/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c $CHANNEL --tls --cafile "$ORDERER_CA"
  { set +x; } 2>/dev/null
  
  infoln "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  #configtxlator proto_decode --input blockchain/channel-artifacts/config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  configtxlator proto_decode --input blockchain/channel-artifacts/config_block.pb --type common.Block --output blockchain/channel-artifacts/config_block.json
  jq ".data.data[0].payload.data.config" blockchain/channel-artifacts/config_block.json > blockchain/channel-artifacts/config.json
  { set +x; } 2>/dev/null

# Modify the configuration to append the new org
set -x
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"RancherMSP":.[1]}}}}}' blockchain/channel-artifacts/config.json ./organizations/peerOrganizations/rancher.beefsupply.com/rancher.json > blockchain/channel-artifacts/modified_config.json
{ set +x; } 2>/dev/null

  ORIGINAL="blockchain/channel-artifacts/config.json"
  MODIFIED="blockchain/channel-artifacts/modified_config.json"
  OUTPUT="blockchain/channel-artifacts/rancher_update_in_envelope.pb"
  echo $CHANNEL_NAME
  echo $CHANNEL
   set -x
  #configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config --output blockchain/channel-artifacts/config.pb
  #configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config --output blockchain/channel-artifacts/modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original blockchain/channel-artifacts/config.pb --updated blockchain/channel-artifacts/modified_config.pb --output blockchain/channel-artifacts/rancher_update.pb
  configtxlator proto_decode --input blockchain/channel-artifacts/rancher_update.pb --type common.ConfigUpdate --output blockchain/channel-artifacts/rancher_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL}'", "type":2}},"data":{"config_update":'$(cat blockchain/channel-artifacts/rancher_update.json)'}}}' | jq . > blockchain/channel-artifacts/rancher_update_in_envelope.json
  configtxlator proto_encode --input blockchain/channel-artifacts/rancher_update_in_envelope.json --type common.Envelope --output blockchain/channel-artifacts/rancher_update_in_envelope.pb
  { set +x; } 2>/dev/null


# Compute a config update, based on the differences between config.json and modified_config.json, write it as a transaction to org3_update_in_envelope.pb
#createConfigUpdate ${CHANNEL_NAME} config.json modified_config.json rancher_update_in_envelope.pb

infoln "Signing config transaction"
#signConfigtxAsPeerOrg farmer0 rancher_update_in_envelope.pb
#signConfigtxAsPeerOrg farmer0 rancher_update_in_envelope.pb
  setGlobals manager0_0
  CONFIGTXFILE="blockchain/channel-artifacts/rancher_update_in_envelope.pb"
  set -x
  peer channel signconfigtx -f "${CONFIGTXFILE}"
  { set +x; } 2>/dev/null
  
  setGlobals regulator0_0
  #CONFIGTXFILE="blockchain/channel-artifacts/rancher_update_in_envelope.pb"
  set -x
  peer channel signconfigtx -f "${CONFIGTXFILE}"
  { set +x; } 2>/dev/null

infoln "Submitting transaction from a different peer (peer0.org2) which also signs it"
setGlobals regulator0_0
set -x
peer channel update -f blockchain/channel-artifacts/rancher_update_in_envelope.pb -c ${CHANNEL_NAME} -o localhost:7050 --ordererTLSHostnameOverride orderer.beefsupply.com --tls --cafile "$ORDERER_CA"
{ set +x; } 2>/dev/null

successln "Config transaction to add rancher to network submitted"
