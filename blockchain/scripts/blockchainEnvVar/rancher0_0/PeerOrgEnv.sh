#!/bin/bash

set_variables() {
    export CORE_PEER_LOCALMSPID="RancherMSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/rancher.beefsupply.com/users/Admin@rancher.beefsupply.com/msp
    export CORE_PEER_ADDRESS=localhost:11051

}

set_variables


