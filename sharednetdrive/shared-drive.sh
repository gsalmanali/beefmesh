#!/bin/bash

# Define functions
REPLICA_COUNT=2



hostip() {
    echo "Grabbing host network address:"
    address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
    #echo $address
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    echo "declare -x ipaddress=$address" > $SCRIPT_DIR/env/hostip.sh  
    #echo "export ipaddress="$address"" > $SCRIPT_DIR/env/env.txt  
    #echo $SCRIPT_DIR
    source "${SCRIPT_DIR}/env/hostip.sh"
    echo $ipaddress    
}




fixpermissions() {
    echo "Fixing permissions related to glusterFS settings!  May require elevated rights!"
 
    sudo chmod 777 /usr/sbin/gluster
    sudo chmod 777 /var/log/glusterfs
}


fixfolderconflict() {

    echo "Fixing issues related to glusterFS folder settings!  May require elevated rights!"
    echo "Warning! This removes all previously shared drives info! Make backup before doing so!"
    echo "Press Enter to exit or any other key to continue..."
    read -n 1 -r
    if [[ $REPLY =~ ^$ ]]; then
    	echo "Exiting the script..."
    	exit 0
    else
    	echo "Continuing with the script..."
    	sudo rm -rf /var/lib/glusterd
    	sudo rm -rf /etc/glusterd
    	sudo rm -rf /var/lib/glusterd
    fi
    

}

removefolder() {
    folder_name=$1
    if [ -z "$1" ]; then
        echo "Error! no folder name provided in argument!"
    else
        #folder_name=$1
        echo "Folder name provided: $folder_name"
        echo "Warning! This removes all previously shared drives info! Make backup before doing so!"
        echo "Press Enter to exit or any other key to continue..."
        read -n 1 -r
        if [[ $REPLY =~ ^$ ]]; then
    		echo "Exiting the script..."
    		exit 0
    	else
    		echo "Continuing with the script..."
    	 	sudo rm -rf $folder_name
        	echo "Reached end of script for removing folder $folder_name, see logs for more details!"
        fi      
    fi

}



nodestatus() {
	echo "current pool of gluster nodes! may require elevated priviliges" 
	echo "Gluster Pool list:"
        sudo gluster pool list
        echo "Gluster peer status:"
        sudo gluster peer status

}


removenode() {
    if [ -z "$1" ]; then
        echo "Error! no node name provided in argument!"
    else
        node_name=$1
        echo "Node name provided: $1"
        sudo gluster peer detach $1 force
        echo "Done removing node $node_name"
    fi


}


listvolume() {
     echo "Note down the volume name!"
     SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    
     if [ -z "$1" ]; then
        sudo gluster volume info $1
       
        volume_info=$(sudo gluster volume info $1)
    	echo "$volume_info" > $SCRIPT_DIR/env/volume_info.txt
     else
        echo "Volume Info: "
        sudo gluster volume info
        volume_info=$(sudo gluster volume info)
    	echo "$volume_info" > $SCRIPT_DIR/env/volume_info.txt
        echo "Volume List: "
        sudo gluster volume list
     fi


}


deletevolume() {
    folder_name=$1
    if [ -z "$1" ]; then
        echo "Error! no volume name provided in argument!"
    else
        #folder_name=$1
        echo "Volume name provided: $folder_name"
        echo "Warning! This removes all previously shared drives info! Make backup before doing so!"
        echo "Press Enter to exit or any other key to continue..."
        read -n 1 -r
        if [[ $REPLY =~ ^$ ]]; then
    		echo "Exiting the script..."
    		exit 0
    	else
    		echo "Continuing with the script..."
    		sudo gluster volume stop $folder_name
    	 	sudo gluster volume delete $folder_name
        	echo "Reached end of script for removing volume $folder_name, see logs for more details!"
        fi      
    fi


}


startvolume() {
    folder_name=$1
    if [ -z "$1" ]; then
        echo "Error! no volume name provided in argument!"
    else
        #folder_name=$1
        echo "Volume name provided: $folder_name"
        echo "Warning! This starts a volume! Make backup before doing so!"
        echo "Press Enter to exit or any other key to continue..."
        read -n 1 -r
        if [[ $REPLY =~ ^$ ]]; then
    		echo "Exiting the script..."
    		exit 0
    	else
    		echo "Continuing with the script..."
    		
		sudo gluster volume start $folder_name
        	echo "Succesfully started volume $folder_name"
        fi      
    fi


}

makefolder() {

    folder_path=$1
    if [ -z "$1" ]; then
        	echo "Error! no directory info provided"
        	exit 0
    else
        	if [ -d $folder_path ]; then
    			echo "Directory already exists."
		else
    			echo "Directory does not exist."
    			echo "Folder name provided: $folder_path"
        		echo "Warning! This creates a new folder! Make backup before doing so!"
        		echo "Press Enter to exit or any other key to continue..."
        		read -n 1 -r
        		if [[ $REPLY =~ ^$ ]]; then
    				echo "Exiting the script..."
    				exit 0
    			else
    				echo "Continuing with the script..."     		
				sudo mkdir -p $folder_path
        		        echo "Succesfully created folder at $folder_path"
        		fi      
    			
    			
    			
		fi       	
        	
    fi

}


configurevolume() {


    if [ "$#" -eq 3 ]; then
   
       	echo "Three input parameters provided."
       	folder_path=$3
       	host_address=$2
       	volume_name=$1    	
        if [ ! -d $folder_path ]; then
    		echo "Directory does not exists."
    		exit 0
	else    				
    		echo "Folder name provided: $folder_path"
    		echo "Host address provided: $host_address"
    		echo "Volume name provided: $volume_name"
        	echo "Warning! This starts a shared network drive! Make backup before doing so!"
        	echo "Press Enter to exit or any other key to continue..."
        	read -n 1 -r
        	if [[ $REPLY =~ ^$ ]]; then
    			echo "Exiting the script..."
    			exit 0
    		else 
    			echo "Attempting to create a shared network drive! "
    			SCRIPT_DIR=$(dirname "$(readlink -f "$0")")  
    			source "${SCRIPT_DIR}/env/hostip.sh"
   		        echo "local ip address: $ipaddress"  
    			sudo gluster volume create $volume_name replica 2 $host_address:$folder_path $ipaddress:$folder_path force
    			
    			if [ $? -ne 0 ]; then
    				echo "Error: Volume creation failed! Trying with localhost!"
    				sudo gluster volume create $volume_name replica 2 localhost:$folder_path $host_address:$folder_path force
			else
    				echo "Reached end of script for volume configuration!"
			fi
    			#sudo gluster volume create $volume_name replica 2 localhost:$folder_path $host_address:$folder_path force
    							    				
    		fi   		    			
        fi      		
    else
        echo "Not sufficient input parameters provided." 
        exit 0	        	
    fi    
}

allowtraffic() {
    if [ -z "$1" ]; then
        echo "Error! no ip address provided in argument! may require elevated priviliges!"
    else
        node_address=$1
        echo "Node address provided: $1"
        sudo iptables -I INPUT -p all -s $1 -j ACCEPT
        # sudo iptables -I INPUT -p all -s -j ACCEPT
        echo "Done removing node $node_name"
    fi


}


disallowtraffic() {
    
   if [ -z "$1" ]; then
        echo "Error! no filtername provided! may require elevated priviliges!"
    else
        if [ "$1" = "ufw" ]; then
    		echo "Input is 'ufw'."
    		sudo ufw deny 24007
    		sudo ufw reload
    	# Add your ufw-related commands here
	elif [ "$1" = "firewall" ]; then
    		echo "Input is 'firewall'."
    		sudo firewall-cmd --permanent --remove-port=24007/tcp
		sudo firewall-cmd --reload
    	# Add your firewall-related commands here
	else
    		echo "Invalid input. Please enter 'ufw' or 'firewall'."
	fi
    fi


}


restartgluster() {
	echo "restarting gluster! may require eleveated priviliges" 
	sudo systemctl stop glusterd 
	sudo systemctl restart glusterd 
	sudo systemctl enable glusterd

}


connectnode() {
        address=$1
	if [ -z "$1" ]; then
        	echo "Error! no ip address provided"
        	exit 0
    	else
        	echo "trying to connect with the node! may require elevated priviliges!"
        	sudo gluster peer probe $address
        	echo "Gluster Pool list:"
        	sudo gluster pool list
        	echo "Gluster peer status:"
        	sudo gluster peer status
        	
   	 fi

}



applyufwfilter() {
        

    	echo "Applying UFW filters! May require previliged rights!" 
    	ufw_status=$(sudo ufw status)
    	# Use a case statement to check ufw status
	if [[ $ufw_status == *"inactive"* ]]; then
    		echo "UFW is not enabled or not working! Enabling it first!"
    		sudo ufw reload
		sudo ufw enable
    		    		
	else
    		echo "UFW is enabled and working."
    		
	fi
	
    	sudo ufw allow 24007:24008/tcp
	sudo ufw allow 24009/tcp
	sudo ufw allow nfs
	sudo ufw allow samba
	sudo ufw allow samba-client
	sudo ufw allow 111/tcp
	sudo ufw allow 139/tcp
	sudo ufw allow 445/tcp
	sudo ufw allow 965/tcp
	sudo ufw allow 2049/tcp
	sudo ufw allow 38465:38469/tcp
	sudo ufw allow 631/tcp
	sudo ufw allow 111/udp
	sudo ufw allow 963/udp
	sudo ufw allow 49152:49251/tcp
	sudo ufw reload
	sudo ufw enable
	echo "Filters all set!"
        
 }
 
 

 
deleteufwfilter() {
 	echo "Deleting UFW network filters! May require previliged rights!" 
 	
 	#echo "Applying UFW filters! May require previliged rights!" 
    	ufw_status=$(sudo ufw status)
    	# Use a case statement to check ufw status
	if [[ $ufw_status == *"inactive"* ]]; then
    		echo "UFW is not enabled or not working! Enabling it first!"
    		sudo ufw reload
		sudo ufw enable
    		    		
	else
    		echo "UFW is enabled and working."
    		
	fi

	sudo ufw delete allow 24007:24008/tcp
	sudo ufw delete allow 24009/tcp
	sudo ufw delete allow nfs
	sudo ufw delete allow samba
	sudo ufw delete allow samba-client
	sudo ufw delete allow 111/tcp
	sudo ufw delete allow 139/tcp
	sudo ufw delete allow 445/tcp
	sudo ufw delete allow 965/tcp
	sudo ufw delete allow 2049/tcp
	sudo ufw delete allow 38465:38469/tcp
	sudo ufw delete allow 631/tcp
	sudo ufw delete allow 111/udp
	sudo ufw delete allow 963/udp
	sudo ufw delete allow 49152:49251/tcp
	sudo ufw reload
	sudo ufw enable
	echo "Filters all reset!"
}


disableufw() {
	echo "Disabling UFW filters: May require previliged rights!" 
 	sudo systemctl stop ufw
	sudo systemctl disable ufw
        echo "UFW filter is disabled!"
}

enableufw() {
	echo "May require previliged rights!" 
	ufw_status=$(sudo ufw status)
    	# Use a case statement to check ufw status
	if [[ $ufw_status == *"inactive"* ]]; then
    		echo "UFW is not enabled or not working! Enabling it now!"
    		sudo ufw reload
		sudo ufw enable 
		echo "UFW is enabled now!"  		
	else
    		echo "UFW is enabled and already working."    		
	fi
}

listufwfilters() {

	#echo "Applying UFW network filters! May require previliged rights!" 
    	ufw_status=$(sudo ufw status)
    	# Use a case statement to check ufw status
	if [[ $ufw_status == *"inactive"* ]]; then
    		echo "UFW is not enabled or not working! Enabling now!"   				
	else
    		echo "UFW is enabled and working."   		
	fi
 	echo "List of UFW filters: May require previliged rights!" 
 	echo "*************************************************************" 
 	sudo ufw reload
	sudo ufw enable
	sudo ufw status numbered
}
 
 
listfirewall() {
	echo "List of firewall-cmd Filters: May require previliged rights!" 
 	echo "*************************************************************" 
 	#sudo ufw reload
	#sudo ufw enable
	if sudo systemctl is-enabled firewalld &> /dev/null; then
    		echo "firewalld is enabled."
	else
    		echo "firewalld is not enabled! enabling it now!"
    		
	fi
	sudo systemctl stop firewalld
	sudo systemctl start firewalld
	sudo firewall-cmd --list-all
	sudo firewall-cmd --zone=public --list-all | awk '/^(public|services|ports|protocols|sources|destination)/ {print}'
	sudo firewall-cmd --zone=internal --list-all | awk '/^(internal|services|ports|protocols|sources|destination)/ {print}'
	


}

disablefirewall() {

	echo "Disable firewall-cmd filters! May require previliged rights! " 
	sudo systemctl stop firewalld
	sudo systemctl disable firewalld
	echo "firewall-cmd disabled!"
       
}



enablefirewall() {

	echo "Enabling firewall-cmd!  May require previliged rights!" 
 	echo "*************************************************************" 
 	#sudo ufw reload
	#sudo ufw enable
	if sudo systemctl is-enabled firewalld &> /dev/null; then
    		echo "firewalld is already enabled and working!"
	else
    		echo "firewalld is not enabled! enabling it now!"
    		sudo systemctl enable firewalld
		sudo systemctl start firewalld
    		
	fi      
}


applyfirewall() {

	echo "Applying firewall-cmd filters!  May require previliged rights!" 
 	echo "*************************************************************" 
 	#sudo ufw reload
	#sudo ufw enable
	if sudo systemctl is-enabled firewalld &> /dev/null; then
    		echo "firewalld is already enabled and working!"
	else
    		echo "firewalld is not enabled! enabling it now!"
    		sudo systemctl enable firewalld
		sudo systemctl start firewalld
		sudo firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
		sudo firewall-cmd --zone=public --add-port=24009/tcp --permanent
		sudo firewall-cmd --zone=public --add-service=nfs --add-service=samba --add-service=samba-client --permanent
		sudo firewall-cmd --zone=public --add-port=111/tcp --add-port=139/tcp --add-port=445/tcp --add-port=965/tcp --add-port=2049/tcp --add-port=38465-38469/tcp --add-port=631/tcp --add-port=111/udp --add-port=963/udp --add-port=49152-49251/tcp --permanent 
		sudo firewall-cmd --reload
    		echo "firewalld-cmd filters applied!"
	fi      


}

removefirewall() {


	echo "Removing firewall-cmd filters!  May require previliged rights!" 
 	echo "*************************************************************" 
 	#sudo ufw reload
	#sudo ufw enable
	if sudo systemctl is-enabled firewalld &> /dev/null; then
    		echo "firewalld is enabled and working!"
    		    		
	else
    		echo "firewalld is not enabled and not working! Enabling it and then removing filters!"
    		
	fi   
	
	sudo firewall-cmd --zone=public --remove-port=24007-24008/tcp --permanent
	sudo firewall-cmd --zone=public --remove-port=24009/tcp --permanent
	sudo firewall-cmd --zone=public --remove-service=nfs --remove-service=samba --remove-service=samba-client --permanent
	sudo firewall-cmd --zone=public --remove-port=111/tcp --remove-port=139/tcp --remove-port=445/tcp --remove-port=965/tcp --remove-port=2049/tcp --remove-port=38465-38469/tcp --remove-port=631/tcp --remove-port=111/udp --remove-port=963/udp --remove-port=49152-49251/tcp --permanent
	sudo firewall-cmd --reload

        echo "firewalld-cmd filters applied!"   


}


joinasclient() {

    if [ "$#" -eq 3 ]; then
   
       	echo "Three input parameters provided."
       	folder_path=$3
       	host_address=$2
       	volume_name=$1    	
        if [ ! -d $folder_path ]; then
    		echo "Directory does not exists."
    		exit 0
	else    				
    		echo "Folder name provided: $folder_path"
    		echo "Host address provided: $host_address"
    		echo "Volume name provided: $volume_name"
        	echo "Warning! This starts a shared network drive! Make backup before doing so!"
        	echo "Press Enter to exit or any other key to continue..."
        	read -n 1 -r
        	if [[ $REPLY =~ ^$ ]]; then
    			echo "Exiting the script..."
    			exit 0
    		else 
    			echo "Attempting to create a shared network drive! "
    			#SCRIPT_DIR=$(dirname "$(readlink -f "$0")")  
    			#source "${SCRIPT_DIR}/env/hostip.sh"
   		        #echo "local ip address: $ipaddress"  
    			sudo mount -t glusterfs $host_address:/$volume_name $folder_path
    			
    			if [ $? -ne 0 ]; then
    				echo "Error: Volume creation failed!"
    				#sudo gluster volume create $volume_name replica 2 localhost:$folder_path $host_address:$folder_path force
			else
    				echo "Reached end of script for configuring volume on client!"
			fi
    			#sudo gluster volume create $volume_name replica 2 localhost:$folder_path $host_address:$folder_path force
    							    				
    		fi   		    			
        fi      		
    else
        echo "Not sufficient input parameters provided." 
        exit 0	        	
    fi    


}

removebrick() {

    if [ "$#" -eq 2 ]; then   
       	echo "Three input parameters provided."
       	brick_info=$2
       	volume_name=$1    	
        echo "Brick provided: $brick_info"
    	echo "Volume name provided: $volume_name"
        echo "Warning! This removes a shared network drive! Make backup before doing so!"
        echo "Press Enter to exit or any other key to continue..."
        read -n 1 -r
        if [[ $REPLY =~ ^$ ]]; then
    		echo "Exiting the script..."
    		exit 0
    	else 
    		echo "Attempting to remove a shared network drive brick! "
    		sudo gluster volume remove-brick $volume_name replica $REPLICA_COUNT $brick_info
	        sudo gluster volume commit $volume_name
    	        if [ $? -ne 0 ]; then
    			echo "Error: Volume brick removal failed!"
    				
		else
    			echo "Reached end of script for removing volume brick!"
		fi
    				    			
        fi      		
    else
        echo "Not sufficient input parameters provided." 
        exit 0	        	
    fi    

      

}


# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [function_name]"
    exit 1
fi


address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
echo "declare -x ipaddress=$address" > $SCRIPT_DIR/env/hostip.sh  

  
 

# Case statement to handle different inputs
case "$1" in
    ipaddress) hostip ;;
    applyufw) applyufwfilter ;;
    removeufw) deleteufwfilter ;;
    listufw) listufwfilters ;;
    disableufw) disableufw ;;  
    enableufw) enableufw ;;    
    listfirewall) listfirewall ;;
    disablefirewall) disablefirewall ;;   
    enablefirewall) enablefirewall ;; 
    applyfirewall) applyfirewall ;;
    removefirewall) removefirewall ;;    
    fixfolderconflict) fixfolderconflict ;;
    fixpermissions) fixpermissions ;;
    removefolder) removefolder $2 ;;
    nodestatus) nodestatus ;;
    removenode) removenode $2 ;;
    allowtraffic) allowtraffic $2 ;;
    disallowtraffic) disallowtraffic $2 ;;
    listvolume) listvolume $2 ;;                   
    deletevolume) deletevolume $2 ;;     
    restartgluster) restartgluster ;; 
    startvolume) startvolume $2 ;; 
    connectnode) connectnode $2 ;; 
    makefolder) makefolder $2 ;;
    configurevolume) configurevolume $2 $3 $4 ;;
    joinasclient) joinasclient $2 $3 $4 ;;    
    removebrick) removebrick $2 $3 ;;
    *) echo "Invalid input. Please provide a function name as an argument." && exit 1 ;;
esac
