#!/bin/bash

set_variables() {
    export ORDERER_CA="${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/tlsca/tlsca.rancherorderer.beefsupply.com-cert.pem"
    export ORDERER_ADMIN_TLS_SIGN_CERT="${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.crt" 
    export ORDERER_ADMIN_TLS_PRIVATE_KEY="${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.key"
}

set_variables



