# Network Shared Drive



Network shared drive serves as an alternative  mechanism for quickly accessing shared beef chain application critical files instead of sharing them from the central beefchain application. Network shared drive applications require dedicated servers spinning up an application and a shared folder to which clients can connect and upload/download documents. We use GlusterFS (https://www.gluster.org/) in our beef chain application to spin up atleast two dedicated servers (in a collaboration group) to which client hosts can connect and start a shared folder.  

`It is advisable to use unallocated disk partitions that are mounted on run time for shared network drives instead of a shared folder in system or root parititon to avoid data conflicts or data loss`


## Getting Started

Setting up a shared network folder requires more than one physical hosts that can be reached over internet. If you are using virtual machines for testing on the same physical host, make sure they are using 'Bridged Adapter' so that each VM gets a separate network adddress. NAT will not work for creating shared network drive/folder on VMs on the same host machine because this assigns them the same network address. Further, WSL machines on windows also get the same network addresses and currently (January 2024) don't support bridged networking. The scripts provided here have been tested with VirtualBox VMs by setting network to use 'Bridged Adapter'. 


 `Note that GlusterFs works with a minimum of two hosts nodes working as servers to which other client nodes can attach and start a shared volume. For the remainder of tutorial, We will make a distinction of whether the script function should be called on a server or client where required. Also, most of the commands below require raised priviliges so make sure to check whether its safe to run it or not before hand! `

To get started, grab the network addresses of each machine and ping other machines to check if they are reachable. Run from within /sharednetdrive folder. 
       
       
       # Run from within 'overlay' folder
 	./shared-drive.sh ipaddress

 	# Replace with other hosts ip address    
 	 ping <other_host_ip_address>
 	 
 The shared-drive.sh script saves environment variables in /sharednetdrive/env folder everytime its called. 
 
## Applying Net Filters
 
 `Note: This is applicable on Server and Client`
 
 Shared net drive works on specific ports which need to be configured to allow traffic coming and and out of the host network interface. To allow configuring the specific ports, either use ufw (Ubuntu) application or firewall-cmd (Debian, CentOS or others) application. To set network filters using ufw (note: may require raised priviliges!), run from within /sharednetdrive folder
 
        # Apply ufw filters
	./shared-drive.sh applyufw
	# Remove ufw filters
	./shared-drive.sh removeufw
	# list applied ufw filters 
	./shared-drive.sh listufw
	# disable ufw application 
	./shared-drive.sh disableufw
	# enable ufw application 
	./shared-drive.sh enableufw
	
`Note: Using both filters on a linux system will cause the same error mentioned earlier due to conflicts. For a similar error scenario, remove and disable either of the network filter application completely and apply and enable the other one!`
	
To set network filters using firewall-cmd (note: may require raised priviliges!), run from within /sharednetdrive folder

	# Apply firewall filters
	./shared-drive.sh applyfirewall
	# Remove firewall filters
	./shared-drive.sh removefirewall
	# list applied firewall filters 
	./shared-drive.sh listfirewall
	# disable firewall application 
	./shared-drive.sh disablefirewall
	# enable firewall application 
	./shared-drive.sh enablefirewall	


 
## Removing Shared Folder


 `Note: This is applicable on Server and Client`

We make a distinction between folder and volume here. A folder is a directory on host machine which when shared over network is seen as a volume with a specific name. Hence different folders on different hosts with different paths can be mapped to one volume. To remove any lingering folders and volumes from previous GlusterFS configurations and to start a new, first check for any existing  volumes 

       # If you don't know any volumes
	 ./shared-drive.sh listvolume 
	 
	 # If you know the volume name (e.g. beefchainvolume) and need details
	 ./shared-drive.sh listvolume beefchainvolume
 
 
Calling the 'listvolume' function stores details of volumes listed under gluster in shardnetdrive/env/volume_info.txt for future reference. Once you know the volume name (e.g. beefchainvolume), you can delete the volume (make sure to create a backup before doing so!)
 
      
	 ./shared-drive.sh deletevolume <replace_volume_name_here>
	 
Once the volume has been deleted, you can now safely remove the folder from the host (make backup before doing so!)

       # To remove a shared folder from host (e.g. /tmp/shared-beefchain-folder)
       ./shared-drive.sh removefolder <replace_full_folder_path_here>
       
If the volume still persists, then remove the bricks before attempting to proceed to delete volume. Bricks information can be viewed by listing volume information and brick can be removed by

	# Assumes volume replica count 2! Change variable 'REPLICA_COUNT' in script if its different 
	./shared-drive.sh removebrick <volume_name> <brick_to_remove>
	
	# Call to removebrick method with example paramaters
	./shared-drive.sh removebrick beefchain 192.168.1.13:/tmp/beefchain-storage
 
## Configuring Shared Folder
 
 `Note: This is applicable on Server`

To start configuring a shared volume, first create a folder on the host (server) machine. It is recommende that a new parition is formatted and used instead of using a folder that is created on s system (root) directory. The commands use '--force' flag to create folder or volume so make sure you are not passing a sensitive folder path. First create a shared folder that will be used for gluster volume
	
       # Create a folder to use, e.g. /tmp/beefchain-shared-folder
       ./shared-drive.sh makefolder <replace_full_folder_path_here>
       
  
Next, connect to a second server node (note that GlusterFS require minimum two server nodes)


       # Make sure the other node (e.g. 192.168.1.25) can be pinged first
       ./shared-drive.sh connectnode <replace_node_ipaddress_here>
       
If there are issues connecting between server node, modify iptables to allow traffic as described in section ##  Modify IPtables
Once the nodes are successfully connected, you can check node status 

	./shared-drive.sh nodestatus
	
	
The above command should return a set of connected nodes, e.g. 
	
	
	UUID					Hostname    	State
	292d2c93-e7f3-44a4-b7f2-8f1da5759a20	192.168.1.13	Connected 
	e378b375-8106-4f42-bf89-b28db00cf186	localhost   	Connected 
	
Once the host server shows up as connected, configure a shared volume

         
         # Generic command (replace with exact parameters)
	./shared-drive.sh configurevolume <volume_name_here> <host_address_here> <folder_path_here>
	 
	 # Above command with specific example parameters 
	./shared-drive.sh configurevolume beefchain 192.168.1.21 /tmp/beefchain-shared-folder
	
Once the shared volume has been successfully configured, start the volume for other clients to access

	./shared-drive.sh startvolume <replace_volume_name_here>
	
Check status of volume 

	 # If you don't know any volumes
	 ./shared-drive.sh listvolume 
	 
	 # If you know the volume name (e.g. beefchain) and need details
	 ./shared-drive.sh listvolume beefchain
 
	
To remove a specific server node (e.g. 192.168.1.25) from the gluster server setup, first make backup of volumes shared with the server, stop the volume, delete it and then proceed to removing the node


	./shared-drive.sh removenode <replace_node_ipaddress_here>
	

## Modify IPTables

If there are issues connecting between servers despite being able to ping them,


	# To allow incoming traffic from a host server (e.g. 192.168.2.31)
	# Run on all hosts (client and and server)
	./shared-drive.sh allowtraffic <replace_node_ipaddress_here>
	
	# To disallow traffic from a specific host for safety purposes 
	./shared-drive.sh disallowtraffic <replace_node_ipaddress_here>
	
 
## Join as Client

Once a minimum of two server nodes have been configured properly, a gluster client can connect to the servers and with  a local folder where all the shared content over gluster volume is synched! Before doing so make sure that the client can ping any of the server nodes, has a local folder setup with proper permissions and knows the volume name configured over the gluster servers.  

	  # Generic command (replace with exact parameters)
	./shared-drive.sh joinasclient <volume_name_here> <server_address_here> <local_folder_path_here>
	 
	 # Above command with specific example parameters 
	./shared-drive.sh joinasclient beefchain 192.168.1.35 /tmp/beefchain-local-folder
	
	
## Testing Volume 

To test the configured shared network drive, simply move a file to the shared folder in any host and it should appear shortly in the shared folder on other hosts

	cp BeefMesh/sharednetdrive/test-file.txt /tmp/beefchain-shared-folder/test-file.txt

       
## Debugging Issues

 `Note: This is applicable on Server and Client`

If gluster daemon is not running, restart it  

	
	./shared-drive.sh restartgluster

If previously created shared volumes are causing issues

	# Remove caches and earlier volume related data (make backup before doing so!) 
	./shared-drive.sh fixfolderconflict
	
	# Fix permissions for gluster application
	./shared-drive.sh fixpermissions

Removing cache and other related files from gluster library for previously configured volumes may generate extra messages (particularly related to geographic data) such as below but does not interfere with normal operation. This was tested for glusterfs 10.1.
 

    Traceback (most recent call last):
    File "/usr/lib/x86_64-linux-gnu/glusterfs/python/syncdaemon/gsyncd.py", line 325, in <module> main()
    File "/usr/lib/x86_64-linux-gnu/glusterfs/python/syncdaemon/gsyncd.py", line 41, in main
    argsupgrade.upgrade()
    File "/usr/lib/x86_64-linux-gnu/glusterfs/python/syncdaemon/argsupgrade.py", line 85, in upgrade
    init_gsyncd_template_conf()
    File "/usr/lib/x86_64-linux-gnu/glusterfs/python/syncdaemon/argsupgrade.py", line 50, in init_gsyncd_template_conf
    fd = os.open(path, os.O_CREAT | os.O_RDWR)
    FileNotFoundError: [Errno 2] No such file or directory: '/var/lib/glusterd/geo-replication/gsyncd_template.conf'
 
