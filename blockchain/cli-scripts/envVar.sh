#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
./blockchain/scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/tlsca/tlsca.beefsupply.com-cert.pem
#export ORDERER_CA=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/msp/tlscacerts/tlsca.beefsupply.com-cert.pem
export PEER0_FARMER_CA=${PWD}/organizations/peerOrganizations/farmer.beefsupply.com/tlsca/tlsca.farmer.beefsupply.com-cert.pem
export PEER0_BREEDER_CA=${PWD}/organizations/peerOrganizations/breeder.beefsupply.com/tlsca/tlsca.breeder.beefsupply.com-cert.pem
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/org3.beefsupply.com/tlsca/tlsca.org3.beefsupply.com-cert.pem

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG = "farmer0" ]; then
    export CORE_PEER_LOCALMSPID="FarmerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_FARMER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmer.beefsupply.com/users/Admin@farmer.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG = "breeder0" ]; then
    export CORE_PEER_LOCALMSPID="BreederMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BREEDER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/breeder.beefsupply.com/users/Admin@breeder.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.beefsupply.com/users/Admin@org3.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG = "farmer0" ]; then
    export CORE_PEER_ADDRESS=peer0.farmer.beefsupply.com:7051
  elif [ $USING_ORG = "breeer0" ]; then
    export CORE_PEER_ADDRESS=peer0.breeder.beefsupply.com:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_ADDRESS=peer0.org3.beefsupply.com:11051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    if [ "$1" = "farmer0" ]; then
      CA=PEER0_FARMER_CA
    elif [ "$1" = "breeder0" ]; then
      CA=PEER0_BREEDER_CA
    else
      errorln "Issues with setting of CA directory"
    fi
    #CA=PEER0_ORG$1_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
