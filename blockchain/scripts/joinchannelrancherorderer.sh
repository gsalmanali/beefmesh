#!/bin/bash


channel_name=$1
echo "Executing osnadmin command!"
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.crt 
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.key 
export RANCHER_ORDERER_CA=${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/tlsca/tlsca.rancherorderer.beefsupply.com-cert.pem

osnadmin channel join --channelID ${channel_name} --config-block ./blockchain/channel-artifacts/${channel_name}.block -o localhost:7043--ca-file "$RANCHER_ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" 
#>> log.txt 2>&1

osnadmin channel list -o localhost:7049 --ca-file "$RANCHER_ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" --channelID ${channel_name}

#osnadmin channel list -c mychannel -o localhost:7061 --ca-file "$OSN_TLS_CA_ROOT_CERT" --client-cert "$ADMIN_TLS_SIGN_CERT" --client-key "$ADMIN_TLS_PRIVATE_KEY"


