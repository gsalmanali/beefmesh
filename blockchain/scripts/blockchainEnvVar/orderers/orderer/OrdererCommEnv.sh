#!/bin/bash

set_variables() {
    export CORE_PEER_TLS_ENABLED="true"
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE="$PWD/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/ca.crt"
    export CORE_PEER_MSPCONFIGPATH="$PWD/organizations/ordererOrganizations/beefsupply.com/users/Admin@beefsupply.com/msp"
    export CORE_PEER_ADDRESS="localhost:7050"
    
}

set_variables
