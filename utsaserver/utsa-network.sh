#!/bin/bash

# Define functions


hostip() {
    echo "Grabbing host network address:"
    address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
    #echo $address
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    echo "declare -x ipaddress=$address" > $SCRIPT_DIR/env/hostip.sh  
    #echo "export ipaddress="$address"" > $SCRIPT_DIR/env/env.txt  
    #echo $SCRIPT_DIR
    source "${SCRIPT_DIR}/env/hostip.sh"
    echo $ipaddress    
}

createtsa() {

    echo "creating tsa certificate files now!"
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    $SCRIPT_DIR/pki/./create_tsa_certs 

}

timestampfile() {

    if [ "$#" -eq 2 ]; then 
     	timestamp_url_address=$1
     	timestamp_file=$2
     	if command -v openssl > /dev/null 2>&1; then
    		echo "OpenSSL is installed."
   	 	openssl version
   	 	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
   	 	echo "sending a request to the url http://$timestamp_url_address:2020 to timestamp file $timestamp_file"
   	 	start_time=$(date +%s%3N)
   	 	$SCRIPT_DIR/goodies/./timestamp-file.sh -i $SCRIPT_DIR/files/$timestamp_file -u http://$timestamp_url_address:2020 -r -O "-cert";
   	 	end_time=$(date +%s%3N)
   	 	elapsed_time=$((end_time - start_time))
   	 	echo "Time taken: $elapsed_time milliseconds"

	else
    		echo "OpenSSL is not installed."
	fi
     	
    else 
    	echo "missing arguments!"
    fi


}



verifytimestamp() {

    if [ "$#" -eq 4 ]; then 
     	timestamp_url_address=$1
     	input_timestampfile=$2
     	original_file=$3
     	certificate_file=$4
     	if command -v openssl > /dev/null 2>&1; then
    		echo "OpenSSL is installed."
   	 	openssl version
   	 	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
   	 	echo "verifying timestamping now! "
   	 	 start_time=$(date +%s%3N)
   	 	openssl ts -verify -in $SCRIPT_DIR/files/$input_timestampfile -data $SCRIPT_DIR/files/$original_file -CAfile $SCRIPT_DIR/pki/$certificate_file
   	 	#$SCRIPT_DIR/goodies/./timestamp-file.sh -i $SCRIPT_DIR/files/$timestamp_file -u http://$timestamp_url_address:2020 -r -O "-cert";
   	 	end_time=$(date +%s%3N)
   	 	elapsed_time=$((end_time - start_time))
   	 	echo "Time taken: $elapsed_time milliseconds"
	else
    		echo "OpenSSL is not installed."
	fi
     	
    else 
    	echo "missing arguments!"
    fi


}



timestampdetails() {

    if [ "$#" -eq 1 ]; then 
   
     	input_timestampfile=$1
     
     	if command -v openssl > /dev/null 2>&1; then
    		echo "OpenSSL is installed."
   	 	openssl version
   	 	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
   	 	echo "getting timestamp details! "
   	        openssl ts -reply -in $SCRIPT_DIR/files/$input_timestampfile -text
   	 	#$SCRIPT_DIR/goodies/./timestamp-file.sh -i $SCRIPT_DIR/files/$timestamp_file -u http://$timestamp_url_address:2020 -r -O "-cert";
	else
    		echo "OpenSSL is not installed."
	fi
     	
    else 
    	echo "missing arguments!"
    fi


}


# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [function_name]"
    exit 1
fi


address=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
#echo "declare -x ipaddress=$address" > $SCRIPT_DIR/env/hostip.sh  
  
 

# Case statement to handle different inputs
case "$1" in
    createtsa) createtsa ;;
    timestampfile) timestampfile $2 $3 ;;
    verifytimestamp) verifytimestamp $2 $3 $4 $5 ;;
    timestampdetails) timestampdetails $2 ;;
    *) echo "Invalid input. Please provide a function name as an argument." && exit 1 ;;
esac
