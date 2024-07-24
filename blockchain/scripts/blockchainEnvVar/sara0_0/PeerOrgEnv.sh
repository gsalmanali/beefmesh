#!/bin/bash

set_variables() {
    export CORE_PEER_LOCALMSPID="SaraMSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/sara.beefsupply.com/users/Admin@sara.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:27051

}

set_variables


