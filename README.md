# Welcome to BeefMesh Project


The 'BeefMesh' framework brings together participants in the "Beef Supply Chain" in a distributed, yet secure and highly connected manner. This enables trust and transparency-oriented collaborative applications, such as managing traceability, measuring supply chain emissions, optimizing resource consumption, and leveraging shared data pipelines for secure federated machine learning applications.

This repository is meant to provide some of the basic microservices required for the BeefMesh framework that can be easily reconfigured and adapated to run other functions. A basic starting point for any collaboration application is a connected group utilizing distributed resources such as databases, internet of things and connectivity channels such as the blockchain channels. To get started, download the repository material to your local machine under a folder named BeefMesh, which will serve as the root directory of the project. 

The framework can be run locally for testing as well as on multiple physical hosts. A single host setup is intended for testing purposes, where all containers run on one physical machine and use a bridge network. The multi-host setup is intended for use on different physical machines with unique IP addresses that are reachable on the Internet. The multi-host network uses Docker Swarm to create an overlay network. For local testing, the main Docker network is the beef_supply (bridge) network. For distributed testing, the main Docker network is the beef_supply network set up as an overlay using Docker Swarm. Several other bridge or overlay networks are also created depending on the scenario.

To start using the framework, run and connect individual components by navigating into each micro-services application folder intended for a collaboration group . The details of the micro-services are summarized in the documentation available at: https://gsalmanali.github.io/beefmesh/

Before any tests or examples can be run, the network components need to be up and running, which includes the blockchain, databases, IPFS, timestamp authority, and Internet of Things. 

The application has been tested in a linux environment (Ubuntu 22.04).

Direct any issues or questions to alisalm1 AT msu DOT edu
