#!/bin/bash

# Define functions


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

leave() {
    echo "Removing and disconneting from any existing swarm network"
    if docker info | grep -q "Swarm: active"; then
    	echo "Docker Swarm is active."
    	result=$(docker swarm leave --force) 
    	echo $result    	
    else
    	echo "Docker Swarm is not active."
    fi
   
}

create() {
    echo "Creating new docker swarm network"
    if docker info | grep -q "Swarm: active"; then
    	echo "Docker Swarm is already active, Remove it first or use the info below!"
    	#result=$(docker network ls --format "table {{.ID}}\t{{.Name}}\t{{.Driver}}") 
    	echo "***********************************************************************"
    	echo "LIST OF DOCKER NETWORKS:"
    	#echo -e "NETWORK ID\tNAME\t\t\tDRIVER"
    	echo "***********************************************************************"   	
    	docker network ls
    	echo "***********************************************************************"   	
    	echo "DOCKER SWARM KEYS" 
    	echo "***********************************************************************"   	 
    	result_manager=$(docker swarm join-token manager)
    	result_worker=$(docker swarm join-token worker)
    	#dockerswarmkey=$(echo $result | grep -o 'docker swarm join --token [^ ]*')
    	swarmmanager=$(echo $result_manager | grep -o "docker swarm join .*")    
    	swarmworker=$(echo $result_worker | grep -o "docker swarm join .*")    		
    	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    	echo $swarmmanager > $SCRIPT_DIR/env/swarmmanager.txt   
    	echo $swarmworker > $SCRIPT_DIR/env/swarmworker.txt   
    	swarmmanager=$(cat $SCRIPT_DIR/env/swarmmanager.txt)
    	swarmworker=$(cat $SCRIPT_DIR/env/swarmworker.txt)
    	#source "${SCRIPT_DIR}/env/swarm.txt"
    	echo "SWARM MANAGER KEY: $swarmmanager"
    	echo "SWARM WORKER KEY: $swarmworker"
    	
    else
    	#echo "Docker Swarm is not active."
    	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    	source "${SCRIPT_DIR}/env/hostip.sh"
    	result=$(docker swarm init --advertise-addr $ipaddress)
    	#dockerswarmkey=$(echo $result | grep -o 'docker swarm join --token [^ ]*' | sed 's/.$//')
    	echo "***********************************************************************"   	
    	echo "DOCKER SWARM KEYS" 
    	echo "***********************************************************************"   	 
    	result_manager=$(docker swarm join-token manager)
    	result_worker=$(docker swarm join-token worker)
    	#dockerswarmkey=$(echo $result | grep -o 'docker swarm join --token [^ ]*')
    	swarmmanager=$(echo $result_manager | grep -o "docker swarm join .*")    
    	swarmworker=$(echo $result_worker | grep -o "docker swarm join .*")    		
    	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    	echo $swarmmanager > $SCRIPT_DIR/env/swarmmanager.txt   
    	echo $swarmworker > $SCRIPT_DIR/env/swarmworker.txt   
    	swarmmanager=$(cat $SCRIPT_DIR/env/swarmmanager.txt)
    	swarmworker=$(cat $SCRIPT_DIR/env/swarmworker.txt)
    	#source "${SCRIPT_DIR}/env/swarm.txt"
    	echo "SWARM MANAGER KEY: $swarmmanager"
    	echo "SWARM WORKER KEY: $swarmworker"    	
    	
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
	
    	sudo ufw allow 22/tcp
	sudo ufw allow 2376/tcp
	sudo ufw allow 2377/tcp
	sudo ufw allow 7946/tcp
	sudo ufw allow 7946/udp
	sudo ufw allow 4789/udp
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
	sudo ufw delete allow 80/tcp
	sudo ufw delete allow 22/tcp
	sudo ufw delete allow 2376/tcp
	sudo ufw delete allow 2377/tcp
	sudo ufw delete allow 7946/tcp
	sudo ufw delete allow 7946/udp
	sudo ufw delete allow 4789/udp
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
		sudo firewall-cmd --add-port=2377/tcp --permanent
                sudo firewall-cmd --add-port=7946/tcp --permanent
                sudo firewall-cmd --add-port=7946/udp --permanent
                sudo firewall-cmd --add-port=4789/udp --permanent
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
	
	sudo systemctl enable firewalld
	sudo systemctl start firewalld
	sudo firewall-cmd --remove-port=2377/tcp --permanent
        sudo firewall-cmd --remove-port=7946/tcp --permanent
        sudo firewall-cmd --remove-port=7946/udp --permanent
        sudo firewall-cmd --remove-port=4789/udp --permanent
        sudo firewall-cmd --reload
        echo "firewalld-cmd filters applied!"   


}


listnetworks() {

	echo "***********************************************************************"
    	echo "LIST OF DOCKER NETWORKS:"
    	#echo -e "NETWORK ID\tNAME\t\t\tDRIVER"
    	echo "***********************************************************************"   	
    	docker network ls


}

joinasmanager() {

    if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q '^active$'; then
    	echo "This node is not part of a Docker Swarm! Trying to connect as a docker swarm manager!"
    	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    	address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
    	#echo $address
    	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    	echo "declare -x ipaddress=$address" > $SCRIPT_DIR/env/hostip.sh  
    	source "${SCRIPT_DIR}/env/hostip.sh"
    	echo "IPAddress: $ipaddress"
    	#echo "export ipaddress="$address"" > $SCRIPT_DIR/env/env.txt  
    	#echo $SCRIPT_DIR
    	file_path="${SCRIPT_DIR}/env/swarmmanager.txt"    	
    	if [ -e "$file_path" ]; then
    		echo "File exists"
    		swarmmanager=$(cat $SCRIPT_DIR/env/swarmmanager.txt)
        else
    		echo "File at location overlaynetwork/env/swarmmanager.txt with key does not exist!"
    		exit 1
        fi
        
        echo "Trying to join now!"
        log_file="${SCRIPT_DIR}/logs/logs.txt"  
        if output=$($swarmmanager "--advertise-addr" "$ipaddress" 2>&1); then
        	echo "Joined Docker swarm successfully as manager!"
        else
        	echo $output > ${SCRIPT_DIR}/logs/logs.txt 
        	echo "Failed to join Docker swarm. See $log_file for details."
        fi
         
    else
        node_role=$(docker node inspect self --format '{{.Spec.Role}}')

        if [ "$node_role" = "manager" ]; then
    		echo "This node is already running as a manager in the Docker Swarm."
    		result_manager=$(docker swarm join-token manager)
    		result_worker=$(docker swarm join-token worker)
    		#dockerswarmkey=$(echo $result | grep -o 'docker swarm join --token [^ ]*')
    		swarmmanager=$(echo $result_manager | grep -o "docker swarm join .*")    
    		swarmworker=$(echo $result_worker | grep -o "docker swarm join .*")    		
    		SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    		echo $swarmmanager > $SCRIPT_DIR/env/swarmmanager.txt   
    		echo $swarmworker > $SCRIPT_DIR/env/swarmworker.txt   
    		swarmmanager=$(cat $SCRIPT_DIR/env/swarmmanager.txt)
    		swarmworker=$(cat $SCRIPT_DIR/env/swarmworker.txt)
    		#source "${SCRIPT_DIR}/env/swarm.txt"
    		echo "SWARM MANAGER KEY: $swarmmanager"
    		echo "SWARM WORKER KEY: $swarmworker"
    		    		    		
        elif [ "$node_role" = "worker" ]; then
    		echo "This node is running as a worker in the Docker Swarm."
        else
    		echo "Failed to determine the role of this node."
       fi     	
    	
    	#exit 1
    fi

    # Check if the node is a manager or worker


}


joinasworker() {

    if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q '^active$'; then
    	echo "This node is not part of a Docker Swarm! Trying to connect as a docker swarm worker!"
    	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    	address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
    	#echo $address
    	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    	echo "declare -x ipaddress=$address" > $SCRIPT_DIR/env/hostip.sh  
    	source "${SCRIPT_DIR}/env/hostip.sh"
    	echo "IPAddress: $ipaddress"
    	#echo "export ipaddress="$address"" > $SCRIPT_DIR/env/env.txt  
    	#echo $SCRIPT_DIR
    	file_path="${SCRIPT_DIR}/env/swarmworker.txt"    	
    	if [ -e "$file_path" ]; then
    		echo "File exists"
    		swarmworker=$(cat $SCRIPT_DIR/env/swarmworker.txt)
        else
    		echo "File at location overlaynetwork/env/swarmworker.txt with key does not exist!"
    		exit 1
        fi
        
        echo "Trying to join now!"
        log_file="${SCRIPT_DIR}/logs/logs.txt"  
        if output=$($swarmworker 2>&1); then
        	echo "Joined Docker swarm successfully as worker!"
        else
        	echo $output > ${SCRIPT_DIR}/logs/logs.txt 
        	echo "Failed to join Docker swarm. See $log_file for details."
        fi
         
    else
        node_role=$(docker node inspect self --format '{{.Spec.Role}}')

        if [ "$node_role" = "manager" ]; then
    		echo "This node is already running as a manager in the Docker Swarm."
    		result_manager=$(docker swarm join-token manager)
    		result_worker=$(docker swarm join-token worker)
    		#dockerswarmkey=$(echo $result | grep -o 'docker swarm join --token [^ ]*')
    		swarmmanager=$(echo $result_manager | grep -o "docker swarm join .*")    
    		swarmworker=$(echo $result_worker | grep -o "docker swarm join .*")    		
    		SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    		echo $swarmmanager > $SCRIPT_DIR/env/swarmmanager.txt   
    		echo $swarmworker > $SCRIPT_DIR/env/swarmworker.txt   
    		swarmmanager=$(cat $SCRIPT_DIR/env/swarmmanager.txt)
    		swarmworker=$(cat $SCRIPT_DIR/env/swarmworker.txt)
    		#source "${SCRIPT_DIR}/env/swarm.txt"
    		echo "SWARM MANAGER KEY: $swarmmanager"
    		echo "SWARM WORKER KEY: $swarmworker"
    		    		    		
        elif [ "$node_role" = "worker" ]; then
    		echo "This node is already running as a worker in the Docker Swarm."
        else
    		echo "Failed to determine the role of this node."
       fi     	
    	
    	#exit 1
    fi


}


createoverlay() {

    if [ -z "$1" ]; then
        echo "Error! no overlay network name provided in argument!"
    else
        overlay_network_name=$1
        echo "Network name provided: $1"
        docker network create -d overlay --attachable $overlay_network_name
        echo "Succesfully created overlay network $overlay_network_name"
    fi

}


removeoverlay() {
    if [ -z "$1" ]; then
        echo "Error! no overlay network name provided in argument!"
    else
        overlay_network_name=$1
        echo "Network name provided: $1"
        docker network rm $overlay_network_name
        echo "Succesfully removed overlay network $overlay_network_name"
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
    remove) leave ;;
    create) create ;;
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
    listnetworks) listnetworks ;;
    joinasmanager) joinasmanager ;;
    joinasworker) joinasworker ;;
    createoverlay) createoverlay $2 ;;
    removeoverlay) removeoverlay $2 ;;
    *) echo "Invalid input. Please provide a function name as an argument." && exit 1 ;;
esac
