# Sessions


This flask based submodule located under /sessions directory is meant to serve as a frontend for verifying user credentials and forming collaboration groups by uploading or downloading resources and information related to swarm overlay network, shared network drive (GlusterFS), shared databases (IPFS) or literally any useful application. The sessions application also runs as the starting collaboration point, hence is also referred to as collaborator or group initiator. 

For testing purposes as a standalone application from BeefMesh framework, create a virtual envrionment 

     virtualenv mainserver
     source mainserver/bin/activate
     pip install -r requirements.txt
     python -m main
    
    
Once up and running, use curl (https://curl.haxx.se/download.html) or  httpie (https://httpie.io/) commands to interact with the API.
For running the application for testing without docker may require setting credentials. These can be imported by "$ source sessions/env/env.sh" or by settting them as,

     export SESSION_SUPERADMIN_PASSWORD=beefchain
     export SESSION_ADMIN_PASSWORD=beefchain
     export SESSION_TEST_USER_PASSWORD=beefchain
     export SESSION_GENERIC_USER_PASSWORD=beefchain
    
In docker, the credentials are imported as secrets and kept under /sessions/secrets for testing purposes. By default, the application initializes with the following credentials defined in /api/db_initializer/db_initializer.py:

**Super Admin Credentials:**

    username: username_superadmin  
    password: beefchain  
    email: email_superadmin@beefsupply.com
    
**Admin Credentials:**
    
    username: username_admin  
    password: beefchain  
    email: email_admin@beefsupply.com
    
**Test User Credentials:**

    username: username_test  
    password: beefchain  
    email: email_test@beefsupply.com
    
**BeefChain User Credentials:**

    username: username_beefsupply  
    password: beefchain  
    email: email_beefsupply@beefsupply.com



The database file is created and maintained under /api/db_files. For testing with docker as a standalone application, spin up the containerby navigating into the /sessions directory.

     docker-compose up -d
    
Once up and running, different routes can be used to interact with the application. Some example routes are given below. 

`Note: The curl commands below use 'localhost' in the url section. This would he replaced with the IP or URL mapping of the hosted application when accessing from an outside host. The port '7001' can be changed to whatever port is suitable for your system`. 

### Register Users

    curl -k -H "Content-Type: application/json" --data '{"username":"example_name","password":"example_password", "email":"example@beefsupply.com"}' https://localhost:7001/beefchain/v1/auth/register
    
Note that we use -k flag to use dummy certificates generated from openssl application or with arbitrary certificate assignment by flask.
### Login Users

     curl -k -H "Content-Type: application/json" --data '{"email":"example@beefsupply.com","password":"example_password"}' https://localhost:7001/beefchain/v1/auth/login


Logging in a user generates an Access Token and a Refresh Token that can be used to access resources on the server. An example of the response with tokens is given below. 

     {
    "access_token": "eyJhbGciOiJIUzUxMiIsImlhdCI6MTcwODY1MDY4NSwiZXhwIjoxNzA4NjU0Mjg1fQ.eyJlbWFpbCI6ImV4YW1wbGVAZXhhbXBsZS5jb20iLCJhZG1pbiI6MH0.DlJnfzALoul7CH_jh0_R6SpNF-2w5xzx7iu2ZR-AXh_ErFyfl_KMOLBLyZ8smX7gSe1sfvJzKHAgQPoqlUnR7w",
    "refresh_token": "eyJhbGciOiJIUzUxMiIsImlhdCI6MTcwODY1MDY4NSwiZXhwIjoxNzA4NjU3ODg1fQ.eyJlbWFpbCI6ImV4YW1wbGVAZXhhbXBsZS5jb20ifQ.ysZ8JDAj5SlPe0rbfr2DXGL0BPCxZ-TFvqRyvabcNYkyKJmWXP3WkJ8xryFtxIE12a04SR-VkFyiLLjGnJvVjw"
}

The tokens will be passed whereever user is requied to be logged in on the server to access any resources. 

### Logout Users

     curl -k -H "Content-Type: application/json" -H 'Authorization: Bearer '$AccessToken --data '{"refresh_token":'\"$RefreshToken\"'}' https://localhost:7001/beefchain/v1/auth/logout
    
Note that the above command requires passing values for token variables. 

### Refresh Tokens

     curl -k  -H "Content-Type: application/json"  -H 'Authorization: Bearer '$AccessToken --data '{"refresh_token":'\"$RefreshToken\"'}' https://localhost:7001/beefchain/v1/auth/refresh
    
### Reset Password

     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"old_pass":"example_password","new_pass":"new_password"}' https://localhost:7001/beefchain/v1/auth/password_reset
    
### Remove User   
    
     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"username":"example_name","password":"example_password","email":"example@beefsupply.com"}' https://localhost:7001/beefchain/v1/auth/remove_user

Note that removing a user requires super admin permissions and the super admin needs to be logged in to be able to pass on their access tokens. These requirements can be changed under relevant classes which are classed against each route. These classes can be found in UserHandlers.py file under /api/handlers

### Checking Permissions

   To check whether a user should be allowed to access any resource on the server,

     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@beefsupply.com","password":"beefchain"}' https://localhost:7001/beefchain/v1/auth/check_user_permission
     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@beefsupply.com","password":"beefchain"}' https://localhost:7001/beefchain/v1/auth/check_admin_permission
     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@beefsupply.com","password":"beefchain"}' https://localhost:7001/beefchain/v1/auth/check_sadmin_permission
    
The route will return a {"status": "success"} or {"status": "failure"} message depending upon whether the user is succesffuly logged in and using correct token. This can be used as a condition to allow access to resources. 


### Testing Permissions 

Some test routes for debugging user permissions are provided below. 

     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://localhost:7001/beefchain/v1/auth/data_user
     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://localhost:7001/beefchain/v1/auth/data_admin
     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://localhost:7001/beefchain/v1/auth/data_super_admin
  
  
### Create Collaboration Groups 


 
 `Note: The curl commands from here onwards have the 'Authorization' header part removed for testing purposes. Enable Authorization for the routes by including @auth.login_required and @role_required.permission(2) for the relevant classes called by routes in the file UserHandlers.py` 
 
  A group for collaboration can be created by,
 
     curl -k -H  "Content-Type: application/json" --data '{"name":"breeder","description":"BreederConsortium","gluster":"192.168.1.5","ipfs":"192.168.1.5","overlay":"breeder_network"}' https://localhost:7001/beefchain/v1/auth/insert_group_info
   
   The command in addition to adding information to a database, creates a folder with the same group name under /api/db_files. The folder further contains files for appending information from group users related to glusterFS, IPFS and Overlay network overtime. Information related to the group can be retrieved by, 
   
     curl -k -H  "Content-Type: application/json" --data '{"name":"breeder","description":"BreederConsortium"}' https://localhost:7001/beefchain/v1/auth/get_group_info
      
      
### Upload Group Related Files

Files that can be used to form collboration groups can be uploaded by, 

    curl -k -F 'file=@/home/USER/BeefChain/sessions/beefchain.txt' https://localhost:7001/beefchain/v1/auth/upload_file

To allow a file extension to be allowed or disallowed from being uploaded to the server, modify the ALLOWED_EXTENSIONS variable in the UserHandlers.py file under /api/handlers. To download a file,

     curl -k -H "Content-Type: application/json" --data '{"filename":"beefchain.txt","description":"beefchain.txt"}' https://localhost:7001/beefchain/v1/auth/download_file > beefchain.txt
    
To remove a file, 
    
    curl -k -H "Content-Type: application/json" --data '{"filename":"beefchain.txt","description":"beefchain.txt"}'  https://localhost:7001/beefchain/v1/auth/remove_file
     
### Making Group Related Requests

To submit any request related to group that can be viewed by admins or reguator,

     curl -k -H "Content-Type: application/json" --data '{"requestor":"breeder","identity":"SpartyBreeder","requestinfo":"create a new sub-group breeder1 for us!"}'  https://localhost:7001/beefchain/v1/auth/add_user_requests
   
This creates a folder under /api/requests with a filename mathching the requestor name. The staus of the request is set to 'Pending' at the time of submission and changed once the request has been fulfilled relevant authority. 
To see the status of the request,

 
     curl -k -H "Content-Type: application/json" --data '{"requestor":"breeder","identity":"SpartyBreeder"}'  https://localhost:7001/beefchain/v1/auth/user_requests_status

To change the status of the request as an adminstrator or regulator, 

     curl -k -H "Content-Type: application/json" --data '{"requestor":"breeder","identity":"SpartyBreeder","status":"Completed!"}'  https://localhost:7001/beefchain/v1/auth/user_requests_update
     
     
###  Bring Down Containers
     
To bring down the container manually,

     docker stop session.beefsupply.com && docker rm session.beefsupply.com && docker volume rm sessions_session.beefsupply.com
	
    # Remove directories created during building and running app
    rm -R mainserver && rm -R __pycache__
    
    # Remove volumes (make back up before doing so)
    docker volume rm sessions_session.beefsupply.com && docker volume prune
    
    # remove all __pycache__ files in /sessions directory generated during the application runtime
    find . -type d -name "__pycache__" -exec rm -r {} +
    
    # To remove the database files
    rm api/db_files/*



`Note: Enable the 'restart' option in docker-compose file with appropriate options {always, on-failure, unless-stopped} for persistence and make back up of volumes before removing them`
	
	
### Multi-Host Environment 

Containers can be accessed from a different host using the (1) hosted ip address (2) domain name or the (3) container name. The container name is set to 'session.beefsupply.com' so any other container directly connected to the network 'beef_supply' can access the cotainer directly using the link  https://session.beefsupply.com:7001/ If the containers are hosted permanently with a domain name, edit the /etc/hosts file to point to the domain name (more details can be found at: https://man7.org/linux/man-pages/man5/hosts.5.html). We restrict the tutorial to a service hosted on a machine with a reachable ip address. 
Once the ip-address of the machine where the service is being hosted in confirmed (e.g. 203.0.113.5
), change it for the variable 'sessions_address' in the BeefMesh/environment/service_ip_address.sh file and source it in the terminal 

	source environment/service_ip_addresses.sh
     
All of the commands above will be used with the new address $sessions_address instead of localhost. 


####  Register Users

    curl -k -H "Content-Type: application/json" --data '{"username":"example_name","password":"example_password", "email":"example@beefsupply.com"}' https://$sessions_address:7001/beefchain/v1/auth/register

#### Login Users

     curl -k -H "Content-Type: application/json" --data '{"email":"example@beefsupply.com","password":"example_password"}' https://$sessions_address:7001/beefchain/v1/auth/login

#### Logout Users

     curl -k -H "Content-Type: application/json" -H 'Authorization: Bearer '$AccessToken --data '{"refresh_token":'\"$RefreshToken\"'}' https://$sessions_address:7001/beefchain/v1/auth/logout
    

#### Refresh Tokens

     curl -k  -H "Content-Type: application/json"  -H 'Authorization: Bearer '$AccessToken --data '{"refresh_token":'\"$RefreshToken\"'}' https://$sessions_address:7001/beefchain/v1/auth/refresh
    
#### Reset Password

     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"old_pass":"example_password","new_pass":"new_password"}' https://$sessions_address:7001/beefchain/v1/auth/password_reset
    
#### Remove User   
    
     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"username":"example_name","password":"example_password","email":"example@beefsupply.com"}' https://$sessions_address:7001/beefchain/v1/auth/remove_user


#### Checking Permissions

For generic user 

     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@beefsupply.com","password":"beefchain"}' https://$sessions_address:7001/beefchain/v1/auth/check_user_permission
     
For admin user 

     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@beefsupply.com","password":"beefchain"}' https://$sessions_address:7001/beefchain/v1/auth/check_admin_permission
     
     
For super admin user 

     curl -k -H  "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" --data '{"refresh_token":'\"$RefreshToken\"',"email":"email_admin@beefsupply.com","password":"beefchain"}' https://$sessions_address:7001/beefchain/v1/auth/check_sadmin_permission
    
#### Testing Permissions 

For generic user 

     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://$sessions_address:7001/beefchain/v1/auth/data_user
     
For admin user 

     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://$sessions_address:7001/beefchain/v1/auth/data_admin
     
For super admin user 

     curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $AccessToken" https://$sessions_address:7001/beefchain/v1/auth/data_super_admin
  
  
#### Create Collaboration Groups 


To create a group 
 
     curl -k -H  "Content-Type: application/json" --data '{"name":"breeder","description":"BreederConsortium","gluster":"192.168.1.5","ipfs":"192.168.1.5","overlay":"breeder_network"}' https://$sessions_address:7001/beefchain/v1/auth/insert_group_info
   
 
To retrieve information related to a group 
     
     curl -k -H  "Content-Type: application/json" --data '{"name":"breeder","description":"BreederConsortium"}' https://$sessions_address:7001/beefchain/v1/auth/get_group_info
      
      
#### Upload Group Related Files

Top upload files related to a group 


    curl -k -F 'file=@/home/USER/BeefChain/sessions/beefchain.txt' https://$sessions_address:7001/beefchain/v1/auth/upload_file

To download a group related file

     curl -k -H "Content-Type: application/json" --data '{"filename":"beefchain.txt","description":"beefchain.txt"}' https://$sessions_address:7001/beefchain/v1/auth/download_file > beefchain.txt
    
To remove a group related file,
    
    curl -k -H "Content-Type: application/json" --data '{"filename":"beefchain.txt","description":"beefchain.txt"}'  https://$sessions_address:7001/beefchain/v1/auth/remove_file
     
#### Making Group Related Requests

To submit any request related to group 

     curl -k -H "Content-Type: application/json" --data '{"requestor":"breeder","identity":"SpartyBreeder","requestinfo":"create a new sub-group breeder1 for us!"}'  https://$sessions_address:7001/beefchain/v1/auth/add_user_requests
    
To see the status of the request

 
     curl -k -H "Content-Type: application/json" --data '{"requestor":"breeder","identity":"SpartyBreeder"}'  https://$sessions_address:7001/beefchain/v1/auth/user_requests_status

To change the status of the request as an adminstrator or regulator 

     curl -k -H "Content-Type: application/json" --data '{"requestor":"breeder","identity":"SpartyBreeder","status":"Completed!"}'  https://$sessions_address:7001/beefchain/v1/auth/user_requests_update
     
     
