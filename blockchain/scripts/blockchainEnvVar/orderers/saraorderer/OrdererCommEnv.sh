#!/bin/bash

set_variables() {
    export CORE_PEER_TLS_ENABLED="true"
    export CORE_PEER_LOCALMSPID="SaraOrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE="$PWD/organizations/ordererOrganizations/saraorderer.beefsupply.com/orderers/saraorderer.beefsupply.com/tls/ca.crt"
    export CORE_PEER_MSPCONFIGPATH="$PWD/organizations/ordererOrganizations/saraorderer.beefsupply.com/users/Admin@saraorderer.beefsupply.com/msp"
    export CORE_PEER_ADDRESS="localhost:7048"
    
}

set_variables
