# IoT Network 


"IoT network" refers to a network infrastructure specifically designed to facilitate communication and data exchange among Internet of Things (IoT) devices. The submodule /iotnetwork directory is meant to serve as a resource for spinning up interfaces for IoTs and sensors. 


### Environment Variables 

IoT network can be run for individual organizations and is meant to consume data within an independent private supply chain domain which can then be shared over other channels. The same setup can therefore be run within other organizations without major changes. Before the iot network can be run, check .env parameters to see if the ports are what is required at the organziation. 

	gedit iotnetwork/docker/.env

If the .env file is empty, copy environment parameters from iotnetwork/env/env.txt into iotnetwork/docker/.env file with required modifications. The framework picks up TLS certificates from iotnetwork/docker/ssl folder during startup. To generate your own certificates, see the certificate generation section. 


The underlying IoT network architecture ( https://mainflux.readthedocs.io/en/latest/) incoprorates there important entities namely  User, Things and Channels. Users are individuals or entities who interact with the Mainflux platform. Things represent physical or virtual IoT devices, sensors, actuators, or any other entities that generate or consume data within the IoT ecosystem. Channels serve as communication conduits within the Mainflux platform, enabling data exchange between things and other components of the IoT system. Each entity can be mapped to other with one-to-one, one-to-many or with other multi connectivity associations.

### Running Application

To run a standalone iotnetwork application (with a number of services) within an organizational domain, run the docker-compose file within iotnetwork/docker/ directory

	# Run from within the /iotnetwork directory 
	docker-compose -f docker/docker-compose.yml up -d
	
	
This will spin up a number of containers including databases that will be attached to 'beefchain-base-net' docker bridge network. 
All default databases have their usernames, passwords and database names set to 'mainflux' which can be changed in the .env file before spinning containers. The most useful environment parameter to begin with is the user email 'admin@example.com' and password 'mainflux' for https://localhost/users route. By default, 'users' service starts with the ability to register any user to begin using the platform. Should only an admin be allowed to access 'users' service, change variable MF_USERS_ALLOW_SELF_REGISTER  in the .env file to false.

### Run Databases

We also need to spin up databases to store data captured from IoTs and sensors. There are a number of options available for that purpose under iotnetwork/docker/addons folder. As an example, spin up mongodb databases. For starting any addon service .env parameters file should be copied to that folder. Call the iotnetwork/iot-network.sh script to copy .env files where required. From within iotnetwork directory use any of the the commands below in bash terminal,   

	# to copy .env files to iotnetwork/docker/addons/mongodb-writer and */mongodb-reader
	./iot-network.sh copyenv mongodb
	
	# to copy .env file to all foders in iotnetwork/docker/addons/*
	./iot-network.sh copyenv all
	
	# to copy .env file to individual folders 
	./iot-network.sh copyenv mongodb
	./iot-network.sh copyenv postgres
	./iot-network.sh copyenv influxdb
	./iot-network.sh copyenv timescale
	./iot-network.sh copyenv twins
	./iot-network.sh copyenv notifier
	./iot-network.sh copyenv adapter
	./iot-network.sh copyenv cassandra


Once, .env files have been successfully copied to */mongodb-writer and */mongodb-reader in iotnetwork/docker/addons/ folder, spin up the containers (assuming user is in the main BeefChain directory) 

`Note that any of the addon services require main services to be up and running as it looks for external 'beefchain-base-net network to connect to. We already started it using iotnetwork/docker/docker-compose.yml file!`
	

	docker-compose -f docker/addons/mongodb-writer/docker-compose.yml -f docker/addons/mongodb-reader/docker-compose.yml up -d
	
### Create Users

Once the cotnainers are up and running successfully, we can start creating users, things and channels. Note that all these there entities get assigned KEYS and IDs over the iot framework for accessing them. These are stored as environment variables in iotnetwork/env directory under /users, /things and /channels folder. 

Creat a new user with email  'farmer@beefchain.com' and password '12345678' by calling the ./iot-network.sh script in iotnetwork/ folder


	user_email='farmer@beefchain.com'
	user_pass='12345678'  
	
	# using bash variables
	./iot-network.sh newuser $user_email $user_pass
	# using direct parameters
	./iot-network.sh newuser farmer@beefchain.com 12345678
	
A user will be created if it doesn't exist and its ID will be stored with varaible name 'user_id' in iotnetwork/env/users/$user_email.sh. At any time it can be viewed in the bash terminal by 

	./iot-network.sh getid farmer@beefchain.com
	# or directly source to bash terminal in variable user_id
	source env/users/$user_email.sh
	

### Signin Users 

Once user has been registered, sign in the paltform to get session tokens (JWT Tokens) that can be used to create things and channels.
Call the provided script with email and password to sign in. 

	./iot-network.sh signin farmer@beefchain.com 12345678
	 

	
A user file will be created if it doesn't exist and its assigned token will be stored with varaible name 'user_token' in iotnetwork/env/tokens/$user_email.sh. At any time it can be viewed in the bash terminal by 

	
	./iot-network.sh gettoken farmer@beefchain.com
	# or directly source to bash terminal in variable user_token
	source env/tokens/$user_email.sh
	
Tokens can get expired after sometime. To get new tokens, simply signin again or use the existing tokens to check if they are still valid.

	./iot-network.sh checktoken farmer@beefchain.com 12345678
	
This will pick up session tokens against the provided user credential and check and return its validity. 

To see all users registered in the paltform at any time, call allusers method using admin username and password


	./iot-network.sh allusers admin@example.com 12345678
	

### Create Sensors

A registered user can create Things (sensor devices) on the platform which can be a direct interace for hardware devices to dump data. To create a sensor device using a registerd user, call the createsensor method with a username, password and sensor name


	./iot-network.sh createsensor farmer@beefchain.com 12345678 energysensor
	
This will register a sensor device interface with  a name 'energysensor', generate a key and an id for the device. The key is stored in iotnetwork/env/keys folder with the sensor name and with variable name sensor_key. The sensor id is stored in the iotnetwork/env/things  folder in a file named after the sensor name in a variable sensor_id along with the user_id that created it. To source directly the variable to bash

 	# Assuming the sensor name is 'energysensor'
 	source iotnetwork/env/things/energysensor.sh
 	source iotnetwork/env/keys/energysensor.sh
 	echo $sensor_id 
 	echo $sensor_key
 
A registed user can list all the sensor devices they have on platform any time, call the getthings function with username and password 

	./iot-network.sh getthings farmer@beefchain.com 12345678 
	
	
Once sensor devices as 'things' have been registered on the platform, communication channels need to be created to allow data to be transmitted from devices over the channels and stored in relevant databases. To create channels, call the createchannel function with a registerd user email, password and channel name 


	./iot-network.sh createchannel farmer@beefchain.com 12345678 energysensorchannel
	
This will register a channel interface with  a name 'energysensorchannel', and generate an id for the channel. The id is stored in iotnetwork/env/channels folder with the channel name and with variable name channel_id along with the user_id that created it. To source directly the variables to bash

 	# Assuming the sensor name is 'energysensorchannel'
 	source iotnetwork/env/things/energysensorchannel.sh
 	echo $channel_id 

A registed user can list all the channel interfaces they have on platform any time, call the getchannels function with username and password 

	./iot-network.sh getchannels farmer@beefchain.com 12345678 
		
Once, sensor devices (things) and channels have been registered on the platform by an authorized user, sensors need to be connected to channels to allow sending data over it. To connect a particular sensor to a particular channel, call the connect function with users email, pass, sensor name and channel name 


	./iot-network.sh connect farmer@beefchain.com 12345678 energysensor energysensorchannel
	

Sensors can also be disconnected from channels. To disconnect a particular sensor from a particular channel, call the disconnect function with users email, pass, sensor name and channel name 


	./iot-network.sh disconnect farmer@beefchain.com 12345678 energysensor energysensorchannel
	
### Transmit Data
	
Start sending data over a channel using a sensor. Connect the sensor and channel again, 	

	./iot-network.sh connect farmer@beefchain.com 12345678 energysensor energysensorchannel
	
	
Since we had already started the mongodb reader and writer containers earlier, we will use the mongodb database to dump sensor data and retrieve it. Check mongodb containers are running
	
		
	docker ps | grep mainflux-mongodb-reader
	docker ps | grep mainflux-mongodb-writer


`Note: Containers for other databases in the iotnetwork/addons can be started in a similar way by first copying .env variables and then calling docker-compose files!`

To send example data from a sensor to a connected channel, call the csv_to_payload function 

	
	./iot-network.sh csv_to_payload farmer@beefchain.com 12345678 energysensor energysensorchannel energy
	# generic call parameters (replace with actual parameters)
	./iot-network.sh csv_to_payload <user_email> <user_pass> <sensor_name> <file_name> 

The above curl call picks up sensor key and channel id along with exporting row parameters from the energy.csv file located in iotenetwork/data/energy.csv. Number of curl calls generated will depend on the data rows in the csv file. In general a curl call to dump data can be configured as

	# grab sensor key for sensor name 'energysensor' in the variable $sensor_key
	source env/keys/energysensor.sh
	# grab channel_id for channel name 'energysensorchannel' in the variable $channel_id 
	source env/channels/energysensorchannel.sh
	# make a curl call to put random energy data in mongodb database
	curl -s -S -i --cacert docker/ssl/certs/ca.crt -X POST -H "Content-Type: application/json" -H "Authorization: Thing $sensor_key" http://localhost/http/channels/$channel_id/messages -d '[{"bn":"urn:dev:DEVEUI:energysensor:", "bt": 1.58565075E9},{"n": "electricity", "v": 35, "u": "kWh"},{"n": "diesel", "v": 50, "u": "lb"}]'

### Read Data
	 
To read back data from database, call the getdata function specifying the type of database (e.g. mongodb) with user credentials (email, pass), sensor name, channel name alonmg with offset and limit of data to view 

	
	./iot-network.sh getdata mongodb farmer@beefchain.com 12345678 energysensor energysensorchannel 0 20
	# generic call parameters (replace with actual parameters)
	./iot-network.sh getdata <database_type> <user_email> <user_pass> <sensor_name> <channel_name> <data_offset> <data_limit>
  

A registered user can also dump data in a file on host machine by calling the dumpdata function  
 	 
	 
	 ./iot-network.sh dumpdata mongodb farmer@beefchain.com 12345678 farmer_data_dump
	 # generic call parameters (replace with actual parameters)
	./iot-network.sh getdata <database_type> <user_email> <user_pass> <output_file_name>
  

### Bringdown Containers

To bring down containers, call the cleanall function

`Note that cleanall deletes stored data and removes containers completeley!`

	
	./iot-network.sh cleanall
	
	
### Create Certificates   

To allow communicating with IoT network using secure Mutual TLS authentication, generate certificates of your own. From  within iotnetwork/docker/ssl directory run 

	# Generate certificate authority certificates
	make ca CN=localhost O=Beefchain OU=beefchain emailAddress=info@beefchain.com

	# Generate iotnetwork server certificates 
	make server_cert CN=localhost O=Beefchain OU=beefchain emailAddress=info@beefchain.com

	# (Extra) Generate things certificate (Note that the THING_KEY varaible should be the actual key described earlier)
	make thing_cert THING_KEY=8f65ed04-0770-4ce4-a291-6d1bf2000f4d CRT_FILE_NAME=thing O=Beefchain OU=beefchain emailAddress=info@beefchain.com

This should generate certificates in the iotnetwork/docker/ssl folder used by containers later. 

To use a user interface based system along with generating digital twins, spin up the docker-compose files in the iotnetwork/ui folder in a similar way after copying over the certificate files from iotnetwork/docker/ssl folder into the iotnetwork/ui/docker/ssl folder or generating new ones. Also copy the .env files before starting containers and make changes where required. Once the ui based containerized application is started, the iot ui can be accessed at http://localhost:3000/explorer/ with the default username admin@example.com and default password 12345678. The grafana setup for iot sensor data visualization can be accessed at http://localhost:3001 with a default username 'admin' and default password 'admin'. The username and password for grafana can be changed in the grafana-defaults.ini in configs folder or a new username and password can be created at the interface after the application runs. 


`Remove configureadmin method from file ./iot-network-unsecure.sh if client using the file is generic user`

### Multihost Unsecured

To call the main server from other hosts without using certificates, first configure and import the url address of the deployed server in the variable 'iot_server_address' 

	source environment/service_ip_addresses.sh

Use the script ./iot-network-unsecure.sh to make calls to the main server from a host that can reach the server over ip 

#### Create User

       user_email='farmer@beefchain.com'
       user_pass='12345678'  
	
	# using bash variables
	./iot-network-unsecure.sh newuser $user_email $user_pass
	# using direct parameters
	./iot-network-unsecure.sh newuser farmer@beefchain.com 12345678
	
The id of created user can  be viewed in the bash terminal by 

	./iot-network-unsecure.sh getid farmer@beefchain.com
	# or directly source to bash terminal in variable user_id
	source env/users/$user_email.sh
	

#### Signin Users 

Once user has been registered, sign in the platform to get session tokens (JWT Tokens) that can be used to create things and channels. 

	./iot-network-unsecure.sh signin farmer@beefchain.com 12345678
	 
	
 At any time user tokens can be viewed in the bash terminal by 

	
	./iot-network-unsecure.sh gettoken farmer@beefchain.com
	# or directly source to bash terminal in variable user_token
	source env/tokens/$user_email.sh
	
To get new tokens, simply signin again or use the existing tokens to check if they are still valid.

	./iot-network-unsecure.sh checktoken farmer@beefchain.com 12345678
	

To see all users registered in the paltform at any time, call allusers method using admin username and password


	./iot-network-unsecure.sh allusers admin@example.com 12345678
	

#### Create Sensors

To create a sensor device using a registerd user, call the createsensor method with a username, password and sensor name


	./iot-network-unsecure.sh createsensor farmer@beefchain.com 12345678 energysensor
	
 To source directly the sensor related id and key variables to bash

 	# Assuming the sensor name is 'energysensor'
 	source iotnetwork/env/things/energysensor.sh
 	source iotnetwork/env/keys/energysensor.sh
 	echo $sensor_id 
 	echo $sensor_key
 
A registed user can list all the sensor devices they have on platform any time, call the getthings function with username and password 

	./iot-network-unsecure.sh getthings farmer@beefchain.com 12345678 
	
	
 To create channels, call the createchannel function with a registerd user email, password and channel name 


	./iot-network-unsecure.sh createchannel farmer@beefchain.com 12345678 energysensorchannel
	
 To source directly the channel id variable to bash

 	# Assuming the sensor name is 'energysensorchannel'
 	source iotnetwork/env/things/energysensorchannel.sh
 	echo $channel_id 

A registed user can list all the channel interfaces they have on platform any time, call the getchannels function with username and password 

	./iot-network-unsecure.sh getchannels farmer@beefchain.com 12345678 

 To connect a particular sensor to a particular channel, call the connect function with users email, pass, sensor name and channel name 


	./iot-network-unsecure.sh connect farmer@beefchain.com 12345678 energysensor energysensorchannel
	

 To disconnect a particular sensor from a particular channel, call the disconnect function with users email, pass, sensor name and channel name 


	./iot-network-unsecure.sh disconnect farmer@beefchain.com 12345678 energysensor energysensorchannel
	
Start sending data over a channel using a sensor. Connect the sensor and channel again, 	

	./iot-network-unsecure.sh connect farmer@beefchain.com 12345678 energysensor energysensorchannel
	

To send example data from a sensor to a connected channel, call the csv_to_payload function 

	
	./iot-network-unsecure.sh csv_to_payload farmer@beefchain.com 12345678 energysensor energysensorchannel energy
	# generic call parameters (replace with actual parameters)
	./iot-network-unsecure.sh csv_to_payload <user_email> <user_pass> <sensor_name> <file_name> 

The file energy.csv file needs to be in iotenetwork/data/energy.csv. Number of curl calls generated will depend on the data rows in the csv file. In general a curl call to dump data can be configured as

	# grab sensor key for sensor name 'energysensor' in the variable $sensor_key
	source env/keys/energysensor.sh
	# grab channel_id for channel name 'energysensorchannel' in the variable $channel_id 
	source env/channels/energysensorchannel.sh
	# make a curl call to put random energy data in mongodb database
	curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: Thing $sensor_key" http://$iot_server_address/http/channels/$channel_id/messages -d '[{"bn":"urn:dev:DEVEUI:energysensor:", "bt": 1.58565075E9},{"n": "electricity", "v": 35, "u": "kWh"},{"n": "diesel", "v": 50, "u": "lb"}]'

	 
To read back data from database, call the getdata function specifying the type of database (e.g. mongodb) with user credentials (email, pass), sensor name, channel name alonmg with offset and limit of data to view 

	
	./iot-network-unsecure.sh getdata mongodb farmer@beefchain.com 12345678 energysensor energysensorchannel 0 20
	# generic call parameters (replace with actual parameters)
	./iot-network-unsecure.sh getdata <database_type> <user_email> <user_pass> <sensor_name> <channel_name> <data_offset> <data_limit>
  

A registered user can also dump data in a file on host machine by calling the dumpdata function  
 	 
	 
	 ./iot-network-unsecure.sh dumpdata mongodb farmer@beefchain.com 12345678 farmer_data_dump
	 # generic call parameters (replace with actual parameters)
	./iot-network-unsecure.sh getdata <database_type> <user_email> <user_pass> <output_file_name>

`Remove configureadmin method from file ./iot-network-secure.sh if client using the file is generic user`

### Multihost Secured

To use the multihost setup using secured connections, generate the certificates by modifying the file iotnetwork/docker/ssl/Makefile. On line 7, change variable value from 'localhost' to the actual host url, e.g. '203.0.113.45'. Then generate certificate and make sure the file iotnetwork/docker/ssl/certs/ca.crt is availabe at the client host. 

Configure and import the url address of the deployed server in the variable 'iot_server_address' 

	source environment/service_ip_addresses.sh

Use the script ./iot-network-secure.sh to make calls to the main server from a host that can reach the server over ip 

#### Create User

       user_email='farmer@beefchain.com'
       user_pass='12345678'  
	
	# using bash variables
	./iot-network-secure.sh newuser $user_email $user_pass
	# using direct parameters
	./iot-network-secure.sh newuser farmer@beefchain.com 12345678
	
The id of created user can  be viewed in the bash terminal by 

	./iot-network-secure.sh getid farmer@beefchain.com
	# or directly source to bash terminal in variable user_id
	source env/users/$user_email.sh
	

#### Signin Users 

Once user has been registered, sign in the paltform to get session tokens (JWT Tokens) that can be used to create things and channels. 

	./iot-network-secure.sh signin farmer@beefchain.com 12345678
	 
	
 At any time user tokens can be viewed in the bash terminal by 

	
	./iot-network-secure.sh gettoken farmer@beefchain.com
	# or directly source to bash terminal in variable user_token
	source env/tokens/$user_email.sh
	
To get new tokens, simply signin again or use the existing tokens to check if they are still valid.

	./iot-network-secure.sh checktoken farmer@beefchain.com 12345678
	

To see all users registered in the paltform at any time, call allusers method using admin username and password


	./iot-network-secure.sh allusers admin@example.com 12345678
	

#### Create Sensors

To create a sensor device using a registerd user, call the createsensor method with a username, password and sensor name


	./iot-network-secure.sh createsensor farmer@beefchain.com 12345678 energysensor
	
 To source directly the sensor related id and key variables to bash

 	# Assuming the sensor name is 'energysensor'
 	source iotnetwork/env/things/energysensor.sh
 	source iotnetwork/env/keys/energysensor.sh
 	echo $sensor_id 
 	echo $sensor_key
 
A registed user can list all the sensor devices they have on platform any time, call the getthings function with username and password 

	./iot-network-secure.sh getthings farmer@beefchain.com 12345678 
	
	
 To create channels, call the createchannel function with a registerd user email, password and channel name 


	./iot-network-secure.sh createchannel farmer@beefchain.com 12345678 energysensorchannel
	
 To source directly the channel id variable to bash

 	# Assuming the sensor name is 'energysensorchannel'
 	source iotnetwork/env/things/energysensorchannel.sh
 	echo $channel_id 

A registed user can list all the channel interfaces they have on platform any time, call the getchannels function with username and password 

	./iot-network-secure.sh getchannels farmer@beefchain.com 12345678 

 To connect a particular sensor to a particular channel, call the connect function with users email, pass, sensor name and channel name 


	./iot-network-secure.sh connect farmer@beefchain.com 12345678 energysensor energysensorchannel
	

 To disconnect a particular sensor from a particular channel, call the disconnect function with users email, pass, sensor name and channel name 


	./iot-network-secure.sh disconnect farmer@beefchain.com 12345678 energysensor energysensorchannel
	
Start sending data over a channel using a sensor. Connect the sensor and channel again, 	

	./iot-network-secure.sh connect farmer@beefchain.com 12345678 energysensor energysensorchannel
	

To send example data from a sensor to a connected channel, call the csv_to_payload function 

	
	./iot-network-secure.sh csv_to_payload farmer@beefchain.com 12345678 energysensor energysensorchannel energy
	# generic call parameters (replace with actual parameters)
	./iot-network-secure.sh csv_to_payload <user_email> <user_pass> <sensor_name> <file_name> 

The file energy.csv file needs to be in iotenetwork/data/energy.csv. Number of curl calls generated will depend on the data rows in the csv file. In general a curl call to dump data can be configured as

	# grab sensor key for sensor name 'energysensor' in the variable $sensor_key
	source env/keys/energysensor.sh
	# grab channel_id for channel name 'energysensorchannel' in the variable $channel_id 
	source env/channels/energysensorchannel.sh
	# make a curl call to put random energy data in mongodb database
	curl -s -S -i -X POST -H "Content-Type: application/json" -H "Authorization: Thing $sensor_key" http://$iot_server_address/http/channels/$channel_id/messages -d '[{"bn":"urn:dev:DEVEUI:energysensor:", "bt": 1.58565075E9},{"n": "electricity", "v": 35, "u": "kWh"},{"n": "diesel", "v": 50, "u": "lb"}]'

	 
To read back data from database, call the getdata function specifying the type of database (e.g. mongodb) with user credentials (email, pass), sensor name, channel name alonmg with offset and limit of data to view 

	
	./iot-network-secure.sh getdata mongodb farmer@beefchain.com 12345678 energysensor energysensorchannel 0 20
	# generic call parameters (replace with actual parameters)
	./iot-network-secure.sh getdata <database_type> <user_email> <user_pass> <sensor_name> <channel_name> <data_offset> <data_limit>
  

A registered user can also dump data in a file on host machine by calling the dumpdata function  
 	 
	 
	 ./iot-network-secure.sh dumpdata mongodb farmer@beefchain.com 12345678 farmer_data_dump
	 # generic call parameters (replace with actual parameters)
	./iot-network-secure.sh getdata <database_type> <user_email> <user_pass> <output_file_name>


	
	




