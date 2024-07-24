# Layout

The BeefMesh framework connects together a number of microservices to run collaborative applications, which are arranged in different sub-folders described below. More details for each sub-module can be found in later sections.

### sessions

The /sessions folder hosts a Flask server that allows users to register to the framework, form groups, and upload or download resources related to GlusterFS, the overlay network, and IPFS addresses, in addition to other required resources to form a distributed network. The sessions application also runs as the starting collaboration point, hence is also referred to as collaborator or group initiator. 

### emissions

The /emissions folder hosts a Flask server that allows a regulator to maintain a carbon emissions database, which can be modified according to the consensus among organizations using a particular emissions factor.

### utsaserver

The /utsaserver folder is meant to timestamp files and verify their originality. The resultant files from timestamping can be stored on the blockchain or other databases.

### databases

The /databases folder is meant to spin up a number of databases to allow organizations to consume different types of data from events and processes occurring within the facility, from which useful information can be extracted and shared.

### ipfsnetwork

The /ipfsnetwork folder is meant to spin up nodes for managing IPFS databases, which allow organizations to mutually maintain data in a decentralized manner with redundancy and fault tolerance, a quality particularly useful for regulatory data.

### overlaynetwork

The /overlaynetwork folder contains resources that can be used to create a swarm-based overlay network between nodes for secure, resilient, and distributed communication between containerized applications.

### iotnetwork

The /iotnetwork folder is meant to spin up interfaces for consuming data from IoT devices, sensors, and other types of similar gadgets so that it can be used for machine learning or knowledge transfer.

### netshareddrive

The /netshareddrive folder is meant to establish a secure network shared drive among groups to quickly access shared or common files needed to run certain applications, e.g., blockchain services.

### blockchain

The /blockchain folder is meant to provide resources to spin up a blockchain network to provide services like traceability, data sharing, or data recording.


