#!/bin/bash

set_variables() {
    export CORE_PEER_LOCALMSPID="customORGMSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/customOrg.beefsupply.com/users/Admin@customOrg.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:CUSTOM_CORE_PEER_ADDRESS_PORT

}

set_variables


