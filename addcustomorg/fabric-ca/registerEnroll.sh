#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

function createCustomOrg {

#: ${customOrg:="cedric"}
#: ${CustomORG:="Cedric"}

	infoln "Enrolling the CA admin"
	mkdir -p organizations/peerOrganizations/$customOrg.beefsupply.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:$CUSTOM_CA_SERVER_PORT --caname ca-$customOrg --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/tls-cert.pem"
  { set +x; } 2>/dev/null
  
  
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

echo "${customConfig}" > "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/msp/config.yaml"

<<EOF
echo "${customConfig}" > "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/msp/config.yaml"

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-rancher.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-rancher.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-rancher.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-rancher.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/msp/config.yaml"
EOF

	infoln "Registering peer0"
  set -x
	fabric-ca-client register --caname ca-$customOrg --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-$customOrg --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-$customOrg --id.name ${customOrg}admin --id.secret ${customOrg}adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:$CUSTOM_CA_SERVER_PORT  --caname ca-$customOrg -M "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:$CUSTOM_CA_SERVER_PORT  --caname ca-$customOrg -M "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/tls" --enrollment.profile tls --csr.hosts peer0.$customOrg.beefsupply.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/tls-cert.pem"
  { set +x; } 2>/dev/null


  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/tls/server.key"

  mkdir "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/msp/tlscacerts/ca.crt"

  mkdir "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/tlsca/tlsca.$customOrg.beefsupply.com-cert.pem"

  mkdir "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/ca"
  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer0.$customOrg.beefsupply.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/ca/ca.$customOrg.beefsupply.com-cert.pem"

  infoln "Generating the user msp"
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:$CUSTOM_CA_SERVER_PORT  --caname ca-$customOrg -M "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/users/User1@$customOrg.beefsupply.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/users/User1@$customOrg.beefsupply.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
	fabric-ca-client enroll -u https://${customOrg}admin:${customOrg}adminpw@localhost:$CUSTOM_CA_SERVER_PORT  --caname ca-$customOrg -M "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/users/Admin@$customOrg.beefsupply.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/users/Admin@$customOrg.beefsupply.com/msp/config.yaml"
}
