# Databases

A number of databases are setup to allow organizations to consume different types of data from events and processes occuring within the facility from which useful information can be extracted and shared. The databases can be individually spun up using docker-compose file or as part of the main setup for BeefMesh.

`Note that the databases are setup individually for different organizations using internal network and does not use the global beef_suppy bridge or overlay network. This is because databases consume internal organizational data which should not be exposed to external components. Examples databases are setup for 'farmer' organization using 'farmer' network under /databases/farmer which can be extended to other organizations by reusing the same files. Specific .sql formatted tables with beef chain specific parameters are available under /databases/beefchainparameters and can be used with postgres, mariadb or mysql. The tables can be split or combined depending upon the supply chain organziation from where the specific parameters are avaialble for consumption`. 



### MariaDB

MariaDB is an open-source relational database management system (RDBMS) and one of the most popular alternatives to MySQL.  For testing with docker as a standalone application, spin up the container by navigating into the /databases/farmer/mariadb directory.

     docker-compose up -d
     
     
Once up and running, there will be two containers that manage MariaDB database. Mariadb image spins up with the name 'farmermdb' and accompanying phpmyadmin contianer to manage SQL datbases runs up with the name 'phpmyadmin'. Mariadb container runs on port  "3307:3306" and phpadmin container runs on port  "8082:8080".  


`For testing purposes, the environment variables are directly specified into the docker-compose file. Pass sensitive information to contianers such as credentials using 'secrets' as described in the 'Sessions' tutorial page.`

The credentials 'usernames' and 'passwords' for mariadb and mysql have been set to 'farmermdb' for testing including the creation of a default database 'farmermdb'.  

A consistent database is attached to the container at runtime 'farmerdb_data' to keep data from being lost. Configuration for the contianers can be done using the file in 'config' folder and any number of databases and tables can be initiated using .sql formatted queries in 'init' folder. 

Once the container is up and running, pass any sql query from files to the container, for example 

	docker exec -i farmermdb  mysql -uroot  -pfarmermdb < farmer.sql
	
	
To pass any query from bash, 

        
	docker exec -i farmermdb  mysql -uroot  -pfarmermdb -e "show databases" 
	docker exec -i farmermdb  mysql -uroot  -pfarmermdb -e "use cattle_db; show tables" 
	docker exec -i farmermdb  mysql -uroot  -pfarmermdb -e "use cattle_db; show tables; select * from cattle"
 
The mariadb cli interface can also be used to do the same. For example, 

	docker exec -it farmermdb mariadb --user root -pfarmermdb -e "show databases"
   
 
To directly access mariadb cli interface within the container, 


	docker exec -it farmermdb mariadb --user root -pfarmermdb

Once inside the container, directly use sql queries at the prompt. In addition, it can be useful to directly access the phpmyadmin page running at 'http://localhost:8082' using 'farmermdb' for username and password. In addition, sotrage engine can be specified during the creation of database to allow utilizing the full potential for parallel or scalable application types. See more details here: https://mariadb.com/kb/en/storage-engines/

To bring down the Mariadb containers 

	docker stop farmerpma && docker stop farmermdb && docker rm farmerpma && docker rm farmermdb 
	
	# make backup before removing docker volume  
	docker volume rm mariadb_farmerdb_data && docker volume prune 
	
 
### MongoDB

MongoDB is a popular open-source, NoSQL database program. It falls under the category of document-oriented databases, which means it stores data in flexible, JSON-like documents. For testing with docker as a standalone application, spin up the container by navigating into the /databases/farmer/mongodb directory.

     docker-compose up -d
     
     
Once up and running, there will be two containers that manage MongoDB database. MongoDB image spins up with the name 'farmermongodb' and accompanying mongo-express contianer to manage mongo datbases runs up with the name 'farmermongoexpress'. Mongodb container runs on port "27018:27017" and mongo-express container runs on port  "8089:8081". 


`For testing purposes, the environment variables are directly specified into the docker-compose file. Pass sensitive information to contianers such as credentials using 'secrets' as described in the 'Sessions' tutorial page.`

The credentials 'usernames' and 'passwords' for mongoDB and mongo-express have been set to 'farmermdb' for testing including the creation of a default database 'farmermdb'.  

A consistent database is attached to the container at runtime 'farmermongo_data' to keep data from being lost. Configuration for the contianers can be done using the file in 'config' folder and any number of databases and tables can be initiated using .json formatted files in 'init' folder. Uncomment relevant lines in docker-compose script to allow using database initialization and custom configuration at container runtime. 

Once the container is up and running, directly access the continer,  

	docker exec -it farmermongodb bash
	
Once inside the container, access mongo cli interace,

	mongo mongodb://localhost:27017 -u farmermdb -p farmermdb

More details on Mongodb shell commands can be found at: https://www.mongodb.com/docs/mongodb-shell/run-commands/

You can also directly access the shell in one go, 

	docker exec -it farmermongodb mongo mongodb://localhost:27017 -u farmermdb -p farmermdb


Or pass any command to mongo shell from outside the container using bash. For example, create a new user credential and a database named 'farmer', 

	docker exec -it farmermongodb mongo  mongodb://localhost:27017 -u farmermdb -p farmermdb --eval "db.createUser({user: 'farmer', pwd: 'farmer', roles: [{role: 'readWrite', db: 'farmer'}]})"

With the flexiblity of mongodb database to store massive collections of data in json format, it is an ideal database for consuming beef supply chain data,  storing documents and sensor data. To store a collection of data in .json format, lets first copy the data file (cattle_data.json) into the container in /tmp folder. 

	docker cp databases/farmer/mongodb/cattle_data.json farmermongodb:/tmp/cattle_data.json
 
Next, login into the container and use 'mongoimport' tool to put the example file in a database,

	docker exec -it farmermongodb bash
	# Inside the container run,
	mongoimport --host localhost --port 27017 --username farmermdb --password farmermdb --authenticationDatabase admin --db farmermdb --collection farmermdb --file tmp/cattle_data.json --jsonArray

You can also run the command directly from outside the container using bash once you have copied the file into the container, 

	
	docker exec -it farmermongodb mongoimport --host localhost --port 27017 --username farmermdb --password farmermdb --authenticationDatabase admin --db farmermdb --collection farmermdb --file tmp/cattle_data.json --jsonArray
	
To retireve a collection of data from a database, 

	docker exec -it farmermongodb mongoexport --host localhost --port 27017 --username farmermdb --password farmermdb --authenticationDatabase admin --db farmermdb --collection farmermdb --out exported_data.json
	
This retrieves  the data collection and saves into the output file exported_data.json. You can copy the file to host machine from the container, 

	docker cp farmermongodb:exported_data.json exported_data.json	

Or you can directly retreive data from the database collection and store it in the host machine using bash,

	
	docker exec -it farmermongodb mongoexport --host localhost --port 27017 --username farmermdb --password farmermdb --authenticationDatabase admin --db farmermdb --collection farmermdb > exported_data_direct.json 
	
The data will be stored in a file 'exported_data_direct.json' in the host machine. 	

In addition, it can be useful to diretly access the mongo-express page running at 'http://127.0.0.1:8089' or 'localhost:8089' using 'farmermdb' for username and password. Mongoexpress allows a graphical interface to manage databases stored in mongodb. 


To bring down the MongoDB containers 

	docker stop farmermongoexpress && docker stop farmermongodb && docker rm farmermongoexpress && docker rm farmermongodb 
	
	# make backup before removing docker volume  
	docker volume rm mongodb_farmermongo_data && docker volume prune 

### PostgreSQL

PostgreSQL, which is a powerful open-source relational database management system (RDBMS). For testing with docker as a standalone application, spin up the container by navigating into the /databases/farmer/postgresql directory.

     docker-compose up -d
     
     
Once up and running, there will be two containers that manage MongoDB database. PostgreSQL image spins up with the name 'farmerpostgres' and accompanying pgadmin contianer to manage potgres datbases runs up with the name 'padmin_farmer'. Postgres container runs on port "5431:5432" and pgadmin container runs on port  "8887:80". 


`For testing purposes, the environment variables are directly specified into the docker-compose file. Pass sensitive information to contianers such as credentials using 'secrets' as described in the 'Sessions' tutorial page.`

The credentials 'usernames' and 'passwords' for postgres and pgadmin have been set to 'farmermdb' for testing including the creation of a default database 'farmermdb'.  

A consistent volume is attached to the container at runtime 'farmerpostgres' including a drive 'farmerpostgres_data' to keep data from being lost. Configuration for the contianers can be done using the file in 'config' folder and any number of databases and tables can be initiated using .sql formatted files in 'init' folder. Uncomment relevant lines in docker-compose script to allow using database initialization and custom configuration at container runtime. 

Once the container is up and running, directly access the continer,  

	docker exec -it farmerpostgres sh
	
Once inside the container, access psql cli interace and enter password 'farmermdb',

	psql -h localhost -p 5432 -U farmermdb -W

More details on psql shell commands can be found at: https://www.postgresql.org/docs/current/tutorial.html

To retrieve (import) an already existing database 'farmermdb' created at runtime, into the host machine using 'pg_dump' from bash terminal, 

	docker exec -i farmerpostgres  /bin/bash -c "PGPASSWORD=farmermdb pg_dump --username farmermdb farmermdb" > retrieved_data.sql

To upload or export data with creation of a new database, first copy .sql file into the container under /tmp folder, 

 
	docker cp farmerpostgres_data/cattle.sql farmerpostgres:/tmp/cattle.sql


Next sh into the container and use 'psql' cli interface to upload data,

  	docker exec -it farmerpostgres sh
  	# Type inside the container terminal, 
  	psql -U farmermdb farmermdb -f /tmp/cattle.sql
  	

You can also upload data into the database without going inside the container and just using the host terminal and using the file in /tmp folder, 

 	
 	docker exec -i farmerpostgres psql -U farmermdb farmermdb -f /tmp/cattle.sql
 	

Now to retrieve the same uploaded data in the database 'cattle_db', 

	
	docker exec -i farmerpostgres  /bin/bash -c "PGPASSWORD=farmermdb pg_dump --username farmermdb cattle_db" > retrieved_cattle_db.sql	

 	
	
In addition, it can be useful to diretly access the pgadmin page running at 'http://127.0.0.1:8887' or 'http://localhost:8887' using 'farmermdb' for username and password. Pgadmin allows a graphical interface to manage databases stored in postgres. Go to 'servers' tab on the left side, create new server connection using localhost as the 'host', port 5431, database 'farmermdb', username and password 'farmermdb'.

 
To bring down the Postgres containers 

	docker stop farmerpostgres && docker stop padmin_farmer && docker rm farmerpostgres && docker rm padmin_farmer 
	
	# make backup before removing docker volume  
	docker volume rm postgresdb_farmerpostgres && docker volume rm postgresdb_padmin_farmer && docker volume prune 



### Cassandra

Cassandra is NoSQL database particularly well-suited for use cases where fast reads and writes are essential, and where data needs to be distributed across multiple locations. For testing with docker as a standalone application, spin up the container by navigating into the /databases/farmer/cassandradb directory.

     docker-compose up -d
     
     
Once up and running, there will be a container running Cassandra database. Cassandra image spins up with the name 'farmercassdb'. The container runs on port "9034:9042" in addition to ports 7000, 7001, 7199 and 9160 exposed for various functions associated with cassandra. 


`For testing purposes, the environment variables are directly specified into the docker-compose file. Pass sensitive information to contianers such as credentials using 'secrets' as described in the 'Sessions' tutorial page.`

The credentials 'usernames' and 'passwords' have been set to 'cassandra' for testing.


A consistent volume is attached to the container at runtime 'farmercassdb_data' to keep data from being lost. Configuration for the contianers can be done using .yaml files present in the /databases/cassandra/etc folder and including it in the docker-compose file at runtime. A sample docker-compose-cluster.yaml file is also provided if a cluster of cassandra databases is requuired with different configurations for each database inherited from files in /etc folder. 


Once the container is up and running, check the status of the node (or cluster)

      docker exec -it farmercassdb  nodetool status

Directly access the cqlsh cli interace in container,  

	docker exec -it farmercassdb sh
	
	cqlsh
	
	# Alernate one liner
	docker exec -it farmercassdb cqlsh 
	
More details on cqlsh shell commands can be found at: https://cassandra.apache.org/doc/stable/cassandra/tools/cqlsh.html
	
Once, inside the container, create a keyspace (a namespace used for replicating data on multiple nodes) and use it as a test database, 

 	CREATE KEYSPACE my_cattle WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};
 	
 	use my_cattle


Once the keyspace has been selected for use, create a sample table,


	CREATE TABLE IF NOT EXISTS cattle_data (
    id UUID PRIMARY KEY,
    name TEXT,
    breed TEXT,
    age INT,
    weight FLOAT
	);

Now, insert sample data into the table, 

	INSERT INTO cattle_data (id, name, breed, age, weight) 
	VALUES (uuid(), 'Bessie', 'Holstein', 4, 1200.5);

	INSERT INTO cattle_data (id, name, breed, age, weight) 
	VALUES (uuid(), 'Daisy', 'Angus', 3, 1100.2);

	INSERT INTO cattle_data (id, name, breed, age, weight) 
	VALUES (uuid(), 'Spot', 'Hereford', 5, 1300.8);



Retrieve, data from table, 


	SELECT * FROM cattle_data;


You can also directly pass commands from host terminal without logging into the container,

	docker exec -it farmercassdb cqlsh -e "CREATE KEYSPACE my_cattle WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};"
	
	
	docker exec -it farmercassdb cqlsh -e "use my_cattle; CREATE TABLE IF NOT EXISTS cattle_data (id UUID PRIMARY KEY, name TEXT, breed TEXT, age INT, weight FLOAT); INSERT INTO cattle_data (id, name, breed, age, weight) VALUES (uuid(), 'Bessie', 'Holstein', 4, 1200.5); SELECT * FROM cattle_data;"
	
	# Or dump data directly to a file (data_out.txt) in host machine
	docker exec -it farmercassdb cqlsh -e "use my_cattle; CREATE TABLE IF NOT EXISTS cattle_data (id UUID PRIMARY KEY, name TEXT, breed TEXT, age INT, weight FLOAT); INSERT INTO cattle_data (id, name, breed, age, weight) VALUES (uuid(), 'Bessie', 'Holstein', 4, 1200.5); SELECT * FROM cattle_data;" > data_out.txt

It is also possible to create tables and upload data from .cql files. 

Copy sample .cql file in the cassandra folder into the container,

    docker cp cattle.cql farmercassdb:/cattle.cql

 
Access the docker container cqlsh shell and source the file, 

	docker exec -it farmercassdb cqlsh 
	
	
	source '/cattle.cql';
        

You can also directly pass the commands from host bash terminal after copying the file to the container,

       docker exec -it farmercassdb cqlsh -e "source '/cattle.cql';"
       

To use cassandra cluster, use the docker-compose-cluster.yaml file after configurig required changes. This may generate a lot of commit log files locally in commitlog/ folder, hence make sure there is tons space before running cluster. 

In addition, it can be useful to directly access the cassandradb-web page running at 'http://127.0.0.1:3003' or 'http://localhost:3003' to manage existing clusters or to create new cassandradb clusters. The cassandradb-web username and password are set to "cassandra". 


To bring down the cassandra containers and remove commit log files

	docker stop farmercassdb && docker rm farmercassdb && docker stop cassandra-web && docker rm cassandra-web
	
	# make backup before removing docker volume  
	docker volume rm cassandradb_farmercassdb_data && docker volume prune 
	
	# remove commitlog files
	rm commitlog/cassandra1/* && rm commitlog/cassandra2/*  && rm commitlog/cassandra3/* 
	# remove cluster data files after backing up 
 	rm data/cassandra1/* && rm data/cassandra2/*  && rm data/cassandra3/* 


### Multihost Setup

The databases are supposed to be run within each organization and should not be accessible from outside, hence the docker shell can be directly accessed from an administrator to upload or retrieve data. The containers connect to 'farmer' network as a bridge which can be changed to other networks or connections depending upon the applciation scenario using the scripts in /utilities folder. To allow other users with limited rights to view or upload data, create new user accounts directly for the databases and allow users to access the web management portal for the databases by updating and sourcing environment varibles for the deployed url of web tools.
  
      # from BeefMesh main directory 
      source environment/service_ip_addresses.sh
	
      # access phpmyadmin page for mariadb 
      http://$mariadb_server_address:8082
        
      # access mongo-express page for mongodb 
      http://$mongodb_server_address:8089
        
      # access pgadmin page for postres 
      http://$postgres_server_address:8087
        
      # access cassandra-web page for mariadb 
      http://$cassandra_server_address:3003


Other options could include resuing the flask-based applications for emissions and sessions sub-module to render specific CRUD api for different stored schemas 


