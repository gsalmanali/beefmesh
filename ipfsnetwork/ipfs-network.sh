#!/bin/bash



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


upload() {

# Check if the required arguments are provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 <container_name> <source_file_path> <container_file_path>"
  exit 1
fi

CONTAINER_NAME=$1
SOURCE_FILE_PATH=$2
CONTAINER_FILE_PATH=$3

# Check if the source file exists
if [ ! -f "$SOURCE_FILE_PATH" ]; then
  echo "Source file does not exist: $SOURCE_FILE_PATH"
  exit 1
fi

# Copy the file to the Docker container
docker cp "$SOURCE_FILE_PATH" "$CONTAINER_NAME:$CONTAINER_FILE_PATH"

# Execute the IPFS add command in the Docker container
result=$(docker exec "$CONTAINER_NAME" ipfs add "$CONTAINER_FILE_PATH")

# Extract the CID from the result
CID_DATA=$(echo "$result" | awk '{print $2}')

# Print the CID
echo "File added to IPFS with CID: $CID_DATA"



# Create a folder to store the records if it doesn't exist
RECORDS_FOLDER="ipfs_records"
#mkdir -p "$RECORDS_FOLDER"

# Get the filename from the source file path
FILENAME=$(basename "$SOURCE_FILE_PATH")

# Write the filename, CID, and container name to a record file
echo "$FILENAME,$CID_DATA,$CONTAINER_NAME" >> "$RECORDS_FOLDER/ipfs_records.csv"

# Print confirmation message
echo "Record saved to $RECORDS_FOLDER/ipfs_records.csv"

# use method
# ./ipfs-network.sh upload <container_name> <source_file_path> <container_file_path>
# ./ipfs-network.sh upload manager.ipfs.com test/user_file.txt /opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/user_file.txt

}


download() {


# Check if the required arguments are provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 <container_name> <cid_data> <container_file_path>"
  exit 1
fi

CONTAINER_NAME=$1
CID_FILE_DATA=$2
CONTAINER_FILE_PATH=$3

# Check if the source file exists
#if [ ! -f "$SOURCE_FILE_PATH" ]; then
#  echo "Source file does not exist: $SOURCE_FILE_PATH"
#  exit 1
#fi

FILENAME=$(basename "$CONTAINER_FILE_PATH")
echo $FILENAME
echo $CONTAINER_NAME
echo $CONTAINER_FILE_PATH
echo $CID_FILE_DATA
docker exec $CONTAINER_NAME sh -c "ipfs cat '$CID_FILE_DATA' > '$FILENAME'"
#docker exec "$CONTAINER_NAME" sh -c "ipfs cat '$CID_DATA' > "$FILENAME"


# Copy the file to the Docker container
docker cp $CONTAINER_NAME:$CONTAINER_FILE_PATH test/$FILENAME

#docker cp "$SOURCE_FILE_PATH" "$CONTAINER_NAME:$CONTAINER_FILE_PATH"

# Execute the IPFS add command in the Docker container
#result=$(docker exec "$CONTAINER_NAME" ipfs add "$CONTAINER_FILE_PATH")

# Extract the CID from the result
#CID_DATA=$(echo "$result" | awk '{print $2}')

# Print the CID
echo "File added to folder test locally with name: $FILENAME"

# use method
# ./ipfs-network.sh download <container_name> <cid_data> <container_file_path>
# ./ipfs-network.sh download manager.ipfs.com Qmc1DxF7dmEAmkwn1eynm2BeW6DnFcgvw9s5W1NDeXZc28 /opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/retrieved_user_file.txt

}

configure() {

# Check if the required arguments are provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 <container_name> <container_address_to_add> <swarm_key_file_path>"
  exit 1
fi

container_name=$1
container_address_to_add=$2
swarm_key_file_path=$3

export LOCKERROR="Error: cannot acquire lock: Lock FcntlFlock of /var/ipfsfb/repo.lock failed: resource temporarily unavailable"
#export PATH=$PATH:/usr/local/go/bin


result=$(docker exec $container_name ipfs bootstrap rm --all)
if  [ "$result" == "$LOCKERROR" ] ;then   
    sudo systemctl status docker|grep tasks   
    docker exec $container_name rm -rf /var/ipfsfb/repo.lock
    docker exec $container_name rm -rf ~/.ipfs/repo.lock
    docker exec $container_name rm -rf ~/repo.lock
    docker exec $container_name ipfs bootstrap rm --all
else
    echo "no file lock errors detected"
fi

#manager_address=$(docker exec manager.ipfs.com ipfs id -f='<addrs>') 
#regulator_address=$(docker exec regulator.ipfs.com ipfs id -f='<addrs>') 

#manageraddress=$(echo $manager_address | cut -d' ' -f2)
#regulatoraddress=$(echo $regulator_address | cut -d' ' -f2)


#echo $PASSWORD | sudo -S docker exec -u 0 farmer.ipfs.com ipfs bootstrap add $breederaddress  

docker exec -u 0 $container_name ipfs bootstrap add $container_address_to_add

#docker exec -u 0 regulator.ipfs.com ipfs bootstrap add $manageraddress


docker cp $swarm_key_file_path $container_name:/var/ipfs

#docker cp swarmkeygen/swarm.key regulator.ipfs.com:/var/ipfs


#optional 
#docker-compose restart

#docker cp test/test_file.txt manager.ipfs.com:/opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/test_file.txt

# use method
# ./ipfs-network.sh configure <container_name> <container_address_to_add> <swarm_key_file_path>
# ./ipfs-network.sh configure manager.ipfs.com /ip4/172.18.0.3/tcp/4001/ipfs/QmPtQcKFmGWato6K5MvtAgHoVJMbermgDqdjNvVAyfozwD swarmkeygen/swarm.key

}

getaddress() {

# Check if the required arguments are provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <container_name>"
  exit 1
fi

container_name=$1

container_address=$(docker exec $container_name ipfs id -f='<addrs>') 
#regulator_address=$(docker exec regulator.ipfs.com ipfs id -f='<addrs>') 

containeraddress=$(echo $container_address | cut -d' ' -f2)
#regulatoraddress=$(echo $regulator_address | cut -d' ' -f2)

echo "here is the required container address for container: $container_name"
echo "address: $containeraddress"

# use method
# ./ipfs-network.sh getaddress <container_name> 
# ./ipfs-network.sh getaddress manager.ipfs.com 

}


RECORDS_FOLDER="ipfs_records"
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
file_path="$SCRIPT_DIR/$RECORDS_FOLDER/$RECORDS_FOLDER.csv" 

if [ ! -f "$file_path" ]; then
    		# If the file doesn't exist, create it using touch command
    		touch "$file_path"
    		echo "File created: $file_path"
fi

#mkdir -p "$RECORDS_FOLDER"


# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [function_name]"
    exit 1
fi


# This code is called to configure and store admin credentials 
#configureadmin $MF_USERS_ADMIN_EMAIL $MF_USERS_ADMIN_PASSWORD


address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
#echo "declare -x ipaddress=$address" > $SCRIPT_DIR/env/hostip.sh  
  
 

# Case statement to handle different inputs
case "$1" in
    upload) upload $2 $3 $4 ;;
    download) download $2 $3 $4 ;;
    configure) configure $2 $3 $4 ;;
    getaddress) getaddress $2 ;;
    #test_message) test_message $2 ;;
    *) echo "Invalid input. Please provide a function name as an argument." && exit 1 ;;
esac


