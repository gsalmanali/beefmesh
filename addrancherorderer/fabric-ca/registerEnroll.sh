#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

function createRancherOrderer {
	infoln "Enrolling the CA admin"
	mkdir -p organizations/ordererOrganizations/rancherorderer.beefsupply.com

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:12054 --caname ca-rancherorderer --tls.certfiles "${PWD}/organizations/fabric-ca/rancherorderer/ca-cert.pem"
  { set +x; } 2>/dev/null

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
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/msp/config.yaml"

	mkdir -p "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/rancherorderer/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/msp/tlscacerts/tlsca.rancherorderer.beefsupply.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/rancherorderer/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/tlsca/tlsca.rancherorderer.beefsupply.com-cert.pem"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-rancherorderer --id.name rancherorderer --id.secret rancherordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/rancherorderer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-rancherorderer --id.name rancherordererAdmin --id.secret rancherordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/rancherorderer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://rancherorderer:rancherordererpw@localhost:12054 --caname ca-rancherorderer -M "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/rancherorderer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://rancherorderer:rancherordererpw@localhost:12054 --caname ca-rancherorderer -M "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls" --enrollment.profile tls --csr.hosts rancherorderer.beefsupply.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/rancherorderer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/orderers/rancherorderer.beefsupply.com/msp/tlscacerts/tlsca.rancherorderer.beefsupply.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://rancherordererAdmin:rancherordererAdminpw@localhost:12054 --caname ca-rancherorderer -M "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/users/Admin@rancherorderer.beefsupply.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/rancherorderer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/rancherorderer.beefsupply.com/users/Admin@rancherorderer.beefsupply.com/msp/config.yaml"
}





