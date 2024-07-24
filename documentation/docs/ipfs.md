# IPFS Network


This submodule located under /ipfsnetwork directory is meant to serve as a resource for spinning up nodes to mainatin IPFS database. IPFS, which stands for InterPlanetary File System, is a protocol and network designed to create a peer-to-peer method of storing and sharing hypermedia in a distributed file system. It is a decentralized system for storing and accessing files, webpages, applications, and data, aiming to improve upon the traditional client-server model of the internet. For beef supply chain, it is particualry useful to maintain regulatory data in addititon to off-loading data of different formats from the blockchain ledger. 

## SingleOrg Setup

To run a standalone two node (manager+regulator) ipfs network (assuming one organizational domain) at the beef chain admin side, run the docker-compose file within /ipfsnetwork directory 

	docker-compose -f p2p/docker-compose-single-org.yml up -d
	

`Note that for testing purposes, 'secrets' lines have been disabled in the docker-compose files. Make sure to pass sensitive information using secure measures using files or by passing parameters through environment variables (.env)` 

This spins up two ipfs cotnainers (manager.ipfs.com  and regulator.ipfs.com) and an ipfc cli (ipfscli) container attached to both for quick access to ipfs resources. The containers are connected to beefchain_ipfs network. We run the ipfs network in private setting and remove all external public nodes from our application setup. A number of preconfigurations can be done in the config/config.sh file as well which is used in the docker-compose setup. To setup ipfs in private settings, a swarm key can be used. Spin up swarm key generator container, 

	
       docker-compose -f swarmkeygen/docker-compose-swarm.yml up -d
    

Generate a key from the swarm key generator container and copy it to host machine, 

	docker exec -i ipfs-swarm-key-gen piskg > swarmkeygen/swarm.key

Now configure the two ipfs nodes to work in a private setting, run from bash terminal

       
        ./configure-single.sh
         
This setsup the two nodes to use private networking by removing all public nodes, adding each others private addresses and copying swarm key. Finally a test is performed by adding a file to manager node and retreiving the file from regulator node by using the CID that was generated at the manager node during the time of file upload. You should see a result like this,

	added /ip4/192.168.0.3/tcp/4001/ipfs/Qmf6G9iaQNVbpYrYxLhEYcSZuyJzya7XV3xxpMLEJ3kBzc
	added /ip4/192.168.0.2/tcp/4001/ipfs/QmUt6WnUFWUmJdBJr4fvPL2oq7KM4gF2M7KNNVbc1veEAS
	Successfully copied 2.05kB to manager.ipfs.com:/var/ipfs
	Successfully copied 2.05kB to regulator.ipfs.com:/var/ipfs
	Successfully copied 2.05kB to manager.ipfs.com:/opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/test_file.txt
	Successfully copied 2.05kB to $USER_PATH/BeefMesh/ipfsnetwork/test/retrieved_file.txt
 

`Note that removing all public addresse and adding only known addresses forces the ipfs nodes to work in private setting. For extra measures you can also force variable LIBP2P_FORCE_PNET to be true by logging into running container and setting variable 'export LIBP2P_FORCE_PNET=true' or enabling it in the docker-compose files 'environment' section`

To upload a file (user_file.txt) to the manager ipfs node, first copy it to the container

	docker cp test/user_file.txt manager.ipfs.com:/opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/user_file.txt
	
Then upload the file and retrive the CID of the uploaded file to store on blockchain or somewhere else,

	result=$(docker exec manager.ipfs.com ipfs add user_file.txt)
	CID_DATA=$(echo $result | awk '{print $2}') 
	
The contents of the variable (echo $CID_DATA) is a binary format string formed by the hash of the uploaded content (e.g. `Qmc1DxF7dmEAmkwn1eynm2BeW6DnFcgvw9s5W1NDeXZc28`
). The CID is stored and kept safe for retrieveing the file later. To retrive the file from the regulator node using the same CID,

	docker exec regulator.ipfs.com bash -c "ipfs cat $CID_DATA > retrieved_user_file.txt"
	
Now copy back the file from container to the host machine,

	docker cp regulator.ipfs.com:/opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/retrieved_user_file.txt test/retrieved_user_file.txt

To spin up a number of IPFS nodes associated with multiple organizations for local testing of BeefMesh application, first make sure the single organization containers are down. 

Use the provided script (ipfs-network.sh) to automate upload and download of files. To upload a file,


      ./ipfs-network.sh upload <container_name> <source_file_path> <container_file_path>
      ./ipfs-network.sh upload manager.ipfs.com test/user_file.txt /opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/user_file.txt


Note that when uploading a file, a record is maintained in the folder 'ipfs_records'. To download a file using the provided script, 



      ./ipfs-network.sh download <container_name> <cid_data> <container_file_path>
     ./ipfs-network.sh download manager.ipfs.com Qmc1DxF7dmEAmkwn1eynm2BeW6DnFcgvw9s5W1NDeXZc28 /opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/retrieved_user_file.txt
     
     
To configure a ipfs node continer to use a specfic private address from other ipfs container,


     ./ipfs-network.sh configure <container_name> <container_address_to_add> <swarm_key_file_path>
     ./ipfs-network.sh configure manager.ipfs.com /ip4/172.18.0.3/tcp/4001/ipfs/QmPtQcKFmGWato6K5MvtAgHoVJMbermgDqdjNvVAyfozwD swarmkeygen/swarm.key
     
     
To get the address of a ipfs node container for sharing with other ipfs node, 

   ./ipfs-network.sh getaddress <container_name> 
   ./ipfs-network.sh getaddress manager.ipfs.com 


A custom container file is provided for instantiating at a new organization. The file is located at ipfsnetwork/p2p/docker-compose-custom.yml



To bring down containers manually, 

       docker stop manager.ipfs.com regulator.ipfs.com ipfscli ipfs-swarm-key-gen
         
       docker rm manager.ipfs.com regulator.ipfs.com ipfscli ipfs-swarm-key-gen
       
       # remove volumes (make sure to create backup before doing do!)
       docker volume rm p2p_manager.ipfs.com && docker volume rm  p2p_regulator.ipfs.com && docker volume prune 

         
## MultiOrg Setup

To run multi-node ipfs network (assuming multiple organizational domain) locally, run the docker-compose file within /ipfsnetwork directory 

	docker-compose -f p2p/docker-compose-multi-org.yml up -d
	

`Note that for testing purposes, 'secrets' lines have been disabled in the docker-compose files. Make sure to pass sensitive information using secure measures using files or by passing parameters through environment variables (.env)` 

We run the ipfs network in private setting and remove all external public nodes from our application setup. These can be preconfigured in the config.sh file and enabled in the docker-compose file. To setup ipfs in private settings, a swarm key can be used. Spin up swarm key generator container, 

	
       docker-compose -f swarmkeygen/docker-compose-swarm.yml up -d
    

Generate a key from the swarm key generator container and copy it to host machine, 

	docker exec -i ipfs-swarm-key-gen piskg > swarmkeygen/swarm.key

Now configure the two ipfs nodes to work in a private setting, run from bash terminal

       
        ./configure-multi.sh
         
This setsup the two nodes to use private networking by removing all public nodes, adding each others private addresses and copying swarm key. Finally a test is performed by adding a file to manager node and retreiving the file from regulator node by using the CID that was generated at the manager node during the time of file upload.

To bring down the containers manually

     docker stop ipfscli manager.ipfs.com regulator.ipfs.com farmer.ipfs.com breeder.ipfs.com  retailer.ipfs.com  consumer.ipfs.com distributor.ipfs.com processor.ipfs.com ipfs-swarm-key-gen 
     
     docker rm ipfscli manager.ipfs.com regulator.ipfs.com farmer.ipfs.com breeder.ipfs.com  retailer.ipfs.com  consumer.ipfs.com distributor.ipfs.com processor.ipfs.com ipfs-swarm-key-gen
     
## Cluster Setup
 
IPFS creates a decentralized method of storing and sharing hypermedia in a distributed file system. While IPFS itself doesn't inherently involve clustering, we can certainly set up clusters of IPFS nodes to improve pinning files and improving performance, redundancy, and availability. Pinning files ensures that they are only available on certain nodes with priority adding another layer of security and reliability. First make sure there are no other IPFS containers running. Generate a cluster secret of random 32 byte hexadecimal stringusing openssl used in docker-compose file later

	export CLUSTER_SECRET=$(openssl rand -hex 32)
	# Save it to a file
	echo $CLUSTER_SECRET > swarmkeygen/cluster_secret.txt

The cluster setup of two ipfs nodes (manager.ipfs.node and regulator.ipfs.node) and two ipfs cluster nodes  (manager.ipfs.cluster and regulator.ipfs.cluster) is split up into two docker-compose files. First, we spin up the manger setup and once its up and running we spin up the regualtor setup which takes configuration settings from the already running manager setup at runtime.  

To start the manager setup, spin up the docker-compose file


 	docker-compose -f p2p/docker-compose-cluster-manager.yml up -d
 	
The running containers connect to beefchain_ipfs network.  To setup ipfs in private settings, a swarm key can be used. Spin up swarm key generator container, 

	
       docker-compose -f swarmkeygen/docker-compose-swarm.yml up -d
    

Generate a key from the swarm key generator container and copy it to host machine, 

	docker exec -i ipfs-swarm-key-gen piskg > swarmkeygen/swarm.key
	
Now run the first bash script to configure and extract settings from the running ipfs cluster nodes. 

       ./configure-cluster-1.sh

Next source node and cluster address settings for the manager containers,

	source p2p/secrets/cluster.sh
	
Spin up the containers for regulator setup,

	docker-compose -f p2p/docker-compose-cluster-regulator.yml up -d

		
Next, run the second bash script to configure the regulator setup which also tests uploading files to manager nodes and retrieving them from regulator nodes. 

	./configure-cluster-2.sh
	
Finally, test cluster settings from any cluster node. Copy test files to regulator cluster 


	docker cp test/test_file.txt regulator.ipfs.cluster:/tmp/test_file.txt
 
Add file to cluster, 

	file_upload_info=(docker exec -it regulator.ipfs.cluster ipfs-cluster-ctl add tmp/test_file.txt)
	
	file_upload_cid=$(echo $file_upload_info | awk '{print $2}')
	
Pin uploaded file to cluster, 

	docker exec -it regulator.ipfs.cluster ipfs-cluster-ctl pin add $file_upload_cid

	
Check status of pinned files, cluster and peer nodes in the cluster  



	docker exec -it regulator.ipfs.cluster ipfs-cluster-ctl pin ls

	docker exec -it regulator.ipfs.cluster  ipfs-cluster-ctl status $file_upload_cid

	docker exec -it regulator.ipfs.cluster ipfs-cluster-ctl peers ls
	

To bring down the containers manually, 

       docker stop regulator.ipfs.cluster regulator.ipfs.node manager.ipfs.cluster manager.ipfs.node

        
       docker rm regulator.ipfs.cluster regulator.ipfs.node manager.ipfs.cluster manager.ipfs.node

