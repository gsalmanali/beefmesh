#!/bin/bash


channel_name=$1
echo "Executing osnadmin command!"
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
source $SCRIPT_DIR/../OrgConfigurations/channel_path.sh
echo $CHANNEL_FOLDER_PATH
readarray -t lines < $SCRIPT_DIR/../OrgConfigurations/ChannelOrgConfig/$CHANNEL_FOLDER_PATH/createChannelOrgs.txt

# Display the lines
export USE_ORDERER=${lines[1]}

source $PWD/blockchain/scripts/blockchainEnvVar/orderers/$USE_ORDERER/OrdererCertEnv.sh

#export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.crt /dev/null 2>&1
#export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/server.key /dev/null 2>&1

osnadmin channel join --channelID ${channel_name} --config-block ./blockchain/channel-artifacts/${channel_name}.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" >> log.txt 2>&1
