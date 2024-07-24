#!/bin/bash

set_variables() {
    export CORE_PEER_TLS_ENABLED="true"
    export CORE_PEER_LOCALMSPID="customORGMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE="$PWD/organizations/ordererOrganizations/customOrg.beefsupply.com/orderers/customOrg.beefsupply.com/tls/ca.crt"
    export CORE_PEER_MSPCONFIGPATH="$PWD/organizations/ordererOrganizations/customOrg.beefsupply.com/users/Admin@customOrg.beefsupply.com/msp"
    export CORE_PEER_ADDRESS="localhost:CUSTOM_ORDERER_GENERAL_LISTEN_PORT"
    
}

set_variables
