# Examples and Applications 

The microservices provided can be used be used within different collaboration groups to run a number of useful applications including traceability, recording and sharing useful regulatory parameters, managing federated data, using machine learning applications with secure data pipelines, negotiating policies, making collaborative decisions,  measuring and optimizing chain emissions and so much more.    

Though running full applications require lengthy scripts that start all of the microservices and perform detailed tasks, a few sample scripts are provided in the repository to help building an idea on how to use data once it is collected and available using the running services. 

 
For example, once data from underlying resoures using IoTs is collected and transmitted over secure blockchain channels for optimization and decision making at a federated node, linear optimization algorithms can be run over it to decide on the paths that organzations can use for routing certain commodity (beef in our case).

The python script under examples/carbonOptimization/ExampleOptimizationMainServer.py can be used as a test case to get an idea on how the supply chain matrix would look like including the decison variables. An accompanying continerized application is provided under examples/containerized to run the optimization decisions serving other connected services. 


With secure blockchain data pipelines, machine learning models can be shared and optimized in coordination with federated databases maintained at different organizational domains. For example, examples/ProcessorFederated provides scripts with containerized nodes to process recognition of beef images at different processors and gradually improve it over time by coordinating with a federated node that globally combines the models and redistributes it over blockchain channels for keeping track of improvement over time and for cold storage of files.

The containerized applications can be started in detached form by spinning docker-compose files,

	docker-compose up -d

Different routes that can be called to start sharing machine learning model files are in the app.py file that gets imported into dockerfile during container startup.   

To manually bring down the application, 


	docker stop processor1-app  
	docker stop processor2-app 
	docker stop processor3-app 
	docker stop processor-agg-app
	docker stop processor-server-app
		
	docker rm processor1-app  
	docker rm processor2-app 
	docker rm processor3-app 
	docker rm processor-agg-app
	docker rm processor-server-app
	
	docker volume prune
	docker system prune 
