#!/bin/bash

set_variables() {
    export ORDERER_CA="${PWD}/organizations/ordererOrganizations/customOrg.beefsupply.com/tlsca/tlsca.customOrg.beefsupply.com-cert.pem"
    export ORDERER_ADMIN_TLS_SIGN_CERT="${PWD}/organizations/ordererOrganizations/customOrg.beefsupply.com/orderers/customOrg.beefsupply.com/tls/server.crt" 
    export ORDERER_ADMIN_TLS_PRIVATE_KEY="${PWD}/organizations/ordererOrganizations/customOrg.beefsupply.com/orderers/customOrg.beefsupply.com/tls/server.key"
}

set_variables



