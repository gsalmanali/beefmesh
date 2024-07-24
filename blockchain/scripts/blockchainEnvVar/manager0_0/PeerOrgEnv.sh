#!/bin/bash

set_variables() {
    export CORE_PEER_LOCALMSPID="ManagerMSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/manager.beefsupply.com/users/Admin@manager.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

set_variables
