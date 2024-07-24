#!/bin/bash

set_variables() {
    export CORE_PEER_LOCALMSPID="RegulatorMSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/users/Admin@regulator.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

set_variables


