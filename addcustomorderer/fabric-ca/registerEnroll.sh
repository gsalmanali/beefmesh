#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

function createCustomOrderer {
	infoln "Enrolling the CA admin"
	mkdir -p organizations/ordererOrganizations/$customOrg.beefsupply.com

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:$CUSTOM_CA_SERVER_PORT --caname ca-$customOrg --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

<<COMMENT
  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-rancherorderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-rancherorderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-rancherorderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-rancherorderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/msp/config.yaml"
COMMENT

 
customConfig=`cat <<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-$CUSTOM_CA_SERVER_PORT-ca-$customOrg.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-$CUSTOM_CA_SERVER_PORT-ca-$customOrg.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-$CUSTOM_CA_SERVER_PORT-ca-$customOrg.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-$CUSTOM_CA_SERVER_PORT-ca-$customOrg.pem
    OrganizationalUnitIdentifier: orderer'
EOF
` 

echo "${customConfig}" > "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/msp/config.yaml"


  mkdir -p "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/msp/tlscacerts/tlsca.$customOrg.beefsupply.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/tlsca/tlsca.$customOrg.beefsupply.com-cert.pem"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-$customOrg --id.name $customOrg --id.secret ${customOrg}pw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-$customOrg --id.name ${customOrg}Admin --id.secret ${customOrg}Adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://$customOrg:${customOrg}pw@localhost:$CUSTOM_CA_SERVER_PORT --caname ca-$customOrg -M "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://$customOrg:${customOrg}pw@localhost:$CUSTOM_CA_SERVER_PORT --caname ca-$customOrg -M "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/tls" --enrollment.profile tls --csr.hosts $customOrg.beefsupply.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/orderers/$customOrg.beefsupply.com/msp/tlscacerts/tlsca.$customOrg.beefsupply.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://${customOrg}Admin:${customOrg}Adminpw@localhost:$CUSTOM_CA_SERVER_PORT --caname ca-$customOrg -M "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/users/Admin@$customOrg.beefsupply.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/$customOrg.beefsupply.com/users/Admin@$customOrg.beefsupply.com/msp/config.yaml"
}





