#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# import utils
. blockchain/scripts/envVar.sh
. blockchain/scripts/configUpdate.sh


# NOTE: this must be run in a CLI container since it requires jq and configtxlator 
createAnchorPeerUpdate() {
  infoln "Fetching channel config for channel $CHANNEL_NAME"
  #fetchChannelConfig $ORG $CHANNEL_NAME ${CORE_PEER_LOCALMSPID}config.json
  #setGlobals rancher0
  #setGlobals manager0
  #setGlobalsCLI farmer0
  docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/config_block.pb blockchain/channel-artifacts/config_block.pb
  infoln "Fetching the most recent configuration block for the channel"
  set -x
  peer channel fetch config blockchain/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c $CHANNEL_NAME --tls --cafile "$ORDERER_CA"
  { set +x; } 2>/dev/null
  
  infoln "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  #configtxlator proto_decode --input blockchain/channel-artifacts/config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  configtxlator proto_decode --input blockchain/channel-artifacts/config_block.pb --type common.Block --output blockchain/channel-artifacts/config_block.json
  
  #jq '.channel_group.groups.Application.groups.RancherMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.rancher.beefsupply.com","port": 11051}]},"version": "0"}}' config.json > modified_anchor_config.json
  
  jq ".data.data[0].payload.data.config" blockchain/channel-artifacts/config_block.json > blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}config.json
  { set +x; } 2>/dev/null
  
  infoln "Generating anchor peer update transaction for ${ORG} on channel $CHANNEL_NAME"

  if [ $ORG = "manager0" ]; then
    HOST="peer0.manager.beefsupply.com"
    PORT=7051
  elif [ $ORG = "regulator0" ]; then
    HOST="peer0.regulator.beefsupply.com"
    PORT=9051
  elif [ $ORG = "regulator1" ]; then
    HOST="peer1.regulator.beefsupply.com"
    PORT=12051
  elif [ $ORG = "rancher0" ]; then
    HOST="peer0.rancher.beefsupply.com"
    PORT=11051
  elif [ $ORG = "salman0" ]; then
    HOST="peer0.salman.beefsupply.com"
    PORT=11051
  else
    errorln "${ORG} unknown"
  fi

  # Modify the configuration to append the anchor peer 
  jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST'","port": '$PORT'}]},"version": "0"}}' blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}config.json > blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}modified_config.json
  { set +x; } 2>/dev/null

  # Compute a config update, based on the differences between 
  # {orgmsp}config.json and {orgmsp}modified_config.json, write
  # it as a transaction to {orgmsp}anchors.tx
  #createConfigUpdate ${CHANNEL_NAME} ${CORE_PEER_LOCALMSPID}config.json ${CORE_PEER_LOCALMSPID}modified_config.json ${CORE_PEER_LOCALMSPID}anchors.tx
  
  
  ORIGINAL="blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}config.json"
  MODIFIED="blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}modified_config.json"
  #OUTPUT="blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}rancher_update_in_envelope.pb"
  #OUTPUT="blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx"
  echo $CHANNEL_NAME
  echo $CHANNEL
   set -x
  #configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config --output blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}config.pb
  #configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config --output blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}config.pb --updated blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}modified_config.pb --output blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}_update.pb
  configtxlator proto_decode --input blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}_update.pb --type common.ConfigUpdate --output blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL}'", "type":2}},"data":{"config_update":'$(cat blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}_update.json)'}}}' | jq . > blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}_update_in_envelope.json
  configtxlator proto_encode --input blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}_update_in_envelope.json --type common.Envelope --output blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}_update_in_envelope.pb
  { set +x; } 2>/dev/null

  
  
}

updateAnchorPeer() {
  #peer channel update -o orderer.beefsupply.com:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c $CHANNEL_NAME -f ${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile "$ORDERER_CA" >&log.txt
  
  peer channel update -f blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}_update_in_envelope.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.beefsupply.com -c $CHANNEL_NAME --tls --cafile "$ORDERER_CA" >&log.txt
  res=$?
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  successln "Anchor peer set for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME'"
}

ORG=$1
CHANNEL_NAME=$2
CHANNEL=$CHANNEL_NAME
OUTPUT="blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}_update_in_envelope.pb"

setGlobals $ORG

 echo $CORE_PEER_ADDRESS
    echo $CORE_PEER_MSPCONFIGPATH
    echo $CORE_PEER_LOCALMSPID
    echo $CORE_PEER_TLS_ROOTCERT_FILE
    echo $FABRIC_CFG_PATH


OUTPUT="blockchain/channel-artifacts/${CORE_PEER_LOCALMSPID}_update_in_envelope.pb"

createAnchorPeerUpdate 

setGlobals $ORG

updateAnchorPeer 
