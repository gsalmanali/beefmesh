declare -x CORE_PEER_TLS_ENABLED="true"
declare -x CORE_PEER_LOCALMSPID="RancherOrdererMSP"
declare -x CORE_PEER_TLS_ROOTCERT_FILE="$PWD/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/ca.crt"
declare -x CORE_PEER_MSPCONFIGPATH="$PWD/organizations/ordererOrganizations/rancherorderer.beefsupply.com/users/Admin@rancherorderer.beefsupply.com/msp"
declare -x CORE_PEER_ADDRESS="localhost:7049"

