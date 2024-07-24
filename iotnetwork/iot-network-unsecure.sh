#!/bin/bash

# Define functions

MF_USERS_ADMIN_EMAIL='admin@example.com'
MF_USERS_ADMIN_PASSWORD='12345678'


hostip() {
    echo "Grabbing host network address:"
    address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
    #echo $address
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    echo "declare -x ipaddress=\"$address\"" > $SCRIPT_DIR/env/hostip.sh  
    #echo "export ipaddress="$address"" > $SCRIPT_DIR/env/env.txt  
    #echo $SCRIPT_DIR
    source "${SCRIPT_DIR}/env/hostip.sh"
    echo $ipaddress    
}


copyenv() {


    if [ -z "$1" ]; then
        echo "Error! no argument provided!"
    else
        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
        cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/bootstrap/ 
        cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/certs/ 
        cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/provision/ 
        cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/vault/  
        case "$1" in
    	    "all")
        	echo "All selected"
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/mongodb-writer/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/mongodb-reader/
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/postgres-writer/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/postgres-reader/
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/influxdb-writer/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/influxdb-reader/
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/timescale-writer/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/timescale-reader/
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/twins/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/smtp-notifier/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/smpp-notifier/
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/lora-adapter/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/cassandra-reader/ 
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/cassandra-writer/ 
        	;;
    	    "mongodb")
        	echo "Mongodb selected"
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/mongodb-writer/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/mongodb-reader/
        	;;
            "postgres")
        	echo "Postgres selected"
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/postgres-writer/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/postgres-reader/
        	;;
            "influxdb")
        	echo "influxdb selected"
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/influxdb-writer/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/influxdb-reader/
        	;;
            "timescale")
        	echo "timescale selected"
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/timescale-writer/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/timescale-reader/
        	;;
            "twins")
        	echo "twins selected"
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/twins/ 
        	;;
            "notifier")
        	echo "smtp selected"
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/smtp-notifier/ 
		cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/smpp-notifier/
        	;;
            "adapter")
        	echo "lora selected"
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/lora-adapter/ 
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/opcua-adapter/ 
        	;;
            "cassandra")
        	echo "cassandra selected"
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/cassandra-reader/ 
        	cp $SCRIPT_DIR/docker/.* $SCRIPT_DIR/docker/addons/cassandra-writer/ 
        	;;
    	    *)
              	echo "Invalid option"
       		 ;;
	esac
    fi
}


configureadmin() {

	user_email=$1
	user_pass=$2 
	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
        file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
	if [ ! -f "$file_path" ]; then
    		# If the file doesn't exist, create it using touch command
    		touch "$file_path"
    		echo "configuring settings for admin first!"
    		echo "File created: $file_path"
    	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    	        #curl -s -S -i --cacert "$SCRIPT_DIR/docker/ssl/certs/ca.crt" -X POST -H "Content-Type: application/json" https://localhost/tokens -d "{\"email\":\"$user_email\", \"password\":\"$user_pass\"}"
    	        curl -s -S -i -X POST -H "Content-Type: application/json" http://$iot_server_address/tokens -d "{\"email\":\"$user_email\", \"password\":\"$user_pass\"}" > $SCRIPT_DIR/logs/log.txt
    	        
	        file_content=$(<$SCRIPT_DIR/logs/log.txt)
	        #echo $file_content
	        user_token=$(echo $file_content | grep -o '"token":"[^"]*' | grep -o '[^"]*$')
	        #echo $user_token
	        if [ -n "$user_token" ]; then
    			#echo "User $user_email is logged in with token: $user_token"
    			file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
			if [ ! -f "$file_path" ]; then
    			# If the file doesn't exist, create it using touch command
    				touch "$file_path"
    				echo "File created: $file_path"
    				echo "declare -x user_token=\"$user_token\"" > $SCRIPT_DIR/env/tokens/$user_email.sh 
			else
    				#echo "File already exists: $file_path"
    				echo "declare -x user_token=\"$user_token\"" > $SCRIPT_DIR/env/tokens/$user_email.sh 
    				
			fi  			
    		else
    			echo "Some issues with configuring admin! Error details: $(grep "error" $SCRIPT_DIR/logs/log.txt)"
    		fi
	        curl -s -S -i -X GET -H "Authorization: Bearer $user_token" http://$iot_server_address/users > $SCRIPT_DIR/logs/log.txt
	        reponse=$(curl -s -S -i -X GET -H "Authorization: Bearer $user_token" http://$iot_server_address/users)
	        file_content=$(<$SCRIPT_DIR/logs/log.txt)
	        #users_data=$(echo "'$file_content'" | jq '.users')
	        data=$(sed -n '/^{/,/^}$/p' $SCRIPT_DIR/logs/log.txt)
		echo "$data"
	        #echo $users_data
	        #admin_id=$(echo "$suers_data" | jq -r ".users[] | select(.email == 'admin@example.com') | .id")
	        #echo $users_data
	        admin_id=$(echo "$data" | jq -r '.users[] | select(.email == "admin@example.com") | .id')
	        #admin_id=$(echo "$data" | sed -E 's/.*"id":"([^"]+)".*/\1/')
	        echo $admin_id

	        #admin_id=$(echo "'$users_data'" | jq -r '.users[0].id')s
		#echo "$admin_id"
		#admin_id=$(echo $users_data | jq -r '.[] | select(.email == "admin@example.com").id')	       
	        #echo $reponse
	        #user_ID=$(echo "$file_content" | jq -r '.Users[] | select(.email == "admin@example.com") | .id')  
	        #admin_id=$(echo "$file_content" | grep -o '"id":"[^"]*"' | awk -F '"' '{print $4}')
                #email_to_search=$user_email
                #echo $email_to_search
                #admin_id=$(echo "'$reponse'" | grep -o "\"email\":\"$email_to_search\"" | head -n1 | awk -F '"' '{print $4}')        
	        #echo $admin_ID  	
    		echo "declare -x user_id=\"$admin_id\"" > $SCRIPT_DIR/env/users/$user_email.sh 
	else
    		echo "Admin is configured properly!"
	fi
	        

}

newuser() {

	if [ "$#" -ne 1 ]; then
	        user_email=$1
	        user_pass=$2
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	        curl -s -S -i -X POST -H "Content-Type: application/json" http://$iot_server_address/users -d "{\"email\":\"$user_email\", \"password\":\"$user_pass\"}" > $SCRIPT_DIR/logs/log.txt
	        #http_code1=$(grep "HTTP/2" $SCRIPT_DIR/logs/log.txt)
		file_content=$(<$SCRIPT_DIR/logs/log.txt)
	        #http_code1=$(grep "HTTP/2" $SCRIPT_DIR/logs/log.txt)
		user_ID=$(grep -i "location" $SCRIPT_DIR/logs/log.txt)
		user_ID=$(echo $user_ID | awk -F '[Ll]ocation: /users/' '{print $2}')
		#http_code1=$(echo $http_code1 | sed 's/[^0-9]*//g')
		#http_code1="${http_code1:1}"
		http_code1=$(echo -e "$file_content" | grep -Eo 'HTTP/[0-9.]+ [0-9]+' | awk '{print $2}')
		if  [ "$http_code1" == "201"  ] ;then   
    			echo "Successfully created user $user_email to manage IoT devices! Here is the ID: $user_ID"
    			file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
			if [ ! -f "$file_path" ]; then
    			# If the file doesn't exist, create it using touch command
    				touch "$file_path"
    				echo "File created: $file_path"
    				echo "declare -x user_id=\"$user_ID\"" > $SCRIPT_DIR/env/users/$user_email.sh 
			else
    				echo "File already exists: $file_path"
			fi
    			
    		
		else
    			echo "Unable to create user $user_email! Error details: $(grep "error" $SCRIPT_DIR/logs/log.txt)"
    			exit 1
		fi

    		
	else 
		echo "Not enough arguments provided"
	
	fi



}

getid() {

    if [ -z "$1" ]; then
        echo "Error! no email provided!"
    else
        user_email=$1
        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
        file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
	if [ ! -f "$file_path" ]; then
		echo "file and credentials don't exist!"
	else
	   source $SCRIPT_DIR/env/users/$user_email.sh
	   echo "ID: $user_id"
	fi
       
    fi
}


signin() {


	if [ "$#" -ne 1 ]; then
	        user_email=$1
	        user_pass=$2
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	        curl -s -S -i -X POST -H "Content-Type: application/json" http://$iot_server_address/tokens -d "{\"email\":\"$user_email\", \"password\":\"$user_pass\"}" > $SCRIPT_DIR/logs/log.txt
	        file_content=$(<$SCRIPT_DIR/logs/log.txt)
	        user_token=$(echo $file_content | grep -o '"token":"[^"]*' | grep -o '[^"]*$')
		if [ -n "$user_token" ]; then
    			echo "User $user_email is logged in with token: $user_token"
    			file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
			if [ ! -f "$file_path" ]; then
    			# If the file doesn't exist, create it using touch command
    				touch "$file_path"
    				echo "File created: $file_path"
    				echo "declare -x user_token=\"$user_token\"" > $SCRIPT_DIR/env/tokens/$user_email.sh 
			else
    				#echo "File already exists: $file_path"
    				echo "declare -x user_token=\"$user_token\"" > $SCRIPT_DIR/env/tokens/$user_email.sh 
    				
			fi  			
    		else
    			echo "Unable to signin user $user_email! Error details: $(grep "error" $SCRIPT_DIR/logs/log.txt)"
    		fi
	else 
		echo "Not enough arguments provided"
	
	fi




}


gettoken() {

    if [ -z "$1" ]; then
        echo "Error! no email provided!"
    else
        user_email=$1
        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
        file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
	if [ ! -f "$file_path" ]; then
		echo "file and credentials don't exist!"
	else
	   source $SCRIPT_DIR/env/tokens/$user_email.sh
	   echo "UserEmail: $user_email"
	   echo "Token: $user_token"
	fi
       
    fi
}


checktoken() {



    if [ "$#" -ne 1 ]; then
	        user_email=$1
	        user_pass=$2
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
        	file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	source $file_path
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
			if [ ! -f "$file_path" ]; then
				echo "user has not signed in yet so no token exist! use signin route!"
			else
	   			source $SCRIPT_DIR/env/tokens/$user_email.sh
	   			echo "UserEmail: $user_email"
	   			echo "Token: $user_token"
	   			
	   			file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
	   			source $file_path
	   			url_link=http://$iot_server_address/users/$user_id
	   	                # removing \r from end 
	   	                url_link=${url_link%$'\r'} 
	   	                echo $url_link
	   	                echo $user_token
	   	                echo "Checking token validity now! If its unauthorized, signin to refresh token!"
	   	                
	   	                curl -s -S -i -X GET -H "Authorization: Bearer $user_token" $url_link
	   	                #response=$(curl -s -S -i -X GET -H "Authorization: Bearer $user_token" $url_link)
	   	        
			fi
		fi
    else
    		echo "not enough arguments provided!"
    fi
        	 	
	       
}


allusers() {



    if [ "$#" -ne 1 ]; then
	        user_email=$1
	        user_pass=$2
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
        	file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	source $file_path
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
			if [ ! -f "$file_path" ]; then
				echo "user has not signed in yet so no token exist! use signin route!"
			else
	   			source $SCRIPT_DIR/env/tokens/$user_email.sh
	   			echo "UserEmail: $user_email"
	   			echo "Token: $user_token"
	   			
	   			file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
	   			source $file_path
	   			url_link=http://$iot_server_address/users
	   	                # removing \r from end 
	   	                #url_link=${url_link%$'\r'} 
	   	                echo $url_link
	   	                echo $user_token
	   	                echo "Checking token validity now! If its unauthorized, signin to refresh token!"
	   	                
	   	                curl -s -S -i -X GET -H "Authorization: Bearer $user_token" $url_link
	   	                #response=$(curl -s -S -i -X GET -H "Authorization: Bearer $user_token" $url_link)
	   	        
			fi
		fi
    else
    		echo "not enough arguments provided!"
    fi
        	 	
	       
}


createsensor() {

    if [ "$#" -ne 2 ]; then
	        user_email=$1
	        user_pass=$2
	        sensor_name=$3
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	        #SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
        	file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	source $file_path
        	 	source $SCRIPT_DIR/env/users/$user_email.sh
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
			if [ ! -f "$file_path" ]; then
				echo "user has not signed in yet so no token exist! use signin route!"
			else
	   			source $SCRIPT_DIR/env/tokens/$user_email.sh
	   			echo "UserEmail: $user_email"
	   			echo "Token: $user_token"
	   			echo "User ID: $user_id"
	   			
	   			#file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
	   			#source $file_path
	   			#url_link=http://localhost/users
	   	                # removing \r from end 
	   	                #url_link=${url_link%$'\r'} 
	   	                #echo $url_link
	   	                #echo $user_token
	   	                #echo "Checking token validity now! If its unauthorized, signin to refresh token!"
	   	                curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $user_token" http://$iot_server_address/things/bulk -d '[{"name": "'"$sensor_name"'"}]' > $SCRIPT_DIR/logs/log.txt
	   	                file_content=$(<$SCRIPT_DIR/logs/log.txt)
	   	                sensor_id=$(echo $file_content | grep -o '"id":"[^"]*' | grep -o '[^"]*$')
				sensor_key=$(echo $file_content | grep -o '"key":"[^"]*' | grep -o '[^"]*$')	
				echo $sensor_id
				echo $sensor_key				
				file_path="$SCRIPT_DIR/env/things/$sensor_name.sh" 
				if [ ! -f "$file_path" ]; then
    			# If the file doesn't exist, create it using touch command
    					touch "$file_path"
    					echo "File created: $file_path"
    					echo "declare -x sensor_id=\"$sensor_id\"" > $SCRIPT_DIR/env/things/$sensor_name.sh 
    					echo "declare -x user_id=\"$user_id\"" >> $SCRIPT_DIR/env/things/$sensor_name.sh 
    					#echo "declare -x user_key=\"$user_key\"" > $SCRIPT_DIR/env/things/$sensor_name.sh 
    					file_path="$SCRIPT_DIR/env/keys/$sensor_name.sh" 
					if [ ! -f "$file_path" ]; then
						
						touch "$file_path"
    						echo "File created: $file_path"
    						echo "declare -x sensor_key=\"$sensor_key\"" > $SCRIPT_DIR/env/keys/$sensor_name.sh 
    					else 
    						echo "can't write sensor key to file!"
    					fi
    				else 
    					echo "sensor with the same name has already been registered! "
    				fi
			
			fi
			
		fi
			
		
    else 
    		echo "not enough (email, pass, sensorname) arguments provided!"	
    fi
        	 	

}


getthings() {


 	if [ "$#" -ne 1 ]; then
	        user_email=$1
	        user_pass=$2
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	        #SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
        	file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
        	 	if [ ! -f "$file_path" ]; then
        			echo "user does not have a registered key on record! signin to generate key first!"
        		else 
        			
        			source $SCRIPT_DIR/env/tokens/$user_email.sh
        			echo "User Token: $user_token"
        			echo "Getting all sensor devices that the user registered!"
        			curl -s -S -i -X GET -H "Authorization: Bearer $user_token" http://$iot_server_address/things > $SCRIPT_DIR/logs/log.txt
        			file_content=$(<$SCRIPT_DIR/logs/log.txt)
        			echo "Here is the reponse from the platform!"
        			echo $file_content
        			

        		
        		fi 
        	 	
        	 	
        	
        	
        	fi
        else 
        	echo "not enough arguments provided!"
        fi



}


createchannel() {

	if [ "$#" -ne 2 ]; then
		user_email=$1
		user_pass=$2
		channel_name=$3
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
		file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	source $SCRIPT_DIR/env/users/$user_email.sh
        	 	echo $user_id
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
        	 	if [ ! -f "$file_path" ]; then
        			echo "user does not have a registered token on record! signin to generate token first!"
        		else 
        			file_path="$SCRIPT_DIR/env/channels/$channel_name.sh" 
        			if [ ! -f "$file_path" ]; then
        				touch $file_path  
        				echo "File created: $file_path"
        				file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
        				source $file_path
        				#echo $user_token			        
        				#source $SCRIPT_DIR/env/channel/$user_email.sh
        				echo "User Token: $user_token"
        				echo "Creating a channel with name $channel_name!"
        				curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $user_token" http://$iot_server_address/channels/bulk -d '[{"name": "'"$channel_name"'"}]' > $SCRIPT_DIR/logs/log.txt
        				
					file_content=$(<$SCRIPT_DIR/logs/log.txt)
        				echo "Here is the reponse from the platform!"
        				echo $file_content
        				channel_id=$(echo $file_content | grep -o '"id":"[^"]*' | grep -o '[^"]*$')
        				#file_path="$SCRIPT_DIR/env/channels/$channel_name.sh" 
        				
    					echo "declare -x channel_id=\"$channel_id\"" > $SCRIPT_DIR/env/channels/$channel_name.sh 
    					echo "declare -x user_id=\"$user_id\"" >> $SCRIPT_DIR/env/channels/$channel_name.sh 
    				else 
    					echo "channel with name $channel_name is already registered!"
    				fi
        				     		
        		fi 
        	 	
        	 	
        	
        	
        	fi
		
		
		
	
	else 
	
		echo "not enough arguments (user email, pass, channelname) provided!"
	
	fi

}


getchannels() {


 	if [ "$#" -ne 1 ]; then
	        user_email=$1
	        user_pass=$2
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	        #SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
        	file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
        	 	if [ ! -f "$file_path" ]; then
        			echo "user does not have a registered key on record! signin to generate key first!"
        		else 
        			
        			source $SCRIPT_DIR/env/tokens/$user_email.sh
        			echo "User Token: $user_token"
        			echo "Getting all channels that the user registered!"
        			curl -s -S -i -X GET -H "Authorization: Bearer $user_token" http://$iot_server_address/channels > $SCRIPT_DIR/logs/log.txt
        			file_content=$(<$SCRIPT_DIR/logs/log.txt)
        			echo "Here is the reponse from the platform!"
        			echo $file_content
        			

        		
        		fi 
        	 	
        	 	
        	
        	
        	fi
        else 
        	echo "not enough arguments provided!"
        fi



}



connect() {

	if [ "$#" -ne 3 ]; then
		user_email=$1
		user_pass=$2
		sensor_name=$3
		channel_name=$4
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
		file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	source $SCRIPT_DIR/env/users/$user_email.sh
        	 	echo $user_id
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
        	 	if [ ! -f "$file_path" ]; then
        			echo "user does not have a registered token on record! signin to generate token first!"
        		else 
        			source $SCRIPT_DIR/env/tokens/$user_email.sh
        	 		echo $user_token
        			file_path="$SCRIPT_DIR/env/channels/$channel_name.sh" 
        			if [ -f "$file_path" ]; then
        				source $file_path
        				echo $channel_id
        				file_path="$SCRIPT_DIR/env/things/$sensor_name.sh" 
        				if [ -f "$file_path" ]; then
        					source $file_path
        					echo $sensor_id
        					echo "Trying to connect sensor $sensor_name to channel $channel_name now!"
        					payload="{\"channel_ids\": [\"${channel_id}\"], \"thing_ids\": [\"${sensor_id}\"]}"
        					curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $user_token" http://$iot_server_address/connect -d "$payload" > $SCRIPT_DIR/logs/log.txt
        					file_content=$(<$SCRIPT_DIR/logs/log.txt)
        					echo "Here is the reponse from the platform!"
        					echo $file_content
        				else 
        					echo "sensor does not have a registered id on file or is not registered at all!"
        					
        				fi
        			else 
        				echo "channel does not have a registered id on file or is not registered at all!"

        					
        			fi	
        		
        		
        		
        		fi	
        	fi
        	
        else 
        	echo "not enough arguments (username, pass, sensorname, channelname) provided!"
        
        
        fi
        				
        		
}


disconnect() {

	if [ "$#" -ne 3 ]; then
		user_email=$1
		user_pass=$2
		sensor_name=$3
		channel_name=$4
	        SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
		file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	source $SCRIPT_DIR/env/users/$user_email.sh
        	 	echo $user_id
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
        	 	if [ ! -f "$file_path" ]; then
        			echo "user does not have a registered token on record! signin to generate token first!"
        		else 
        			source $SCRIPT_DIR/env/tokens/$user_email.sh
        	 		echo $user_token
        			file_path="$SCRIPT_DIR/env/channels/$channel_name.sh" 
        			if [ -f "$file_path" ]; then
        				source $file_path
        				echo $channel_id
        				file_path="$SCRIPT_DIR/env/things/$sensor_name.sh" 
        				if [ -f "$file_path" ]; then
        					source $file_path
        					echo $sensor_id
        					echo "Trying to diconnect sensor $sensor_name from channel $channel_name now!"
        					#payload="{\"channel_ids\": [\"${channel_id}\"], \"thing_ids\": [\"${sensor_id}\"]}"
        					url_payload=http://$iot_server_address/channels/$channel_id/things/$sensor_id
        					url_link=${url_payload%$'\r'} 
        					#curl -s -S -i --cacert $SCRIPT_DIR/docker/ssl/certs/ca.crt  -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $user_token" http://localhost/connect -d "$payload" > $SCRIPT_DIR/logs/log.txt
        					curl -s -S -i -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer $user_token" $url_link > $SCRIPT_DIR/logs/log.txt

        					file_content=$(<$SCRIPT_DIR/logs/log.txt)
        					echo "Here is the reponse from the platform!"
        					echo $file_content
        				else 
        					echo "sensor does not have a registered id on file or is not registered at all!"
        					
        				fi
        			else 
        				echo "channel does not have a registered id on file or is not registered at all!"

        					
        			fi	
        		
        		
        		
        		fi	
        	fi
        	
        else 
        	echo "not enough arguments (username, pass, sensorname, channelname) provided!"
        
        
        fi
        				
        		
}



# Usage example: read data from example.csv
csv_to_payload() {

    if [ "$#" -ne 4 ]; then   
		user_email=$1
		user_pass=$2
		sensor_name=$3
		channel_name=$4
		file_name=$5
		#column_names=$6
		SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
		file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	source $SCRIPT_DIR/env/users/$user_email.sh
        	 	echo $user_id
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
        	 	if [ ! -f "$file_path" ]; then
        			echo "user does not have a registered token on record! signin to generate token first!"
        		else 
        			source $SCRIPT_DIR/env/tokens/$user_email.sh
        	 		echo $user_token
        			file_path="$SCRIPT_DIR/env/channels/$channel_name.sh" 
        			if [ -f "$file_path" ]; then
        				source $file_path
        				echo $channel_id
        				file_path="$SCRIPT_DIR/env/things/$sensor_name.sh" 
        				if [ -f "$file_path" ]; then
        					source $file_path
        					echo $sensor_id
        					SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    						file_path="$SCRIPT_DIR/data/$file_name.csv" 
    						if [ -f "$file_path" ]; then
    							echo "Trying to read and send data from $file_path using $sensor_name over $channel_name!"
    							source $SCRIPT_DIR/env/keys/$sensor_name.sh
    							echo $sensor_key
    							url_link=http://$iot_server_address/http/channels/$channel_id/messages
    							# removing \r from end
							url_link=${url_link%$'\r'}
        						#data_payload='[{"bn":"urn:dev:DEVEUI:'"$sensor_name"':", "bt": 1.58565075E9},'
        						read -r header < $file_path
							# Split the header into an array
							IFS=',' read -r -a columns <<< "$header"

							# Iterate over the CSV file skipping the first line
							while IFS=',' read -r row; do
    								# Skip first line
    								((i++)) && ((i==1)) && continue
    
    								# Split the row into an array
    								IFS=',' read -r -a values <<< "$row"
    
    								# Construct the JSON payload dynamically, read more about senML here: https://www.rfc-editor.org/rfc/rfc8428.html
   								json_payload='[{"bn":"urn:dev:DEVEUI:'"$sensor_name"':", "bt": 1.58565075E9,"bu":"A","bver":5,"n":"energy","u":"KWh","v":120.1},'
    
  								 # Iterate over the columns and values to construct the payload
    								for ((j = 0; j < ${#columns[@]}; j++)); do
       								 	# 'n' is the column name
        								n=${columns[j]}
       									 # 'v' is the corresponding value from the row
        								v=${values[j]}
        								# Add the 'n' and 'v' pair to the JSON payload
        								json_payload+='{"n": "'$n'", "v": '"$v"', "u": "unit"}'
        								# Add a comma if it's not the last column
       									 ((j != ${#columns[@]} - 1)) && json_payload+=','
   							        done
    
    								# Close the JSON payload
   								json_payload+=']'
   								echo $json_payload
   								json_payload_escaped=$(echo "$json_payload" | sed "s/'/\\\\'/g")

   								echo $url_link
   								echo $sensor_key
   								echo $user_token
    
  								# Replace 'unit' with the appropriate unit for each column
    
  								# Make the curl request with the constructed JSON payload
  								curl -s -S -i -X POST -H "Content-Type: application/senml+json" -H "Authorization: Thing $sensor_key" http://$iot_server_address/http/channels/$channel_id/messages -d "$json_payload_escaped"
  								
  								
  								#payload="{\"channel_ids\": [\"${channel_id}\"], \"thing_ids\": [\"${sensor_id}\"]}"
        					                #curl -s -S -i --cacert $SCRIPT_DIR/docker/ssl/certs/ca.crt -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $user_token" http://localhost/connect -d "$payload" > $SCRIPT_DIR/logs/log.txt
							done < <(tail -n +2 $file_path) # Skip the first line while reading the file
						else 
							echo "csv file does not exist at $file_path! try creating one first! "
						
						fi 
					else 
					 	echo "sensor credentails for $sensor_name do not exist, try creating one first!"
					
					fi 
				else 
					echo "channel credetnails for $channel_name do not exist try creating one first!"
							
				
				fi 
				
			fi
			
		fi
	else
		echo "not enough arguments provided! see documentation! "
	
	
	fi
        						
    	   
}


getdata() {
 	if [ "$#" -ne 6 ]; then 
 	        database_type=$1  
		user_email=$2
		user_pass=$3
		sensor_name=$4
		channel_name=$5
		file_offset=$6
		file_limit=$7
		# default port
		service_port=8904
		
		if [ "$database_type" = "mongodb" ]; then
			service_port=8904
    		elif [ "$database_type" = "postgres" ]; then
    			service_port=8904
    		else
    			service_port=8904
    		
    		fi

		SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
		file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	source $SCRIPT_DIR/env/users/$user_email.sh
        	 	echo $user_id
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
        	 	if [ ! -f "$file_path" ]; then
        			echo "user does not have a registered token on record! signin to generate token first!"
        		else 
        			source $SCRIPT_DIR/env/tokens/$user_email.sh
        	 		echo $user_token
        			file_path="$SCRIPT_DIR/env/channels/$channel_name.sh" 
        			if [ -f "$file_path" ]; then
        				source $file_path
        				echo $channel_id
        				file_path="$SCRIPT_DIR/env/things/$sensor_name.sh" 
        				if [ -f "$file_path" ]; then
        					source $file_path
        					echo $sensor_id
        					SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    						echo "Retrieving data for sensor $sensor_name against channel $channel_name for user $user_email with offset $file_offset and limit $file_limit!"
    						echo $service_port
    						source $SCRIPT_DIR/env/keys/$sensor_name.sh
    						echo $sensor_key
      						base_url="http://$iot_server_address:$service_port/channels/$channel_id/messages"
      						offset=$(printf "%s" "$file_offset" | sed 's/[^a-zA-Z0-9_\.~-]/\\&/g')
						limit=$(printf "%s" "$file_limit" | sed 's/[^a-zA-Z0-9_\.~-]/\\&/g')
    						# removing \r from end
    						final_url="${base_url}?offset=${offset}&limit=${limit}"
						#url=${url%$'\r'}
						echo $final_url
    						#curl -s -S -i --cacert $SCRIPT_DIR/docker/ssl/certs/ca.crt -H "Authorization: Thing $sensor_key" $final_url > $SCRIPT_DIR/logs/log.txt
    						curl -s -S -i -H "Authorization: Thing $sensor_key" $final_url
    						#file_content=$(<$SCRIPT_DIR/logs/log.txt)
        					#echo "Here is the data reponse from the platform!"
        					#echo $file_content
    						
    					else 
    						echo "sensor credentials don't exist!"
    					fi
    					
    				else
    					echo "channel credentials don't exist!"
    				
    				fi
    			fi	
		
   		fi
   	else
   	
   		echo "not enough arguments provided! see documentation!"
   	
   	
   	fi



}


dumpdata() {
 	if [ "$#" -ne 3 ]; then 
 	        database_type=$1  
		user_email=$2
		user_pass=$3
		output_filename=$4
		#sensor_name=$4
		#channel_name=$5
		#file_offset=$6
		#file_limit=$7
		# default port
		service_port=8904
		
		if [ "$database_type" = "mongodb" ]; then
			service_port=8904
    		elif [ "$database_type" = "postgres" ]; then
    			service_port=8904
    		else
    			service_port=8904
    		
    		fi

		SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
		file_path="$SCRIPT_DIR/env/users/$user_email.sh" 
        	if [ ! -f "$file_path" ]; then
        		echo "user does not have an ID on record! signup again!"
        	else 
        	 	source $SCRIPT_DIR/env/users/$user_email.sh
        	 	echo $user_id
        	 	file_path="$SCRIPT_DIR/env/tokens/$user_email.sh" 
        	 	if [ ! -f "$file_path" ]; then
        			echo "user does not have a registered token on record! signin to generate token first!"
        		else 
        			source $SCRIPT_DIR/env/tokens/$user_email.sh
        	 		echo $user_token
        	 		
        			file_path="$SCRIPT_DIR/data/$output_filename.txt" 
        			if [ ! -f "$file_path" ]; then
        				source $file_path
        				#echo $channel_id
        				docker exec mainflux-mongodb sh -c "mongoexport --db mainflux --collection messages" > $file_path
        				echo "data dumped to file at: $file_path"
        				
    					
    				else
    					echo "output file $file_path already exits!"
    				
    				fi
    			fi	
		
   		fi
   	else
   	
   		echo "not enough arguments provided! see documentation!"
   	
   	
   	fi



}


cleanall() {

	echo "stopping containers"
	docker stop mainflux-things-db mainflux-broker mainflux-mongodb-reader mainflux-ui mainflux-jaeger mainflux-influxdb-reader mainflux-es-redis mainflux-webhooks-db mainflux-users-db mainflux-auth-db mainflux-auth-redis mainflux-mongodb mainflux-filestore-db mainflux-vernemq mainflux-smtp-notifier mainflux-mqtt-db mainflux-influxdb mainflux-webhooks mainflux-auth mainflux-filestore mainflux-mongodb-writer mainflux-influxdb-writer mainflux-users mainflux-things mainflux-http mainflux-ws mainflux-coap mainflux-mqtt mainflux-nginx mainflux-keto mainflux-keto-migrate mainflux-keto-db mainflux-nats
	echo "removing containers"
	docker rm mainflux-things-db mainflux-broker mainflux-mongodb-reader mainflux-ui mainflux-jaeger mainflux-influxdb-reader mainflux-es-redis mainflux-webhooks-db mainflux-users-db mainflux-auth-db mainflux-auth-redis mainflux-mongodb mainflux-filestore-db mainflux-vernemq mainflux-smtp-notifier mainflux-mqtt-db mainflux-influxdb mainflux-webhooks mainflux-auth mainflux-filestore mainflux-mongodb-writer mainflux-influxdb-writer mainflux-users mainflux-things mainflux-http mainflux-ws mainflux-coap mainflux-mqtt mainflux-nginx mainflux-keto mainflux-keto-migrate mainflux-keto-db mainflux-nats
	echo "removing dangling containers" 
	docker volume ls -qf dangling=true | xargs docker volume rm
        echo "removing envrionment variables"
	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	rm $SCRIPT_DIR/env/channels/*
	rm $SCRIPT_DIR/env/tokens/*
	rm $SCRIPT_DIR/env/keys/*
	rm $SCRIPT_DIR/env/things/*
	rm $SCRIPT_DIR/env/users/*
	#sudo chmod 777 -R $SCRIPT_DIR
	sudo fuser -k -n tcp 8181
	#sudo fuser -k -n tcp 5432
	sudo fuser -k -n tcp 8904
	#sudo chmod 777 -R ssl  
	
}

# Usage example: read data from example.csv
#columns=("electricity" "kWh" "diesel" "lb" "fossil" "lb" "petroleum" "lb" "naturalgas" "cubicfeet" "steam" "lb")
#csv_to_payload "example.csv" "${columns[@]}"
#csv_to_payload "example.csv" "electricity" "kWh" "diesel" "lb" "fossil" "lb" "petroleum" "lb" "naturalgas" "cubicfeet" "steam" "lb"




# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [function_name]"
    exit 1
fi


# This code is called to configure and store admin credentials 
#configureadmin $MF_USERS_ADMIN_EMAIL $MF_USERS_ADMIN_PASSWORD


address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
echo "declare -x ipaddress=$address" > $SCRIPT_DIR/env/hostip.sh  
  
 

# Case statement to handle different inputs
case "$1" in
    copyenv) copyenv $2 ;;
    ipaddress) hostip ;;
    newuser) newuser $2 $3 ;;
    getid) getid $2 ;;
    signin) signin $2 $3 ;;
    gettoken) gettoken $2 ;;
    checktoken) checktoken $2 $3 ;;
    allusers) allusers $2 $3 ;;  
    createsensor) createsensor $2 $3 $4 ;;  
    getthings) getthings $2 $3 ;; 
    createchannel) createchannel $2 $3 $4 ;;
    getchannels) getchannels $2 $3 ;; 
    connect) connect $2 $3 $4 $5 ;;
    disconnect) disconnect $2 $3 $4 $5 ;;
    csv_to_payload) csv_to_payload $2 $3 $4 $5 $6 ;;
    getdata) getdata $2 $3 $4 $5 $6 $7 $8 ;;
    dumpdata) dumpdata $2 $3 $4 $5 ;;
    cleanall) cleanall ;;
    #test_message) test_message $2 ;;
    *) echo "Invalid input. Please provide a function name as an argument." && exit 1 ;;
esac
