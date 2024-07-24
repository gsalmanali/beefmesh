# Emissions


This flask based submodule located under /emissions directroy is meant to serve as a common carbon emissions database maintained by a regulator. Emission parameters and factors are added to the database after neogtiation and voting on blockchain channels. Once a emissions factor is finalized, it is added to the database for users to consult from when calculating emissions at their end.    

For testing purposes as a standalone application from BeefMesh framework, create a virtual envrionment 

     virtualenv emissions
     source emissions/bin/activate
     pip install -r requirements.txt
     python -m main
    
    
Once up and running, use curl (https://curl.haxx.se/download.html) or  httpie (https://httpie.io/) commands to interact with the API.
For running the application for testing without docker may require setting credentials. These can be imported by "$ source emissions/env/env.sh" or by settting them as,

     export EMISSION_SUPERADMIN_PASSWORD=emissions
     export EMISSION_ADMIN_PASSWORD=emissions
     export EMISSION_TEST_USER_PASSWORD=emissions
     export EMISSION_GENERIC_USER_PASSWORD=emissions
     
        
By default, the application initializes with the following credentials defined in /api/db_initializer/db_initializer.py:

**Super Admin Credentials:**

    username: username_superadmin  
    password: emissions  
    email: email_superadmin@emissions.com
    
**Admin Credentials:**
    
    username: username_admin  
    password: emissions  
    email: email_admin@emissions.com
    
**Test User Credentials:**

    username: username_test  
    password: emissions  
    email: email_test@emissions.com
    
**Emissions User Credentials:**

    username: username_emissions 
    password: emissions  
    email: email_emissions@emissions.com


The database file is created and maintained under /api/db_files.
    
In docker, the credentials are imported as secrets and kept under /emissions/secrets for testing purposes. For testing with docker as a standalone application, spin up the containerby navigating into the /emissions directory.

     docker-compose up -d
    
Once up and running, different routes can be used to interact with the application. Some example routes are given below. 

`Note: The curl commands below use 'localhost' in the url section. This would he replaced with the IP or URL mapping of the hosted application when accessing from an outside host. The port '6001' can be changed to whatever port is suitable for your system`. 

The application consits of custom emission factors added for beef supply chain. Users can add their own paramters under generic category.  


### Register Users

     curl -k -H "Content-Type: application/json" --data '{"username":"example_name","password":"example_password", "email":"example@emissions.com"}' https://localhost:6001/emissions/v1/auth/register
    
Note that we use -k flag to use dummy certificates generated from openssl application or with arbitrary certificate assignment by flask.
### Login Users

     curl -k -H "Content-Type: application/json" --data '{"email":"example@emissions.com","password":"example_password"}' https://localhost:6001/emissions/v1/auth/login


Logging in a user generates an Access Token and a Refresh Token that can be used to access resources on the server. An example of the response with tokens is given below. 

     {
    "access_token": "eyJhbGciOiJIUzUxMiIsImlhdCI6MTcwODY1MDY4NSwiZXhwIjoxNzA4NjU0Mjg1fQ.eyJlbWFpbCI6ImV4YW1wbGVAZXhhbXBsZS5jb20iLCJhZG1pbiI6MH0.DlJnfzALoul7CH_jh0_R6SpNF-2w5xzx7iu2ZR-AXh_ErFyfl_KMOLBLyZ8smX7gSe1sfvJzKHAgQPoqlUnR7w",
    "refresh_token": "eyJhbGciOiJIUzUxMiIsImlhdCI6MTcwODY1MDY4NSwiZXhwIjoxNzA4NjU3ODg1fQ.eyJlbWFpbCI6ImV4YW1wbGVAZXhhbXBsZS5jb20ifQ.ysZ8JDAj5SlPe0rbfr2DXGL0BPCxZ-TFvqRyvabcNYkyKJmWXP3WkJ8xryFtxIE12a04SR-VkFyiLLjGnJvVjw"
}

The tokens will be passed whereever user is requied to be logged in on the server to access any resources. 

### Logout Users

     curl -k -H "Content-Type: application/json" -H 'Authorization: Bearer '$AccessToken --data '{"refresh_token":'\"$RefreshToken\"'}' https://localhost:6001/emissions/v1/auth/logout
    
Note that the above command requires passing values for token variables. 

### Refresh Tokens

    curl -k  -H "Content-Type: application/json"  -H 'Authorization: Bearer '$AccessToken --data '{"refresh_token":'\"$RefreshToken\"'}' https://localhost:6001/emissions/v1/auth/refresh
    
### Reset Password

    curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"old_pass":"example_password","new_pass":"new_password"}' https://localhost:6001/emissions/v1/auth/password_reset
    
### Remove User   
    
     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"username":"example_name","password":"example_password","email":"example@emissions.com"}' https://localhost:6001/emissions/v1/auth/remove_user

Note that removing a user requires super admin permissions and the super admin needs to be logged in to be able to pass on their access tokens. These requirements can be changed under relevant classes which are classed against each route. These classes can be found in UserHandlers.py file under /api/handlers

### Checking Permissions

   To check whether a user should be allowed to access any resource on the server,

     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@emissions.com","password":"emissions"}' https://localhost:6001/beefchain/v1/auth/check_user_permission
     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@emissions.com","password":"emissions"}' https://localhost:6001/beefchain/v1/auth/check_admin_permission
     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@emissions.com","password":"emissions"}' https://localhost:6001/beefchain/v1/auth/check_sadmin_permission
    
The route will return a {"status": "success"} or {"status": "failure"} message depending upon whether the user is succesffuly logged in and using correct token. This can be used as a condition to allow access to resources. 


### Testing Permissions 

Some test routes for debugging user permissions are provided below. 

     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://localhost:6001/emissions/v1/auth/data_user
     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://localhost:6001/emissions/v1/auth/data_admin
     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://localhost:6001/emissions/v1/auth/data_super_admin
     

### Generic Parameters

To add generic parameters for emissions calculations, 

     curl -k -H "Content-Type: application/json" --data '{"name":"generic","factor":"0.0017","link":"https://shorturl.at/hiBCG","code":"plastic","region":"michigan","unit":"kg","info":"The cradle to grave carbon footprint of a plastic use is 0.94 kg CO2e/kg"}'  https://localhost:6001/emissions/v1/auth/insert_data_generic
     
A reponse could look like
     
     {
    "status": "successfully added parameters to generic data"
     }
     
     
In the above call to emissions API, 'unit' is used as a measure for resource consumption input against which emissions are calculated, for example 500 kg of platic use and factor is a floating value. 'Code' can be used to refer to category. 'link' is used to refer to the source, 'region' can be used to highlight the area, the factor is specific to. Further 'info' can also be added to make use of more parameters to fine tune emissions or to get a detaled view of underlying processes. For example, when calculating emissions from a 'heating' process, the boiler efficiency percentage, the water temperature, losses in tranfer of heating can be taken into account. To get a view of all the available factors for generic category, 
     
     
      curl -k -H "Content-Type: application/json" --data '{"name":"generic"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
      
A reponse could look like 
      
    [
    {
        "name": "generic",
        "id": 1,
        "region": "michigan",
        "unit": "kWh",
        "factor": 0.000433,
        "link": "https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references",
        "code": "electricity",
        "info": "92.7% efficiency over distribution lines"
    },
    {
        "name": "generic",
        "id": 2,
        "region": "michigan",
        "unit": "kg",
        "factor": 0.0017,
        "link": "https://shorturl.at/hiBCG",
        "code": "plastic",
        "info": "The cradle to grave carbon footprint of a plastic use is 0.94 kg CO2e/kg"
    }
      ]


To get the resultant value of total emissions against a particular amount of resource consumption, 

       
      curl -k -H "Content-Type: application/json" --data '{"name":"generic","code":"electricity","region":"michigan","value":"1000"}'  https://localhost:6001/emissions/v1/auth/get_data_generic

Here, 'value' is used as a place holder for resource consumption, for example 1000 kWh.  A reponse could look like one given below. Note that the parameter 'scale' refers to the fact that the resultant value of total emissions given in 'result' is in metric ton CO2 equivalent. 
    
    
    {
    "factor": 0.000433,
    "result": 0.433,
    "info": "92.7% efficiency over distribution lines",
    "unit": "kWh",
    "scale": "metric ton CO2-equivalent" 
    }


`Note that the resultant values are given in CO2 equivalent by converting the input value (e.g. CO2 into CO2-equivalent) assuming that the input value is the only form of emissions available. The factors are used from online resources and not all of them take into account  all of the CO2-equivalent contributing gases. If other measures of contributing gases (such as methane) are also available, add their CO2-equivalent contribution (in metric ton) to the resultant values`.    

    
### Retrieving all Info    
    
`Note: The curl commands from here onwards have the 'Authorization' header part removed for testing purposes. Enable Authorization for the routes by including @auth.login_required and @role_required.permission(2) for the relevant classes called by routes in the file UserHandlers.py` 

To get all info of factors available related to different categories, 

	curl -k -H "Content-Type: application/json" --data '{"name":"generic"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors


	curl -k -H "Content-Type: application/json" --data '{"name":"electricity"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"diesel"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"gasoline"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"fossil"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"naturalgas"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"biogas"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"solar"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"windturbine"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"steam"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"feed"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"byproducts"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"packaging"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"consumption"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"water"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	surl -k -H "Content-Type: application/json" --data '{"name":"plantation"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"chemicals"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"processes"}'  https://localhost:6001/emissions/v1/auth/get_all_emission_factors
	
	
`Example calls to API for inserting factors into database or retreiving resultant emissions from available factors in different custom categories are summarized below`. 

### Electricity Factors
    
    
	curl -k -H "Content-Type: application/json" --data '{"name":"electricity","factor":"0.000433","link":"replace_url_here","code":"v02","region":"michigan","unit":"kWh","info":"92.7% efficiency"}'  https://localhost:6001/emissions/v1/auth/insert_data_electricity

	curl -k -H "Content-Type: application/json" --data '{"name":"electricity","code":"v01","region":"michigan","value":"50000"}'  https://localhost:6001/emissions/v1/auth/get_data_electricity

### Diesel Factors     

	curl -k -H "Content-Type: application/json" --data '{"name":"diesel","factor":"0.001219","link":"replace_url_here","code":"v02","region":"michigan","unit":"lb","info":"none"}'  https://localhost:6001/emissions/v1/auth/insert_data_diesel

	curl -k -H "Content-Type: application/json" --data '{"name":"diesel","code":"v01","region":"michigan","value":"5000"}'  https://localhost:6001/emissions/v1/auth/get_data_diesel
	
### Gasoline Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"gasoline","factor":"0.0010617","link":"replace_url_here","code":"v02","region":"michigan","unit":"lb","info":"none"}'  https://localhost:6001/emissions/v1/auth/insert_data_gasoline

	curl -k -H "Content-Type: application/json" --data '{"name":"gasoline","code":"v01","region":"michigan","value":"5000"}'  https://localhost:6001/emissions/v1/auth/get_data_gasoline

### Fossil Factors

	curl -k -H "Content-Type: application/json" --data '{"name":"fossil","factor":"0.000904","link":"replace_url_here","code":"v02","region":"michigan","unit":"lb","info":"none"}'  https://localhost:6001/emissions/v1/auth/insert_data_fossil

	curl -k -H "Content-Type: application/json" --data '{"name":"fossil","code":"v01","region":"michigan","value":"4000"}'  https://localhost:6001/emissions/v1/auth/get_data_fossil

### Naturalgas Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"naturalgas","factor":"0.00005301","link":"replace_url_here","code":"v02","region":"michigan","unit":"feet^3","info":"none"}'  https://localhost:6001/emissions/v1/auth/insert_data_naturalgas

	curl -k -H "Content-Type: application/json" --data '{"name":"naturalgas","code":"v01","region":"michigan","value":"100000"}'  https://localhost:6001/emissions/v1/auth/get_data_naturalgas

### Biogas Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"biogas","factor":"0.0000247","link":"replace_url_here","code":"v02","region":"michigan","unit":"feet^3","info":"carbon reduction, (electricity*0.0571) assuming 1 cubic meterbiogas = 2kWh energy"}'  https://localhost:6001/emissions/v1/auth/insert_data_biogas

	curl -k -H "Content-Type: application/json" --data '{"name":"biogas","code":"v01","region":"michigan","value":"5000"}'  https://localhost:6001/emissions/v1/auth/get_data_biogas


### Solar Factors 



	curl -k -H "Content-Type: application/json" --data '{"name":"solar","factor":"0.00005","link":"replace_url_here","code":"v02","region":"michigan","unit":"kWh","info":"solar panels offset 50 grams of CO2 for every kilowatt-hour of power produced"}'  https://localhost:6001/emissions/v1/auth/insert_data_solar

	curl -k -H "Content-Type: application/json" --data '{"name":"solar","code":"v01","region":"michigan","value":"1000"}'  https://localhost:6001/emissions/v1/auth/get_data_solar


### Windturbine Factors 


	curl -k -H "Content-Type: application/json" --data '{"name":"windturbine","factor":"0.000006","link":"replace_url_here","code":"v02","region":"michigan","unit":"kWh","info":"offset 6 grams of CO2 for every kilowatt-hour of power produced"}'  https://localhost:6001/emissions/v1/auth/insert_data_windturbine

	curl -k -H "Content-Type: application/json" --data '{"name":"windturbine","code":"v01","region":"michigan","value":"2000"}'  https://localhost:6001/emissions/v1/auth/get_data_windturbine


### Steam Factors 



	curl -k -H "Content-Type: application/json" --data '{"name":"steam","factor":"0.000004","link":"replace_url_here","code":"v02","region":"michigan","unit":"lb","info":"assuming 80% efficient boiler and converting used steam to natural gas, also assuming water is coming in at 60F (about 15C) with 28 btu"}'  https://localhost:6001/emissions/v1/auth/insert_data_steam

	curl -k -H "Content-Type: application/json" --data '{"name":"steam","code":"v01","region":"michigan","value":"100000"}'  https://localhost:6001/emissions/v1/auth/get_data_steam


### Feed Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"feed","factor":"0.000032","link":"replace_url_here","code":"organicgrass","region":"michigan","unit":"lb","info":"from 80% dry matter"}'  https://localhost:6001/emissions/v1/auth/insert_data_feed

	curl -k -H "Content-Type: application/json" --data '{"name":"feed","code":"alfalfa","region":"michigan","value":"10000"}'  https://localhost:6001/emissions/v1/auth/get_data_feed

### Byproducts Factors 


	curl -k -H "Content-Type: application/json" --data '{"name":"byproducts","factor":"0.000015","link":"replace_url_here","code":"discharge","region":"michigan","unit":"lb","info":"volatile mixture from dump"}'  https://localhost:6001/emissions/v1/auth/insert_data_byproducts

	curl -k -H "Content-Type: application/json" --data '{"name":"byproducts","code":"methane","region":"michigan","value":"10000"}'  https://localhost:6001/emissions/v1/auth/get_data_byproducts


### Packaging Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"packaging","factor":"0.000942","link":"replace_url_here","code":"bleachedpaper","region":"michigan","unit":"kg","info":"The cradle to grave carbon footprint of a cardboard box is 0.94 kg CO2e / kg"}'  https://localhost:6001/emissions/v1/auth/insert_data_packaging

	curl -k -H "Content-Type: application/json" --data '{"name":"packaging","code":"paper","region":"michigan","value":"1000"}'  https://localhost:6001/emissions/v1/auth/get_data_packaging

### Consumption Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"consumption","factor":"0.00316","link":"replace_url_here","code":"bake","region":"michigan","unit":"lb","info":"using standard equipment for cooking"}'  https://localhost:6001/emissions/v1/auth/insert_data_consumption

	curl -k -H "Content-Type: application/json" --data '{"name":"consumption","code":"roast","region":"michigan","value":"5"}'  https://localhost:6001/emissions/v1/auth/get_data_consumption

### Water Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"water","factor":"0.00000098","link":"replace_url_here","code":"filtered","region":"michigan","unit":"lb","info":"from life cycle energy used for processing, reactions and and distribution/packaging"}'  https://localhost:6001/emissions/v1/auth/insert_data_water

	curl -k -H "Content-Type: application/json" --data '{"name":"water","code":"brackish","region":"michigan","value":"1000"}'  https://localhost:6001/emissions/v1/auth/get_data_water

### Plantation Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"plantation","factor":"0.060","link":"replace_url_here","code":"palmtrees","region":"michigan","unit":"hactre","info":"redcution from 100 generic trees/hactre, 0.060 metric ton CO2 per urban tree planted"}'  https://localhost:6001/emissions/v1/auth/insert_data_plantation

	curl -k -H "Content-Type: application/json" --data '{"name":"plantation","code":"trees","region":"michigan","value":"100"}'  https://localhost:6001/emissions/v1/auth/get_data_plantation

### Chemicals Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"chemicals","factor":"0.00168","link":"replace_url_here","code":"colorants","region":"michigan","unit":"lb","info":"Imidazole + Trizole 3.90kg CO2 per kg, Organophosphate 3.70kg CO2 per kg"}'  https://localhost:6001/emissions/v1/auth/insert_data_chemicals

	curl -k -H "Content-Type: application/json" --data '{"name":"chemicals","code":"fungicide","region":"michigan","value":"100"}'  https://localhost:6001/emissions/v1/auth/get_data_chemicals

### Processes Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"processes","factor":"0.00019","link":"replace_url_here","code":"compression","region":"michigan","unit":"kWh","info":"0.19 Kg CO2 eq per kWh for HVAC"}'  https://localhost:6001/emissions/v1/auth/insert_data_processes

	curl -k -H "Content-Type: application/json" --data '{"name":"processes","code":"cooling","region":"michigan","value":"1000"}'  https://localhost:6001/emissions/v1/auth/get_data_processes
	
### Bring down containers 

To bring down the container manually,

	docker stop emission.beefsupply.com && docker rm emission.beefsupply.com && docker volume rm emission.beefsupply.com

`Note: Enable the 'restart' option in docker-compose file with appropriate options {always, on-failure, unless-stopped} for persistence and make back up of volumes before removing them`
	
    # Remove directories created during building and running app
    rm -R mainserver && rm -R __pycache__
    
    # Remove volumes (make back up before doing so)
    docker volume rm emissions_emission.beefsupply.com && docker volume prune
    
    
    # remove all __pycache__ files in /emissions directory generated during the application runtime
    find . -type d -name "__pycache__" -exec rm -r {} +
	
	
### Multi-Host Environment

Containers can be accessed from a different host using the (1) hosted ip address (2) domain name or the (3) container name. The container name is set to 'emission.beefsupply.com' so any other container directly connected to the network 'beef_supply' can access the cotainer directly using the link https://emission.beefsupply.com:6001/ If the containers are hosted permanently with a domain name, edit the /etc/hosts file to point to the domain name (more details can be found at: https://man7.org/linux/man-pages/man5/hosts.5.html). We restrict the tutorial to a service hosted on a machine with a reachable ip address. Once the ip-address of the machine where the service is being hosted in confirmed (e.g. 203.0.113.5 ), change it for the variable 'emissions_address' in the BeefMesh/environment/service_ip_address.sh file and source it in the terminal

	source environment/service_ip_addresses.sh

All of the commands above will be used with the new address $emissions_address instead of localhost. 


#### Register Users

     curl -k -H "Content-Type: application/json" --data '{"username":"example_name","password":"example_password", "email":"example@emissions.com"}' https://$emissions_address:6001/emissions/v1/auth/register
    

#### Login Users

     curl -k -H "Content-Type: application/json" --data '{"email":"example@emissions.com","password":"example_password"}' https://$emissions_address:6001/emissions/v1/auth/login


#### Logout Users

     curl -k -H "Content-Type: application/json" -H 'Authorization: Bearer '$AccessToken --data '{"refresh_token":'\"$RefreshToken\"'}' https://$emissions_address:6001/emissions/v1/auth/logout
    

#### Refresh Tokens

    curl -k  -H "Content-Type: application/json"  -H 'Authorization: Bearer '$AccessToken --data '{"refresh_token":'\"$RefreshToken\"'}' https://$emissions_address:6001/emissions/v1/auth/refresh
    
#### Reset Password

    curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"old_pass":"example_password","new_pass":"new_password"}' https://$emissions_address:6001/emissions/v1/auth/password_reset
    
#### Remove User   
    
     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"username":"example_name","password":"example_password","email":"example@emissions.com"}' https://$emissions_address:6001/emissions/v1/auth/remove_user


#### Checking Permissions

To check generic user permission 

     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@emissions.com","password":"emissions"}' https://$emissions_address:6001/beefchain/v1/auth/check_user_permission
     
To check admin user permission 

     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@emissions.com","password":"emissions"}' https://$emissions_address:6001/beefchain/v1/auth/check_admin_permission
     
To check super admin user permission 
     
     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@emissions.com","password":"emissions"}' https://$emissions_address:6001/beefchain/v1/auth/check_sadmin_permission
    

#### Testing Permissions 

Test routes for debugging generic user permission 

     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://$emissions_address:6001/emissions/v1/auth/data_user
     
     
Test routes for debugging admin user permission 
     
     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://$emissions_address:6001/emissions/v1/auth/data_admin
     
Test routes for debugging super admin user permission 
     
     
     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://$emissions_address:6001/emissions/v1/auth/data_super_admin
     

#### Generic Parameters

To add generic parameters for emissions calculations 

     curl -k -H "Content-Type: application/json" --data '{"name":"generic","factor":"0.0017","link":"https://shorturl.at/hiBCG","code":"plastic","region":"michigan","unit":"kg","info":"The cradle to grave carbon footprint of a plastic use is 0.94 kg CO2e/kg"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_generic
     
To get a view of all the available factors for generic category, 
     
     
      curl -k -H "Content-Type: application/json" --data '{"name":"generic"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors


To get the resultant value of total emissions against a particular amount of resource consumption, 

       
      curl -k -H "Content-Type: application/json" --data '{"name":"generic","code":"electricity","region":"michigan","value":"1000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_generic

  

    
#### Retrieving all Info    
    

To get all info of factors available related to different categories, 

	curl -k -H "Content-Type: application/json" --data '{"name":"generic"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors


	curl -k -H "Content-Type: application/json" --data '{"name":"electricity"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"diesel"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"gasoline"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"fossil"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"naturalgas"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"biogas"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"solar"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"windturbine"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"steam"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"feed"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"byproducts"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"packaging"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"consumption"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"water"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	surl -k -H "Content-Type: application/json" --data '{"name":"plantation"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"chemicals"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	curl -k -H "Content-Type: application/json" --data '{"name":"processes"}'  https://$emissions_address:6001/emissions/v1/auth/get_all_emission_factors
	
	
Example calls to API for inserting factors into database or retreiving resultant emissions are summarized below`. 

#### Electricity Factors
    
    
	curl -k -H "Content-Type: application/json" --data '{"name":"electricity","factor":"0.000433","link":"replace_url_here","code":"v02","region":"michigan","unit":"kWh","info":"92.7% efficiency"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_electricity

	curl -k -H "Content-Type: application/json" --data '{"name":"electricity","code":"v01","region":"michigan","value":"50000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_electricity

#### Diesel Factors     

	curl -k -H "Content-Type: application/json" --data '{"name":"diesel","factor":"0.001219","link":"replace_url_here","code":"v02","region":"michigan","unit":"lb","info":"none"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_diesel

	curl -k -H "Content-Type: application/json" --data '{"name":"diesel","code":"v01","region":"michigan","value":"5000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_diesel
	
#### Gasoline Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"gasoline","factor":"0.0010617","link":"replace_url_here","code":"v02","region":"michigan","unit":"lb","info":"none"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_gasoline

	curl -k -H "Content-Type: application/json" --data '{"name":"gasoline","code":"v01","region":"michigan","value":"5000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_gasoline

#### Fossil Factors

	curl -k -H "Content-Type: application/json" --data '{"name":"fossil","factor":"0.000904","link":"replace_url_here","code":"v02","region":"michigan","unit":"lb","info":"none"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_fossil

	curl -k -H "Content-Type: application/json" --data '{"name":"fossil","code":"v01","region":"michigan","value":"4000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_fossil

#### Naturalgas Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"naturalgas","factor":"0.00005301","link":"replace_url_here","code":"v02","region":"michigan","unit":"feet^3","info":"none"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_naturalgas

	curl -k -H "Content-Type: application/json" --data '{"name":"naturalgas","code":"v01","region":"michigan","value":"100000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_naturalgas

#### Biogas Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"biogas","factor":"0.0000247","link":"replace_url_here","code":"v02","region":"michigan","unit":"feet^3","info":"carbon reduction, (electricity*0.0571) assuming 1 cubic meterbiogas = 2kWh energy"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_biogas

	curl -k -H "Content-Type: application/json" --data '{"name":"biogas","code":"v01","region":"michigan","value":"5000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_biogas


#### Solar Factors 



	curl -k -H "Content-Type: application/json" --data '{"name":"solar","factor":"0.00005","link":"replace_url_here","code":"v02","region":"michigan","unit":"kWh","info":"solar panels offset 50 grams of CO2 for every kilowatt-hour of power produced"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_solar

	curl -k -H "Content-Type: application/json" --data '{"name":"solar","code":"v01","region":"michigan","value":"1000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_solar


#### Windturbine Factors 


	curl -k -H "Content-Type: application/json" --data '{"name":"windturbine","factor":"0.000006","link":"replace_url_here","code":"v02","region":"michigan","unit":"kWh","info":"offset 6 grams of CO2 for every kilowatt-hour of power produced"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_windturbine

	curl -k -H "Content-Type: application/json" --data '{"name":"windturbine","code":"v01","region":"michigan","value":"2000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_windturbine


#### Steam Factors 



	curl -k -H "Content-Type: application/json" --data '{"name":"steam","factor":"0.000004","link":"replace_url_here","code":"v02","region":"michigan","unit":"lb","info":"assuming 80% efficient boiler and converting used steam to natural gas, also assuming water is coming in at 60F (about 15C) with 28 btu"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_steam

	curl -k -H "Content-Type: application/json" --data '{"name":"steam","code":"v01","region":"michigan","value":"100000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_steam


#### Feed Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"feed","factor":"0.000032","link":"replace_url_here","code":"organicgrass","region":"michigan","unit":"lb","info":"from 80% dry matter"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_feed

	curl -k -H "Content-Type: application/json" --data '{"name":"feed","code":"alfalfa","region":"michigan","value":"10000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_feed

#### Byproducts Factors 


	curl -k -H "Content-Type: application/json" --data '{"name":"byproducts","factor":"0.000015","link":"replace_url_here","code":"discharge","region":"michigan","unit":"lb","info":"volatile mixture from dump"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_byproducts

	curl -k -H "Content-Type: application/json" --data '{"name":"byproducts","code":"methane","region":"michigan","value":"10000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_byproducts


#### Packaging Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"packaging","factor":"0.000942","link":"replace_url_here","code":"bleachedpaper","region":"michigan","unit":"kg","info":"The cradle to grave carbon footprint of a cardboard box is 0.94 kg CO2e / kg"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_packaging

	curl -k -H "Content-Type: application/json" --data '{"name":"packaging","code":"paper","region":"michigan","value":"1000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_packaging

#### Consumption Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"consumption","factor":"0.00316","link":"replace_url_here","code":"bake","region":"michigan","unit":"lb","info":"using standard equipment for cooking"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_consumption

	curl -k -H "Content-Type: application/json" --data '{"name":"consumption","code":"roast","region":"michigan","value":"5"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_consumption

#### Water Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"water","factor":"0.00000098","link":"replace_url_here","code":"filtered","region":"michigan","unit":"lb","info":"from life cycle energy used for processing, reactions and and distribution/packaging"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_water

	curl -k -H "Content-Type: application/json" --data '{"name":"water","code":"brackish","region":"michigan","value":"1000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_water

#### Plantation Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"plantation","factor":"0.060","link":"replace_url_here","code":"palmtrees","region":"michigan","unit":"hactre","info":"redcution from 100 generic trees/hactre, 0.060 metric ton CO2 per urban tree planted"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_plantation

	curl -k -H "Content-Type: application/json" --data '{"name":"plantation","code":"trees","region":"michigan","value":"100"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_plantation

#### Chemicals Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"chemicals","factor":"0.00168","link":"replace_url_here","code":"colorants","region":"michigan","unit":"lb","info":"Imidazole + Trizole 3.90kg CO2 per kg, Organophosphate 3.70kg CO2 per kg"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_chemicals

	curl -k -H "Content-Type: application/json" --data '{"name":"chemicals","code":"fungicide","region":"michigan","value":"100"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_chemicals

#### Processes Factors 

	curl -k -H "Content-Type: application/json" --data '{"name":"processes","factor":"0.00019","link":"replace_url_here","code":"compression","region":"michigan","unit":"kWh","info":"0.19 Kg CO2 eq per kWh for HVAC"}'  https://$emissions_address:6001/emissions/v1/auth/insert_data_processes

	curl -k -H "Content-Type: application/json" --data '{"name":"processes","code":"cooling","region":"michigan","value":"1000"}'  https://$emissions_address:6001/emissions/v1/auth/get_data_processes


