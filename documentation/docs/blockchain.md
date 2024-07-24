# Blockchain Network


The submodule files located under /blockchain directory are meant to start a hybrid permissioned blockchain network that can be extended to form different groups for collaboration. The blockchain framework apart from running containers, requires hyperledger fabric version 2.5 related binary files located under BeefMesh/fabric-samples/bin folder. Downloading the hyperledger fabric within the BeefMesh folder will create the fabric-samples/bin automatically. To download the fabric 2.5 binary files within the BeefMesh folder, call the blockchain-net.sh file in /blockchain folder. 

        # Note that this only downloads binary files and container images!
	./blockchain/blockchain-net.sh downloadfabric

	
This will download required docker images and binary files in a /bin folder inside BeefMesh/blockchain directory. 
The rest of the tutorial is divided into two sections. One for testing locally on a single host and one for testing on a multi host setup. 


## A Note on Environment Variables 

Environmnet variables are automatically picked up from configuration files and stored under blockchain/blockchainEnvVar for different organizations, peers and orderers. The format of the folders inside blockchain/blockchainEnvVar is of the form organizationX_Y, where X is the organziation number and Y is the peer number. This allows storing multiple organziations of the same type, e.g. first breeder org with one peer node can be stored as breeder0_0 and when another peer gets added, it can be stored as breeder0_1. Or or separate new breeder organizations can be added as breeder1_0,  breeder2_0, ... and so on. 

Next, blockchain/OrgConfigurations folder allows storing network configuration files so that different set of organzations can be configured for a particualr channel using a particular orderer. Use the chaincode_path.sh, channel_path.sh and configtx_path.sh files to target different organization configurations. For example, if all the settings are set for 'main' configuration, then different files inside blockchain/OrgConfigurations/main folder can be used to  spin up different set of blockchain confgurations when creating channels, installing chaincode etc. 



## SingleHost Setup

Once the binary are downloaded in the BeefMesh/blockchain/bin folder, start the minimim setup of manager and regulator for the main server.

	./blockchain/blockchain-net.sh blockchainup tracechannel
	# generic call (replace the starting channel name variable)
	./blockchain/blockchain-net.sh blockchainup <starting_channel_name> 
	

The initial blockchain framework uses network configuration files in blockchain/configtx folder to start up a blockchain network of manager and regulator that are connected with a channel (tracechannel) and to a docker bridge named 'beef_supply'. Here is the basic overview of the sequence of files/functions called. 

1. call the network.sh file in BeefMesh folder 
2. pick up configuration files in BeefMesh/blockchain/configtx folder 
3. pick up binary files in BeefMesh/blockchain/bin folder 
4. start certificate authority (CA) containers for manager and  regulator with a single orderer using docker compose files in blockchain/compose/docker/ folder
5. call the enrollment functions for manager, regulator and orderer in organizations/fabric-ca/registerEnroll.sh that creates certificates and stores them for each organziation under BeefMesh/organizations/peerOrganizations/ and BeefMesh/organizations/ordererOrganizations/
6. start the database and base containers for orderer and peer using the docker compose files in blockchain/compose/docker/ folder
7. call the blockchain/scripts/createChannel.sh to start the initial channel which creates the genesis block (tracechannel.block) in blockchain/channel-artifacts folder along with setting ports for anchor peers. 

This setup can be brought down any time 

	./blockchain/blockchain-net.sh blockchaindown tracechannel
	# generic call (replace the starting channel name variable)
	./blockchain/blockchain-net.sh blockchaindown <starting_channel_name> 
	
	
The blockchain network comprising of manager and regulator consits of a peer node in each organization and an orderer node. The orderer node is required to arrange the blockchain files after consensus when they are stored. Each organization can have their on multiple orderers and peers. The tutorial below describes how to add a new custom organization (rancher), a new peer (for regulator) and a new orderer (for racher) along with generic organization, peer and orderer with user configured settings. 

### Managing a new organization
	
Expand the network and add a new organization (rancher) to the network. Call the addRancher.sh file  in the BeefMesh/addrancher/ folder 

	./blockchain/blockchain-net.sh addrancher tracechannel
	# generic call (replace the starting channel name variable)
	./blockchain/blockchain-net.sh addrancher <starting_channel_name> 



This adds a new organization to the already running network of blockchain and joins it to the channel tracechannel. 

`Note an error of the type "Error: proposal failed (err: bad proposal response 500: cannot create ledger from genesis block: ledger [<channel_name>] already exists with state [ACTIVE])" means that volumes from previous configurations are still being reported by the system. This can be fixed by removing the organizations and unused docker volumes completely.`
`

To remove the organization from the network and from the channel, run 

	./blockchain/blockchain-net.sh removerancher tracechannel
	# generic call (replace the starting channel name variable)
	./blockchain/blockchain-net.sh removerancher <starting_channel_name> 
	
This removes the organziation completely from the network and from the channel while reconfiguring the network. 


### Managing new peers


Add a new peer for the regulator organization 

	./blockchain/blockchain-net.sh addregulatorpeer tracechannel
	# generic call (replace the starting channel name variable)
	./blockchain/blockchain-net.sh addregulatorpeer <starting_channel_name> 
	
	
Remove the extra peer from regulator organization 

	./blockchain/blockchain-net.sh removeregulatorpeer tracechannel
	# generic call (replace the starting channel name variable)
	./blockchain/blockchain-net.sh removeregulatorpeer <starting_channel_name> 
	
Since manager and regulator setup is assumed to be running on the same host along with an orderer node, the new organization running on some other host (multi-host scenario) might not be able to directly access the single running orderer. Start a new orderer for the rancher organization 


### Managing new orderer

Add a new orderer for the regulator and manager organization 


	./blockchain/blockchain-net.sh addrancherorderer tracechannel
	# generic call (replace the starting channel name variable)
	./blockchain/blockchain-net.sh addrancherorderer <starting_channel_name> 
	
	
Remove the extra orderer just added above for the rancher organization 

	./blockchain/blockchain-net.sh removerancherorderer tracechannel
	# generic call (replace the starting channel name variable)
	./blockchain/blockchain-net.sh removerancherorderer <starting_channel_name> 
	
	
	
## Custom MultiHost Setup



`Note: A list of ports and addresses used by blockchain containers is maintained under blockchain/blockchain_ports_master.txt and would be helpful to maintain when running all containers locally or in multihost setup! When adding more organziations, just increase port number and make sure it is not used with any other container`


The scripts under this section can be run in single host and multi-host environment and are meant to be flexible enough to allow adpating quickly for new organizations, peers and orderers. Before using for multihost setup, make sure all networks are using 'overlay' option instead of 'bridge' in the docker-compose files.  

A difference between running scripts locally and multihost setup is summarized below. 

1. For multihost setup, configure the PeerOrgEnv.sh environment files with the ip address of the peer node instead of using localhost. Ports can remain the same.
2. In a multihost setup, each organziation should setup their own orderer since it is not advisable to share configurations with other nodes running orderer to update changes to common channel. Initially, the orderers are added by sharing configurations in a group that other organziations can use to make udpates to channel. Once the changes are made, each organziation can continue with their own orderer to make more channels and make changes to it. 
3. Due to limitation of space, combined scripts are provided that can be split into more than one script that requires utilizing an orderer owned by other organization. This requires sharing files using collaboration server to allow required changes to server. 
4. The main changes that are required to use other organizations orderers are when a channel genesis file is required or when the organziaton is not on the channel but wants to join.  

### Custom Organization 

To bring up a custom organization to an already existing network started by manager and regulator, use the addCustom.sh file in /addustomorg folder. First change the environment variables (non-conflicting org name, ports, addresses in the addcustomorg/env/env.sh file. Then export the variables in the terminal 


	source addcustomorg/env/env.sh
	
`Note that folder name can be changed when resuing the template. Also change the folder name path variable in the env/env.sh file`	

Call the the setparamcustomorg method to set configuration for the new organization

  	./blockchain/blockchain-net.sh setparamcustomorg
  	
Now, bring up or bring down the new organization 

	# bring organziation up
	./blockchain/blockchain-net.sh addcustomorg tracechannel
	# bring organziation down
	./blockchain/blockchain-net.sh removecustomorg tracechannel
	
### Custom Peer 

`Note that extra peer uses the same ports for certificate authority for the organization to which it is added to`	


To bring up a custom peer to the already existing network started by manager and regulator, use the addCustom.sh file in /addustompeer folder. First change the envrionemnt variables (non-conflicting org name, ports, addresses in the addustompeer/env/env.sh file. Then export the variables in the terminal 

	source addcustompeer/env/env.sh

Call the the setparamcustompeer method to set configuration for the new peer

  	./blockchain/blockchain-net.sh setparamcustompeer
  	
Now, bring up or bring down the new organization 

	# bring organziation up
	./blockchain/blockchain-net.sh addcustompeer tracechannel
	# bring organziation down
	./blockchain/blockchain-net.sh removecustompeer tracechannel
	
### Custom Orderer 	
	
	
To bring up a custom orderer to the already existing network started by manager and regulator, use the addCustom.sh file in /addustomorderer folder. First change the envrionemnt variables (non-conflicting org name, ports, addresses in the addustomorderer/env/env.sh file. Then export the variables in the terminal 

	source addcustomorderer/env/env.sh

Call the the setparamcustompeer method to set configuration for the new peer

  	./blockchain/blockchain-net.sh setparamcustomorderer
  	
Now, bring up or bring down the new organization 

	# bring organziation up
	./blockchain/blockchain-net.sh addcustomorderer tracechannel
	# bring organziation down
	./blockchain/blockchain-net.sh removecustomorderer tracechannel


## Manage Blockchain Channels


To create new channels for use after an organzation has been setup, use the porvided scripts as follows 

        ./blockchain/blockchain-net.sh createchannel <channel_name>
	./blockchain/blockchain-net.sh createchannel cedric
	

Note that, before calling the script to use, make changes to environment variables under blockchain/OrgConfigurations and particularly  createChannelOrgsCustom.txt file with first line being the channel configuration to be picked up from configtx file, the second line being the orderer to use, the third being the main organization which will start the process and fourth line being the list of organizations that will be part of the channel. 



## Deploy Chaincode to Channel

Once channels have been created, smart contracts need to be installed on the channels to use them. Same version of the program should be pakcaged and installed on all peers using the same channel to be able to make changes to the same data when they have the rights to do so. A sample Beef Chain specific program is provided under 
examples/emissionschaincode written in GO language. To install the program, use the custom scripts provided

`Note that while environment variables are automatically set for rest of the application, a record needs to be manually made before installing chaincode for the peer connection paramameters in the file blockchain/scripts/envVar.sh and in the function  parsePeerConnectionParameters()`

        
        ./blockchain/blockchain-net.sh installcontract <channel_name> <program_name> <program_location> <program_language> <collaboration_orgs>
        
        ./blockchain/blockchain-net.sh installcontract tracechannel traceexample ./examples/emissionschaincode/ go "OR('ManagerMSP.peer','RegulatorMSP.peer')"

Not that this again makes use of target envrionment files in blockchain/OrgConfigurations and particularly installChaincodeOrgsCustom.txt file. The smartcontract can be reused by copying the program under different folder and installing with different program name. 

## Deploy Chaincode to Channel

Once channels have been created, smart contracts need to be installed on the channels to use them. Same version of the program should be pakcaged and installed on all peers using the same channel to be able to make changes to the same data when they have the rights to do so. A sample Beef Chain specific program is provided under 
examples/emissionschaincode written in GO language. To install the program, use the custom scripts provided

        
        ./blockchain/blockchain-net.sh installcontract <channel_name> <program_name> <program_location> <program_language> <collaboration_orgs>
        
        ./blockchain/blockchain-net.sh installcontract tracechannel traceexample ./examples/emissionschaincode/ go "OR('ManagerMSP.peer','RegulatorMSP.peer')"

Not that this again makes use of target envrionment files in blockchain/OrgConfigurations and particularly installChaincodeOrgsCustom.txt file. The smartcontract can be reused by copying the program under different folder and installing with different program name. 

## Writing and Reading Data from Chaincode


Once program is installed, a helper function file is provided to read and write data into the channel using the installed program. To write a new animal record to the 
program,


        ./blockchain/blockchain-writer.sh createanimal <main_org> <orderer_to_use> <channel_name> <program_name> <animal_properties_file> <some_info> 
        
	./blockchain/blockchain-writer.sh createanimal manager0_0 orderer tracechannel traceexample animal1.sh NewAnimal 


Note that the record above uses an animal properties file located under examples/ folder and writes the animal_id that is generated by the blockchain under examples/animalrecords. 

To read back the data recorded on the blockchain, 


	./blockchain/blockchain-writer.sh readanimal <main_org> <orderer_to_use> <channel_name> <program_name> <animal_id> 
	
	./blockchain/blockchain-writer.sh readanimal manager0_0 orderer tracechannel traceexample c9561e1bfd916da55119de6eae55cda85ac0aa5c89ed606721cd53d25d4bddf6

Note that, we use the animal_id (example here) that was generated from the first stage of recording the animal on blockchain to target later blockchain changes. 

To read private data of animal from blockchain by the owner who created the data, 

        ./blockchain/blockchain-writer.sh readprivate <main_org> <orderer_to_use> <channel_name> <program_name> <animal_id> 
        
	./blockchain/blockchain-writer.sh readprivate manager0_0 orderer tracechannel traceexample c9561e1bfd916da55119de6eae55cda85ac0aa5c89ed606721cd53d25d4bddf6


To make changes to the data stored on the blockchain, particularly the description of data, 


          ./blockchain/blockchain-writer.sh changedescription <main_org> <orderer_to_use> <channel_name> <program_name> <animal_id> <description>
         ./blockchain/blockchain-writer.sh changedescription manager0_0 orderer tracechannel traceexample c9561e1bfd916da55119de6eae55cda85ac0aa5c89ed606721cd53d25d4bddf6 AnimalForSale


To record data from traceability channels such as the IPFS or some other general data, 


	  ./blockchain/blockchain-writer.sh recorddata <main_org> <orderer_to_use> <channel_name> <program_name> <animal_id> <data> <target_function>

	 ./blockchain/blockchain-writer.sh recorddata manager0_0 orderer tracechannel traceexample c9561e1bfd916da55119de6eae55cda85ac0aa5c89ed606721cd53d25d4bddf6 SomeIPFScid ChangeFarmerData
	 
Note that we used ChangeFarmerData target function above as it makes changes to the FarmerData variable. To make changes to other varaibles, some useful target functions are given below: 

* ChangeFarmerData/ChangeFarmerTrace  for managing data on FarmerData/FarmerTrace 
* ChangeBreederData/ChangeBreederTrace  for managing data on BreederData/BreederTrace 
* ChangeDistributorData/ChangeBreederTrace  for managing data on DistributorData/DistributorTrace 
* ChangeRetailerData/ChangeBreederTrace  for managing data on RetailerData/RetailerTrace 
* ChangeRegulatorData/ChangeRegulatorTrace  for managing data on RegulatorData/RegulatorTrace 
* ChangeConsumerData/ChangeConsumerTrace  for managing data on ConsumerData/ConsumerTrace 
* ChangeProcessorData/ChangeProcessorTrace  for managing data on ProcessorData/ProcessorTrace 

To move private animal record to other organization, officially start a selling process, 


        ./blockchain/blockchain-writer.sh agreetosell <seller_org> <orderer_to_use> <channel_name> <program_name> <animal_id> <animal_trade_id>> <price>

	./blockchain/blockchain-writer.sh agreetosell manager0_0 orderer tracechannel traceexample c9561e1bfd916da55119de6eae55cda85ac0aa5c89ed606721cd53d25d4bddf6 109f4b3c50d7b0df729d299bc6f8e9ef9066971f 2500
	
	
Check the sale price that was just changed, 
 

       ./blockchain/blockchain-writer.sh checksaleprice <main_org> <orderer_to_use> <channel_name> <program_name> <animal_id> 

       ./blockchain/blockchain-writer.sh checksaleprice manager0_0 orderer tracechannel traceexample c9561e1bfd916da55119de6eae55cda85ac0aa5c89ed606721cd53d25d4bddf6 


The other orgaznation interested in taking in the animal, puts on their bid price, 

              ./blockchain/blockchain-writer.sh agreetobuy <buyer_org> <orderer_to_use> <channel_name> <program_name> <animal_id> <animal_properties> <price>
             
		./blockchain/blockchain-writer.sh agreetobuy regulator0_0 orderer tracechannel traceexample c9561e1bfd916da55119de6eae55cda85ac0aa5c89ed606721cd53d25d4bddf6 animal1.sh 2500
		
Note, that the other organization needs to knwow the properties data of the animal under negotiation   

Check the bid price that was just put on the blockchain,


	./blockchain/blockchain-writer.sh checkbidprice <main_org> <orderer_to_use> <channel_name> <program_name> <animal_id> 
	
	./blockchain/blockchain-writer.sh checkbidprice regulator0_0 orderer tracechannel traceexample c9561e1bfd916da55119de6eae55cda85ac0aa5c89ed606721cd53d25d4bddf6 


If the prices match and the seller agrees to hand over the animals, the seller can tranfer the animal to the other organization by using the other organizations credentails 


         ./blockchain/blockchain-writer.sh transferanimal <seller_org> <orderer_to_use> <channel_name> <program_name> <animal_id> <animal_trade_id> <buyer_org> <price_settled>


	./blockchain/blockchain-writer.sh transferanimal manager0_0 orderer tracechannel traceexample c9561e1bfd916da55119de6eae55cda85ac0aa5c89ed606721cd53d25d4bddf6 109f4b3c50d7b0df729d299bc6f8e9ef9066971f regulator0_0 2500 


### Check Block Details 


To check the details of a particular transaction in a block, download and build the application provided here: https://github.com/Deeptiman/blockreader
Optionally,  use the blockchain explorer application to visualize the block transactions. 

Remove any existing organizations from the folder fabricexplorer and copy organizations data to the fabricexplorer directory . 


	rm -d -r fabricexplorer/organizations
        cp -R organizations fabricexplorer/
        chmod -R a+rwx fabricexplorer
        
Use jq to export and replace keys in bulk for the organizations that are required to be viewed. For example, if there is just manager org, 

	key_value=$(ls organizations/peerOrganizations/manager.beefsupply.com/users/User1@manager.beefsupply.com/msp/keystore/)
        export key_value
        
Spin up the fabric explorer container, 

	cd fabricexplorer && docker-compose up -d
	
Blockchain explorer will run on interface localhost:8090 with username: exploreradmin and pass: exploreradminpw

Bring down the container manually, 

	docker stop explorerdb.beefnetwork.com
	docker rm explorerdb.beefnetwork.com
	docker stop explorer.beefnetwork.com
	docker rm explorer.beefnetwork.com
	rm -d -r fabricexplorer/organizations
	fuser -k 8090/tcp

	


