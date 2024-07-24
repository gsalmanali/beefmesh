#!/bin/bash

set_variables() {
    #export CORE_PEER_TLS_ENABLED="true"
    #export CORE_PEER_LOCALMSPID="RancherOrdererMSP"
    #export CORE_PEER_TLS_ROOTCERT_FILE="$PWD/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/ca.crt"
    #export CORE_PEER_MSPCONFIGPATH="$PWD/organizations/ordererOrganizations/rancherorderer.beefsupply.com/users/Admin@rancherorderer.beefsupply.com/msp"
    export CORE_ORDERER_PEER_ADDRESS="localhost:7048"
    export CORE_ORDERER_CONTAINER_ADDRESS="saraorderer.beefsupply.com"
    export CORE_ORDERER_ADMIN_LISTEN_ADDRESS="localhost:7063"
    
}

set_variables


