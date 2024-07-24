#!/bin/bash

set_variables() {
    export CORE_PEER_TLS_ROOTCERT_FILE="${PWD}/organizations/peerOrganizations/manager.beefsupply.com/peers/peer0.manager.beefsupply.com/tls/ca.crt"
}

set_variables
