# Utilities and Monitoring 


To monitor the containerized network, use the grafana and prometheus setup provided in utilities/prometheus folder.
Navigate to utilities/prometheus folder and spin the containers, 

	docker-compose up -d
	
This will start an application setup comprising of cadvisor, grafana and prometheus that can be used to monitor the workload of containers and the network throughout.

Navigate to 127.0.0.1:9100  address to view grafana interface. Select prometheus as the data source and use any dashboard of choice from the grafana website (https://grafana.com/grafana/dashboards/) that supports cadvisor and prometheus. 

To bring down the containers manually, 

	docker stop prometheus advisor grafana
	docker rm prometheus advisor grafana
	docker volume prune 
	
	
A script from hyperledger fabric is also reproduced here that is used when downloading fabric resources locally using custom scripts provided under blockchain/ folder.

Docker container scripts under folder utilities/docker can be used as a guide to setup large blockchain consortium groups locally for testing. 

