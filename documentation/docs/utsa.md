# UTSAServer

This submodule is located under /utsaserver directory and is meant to time stamp files using RFC 3161. The time stamp is basically a cryptographic signature with a date attached to it.

## Basics 

The bacis working of time stamp authority is as follows. 

1. Hash of the data that the client wants to time stamp, is sent to the time stamp authority.
2. The time stamp authority then concatenates the exact time with the hash of the data. It then creates the time stamp to deliver by using a private key.
3. The time stamped file is then returned to the requesting client application. 

The returned time stamped file can be used to verify the originality of the file and its creation. To verify the 
time stamped file, a time stamp key pair (X509 certificate) is required at the time of verification request that is issued by a certificate authority. The main use of time stamping could be to verify logs from rotation time, or to prove files upload in due time along with cross checking data context. 

## Creating Certificates 


By default the application runs a 'uts-server' USER which can be changed from docker compose file or using any of the sample configuration files given in /utsaserver/cfg/ folder.  Before the applciation can be started it is necessary to create certificate files that are then imported into the application when it is run.
To create certificate files, first modify the configuration file CAtsa.cnf in /utsaserver/pki/ folder accordingly or use the default settings. Then call the createtsa method from BeefMesh directory to generate required files

 	./utsaserver/utsa-network.sh createtsa
 
 
A number of certificate are created for ssl communication between client and server, and to verify files using certificate authority. The certicficates contained in the folder /utsaserver/pki are imported into the container under /opt/uts-server/tests/cfg/pki/ for use. This can be modified accordingly including the ports (2020) and addresses. 

`Note: To modify the ports on which the server runs, also change it in the configuration file in addition to the docker compose file. Further, force the uts-server to pick the configuration file by specifying it in the docker entrypoint 'uts-server -c /etc/uts-server/uts-server.cnf -D'`.

## Running Application 


For testing with docker as a standalone application, spin up the container by navigating into the /utsaserver directory.

     docker-compose up -d
    
Once up and running, a file can be time stamped using the server url 'http://localhost:2020' (assuming testing locally). To timestamp a file (e.g. sample file ./utsaserver/files/test-file.txt), use the utility function provided with the application that creates a formatted curl command to send to the time stamping authority using the hash of the provided data. Required certitificates for clients should be shared and be available in the /utsaserver/pki folder for client to call the server. From the main BeefMesh directory, run 

     
     ./utsaserver/utsa-network.sh timestampfile localhost test-file.txt
     
     # generic call assuming files are located in utsaserver/files/
     ./utsaserver/utsa-network.sh timestampfile <server_address> <file_name_with_extension>
     
     

Once the command is run successfully, an example result could look like this 
	
	[INFO] Generating timestamp on file '/home/USER/BeefMesh/utsaserver/test-file.txt', to '/home/USER/BeefMesh/utsaserver/test-file.txt.tsr', using server 'http://localhost:2020'
	Using configuration from /usr/lib/ssl/openssl.cnf
	[SUCCESS] Timestamp of file '/home/USER/BeefMesh/utsaserver/test-file.txt' using server 'http://localhost:2020' succeed, ts written to '/home/USER/BeefMesh/utsaserver/test-file.txt.tsr'
	

The timestamped file is returned and stored as a .tsr format file. The timestamped file can then be verified any time using the earlier created certificates containing public key. 

## Verifying Files 

To verify the time stamp file, run


     ./utsaserver/utsa-network.sh verifytimestamp localhost test-file.txt.tsr test-file.txt tsaca.pem
     
     # generic call assuming files are located in utsaserver/files/ and certificate is in utsaserver/pki/ 
     ./utsaserver/utsa-network.sh verifytimestamp <server_address> <timestamped_file> <original_file> <certificate_name>

            
Note that the timestamped file (./utsaserver/files/test-file.txt.tsr) and the orignal file (./utsaserver/files/test-file.txt) needs to be provided  along with the certificate (./utsaserver/pki/tsaca.pem). A sample response could look like this

	Using configuration from /usr/lib/ssl/openssl.cnf
	Verification: OK
	
The details of the time stamp file can also be retreived for examination by calling  timestampdetails method

     ./utsaserver/utsa-network.sh timestampdetails test-file.txt.tsr
     
     # generic call assuming files are located in utsaserver/files/ and certificate is in utsaserver/pki/ 
     ./utsaserver/utsa-network.sh timestampdetails <timestamped_file> 

		
 
Here, we have given the .tsr file as an input. A typical response could look like this

	TST info:
	Version: 1
	Policy OID: tsa_policy1
	Hash Algorithm: sha256
	Message data:
    		0000 - 1e b4 c9 63 84 6c db 8f-88 9c 63 49 41 07 a1 51   ...c.l....cIA..Q
    		0010 - 06 b5 9f d0 fd 49 5f 03-03 fd 20 ba 08 17 79 bd   .....I_... ...y.
	Serial number: 0x8FD375B3007C73207DEC3B03D1164F8C8B247DCC
	Time stamp: Mar 26 17:21:14 2024 GMT
	Accuracy: 0x01 seconds, 0x01F4 millis, 0x64 micros
	Ordering: yes
	Nonce: 0x96522CA3458B1660
	TSA: DirName:/C=US/ST=Michigan/L=USA/O=UTS-SERVER test/CN=TSA CERT 1

## Bringdown Containers  

To bring down and clear containers 

	  docker stop beef.utsa.com && docker rm beef.utsa.com 
	  
	  
	  
	  
## Multihost Setup

When using from a different host, update the server address variable in the environment/service_ip_addresses.sh file and source it before calling the server. 
  
      # from BeefMesh main directory 
      source environment/service_ip_addresses.sh
	
      # call to server with the url for deployed server to timestamp file  
      ./utsaserver/utsa-network.sh timestampfile $utsa_address test-file.txt
      
      # call to server with the url for deployed server to verify timestamped file  
      ./utsaserver/utsa-network.sh verifytimestamp $utsa_address test-file.txt.tsr test-file.txt tsaca.pem
        
     

