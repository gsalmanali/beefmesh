#!/bin/bash


#export PATH=$PATH:/usr/local/go/bin

#echo $PASSWORD | sudo -S docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $breederaddress  
docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $breederaddress
docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $processoraddress
docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $distributoraddress
docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $retaileraddress
docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $consumeraddress
docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $manageraddress
docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $regulatoraddress

docker exec -u 0 breeder.ipfs.com ipfs bootstrap add $farmeraddress
docker exec -u 0 breeder.ipfs.com ipfs bootstrap add $processoraddress
docker exec -u 0 breeder.ipfs.com ipfs bootstrap add $distributoraddress
docker exec -u 0 breeder.ipfs.com ipfs bootstrap add $retaileraddress
docker exec -u 0 breeder.ipfs.com ipfs bootstrap add $consumeraddress
docker exec -u 0 breeder.ipfs.com ipfs bootstrap add $manageraddress
docker exec -u 0 breeder.ipfs.com ipfs bootstrap add $regulatoraddress


docker exec -u 0 processor.ipfs.com ipfs bootstrap add $farmeraddress
docker exec -u 0 processor.ipfs.com ipfs bootstrap add $breederaddress
docker exec -u 0 processor.ipfs.com ipfs bootstrap add $distributoraddress
docker exec -u 0 processor.ipfs.com ipfs bootstrap add $retaileraddress
docker exec -u 0 processor.ipfs.com ipfs bootstrap add $consumeraddress
docker exec -u 0 processor.ipfs.com ipfs bootstrap add $manageraddress
docker exec -u 0 processor.ipfs.com ipfs bootstrap add $regulatoraddress


docker exec -u 0 distributor.ipfs.com ipfs bootstrap add $farmeraddress
docker exec -u 0 distributor.ipfs.com ipfs bootstrap add $breederaddress
docker exec -u 0 distributor.ipfs.com ipfs bootstrap add $processoraddress
docker exec -u 0 distributor.ipfs.com ipfs bootstrap add $retaileraddress
docker exec -u 0 distributor.ipfs.com ipfs bootstrap add $consumeraddress
docker exec -u 0 distributor.ipfs.com ipfs bootstrap add $manageraddress
docker exec -u 0 distributor.ipfs.com ipfs bootstrap add $regulatoraddress


docker exec -u 0 retailer.ipfs.com ipfs bootstrap add $farmeraddress
docker exec -u 0 retailer.ipfs.com ipfs bootstrap add $breederaddress
docker exec -u 0 retailer.ipfs.com ipfs bootstrap add $processoraddress
docker exec -u 0 retailer.ipfs.com ipfs bootstrap add $distributoraddress
docker exec -u 0 retailer.ipfs.com ipfs bootstrap add $consumeraddress
docker exec -u 0 retailer.ipfs.com ipfs bootstrap add $manageraddress
docker exec -u 0 retailer.ipfs.com ipfs bootstrap add $regulatoraddress

docker exec -u 0 consumer.ipfs.com ipfs bootstrap add $farmeraddress
docker exec -u 0 consumer.ipfs.com ipfs bootstrap add $breederaddress
docker exec -u 0 consumer.ipfs.com ipfs bootstrap add $processoraddress
docker exec -u 0 consumer.ipfs.com ipfs bootstrap add $distributoraddress
docker exec -u 0 consumer.ipfs.com ipfs bootstrap add $retaileraddress
docker exec -u 0 consumer.ipfs.com ipfs bootstrap add $manageraddress
docker exec -u 0 consumer.ipfs.com ipfs bootstrap add $regulatoraddress

docker exec -u 0 manager.ipfs.com ipfs bootstrap add $farmeraddress
docker exec -u 0 manager.ipfs.com ipfs bootstrap add $breederaddress
docker exec -u 0 manager.ipfs.com ipfs bootstrap add $processoraddress
docker exec -u 0 manager.ipfs.com ipfs bootstrap add $distributoraddress
docker exec -u 0 manager.ipfs.com ipfs bootstrap add $retaileraddress
docker exec -u 0 manager.ipfs.com ipfs bootstrap add $consumeraddress
docker exec -u 0 manager.ipfs.com ipfs bootstrap add $regulatoraddress

docker exec -u 0 regulator.ipfs.com ipfs bootstrap add $farmeraddress
docker exec -u 0 regulator.ipfs.com ipfs bootstrap add $breederaddress
docker exec -u 0 regulator.ipfs.com ipfs bootstrap add $processoraddress
docker exec -u 0 regulator.ipfs.com ipfs bootstrap add $distributoraddress
docker exec -u 0 regulator.ipfs.com ipfs bootstrap add $retaileraddress
docker exec -u 0 regulator.ipfs.com ipfs bootstrap add $consumeraddress
docker exec -u 0 regulator.ipfs.com ipfs bootstrap add $manageraddress









