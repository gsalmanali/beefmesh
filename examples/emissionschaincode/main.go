/*
 SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/golang/protobuf/ptypes"
	"github.com/hyperledger/fabric-chaincode-go/pkg/statebased"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

const (
	typeAnimalForSale     = "ForSale"
	typeAnimalBid         = "OfferBid"
	typeAnimalSaleReceipt = "SaleReceipt"
	typeAnimalBuyReceipt  = "BuyReceipt"
)

type SmartContract struct {
	contractapi.Contract
}

type QueryResult struct {
	Record    *Animal
	TxId      string    `json:"txId"`
	Timestamp time.Time `json:"timestamp"`
}

type Agreement struct {
	AnimalID      string `json:"animal_id"`
	Price   int    `json:"price"`
	TransferID string `json:"transfer_id"`
}

// Animal struct and properties must be exported (start with capitals) to work with contract api metadata
type Animal struct {
	AnimalType        string `json:"animalType"` // AnimalType is used to distinguish different object types in the same chaincode namespace
	AnimalID                string `json:"animalID"`
	CurrentOwner          string `json:"currentOwner"`
        FarmerData         string `json:"farmerData "`
        FarmerTrace         string `json:"farmerTrace "`
        BreederData         string `json:"breederData"`
        BreederTrace         string `json:"breederTrace"`
        ProcessorData         string `json:"processorData"`
        ProcessorTrace         string `json:"processorTrace"`
        DistributorData         string `json:"distributorData"`
        DistributorTrace         string `json:"distributorTrace"`
        RetailerData         string `json:"retailerData"`
        RetailerTrace         string `json:"retailerTrace"`
        RegulatorData         string `json:"regulatorData"`
        RegulatorTrace         string `json:"regulatorTrace"`
        ConsumerData         string `json:"consumerData"`
        ConsumerTrace         string `json:"consumerTrace"`
	OpenDescription string `json:"openDescription"`
}

/*
type AnimalWhat struct {
	AnimalType        string `json:"animalType"` // AnimalType is used to distinguish different object types in the same chaincode namespace
	AnimalID                string `json:"animalID"`
	CurrentOwner          string `json:"currentOwner"`
        FarmerWhat        string `json:"farmerWhat "`
        BreederWhat         string `json:"breederWhat"`
        ProcessorWhat        string `json:"processorWhat"`
        DistributorWhat        string `json:"distributorWhat"`
        RetailerWhat         string `json:"retailerWhat"`
        RegulatorWhat         string `json:"regulatorWhat"`
        ConsumerWhat        string `json:"consumerWhat"`
	WhatDescription string `json:"whatDescription"`
}


*/

type receipt struct {
	price     int
	timestamp time.Time
}



// Create animal creates an animal and sets it as owned by the client's org
func (s *SmartContract) CreateAnimal(ctx contractapi.TransactionContextInterface, openDescription, farmerData, farmerTrace, breederData, breederTrace,  processorData, processorTrace, distributorData, distributorTrace, retailerData, retailerTrace, regulatorData, regulatorTrace, consumerData, consumerTrace string) (string, error) {
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return "", fmt.Errorf("error getting transient: %v", err)
	}

	// animal properties must be retrieved from the transient field as they are private
	immutablePropertiesJSON, ok := transientMap["animal_properties"]
	if !ok {
		return "", fmt.Errorf("animal_properties key not found in the transient map")
	}

        // AnimalID will be the hash of the animal's properties
	hash := sha256.New()
	hash.Write(immutablePropertiesJSON)
	animalID := hex.EncodeToString(hash.Sum(nil))

	// Get client org id and verify it matches peer org id.
	// In this scenario, client is only authorized to read/write private data from its own peer.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return "", fmt.Errorf("failed to get verified OrgID: %v", err)
	}

        // In this scenario, client is only authorized to read/write private data from its own peer, therefore verify client org id matches peer org id.
	err = verifyClientOrgMatchesPeerOrg(clientOrgID)
	if err != nil {
		return "", err
	}

	animal := Animal{
		AnimalType:        "animal",
		AnimalID:          animalID,
		CurrentOwner:      clientOrgID,
		OpenDescription:   openDescription,
                FarmerData:        farmerData,
                FarmerTrace:       farmerTrace,
                BreederData:       breederData,
                BreederTrace:      breederTrace,
                ProcessorData:     processorData,
                ProcessorTrace:    processorTrace,
                DistributorData:   distributorData,
                DistributorTrace:  distributorTrace,
                RetailerData:      retailerData,
                RetailerTrace:     retailerTrace,
                RegulatorData:     regulatorData,
                RegulatorTrace:    regulatorTrace,
                ConsumerData:      consumerData,
                ConsumerTrace:     consumerTrace,
	}

	animalBytes, err := json.Marshal(animal)
	if err != nil {
		return "", fmt.Errorf("failed to create animal JSON: %v", err)
	}

   

	err = ctx.GetStub().PutState(animal.AnimalID, animalBytes)
	if err != nil {
		return "", fmt.Errorf("failed to put animal in open database: %v", err)
	}

   

	// Set the endorsement policy such that an owner org peer is required to endorse future updates
	//err = setAnimalStateBasedEndorsement(ctx, animal.AnimalID, clientOrgID)
	//if err != nil {
	//	return "", fmt.Errorf("failed setting state based endorsement for owner: %v", err)
	//}

   
        endorsingOrgs := []string{clientOrgID}
        err = setAnimalStateBasedEndorsement(ctx, animal.AnimalID, endorsingOrgs)
	if err != nil {
		return "", fmt.Errorf("failed setting state based endorsement for buyer and seller: %v", err)
	}

	// Persist private immutable animal properties to owner's private data collection
	collection := buildCollectionName(clientOrgID)
	err = ctx.GetStub().PutPrivateData(collection, animalID, immutablePropertiesJSON)
	if err != nil {
		return "", fmt.Errorf("failed to put Animal private details: %v", err)
	}


	return animalID, nil
}

/*
func (s *SmartContract) CreateAnimalWhat(ctx contractapi.TransactionContextInterface, animalID, whatDescription, farmerWhat, breederWhat, processorWhat, distributorWhat, retailerWhat, regulatorWhat, consumerWhat string) error {

        clientOrgID, err := getClientOrgID(ctx, false)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}
        animalid, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animalid.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animalid.CurrentOwner)
	}


        //animal.OpenDescription = newDescription
	//updatedAnimalJSON, err := json.Marshal(animal)
	//if err != nil {
	//	return fmt.Errorf("failed to marshal animal: %v", err)
	//}
//
	//return ctx.GetStub().PutState(animalID, updatedAnimalJSON)

	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return fmt.Errorf("error getting transient: %v", err)
	}

	// animal properties must be retrieved from the transient field as they are private
	immutablePropertiesJSON, ok := transientMap["animal_properties"]
	if !ok {
		return fmt.Errorf("animal_properties key not found in the transient map")
	}

	// Get client org id and verify it matches peer org id.
	// In this scenario, client is only authorized to read/write private data from its own peer.

	animalwhat := AnimalWhat{
		AnimalType:        "animal",
		AnimalID:          animalID,
		CurrentOwner:      clientOrgID,
		WhatDescription:   whatDescription,
                FarmerWhat:        farmerWhat,
                BreederWhat:       breederWhat,
                ProcessorWhat:     processorWhat,
                DistributorWhat:   distributorWhat,
                RetailerWhat:      retailerWhat,
                RegulatorWhat:     regulatorWhat,
                ConsumerWhat:      consumerWhat,
	}

	animalBytes, err := json.Marshal(animalwhat)
	if err != nil {
		return fmt.Errorf("failed to create animal JSON: %v", err)
	}

   

	err = ctx.GetStub().PutState(animalwhat.AnimalID, animalBytes)
	if err != nil {
		return fmt.Errorf("failed to put animal in open database: %v", err)
	}

   

	// Set the endorsement policy such that an owner org peer is required to endorse future updates
	err = setAnimalStateBasedEndorsement(ctx, animalwhat.AnimalID, clientOrgID)
	if err != nil {
		return fmt.Errorf("failed setting state based endorsement for owner: %v", err)
	}

   

	// Persist private immutable animal properties to owner's private data collection
	collection := buildCollectionName(clientOrgID)
	err = ctx.GetStub().PutPrivateData(collection, animalwhat.AnimalID, immutablePropertiesJSON)
	if err != nil {
		return fmt.Errorf("failed to put Animal private details: %v", err)
	}


	return nil
}
*/



// ChangePublicDescription updates the animal public description. Only the current owner can update the public description
func (s *SmartContract) ChangeOpenDescription(ctx contractapi.TransactionContextInterface, animalID string, newDescription string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.OpenDescription = newDescription
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}


func (s *SmartContract) ChangeFarmerData(ctx contractapi.TransactionContextInterface, animalID string, newFarmerData string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.FarmerData = newFarmerData
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}

//func (s *SmartContract) ChangeFarmerWhat(ctx contractapi.TransactionContextInterface, animalID string, newFarmerWhat string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
        //func agreeToPrice(ctx contractapi.TransactionContextInterface, animalID string, priceType string) error 
	//clientOrgID, err := getClientOrgID(ctx, true)
	//if err != nil {
	//	return fmt.Errorf("failed to get verified OrgID: %v", err)
	//}

	//animalwhat, err := s.ReadAnimal(ctx, animalID)
	//if err != nil {
	//	return fmt.Errorf("failed to get animal: %v", err)
	//}

	// Auth check to ensure that client's org actually owns the animal
	//if clientOrgID != animalwhat.CurrentOwner {
	//	return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animalwhat.CurrentOwner)
	//}

	//animalwhat.FarmerWhat = newFarmerWhat
	//updatedAnimalJSON, err := json.Marshal(animalwhat)
	//if err != nil {
	//	return fmt.Errorf("failed to marshal animal: %v", err)
	//}

	//return ctx.GetStub().PutState(animalID, updatedAnimalJSON)

       
//}

func (s *SmartContract) ChangeFarmerTrace(ctx contractapi.TransactionContextInterface, animalID string, newFarmerTrace string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.FarmerTrace = newFarmerTrace
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}


func (s *SmartContract) ChangeBreederData(ctx contractapi.TransactionContextInterface, animalID string, newBreederData string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.BreederData = newBreederData
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}

func (s *SmartContract) ChangeBreederTrace(ctx contractapi.TransactionContextInterface, animalID string, newBreederTrace string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.BreederTrace = newBreederTrace
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}


func (s *SmartContract) ChangeProcessorData(ctx contractapi.TransactionContextInterface, animalID string, newProcessorData string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.ProcessorData = newProcessorData
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}

func (s *SmartContract) ChangeProcessorTrace(ctx contractapi.TransactionContextInterface, animalID string, newProcessorTrace string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.ProcessorTrace = newProcessorTrace
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}

func (s *SmartContract) ChangeDistributorData(ctx contractapi.TransactionContextInterface, animalID string, newDistributorData string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.DistributorData = newDistributorData
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}

func (s *SmartContract) ChangeDistributorTrace(ctx contractapi.TransactionContextInterface, animalID string, newDistributorTrace string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.DistributorTrace = newDistributorTrace
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}


func (s *SmartContract) ChangeRetailerData(ctx contractapi.TransactionContextInterface, animalID string, newRetailerData string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.RetailerData = newRetailerData
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}

func (s *SmartContract) ChangeRetailerTrace(ctx contractapi.TransactionContextInterface, animalID string, newRetailerTrace string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.RetailerTrace = newRetailerTrace
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}

func (s *SmartContract) ChangeConsumerData(ctx contractapi.TransactionContextInterface, animalID string, newConsumerData string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.ConsumerData = newConsumerData
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}

func (s *SmartContract) ChangeConsumerTrace(ctx contractapi.TransactionContextInterface, animalID string, newConsumerTrace string) error {
	// No need to check client org id matches peer org id, rely on the animal ownership check instead.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	// Auth check to ensure that client's org actually owns the animal
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot update the description of a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	animal.ConsumerTrace = newConsumerTrace
	updatedAnimalJSON, err := json.Marshal(animal)
	if err != nil {
		return fmt.Errorf("failed to marshal animal: %v", err)
	}

	return ctx.GetStub().PutState(animalID, updatedAnimalJSON)
}



// AgreeToSell adds seller's asking price to seller's implicit private data collection
func (s *SmartContract) AgreeToSell(ctx contractapi.TransactionContextInterface, animalID string) error {
	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return err
	}

	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

        // Verify that this client belongs to the authorized peer's org

        err = verifyClientOrgMatchesPeerOrg(clientOrgID)
	if err != nil {
		return err
	}

	// Verify that this clientOrgId actually owns the animal.
	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot sell an animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	return agreeToPrice(ctx, animalID, typeAnimalForSale)
}

// AgreeToBuy adds buyer's bid price to buyer's implicit private data collection
func (s *SmartContract) AgreeToBuy(ctx contractapi.TransactionContextInterface, animalID string) error {transientMap, err := ctx.GetStub().GetTransient()
	
        if err != nil {
		return fmt.Errorf("error getting transient: %v", err)
	}

	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return err
	}

	// Verify that this client belongs to the peer's org
	err = verifyClientOrgMatchesPeerOrg(clientOrgID)
	if err != nil {
		return err
	}

	// Animal properties must be retrieved from the transient field as they are private
	immutablePropertiesJSON, ok := transientMap["animal_properties"]
	if !ok {
		return fmt.Errorf("animal_properties key not found in the transient map")
	}

	// Persist private immutable animal properties to seller's private data collection
	collection := buildCollectionName(clientOrgID)
	err = ctx.GetStub().PutPrivateData(collection, animalID, immutablePropertiesJSON)
	if err != nil {
		return fmt.Errorf("failed to put Animal private details: %v", err)
	}

	return agreeToPrice(ctx, animalID, typeAnimalBid)
}

// agreeToPrice adds a bid or ask price to caller's implicit private data collection
func agreeToPrice(ctx contractapi.TransactionContextInterface, animalID string, priceType string) error {
	// In this scenario, client is only authorized to read/write private data from its own peer.
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	transMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return fmt.Errorf("error getting transient: %v", err)
	}

	// animal price must be retrieved from the transient field as they are private
	price, ok := transMap["animal_price"]
	if !ok {
		return fmt.Errorf("animal_price key not found in the transient map")
	}

	collection := buildCollectionName(clientOrgID)

	// Persist the agreed to price in a collection sub-namespace based on priceType key prefix,
	// to avoid collisions between private animal properties, sell price, and buy price
	animalPriceKey, err := ctx.GetStub().CreateCompositeKey(priceType, []string{animalID})
	if err != nil {
		return fmt.Errorf("failed to create composite key: %v", err)
	}

	// The Price hash will be verified later, therefore always pass and persist price bytes as is,
	// so that there is no risk of nondeterministic marshaling.
	err = ctx.GetStub().PutPrivateData(collection, animalPriceKey, price)
	if err != nil {
		return fmt.Errorf("failed to put animal bid: %v", err)
	}

	return nil
}

// VerifyanimalProperties  Allows a buyer to validate the properties of
// an animal against the owner's implicit private data collection
func (s *SmartContract) VerifyAnimalProperties(ctx contractapi.TransactionContextInterface, animalID string) (bool, error) {
	transMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return false, fmt.Errorf("error getting transient: %v", err)
	}

	/// animal properties must be retrieved from the transient field as they are private
	immutablePropertiesJSON, ok := transMap["animal_properties"]
	if !ok {
		return false, fmt.Errorf("animal_properties key not found in the transient map")
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return false, fmt.Errorf("failed to get animal: %v", err)
	}

	collectionOwner := buildCollectionName(animal.CurrentOwner)
	immutablePropertiesOnChainHash, err := ctx.GetStub().GetPrivateDataHash(collectionOwner, animalID)
	if err != nil {
		return false, fmt.Errorf("failed to read animal private properties hash from seller's collection: %v", err)
	}
	if immutablePropertiesOnChainHash == nil {
		return false, fmt.Errorf("animal private properties hash does not exist: %s", animalID)
	}

	hash := sha256.New()
	hash.Write(immutablePropertiesJSON)
	calculatedPropertiesHash := hash.Sum(nil)

	// verify that the hash of the passed immutable properties matches the on-chain hash
	if !bytes.Equal(immutablePropertiesOnChainHash, calculatedPropertiesHash) {
		return false, fmt.Errorf("hash %x for passed immutable properties %s does not match on-chain hash %x",
			calculatedPropertiesHash,
			immutablePropertiesJSON,
			immutablePropertiesOnChainHash,
		)
	}

     // verify that the hash of the passed immutable animal properties and on chain hash matches the animalID
	if !(hex.EncodeToString(immutablePropertiesOnChainHash) == animalID) {
		return false, fmt.Errorf("hash %x for passed immutable properties %s does match on-chain hash %x but do not match animalID %s: animal details were altered from its initial form",
			calculatedPropertiesHash,
			immutablePropertiesJSON,
			immutablePropertiesOnChainHash,
			animalID)
	}

	return true, nil
}

// Transferanimal checks transfer conditions and then transfers animal state to buyer.
// Transferanimal can only be called by current owner
func (s *SmartContract) TransferAnimal(ctx contractapi.TransactionContextInterface, animalID string, buyerOrgID string) error {
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	transMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return fmt.Errorf("error getting transient data: %v", err)
	}

	//immutablePropertiesJSON, ok := transMap["animal_properties"]
	//if !ok {
	//	return fmt.Errorf("animal_properties key not found in the transient map")
	//}

	priceJSON, ok := transMap["animal_price"]
	if !ok {
		return fmt.Errorf("animal_price key not found in the transient map")
	}

	var agreement Agreement
	err = json.Unmarshal(priceJSON, &agreement)
	if err != nil {
		return fmt.Errorf("failed to unmarshal price JSON: %v", err)
	}

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return fmt.Errorf("failed to get animal: %v", err)
	}

	err = verifyTransferConditions(ctx, animal, clientOrgID, buyerOrgID, priceJSON)
	if err != nil {
		return fmt.Errorf("failed transfer verification: %v", err)
	}

	err = transferAnimalState(ctx, animal, clientOrgID, buyerOrgID, agreement.Price)
	if err != nil {
		return fmt.Errorf("failed animal transfer: %v", err)
	}

	return nil

}

// verifyTransferConditions checks that client org currently owns animal and that both parties have agreed on price
func verifyTransferConditions(ctx contractapi.TransactionContextInterface,
	animal *Animal,
	clientOrgID string,
	buyerOrgID string,
	priceJSON []byte) error {

	// CHECK1: Auth check to ensure that client's org actually owns the animal

	if clientOrgID != animal.CurrentOwner {
		return fmt.Errorf("a client from %s cannot transfer a animal owned by %s", clientOrgID, animal.CurrentOwner)
	}

	// CHECK2: Verify that the hash of the passed immutable properties matches the on-chain hash

	collectionSeller := buildCollectionName(clientOrgID)
        collectionBuyer := buildCollectionName(buyerOrgID)
        sellerPropertiesOnChainHash, err := ctx.GetStub().GetPrivateDataHash(collectionSeller, animal.AnimalID)
	if err != nil {
		return fmt.Errorf("failed to read animal private properties hash from seller's collection: %v", err)
	}
	if sellerPropertiesOnChainHash == nil {
		return fmt.Errorf("animal private properties hash does not exist: %s", animal.AnimalID)
	}
	buyerPropertiesOnChainHash, err := ctx.GetStub().GetPrivateDataHash(collectionBuyer, animal.AnimalID)
	if err != nil {
		return fmt.Errorf("failed to read animal private properties hash from seller's collection: %v", err)
	}
	if buyerPropertiesOnChainHash == nil {
		return fmt.Errorf("animal private properties hash does not exist: %s", animal.AnimalID)
	}


	//immutablePropertiesOnChainHash, err := ctx.GetStub().GetPrivateDataHash(collectionSeller, animal.AnimalID)
	//if err != nil {
		//return fmt.Errorf("failed to read animal private properties hash from seller's collection: %v", err)
	//}
	//if immutablePropertiesOnChainHash == nil {
		//return fmt.Errorf("animal private properties hash does not exist: %s", animal.AnimalID)
	//}

	//hash := sha256.New()
	//hash.Write(immutablePropertiesJSON)
	//calculatedPropertiesHash := hash.Sum(nil)

	// verify that the hash of the passed immutable properties matches the on-chain hash
	//if !bytes.Equal(immutablePropertiesOnChainHash, calculatedPropertiesHash) {
	//	return fmt.Errorf("hash %x for passed immutable properties %s does not match on-chain hash %x",
		//	calculatedPropertiesHash,
		//	immutablePropertiesJSON,
		//	immutablePropertiesOnChainHash,
		//)
	//}
        if !bytes.Equal(sellerPropertiesOnChainHash, buyerPropertiesOnChainHash) {
		return fmt.Errorf("on chain hash of seller %x does not match on-chain hash of buyer %x",
			sellerPropertiesOnChainHash,
			buyerPropertiesOnChainHash,
		)
	}

	// Verify that seller and buyer agreed on the same price

	// Get sellers asking price
	animalForSaleKey, err := ctx.GetStub().CreateCompositeKey(typeAnimalForSale, []string{animal.AnimalID})
	if err != nil {
		return fmt.Errorf("failed to create composite key: %v", err)
	}
	sellerPriceHash, err := ctx.GetStub().GetPrivateDataHash(collectionSeller, animalForSaleKey)
	if err != nil {
		return fmt.Errorf("failed to get seller price hash: %v", err)
	}
	if sellerPriceHash == nil {
		return fmt.Errorf("seller price for %s does not exist", animal.AnimalID)
	}

	// Get buyers bidding price
	//collectionBuyer := buildCollectionName(buyerOrgID)
	animalBidKey, err := ctx.GetStub().CreateCompositeKey(typeAnimalBid, []string{animal.AnimalID})
	if err != nil {
		return fmt.Errorf("failed to create composite key: %v", err)
	}
	buyerPriceHash, err := ctx.GetStub().GetPrivateDataHash(collectionBuyer, animalBidKey)
	if err != nil {
		return fmt.Errorf("failed to get buyer price hash: %v", err)
	}
	if buyerPriceHash == nil {
		return fmt.Errorf("buyer price for %s does not exist", animal.AnimalID)
	}

	hash := sha256.New()
	hash.Write(priceJSON)
	calculatedPriceHash := hash.Sum(nil)

	// Verify that the hash of the passed price matches the on-chain sellers price hash
	if !bytes.Equal(calculatedPriceHash, sellerPriceHash) {
		return fmt.Errorf("hash %x for passed price JSON %s does not match on-chain hash %x, seller hasn't agreed to the passed trade id and price",
			calculatedPriceHash,
			priceJSON,
			sellerPriceHash,
		)
	}

	// Verify that the hash of the passed price matches the on-chain buyer price hash
	if !bytes.Equal(calculatedPriceHash, buyerPriceHash) {
		return fmt.Errorf("hash %x for passed price JSON %s does not match on-chain hash %x, buyer hasn't agreed to the passed trade id and price",
			calculatedPriceHash,
			priceJSON,
			buyerPriceHash,
		)
	}

	return nil
}

// transferanimalState performs the public and private state updates for the transferred animal
func transferAnimalState(ctx contractapi.TransactionContextInterface, animal *Animal, clientOrgID string, buyerOrgID string, price int) error {
	animal.CurrentOwner = buyerOrgID
	updatedAnimal, err := json.Marshal(animal)
	if err != nil {
		return err
	}

	err = ctx.GetStub().PutState(animal.AnimalID, updatedAnimal)
	if err != nil {
		return fmt.Errorf("failed to write animal for buyer: %v", err)
	}

	// Change the endorsement policy to the new owner
        endorsingOrgs := []string{buyerOrgID}
	err = setAnimalStateBasedEndorsement(ctx, animal.AnimalID, endorsingOrgs)
	if err != nil {
		return fmt.Errorf("failed setting state based endorsement for new owner: %v", err)
	}

	// Transfer the private properties (delete from seller collection, create in buyer collection)
	collectionSeller := buildCollectionName(clientOrgID)
	err = ctx.GetStub().DelPrivateData(collectionSeller, animal.AnimalID)
	if err != nil {
		return fmt.Errorf("failed to delete Animal private details from seller: %v", err)
	}

	

	// Delete the price records for seller
	animalPriceKey, err := ctx.GetStub().CreateCompositeKey(typeAnimalForSale, []string{animal.AnimalID})
	if err != nil {
		return fmt.Errorf("failed to create composite key for seller: %v", err)
	}

	err = ctx.GetStub().DelPrivateData(collectionSeller, animalPriceKey)
	if err != nil {
		return fmt.Errorf("failed to delete animal price from implicit private data collection for seller: %v", err)
	}

        collectionBuyer := buildCollectionName(buyerOrgID)
        animalPriceKey, err = ctx.GetStub().CreateCompositeKey(typeAnimalBid, []string{animal.AnimalID})
	if err != nil {
		return fmt.Errorf("failed to create composite key for buyer: %v", err)
	}

	err = ctx.GetStub().DelPrivateData(collectionBuyer, animalPriceKey)
	if err != nil {
		return fmt.Errorf("failed to delete animal price from implicit private data collection for buyer: %v", err)
	}
	//err = ctx.GetStub().PutPrivateData(collectionBuyer, animal.AnimalID, immutablePropertiesJSON)
	//if err != nil {
		//return fmt.Errorf("failed to put Animal private properties for buyer: %v", err)
	//}
	// Delete the price records for buyer
	//animalPriceKey, err = ctx.GetStub().CreateCompositeKey(typeAnimalBid, []string{animal.AnimalID})
	//if err != nil {
		//return fmt.Errorf("failed to create composite key for buyer: %v", err)
	//}

	//err = ctx.GetStub().DelPrivateData(collectionBuyer, animalPriceKey)
	//if err != nil {
		//return fmt.Errorf("failed to delete animal price from implicit private data collection for buyer: %v", err)
	//}

	// Keep record for a 'receipt' in both buyers and sellers private data collection to record the sale price and date.
	// Persist the agreed to price in a collection sub-namespace based on receipt key prefix.
	receiptBuyKey, err := ctx.GetStub().CreateCompositeKey(typeAnimalBuyReceipt, []string{animal.AnimalID, ctx.GetStub().GetTxID()})
	if err != nil {
		return fmt.Errorf("failed to create composite key for receipt: %v", err)
	}

	txTimestamp, err := ctx.GetStub().GetTxTimestamp()
	if err != nil {
		return fmt.Errorf("failed to create timestamp for receipt: %v", err)
	}

	timestamp, err := ptypes.Timestamp(txTimestamp)
	if err != nil {
		return err
	}
	animalReceipt := receipt{
		price:     price,
		timestamp: timestamp,
	}
	receipt, err := json.Marshal(animalReceipt)
	if err != nil {
		return fmt.Errorf("failed to marshal receipt: %v", err)
	}

	err = ctx.GetStub().PutPrivateData(collectionBuyer, receiptBuyKey, receipt)
	if err != nil {
		return fmt.Errorf("failed to put private animal receipt for buyer: %v", err)
	}

	receiptSaleKey, err := ctx.GetStub().CreateCompositeKey(typeAnimalSaleReceipt, []string{ctx.GetStub().GetTxID(), animal.AnimalID})
	if err != nil {
		return fmt.Errorf("failed to create composite key for receipt: %v", err)
	}

	err = ctx.GetStub().PutPrivateData(collectionSeller, receiptSaleKey, receipt)
	if err != nil {
		return fmt.Errorf("failed to put private animal receipt for seller: %v", err)
	}

	return nil
}

// getClientOrgID gets the client org ID.
// The client org ID can optionally be verified against the peer org ID, to ensure that a client
// from another org doesn't attempt to read or write private data from this peer.
// The only exception in this scenario is for Transferanimal, since the current owner
// needs to get an endorsement from the buyer's peer.
func getClientOrgID(ctx contractapi.TransactionContextInterface) (string, error) {
	clientOrgID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("failed getting client's orgID: %v", err)
	}

	//if verifyOrg {
		//err = verifyClientOrgMatchesPeerOrg(clientOrgID)
		//if err != nil {
			//return "", err
		//}
	//}

	return clientOrgID, nil
}

// verifyClientOrgMatchesPeerOrg checks the client org id matches the peer org id.
func verifyClientOrgMatchesPeerOrg(clientOrgID string) error {
	peerOrgID, err := shim.GetMSPID()
	if err != nil {
		return fmt.Errorf("failed getting peer's orgID: %v", err)
	}

	if clientOrgID != peerOrgID {
		return fmt.Errorf("client from org %s is not authorized to read or write private data from an org %s peer",
			clientOrgID,
			peerOrgID,
		)
	}

	return nil
}

// setAnimalStateBasedEndorsement adds an endorsement policy to a animal so that only a peer from an owning org
// can update or transfer the animal.
func setAnimalStateBasedEndorsement(ctx contractapi.TransactionContextInterface, animalID string, orgToEndorse []string) error {
	endorsementPolicy, err := statebased.NewStateEP(nil)
	if err != nil {
		return err
	}
	err = endorsementPolicy.AddOrgs(statebased.RoleTypePeer, orgToEndorse...)
	if err != nil {
		return fmt.Errorf("failed to add org to endorsement policy: %v", err)
	}
	policy, err := endorsementPolicy.Policy()
	if err != nil {
		return fmt.Errorf("failed to create endorsement policy bytes from org: %v", err)
	}
	err = ctx.GetStub().SetStateValidationParameter(animalID, policy)
	if err != nil {
		return fmt.Errorf("failed to set validation parameter on animal: %v", err)
	}

	return nil
}

func buildCollectionName(clientOrgID string) string {
	return fmt.Sprintf("_implicit_org_%s", clientOrgID)
}

func getClientImplicitCollectionName(ctx contractapi.TransactionContextInterface) (string, error) {
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return "", fmt.Errorf("failed to get verified OrgID: %v", err)
	}

	err = verifyClientOrgMatchesPeerOrg(clientOrgID)
	if err != nil {
		return "", err
	}

	return buildCollectionName(clientOrgID), nil
}

func (s *SmartContract) ReadAnimal(ctx contractapi.TransactionContextInterface, animalID string) (*Animal, error) {
	// Since only public data is accessed in this function, no access control is required
	animalJSON, err := ctx.GetStub().GetState(animalID)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if animalJSON == nil {
		return nil, fmt.Errorf("%s does not exist", animalID)
	}

	var animal *Animal
	err = json.Unmarshal(animalJSON, &animal)
	if err != nil {
		return nil, err
	}
	return animal, nil
}


/*
func (s *SmartContract) ReadAnimalWhat(ctx contractapi.TransactionContextInterface, animalID string) (*AnimalWhat, error) {
	// Since only public data is accessed in this function, no access control is required
	animalJSON, err := ctx.GetStub().GetState(animalID)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if animalJSON == nil {
		return nil, fmt.Errorf("%s does not exist", animalID)
	}

	var animalwhat *AnimalWhat
	err = json.Unmarshal(animalJSON, &animalwhat)
	if err != nil {
		return nil, err
	}
	return animalwhat, nil
}
*/

// GetAnimalPrivateProperties returns the immutable animal properties from owner's private data collection
func (s *SmartContract) GetAnimalPrivateProperties(ctx contractapi.TransactionContextInterface, animalID string) (string, error) {
	// In this scenario, client is only authorized to read/write private data from its own peer.
	collection, err := getClientImplicitCollectionName(ctx)
	if err != nil {
		return "", err
	}

	immutableProperties, err := ctx.GetStub().GetPrivateData(collection, animalID)
	if err != nil {
		return "", fmt.Errorf("failed to read animal private properties from client org's collection: %v", err)
	}
	if immutableProperties == nil {
		return "", fmt.Errorf("animal private details does not exist in client org's collection: %s", animalID)
	}

	return string(immutableProperties), nil
}

// GetanimalSalesPrice returns the sales price
func (s *SmartContract) GetAnimalSalesPrice(ctx contractapi.TransactionContextInterface, animalID string) (string, error) {
	return getAnimalPrice(ctx, animalID, typeAnimalForSale)
}

// GetanimalBidPrice returns the bid price
func (s *SmartContract) GetAnimalBidPrice(ctx contractapi.TransactionContextInterface, animalID string) (string, error) {
	return getAnimalPrice(ctx, animalID, typeAnimalBid)
}

// getanimalPrice gets the bid or ask price from caller's implicit private data collection
func getAnimalPrice(ctx contractapi.TransactionContextInterface, animalID string, priceType string) (string, error) {
	collection, err := getClientImplicitCollectionName(ctx)
	if err != nil {
		return "", err
	}

	animalPriceKey, err := ctx.GetStub().CreateCompositeKey(priceType, []string{animalID})
	if err != nil {
		return "", fmt.Errorf("failed to create composite key: %v", err)
	}

	price, err := ctx.GetStub().GetPrivateData(collection, animalPriceKey)
	if err != nil {
		return "", fmt.Errorf("failed to read animal price from implicit private data collection: %v", err)
	}
	if price == nil {
		return "", fmt.Errorf("animal price does not exist: %s", animalID)
	}

	return string(price), nil
}

// QueryAnimalSaleAgreements returns all of an organization's proposed sales
func (s *SmartContract) QueryAnimalSaleAgreements(ctx contractapi.TransactionContextInterface) ([]Agreement, error) {
	return queryAgreementsByType(ctx, typeAnimalForSale)
}

// QueryAnimalBuyAgreements returns all of an organization's proposed bids
func (s *SmartContract) QueryAnimalBuyAgreements(ctx contractapi.TransactionContextInterface) ([]Agreement, error) {
	return queryAgreementsByType(ctx, typeAnimalBid)
}

func queryAgreementsByType(ctx contractapi.TransactionContextInterface, agreeType string) ([]Agreement, error) {
	collection, err := getClientImplicitCollectionName(ctx)
	if err != nil {
		return nil, err
	}

	// Query for any object type starting with `agreeType`
	agreementsIterator, err := ctx.GetStub().GetPrivateDataByPartialCompositeKey(collection, agreeType, []string{})
	if err != nil {
		return nil, fmt.Errorf("failed to read from private data collection: %v", err)
	}
	defer agreementsIterator.Close()

	var agreements []Agreement
	for agreementsIterator.HasNext() {
		resp, err := agreementsIterator.Next()
		if err != nil {
			return nil, err
		}

		var agreement Agreement
		err = json.Unmarshal(resp.Value, &agreement)
		if err != nil {
			return nil, err
		}

		agreements = append(agreements, agreement)
	}

	return agreements, nil
}

// QueryanimalHistory returns the chain of custody for a animal since issuance
func (s *SmartContract) QueryAnimalHistory(ctx contractapi.TransactionContextInterface, animalID string) ([]QueryResult, error) {
	resultsIterator, err := ctx.GetStub().GetHistoryForKey(animalID)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var results []QueryResult
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var animal *Animal
		err = json.Unmarshal(response.Value, &animal)
		if err != nil {
			return nil, err
		}

		timestamp, err := ptypes.Timestamp(response.Timestamp)
		if err != nil {
			return nil, err
		}
		record := QueryResult{
			TxId:      response.TxId,
			Timestamp: timestamp,
			Record:    animal,
		}
		results = append(results, record)
	}

	return results, nil
}


func getClientImplicitCollectionNameAndVerifyClientOrg(ctx contractapi.TransactionContextInterface) (string, error) {
	clientOrgID, err := getClientOrgID(ctx)
	if err != nil {
		return "", err
	}

	err = verifyClientOrgMatchesPeerOrg(clientOrgID)
	if err != nil {
		return "", err
	}

	return buildCollectionName(clientOrgID), nil
}

func (s *SmartContract) GetAnimalHashId(ctx contractapi.TransactionContextInterface) (string, error) {
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return "", fmt.Errorf("error getting transient: %v", err)
	}

	// Animal properties must be retrieved from the transient field as they are private
	propertiesJSON, ok := transientMap["animal_properties"]
	if !ok {
		return "", fmt.Errorf("animal_properties key not found in the transient map")
	}

	hash := sha256.New()
	hash.Write(propertiesJSON)
	animalID := hex.EncodeToString(hash.Sum(nil))

	animal, err := s.ReadAnimal(ctx, animalID)
	if err != nil {
		return "", fmt.Errorf("failed to get animal: %v, animal properies provided do not represent any on chain animal", err)
	}
	if animal.AnimalID != animalID {
		return "", fmt.Errorf("Animal properies provided do not correpond to any on chain animal")
	}
	return animal.AnimalID, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(new(SmartContract))
	if err != nil {
		log.Panicf("Error create transfer animal chaincode: %v", err)
	}

	if err := chaincode.Start(); err != nil {
		log.Panicf("Error starting animal chaincode: %v", err)
	}
}
