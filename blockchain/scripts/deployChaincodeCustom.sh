#!/bin/bash

source blockchain/scripts/utils.sh

CHANNEL_NAME=${1:-"tracechannel"}
CC_NAME=${2}
CC_SRC_PATH=${3}
CC_SRC_LANGUAGE=${4}
CC_VERSION=${5:-"1.0"}
CC_SEQUENCE=${6:-"1"}
CC_INIT_FCN=${7:-"NA"}
CC_END_POLICY=${8:-"NA"}
CC_COLL_CONFIG=${9:-"NA"}
DELAY=${10:-"3"}
MAX_RETRY=${11:-"5"}
VERBOSE=${12:-"false"}

println "executing with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_PATH: ${C_GREEN}${CC_SRC_PATH}${C_RESET}"
println "- CC_SRC_LANGUAGE: ${C_GREEN}${CC_SRC_LANGUAGE}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"
println "- CC_SEQUENCE: ${C_GREEN}${CC_SEQUENCE}${C_RESET}"
println "- CC_END_POLICY: ${C_GREEN}${CC_END_POLICY}${C_RESET}"
println "- CC_COLL_CONFIG: ${C_GREEN}${CC_COLL_CONFIG}${C_RESET}"
println "- CC_INIT_FCN: ${C_GREEN}${CC_INIT_FCN}${C_RESET}"
println "- DELAY: ${C_GREEN}${DELAY}${C_RESET}"
println "- MAX_RETRY: ${C_GREEN}${MAX_RETRY}${C_RESET}"
println "- VERBOSE: ${C_GREEN}${VERBOSE}${C_RESET}"

INIT_REQUIRED="--init-required"
# check if the init fcn should be called
if [ "$CC_INIT_FCN" = "NA" ]; then
  INIT_REQUIRED=""
fi

if [ "$CC_END_POLICY" = "NA" ]; then
  CC_END_POLICY=""
else
  CC_END_POLICY="--signature-policy $CC_END_POLICY"
fi

if [ "$CC_COLL_CONFIG" = "NA" ]; then
  CC_COLL_CONFIG=""
else
  CC_COLL_CONFIG="--collections-config $CC_COLL_CONFIG"
fi


source ${PWD}/blockchain/OrgConfigurations/configtx_path.sh
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export PATH=$PATH:/usr/local/go/bin
export PATH=${ROOTDIR}/blockchain/bin:${PWD}/blockchain/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/blockchain/configtx/$CONFIGTX_FOLDER_PATH
export VERBOSE=false

#FABRIC_CFG_PATH=$PWD/blockchain/config/

# import utils
. blockchain/scripts/envVar.sh
. blockchain/scripts/ccutilsCustom.sh

function checkPrereqs() {
  jq --version > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    errorln "jq command not found..."
    errorln
    errorln "Follow the instructions in the Fabric docs to install the prereqs"
    errorln "https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html"
    exit 1
  fi
}

#check for prerequisites
checkPrereqs

## package the chaincode
./blockchain/scripts/packageCC.sh $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION 

PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CC_NAME}.tar.gz)


SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source $SCRIPT_DIR/../OrgConfigurations/chaincode_path.sh
echo $CHANNEL_FOLDER_PATH
readarray -t lines < $SCRIPT_DIR/../OrgConfigurations/ChannelOrgConfig/$CHAINCODE_FOLDER_PATH/installChaincodeOrgsCustom.txt
# Display the lines
export USE_CHAINCODE_NAME=${lines[0]}
export USE_ORDERER=${lines[1]}
export USE_MAIN_ORG=${lines[2]}
export USE_ORGANIZATIONS=${lines[3]}
echo $USE_CHANNEL_NAME
echo $USE_ORDERER
echo $USE_MAIN_ORG
echo $USE_ORGANIZATIONS


IFS=',' read -ra ORG_ARRAY <<< "$USE_ORGANIZATIONS"
for org in "${ORG_ARRAY[@]}"; do
   echo "Processing organization: $org"
    # Add your processing logic here
   infoln "Installing chaincode on peer0.$org..."
   installChaincode $org
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   LAST_ORG=$org
done

resolveSequence


IFS=',' read -ra ORG_ARRAY <<< "$USE_ORGANIZATIONS"
for org in "${ORG_ARRAY[@]}"; do
   echo "Processing organization: $org"
    # Add your processing logic here
   infoln "Querying chaincode on peer0.$org..."
   queryInstalled $org 
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   LAST_ORG=$org
done


IFS=',' read -ra ORG_ARRAY <<< "$USE_ORGANIZATIONS"
for org in "${ORG_ARRAY[@]}"; do
   echo "Processing organization: $org"
    # Add your processing logic here
   infoln "Approving chaincode on peer0.$org..."
   approveForMyOrg $org $USE_ORDERER
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   LAST_ORG=$org
done

commitChaincodeDefinition "${ORG_ARRAY[@]}"

IFS=',' read -ra ORG_ARRAY <<< "$USE_ORGANIZATIONS"
for org in "${ORG_ARRAY[@]}"; do
   echo "Processing organization: $org"
    # Add your processing logic here
   infoln "Querying chaincode on peer0.$org..."
   queryCommitted $org 
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   LAST_ORG=$org
done


IFS=',' read -ra ORG_ARRAY <<< "$USE_ORGANIZATIONS"
for org in "${ORG_ARRAY[@]}"; do
   echo "Processing organization: $org"
    # Add your processing logic here
   infoln "Querying chaincode on peer0.$org..."
   queryCommitted $org 
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   #signConfigtxAsPeerOrg farmer0 ${customOrg}_update_in_envelope.pb
   LAST_ORG=$org
done


#commitChaincodeDefinition farmer0 breeder0

## Install chaincode on peer0.org1 and peer0.org2
#infoln "Installing chaincode on peer0.farmer..."
#installChaincode farmer0
#infoln "Install chaincode on peer0.breeder..."
#installChaincode breeder0

#resolveSequence

## query whether the chaincode is installed
#queryInstalled farmer0

## approve the definition for org1
#approveForMyOrg farmer0

## check whether the chaincode definition is ready to be committed
## expect org1 to have approved and org2 not to
#checkCommitReadiness farmer0 "\"FarmerMSP\": true" "\"BreederMSP\": false"
#checkCommitReadiness breeder0 "\"FarmerMSP\": true" "\"BreederMSP\": false"

## now approve also for org2
#approveForMyOrg breeder0

## check whether the chaincode definition is ready to be committed
## expect them both to have approved
#checkCommitReadiness farmer0 "\"FarmerMSP\": true" "\"BreederMSP\": true"
#checkCommitReadiness breeder0 "\"FarmerMSP\": true" "\"BreederMSP\": true"

## now that we know for sure both orgs have approved, commit the definition
#commitChaincodeDefinition farmer0 breeder0

## query on both orgs to see that the definition committed successfully
#queryCommitted farmer0
#queryCommitted breeder0

## Invoke the chaincode - this does require that the chaincode have the 'initLedger'
## method defined
if [ "$CC_INIT_FCN" = "NA" ]; then
  infoln "Chaincode initialization is not required"
else
  chaincodeInvokeInit manager0_0 regulator0_0
fi

exit 0