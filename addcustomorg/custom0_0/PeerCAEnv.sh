#!/bin/bash

set_variables() {
    export CORE_PEER_TLS_ROOTCERT_FILE="${PWD}/organizations/peerOrganizations/customOrg.beefsupply.com/peers/peer0.customOrg.beefsupply.com/tls/ca.crt"


}

set_variables
