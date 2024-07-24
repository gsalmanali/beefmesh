# Overlay Network

Overlay network allows nodes in the network to communicate with each other regardless of their physical location or the underlying network infrastructure. Overlay networks are commonly used in peer-to-peer (P2P) systems, content delivery networks (CDNs), and virtual private networks (VPNs). It can be establisehd using docker and swarm services. We use overlay network in our application for following reasons. 

1. It allows calling containerzied applciations by their hostname or container name. There is therefore no need to individually host tons of containers for a domain name.
2. It provides a secure layer for containers to interact and isolates it from other public networks. It further makes it easier to discover services over the dedicated network.
3. It is secure, resiliant and enables efficient communication between P2P and CDN architectures. 

Setting up an overlay network requires more than one physical hosts that can be reached over internet. If you are using virtual machines for testing on the same physical host, make sure they are using 'Bridged Adapter' so that each VM gets a separate network adddress. NAT will not work for creating overlay on VMs on the same host machine because this assigns them the same network address. Further, WSL machines on windows also get the same network addresses and currently (January 2024) don't support bridged networking. The scripts provided here have been tested with VirtualBox VMs by setting network to use 'Bridged Adapter'.  

To get started, grab the network addresses of each machine and ping other machines to check if they are reachable. Run from within overlaynetwork folder. 

     # Run from within 'overlay' folder
     ./overlay-network.sh ipaddress
     
     # Replace with other hosts ip address    
      ping <other_host_ip_address>
	
The overlay-network.sh script saves environment variables in /overlaynetwork/env folder everytime its called. One of the host machines needs to start a docker swarm manager and others can join as 'manager' or 'workers' depending upon the requirements and hierarchy of network. On any one of the host machines, first remove any existing swarm network and create a new one. 

     # (Optional) Remove existing overlay network 
     ./overlay-network.sh remove
     
     # Create a new swarm overlay network 
     ./overlay-network.sh create
     
     
Successful creation of swarm overlay network stores 'manager' and 'worker' keys in /overlaynetwork/env folder (swarmmanager.txt and swarmworker.txt). These keys are needed in other host machine and should be shared and avialble in overlaynetwork/env folder before they can join the overlay network. Once the files are successfully shared and in place, run the provided script to join as 'manager' or 'worker'.

     # Join as manager 
     ./overlay-network.sh joinasmanager
     
     # Join as worker
     ./overlay-network.sh joinasworker
     
Ocassionally, an error shown below may pop up:    

`Error response from daemon: manager stopped: can't initialize raft node: rpc error: code = Unknown desc = could not connect to prospective new cluster member using its advertised address: rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial tcp x.x.x.x:2377: connect: no route to host"`

Overlay network works on specific ports which need to be configured to allow traffic coming and and out of the host network interface. To allow configuring the specific ports, either use ufw (Ubuntu) application or firewall-cmd (Debian, CentOS or others) application. To set network filters using ufw (note: may require raised priviliges!)

       # Apply ufw filters
	./overlay-network.sh applyufw
	# Remove ufw filters
	./overlay-network.sh removeufw
	# list applied ufw filters 
	./overlay-network.sh listufw
	# disable ufw application 
	./overlay-network.sh disableufw
	# enable ufw application 
	./overlay-network.sh enableufw
	
To set network filters using firewall-cmd (note: may require raised priviliges!)

	# Apply firewall filters
	./overlay-network.sh applyfirewall
	# Remove firewall filters
	./overlay-network.sh removefirewall
	# list applied firewall filters 
	./overlay-network.sh listfirewall
	# disable firewall application 
	./overlay-network.sh disablefirewall
	# enable firewall application 
	./overlay-network.sh enablefirewall	

`Note: Using both filters on a linux system will cause the same error mentioned earlier due to conflicts. For a similar error scenario, remove and disable either of the network filter application completely and apply and enable the other one!`
 
Once other hosts have joined the overlay network, create a named network that will used to connect containerized applications. (Note that this can be done on 'managers' only and since we join hosts as managers, we can create it from any host connected to the overlay network).

       # Create a named network to use on overlay 
	./overlay-network.sh createoverlay <network_name>
	# Remove a named network from overlay
      ./overlay-network.sh removeoverlay <network_name>
      

At any time, list the networks (bridge, overlay, host, null) available to use with contaiers


 	./overlay-network.sh listnetworks 


To directly source variables stored in overlaynetwork/env folder to use in bash terminal 

       # ipaddress=x.x.x.x
       source overlaynetwork/env/hostip.sh
       # swarm_manager_key
       manager_key=$(cat overlaynetwork/env/swarmmanager.txt)
       # swam_worker_key
       worker_key=$(cat overlaynetwork/env/swarmworker.txt)
       
