declare -x CORE_PEER_TLS_ENABLED="true"
declare -x CORE_PEER_LOCALMSPID="OrdererMSP"
declare -x CORE_PEER_TLS_ROOTCERT_FILE="$PWD/organizations/ordererOrganizations/beefsupply.com/orderers/orderer.beefsupply.com/tls/ca.crt"
declare -x CORE_PEER_MSPCONFIGPATH="$PWD/organizations/ordererOrganizations/beefsupply.com/users/Admin@beefsupply.com/msp"
declare -x CORE_PEER_ADDRESS="localhost:7050"

