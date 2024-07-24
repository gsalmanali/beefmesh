#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
function createCustomPeer() {
  infoln "Enrolling the CA admin"
  #mkdir -p organizations/peerOrganizations/$customOrg.beefsupply.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/
  echo $FABRIC_CA_CLIENT_HOME
  echo $FABRIC_CFG_PATH
  echo $ORDERER_CA
  echo $CORE_PEER_LOCALMSPID
  
<<COMMENT
  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-$customOrg --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/ca-cert1.pem"
  { set +x; } 2>/dev/null


  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-regulator.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-regulator.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-regulator.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-regulator.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/msp/config1.yaml"
    
COMMENT


  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy regulator's CA cert to regulator's /msp/tlscacerts directory (for use in the channel MSP definition)
  #mkdir -p "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/msp/tlscacerts"
 # cp "${PWD}/organizations/fabric-ca/regulator/ca-cert1.pem" "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/msp/tlscacerts/ca1.crt"

  # Copy regulator's CA cert to regulator's /tlsca directory (for use by clients)
  #mkdir -p "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/tlsca"
 # cp "${PWD}/organizations/fabric-ca/regulator/ca-cert1.pem" "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/tlsca/tlsca.regulator.beefsupply.com-cert1.pem"

  # Copy regulator's CA cert to regulator's /ca directory (for use by clients)
  #mkdir -p "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/ca"
 # cp "${PWD}/organizations/fabric-ca/regulator/ca-cert1.pem" "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/ca/ca.regulator.beefsupply.com-cert1.pem"
  

  infoln "Registering peer1"
  set -x
  #fabric-ca-client register --caname ca-regulator --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  #fabric-ca-client register --caname ca-regulator --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  #fabric-ca-client register --caname ca-regulator --id.name peer1 --id.secret peer1pw -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/users/Admin@regulator.beefsupply.com/msp" --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  fabric-ca-client register --caname ca-$customOrg --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

<<COMMENT
  infoln "Registering user2"
  set -x
  #fabric-ca-client register --caname ca-regulator --id.name user2 --id.secret user2pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  fabric-ca-client register --caname ca-regulator --id.name user2 --id.secret user2pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/tls-cert.pem"
  { set +x; } 2>/dev/null
COMMENT

<<COMMENT

  infoln "Registering the org admin1"
  set -x
  fabric-ca-client register --caname ca-regulator --id.name regulatoradmin1 --id.secret regulatoradmin1pw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  { set +x; } 2>/dev/null
  
COMMENT

  #rm organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com

  mkdir -p organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer1.$customOrg.beefsupply.com

  infoln "Generating the peer1 msp"
  set -x
  #fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  #fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/msp" --csr.hosts peer1.regulator.beefsupply.com --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/tls-cert.pem"
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:${CUSTOM_CA_SERVER_PORT} --caname ca-$customOrg -M "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer1.$customOrg.beefsupply.com/msp" --csr.hosts peer1.$customOrg.beefsupply.com --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer1.$customOrg.beefsupply.com/msp/config.yaml"

  infoln "Generating the peer1-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  #fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls" --enrollment.profile tls --csr.hosts peer1.regulator.beefsupply.com --csr.hosts localhost -csr.hosts 127.0.0.1 --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:${CUSTOM_CA_SERVER_PORT} --caname ca-$customOrg -M "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer1.$customOrg.beefsupply.com/tls" --enrollment.profile tls --csr.hosts peer1.$customOrg.beefsupply.com   --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/$customOrg/ca-cert.pem"
 #--csr.hosts 127.0.0.1 --csr.hosts 0.0.0.0 
  { set +x; } 2>/dev/null
#--csr.hosts 'localhost,127.0.0.1'
#--csr.hosts "localhost,127.0.0.1,0.0.0.0"
<<COMMENT 
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls" --enrollment.profile tls --csr.hosts peer1.regulator.beefsupply.com --csr.hosts peer1.regulator.beefsupply.com --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  { set +x; } 2>/dev/null
COMMENT

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer1.$customOrg.beefsupply.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer1.$customOrg.beefsupply.com/tls/ca.crt"
  
  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer1.$customOrg.beefsupply.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer1.$customOrg.beefsupply.com/tls/server.crt"
  
  cp "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer1.$customOrg.beefsupply.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/$customOrg.beefsupply.com/peers/peer1.$customOrg.beefsupply.com/tls/server.key"
  


<<COMMENT

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user2:user2pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/users/User2@regulator.beefsupply.com/msp" --csr.hosts peer1.regulator.beefsupply.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/users/User2@regulator.beefsupply.com/msp/config.yaml"


  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://regulatoradmin1:regulatoradmin1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/users/Admin1@regulator.beefsupply.com/msp" --csr.hosts peer1.regulator.beefsupply.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/users/Admin1@regulator.beefsupply.com/msp/config.yaml"
  
COMMENT
}


function recreateRegulatorPeer() {
  infoln "Enrolling the CA admin"
  #mkdir -p organizations/peerOrganizations/regulator.beefsupply.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/
  echo $FABRIC_CA_CLIENT_HOME
  
  infoln "Registering peer1"
  set -x
  #fabric-ca-client register --caname ca-regulator --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  fabric-ca-client register --caname ca-regulator --id.name peer2 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/tls-cert.pem"
  { set +x; } 2>/dev/null

<<COMMENT
  infoln "Registering user2"
  set -x
  #fabric-ca-client register --caname ca-regulator --id.name user2 --id.secret user2pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  fabric-ca-client register --caname ca-regulator --id.name user2 --id.secret user2pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/tls-cert.pem"
  { set +x; } 2>/dev/null
COMMENT

<<COMMENT

  infoln "Registering the org admin1"
  set -x
  fabric-ca-client register --caname ca-regulator --id.name regulatoradmin1 --id.secret regulatoradmin1pw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  { set +x; } 2>/dev/null
  
COMMENT

  #rm organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com

  mkdir -p organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com

  infoln "Generating the peer1 msp"
  set -x
  #fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  #fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/msp" --csr.hosts peer1.regulator.beefsupply.com --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/tls-cert.pem"
  
  fabric-ca-client enroll -u https://peer2:peer1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/users/Admin@regulator.beefsupply.com/msp" --csr.hosts peer1.regulator.beefsupply.com --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/msp/config.yaml"

  infoln "Generating the peer1-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  #fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls" --enrollment.profile tls --csr.hosts peer1.regulator.beefsupply.com --csr.hosts localhost -csr.hosts 127.0.0.1 --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  fabric-ca-client enroll -u https://peer2:peer1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls" --enrollment.profile tls --csr.hosts peer1.regulator.beefsupply.com   --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/tls-cert.pem"
#  --csr.hosts 127.0.0.1 --csr.hosts 0.0.0.0
  
  { set +x; } 2>/dev/null
#--csr.hosts 'localhost,127.0.0.1'
#--csr.hosts "localhost,127.0.0.1,0.0.0.0"
<<COMMENT 
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-regulator -M "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls" --enrollment.profile tls --csr.hosts peer1.regulator.beefsupply.com --csr.hosts peer1.regulator.beefsupply.com --tls.certfiles "${PWD}/organizations/fabric-ca/regulator/ca-cert.pem"
  { set +x; } 2>/dev/null
COMMENT

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/regulator.beefsupply.com/peers/peer1.regulator.beefsupply.com/tls/server.key"
  

}
