#!/bin/bash

set_variables() {
    export ORDERER_CA="${PWD}/organizations/ordererOrganizations/saraorderer.beefsupply.com/tlsca/tlsca.saraorderer.beefsupply.com-cert.pem"
    export ORDERER_ADMIN_TLS_SIGN_CERT="${PWD}/organizations/ordererOrganizations/saraorderer.beefsupply.com/orderers/saraorderer.beefsupply.com/tls/server.crt" 
    export ORDERER_ADMIN_TLS_PRIVATE_KEY="${PWD}/organizations/ordererOrganizations/saraorderer.beefsupply.com/orderers/saraorderer.beefsupply.com/tls/server.key"
}

set_variables



