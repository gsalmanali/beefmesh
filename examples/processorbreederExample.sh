#!/bin/bash

#echo "Type system user password to enable complete network reset and enable sudo commands to run!!!"
#read -p "press enter to continue or ctrl+C to cancel ..." y
#echo "Enter Username:"
#read -s USERNAME
#echo "Enter Password:"
#read -s PASSWORD
# Make sure to replace with your local system credentials!!!
USERNAME=ali
PASSWORD=salmanali

#echo $PASSWORD | sudo -S command

# REMOVE COMMENT BLOCKS WHERE NEEDED!

# Create Directories! 

#cd organizations && mkdir processor1 processor2 processor3
#cd ..
cd organizations/processor1/ && mkdir Fresh Spoiled
cd .. 
cd organizations/processor2/ && mkdir Fresh Spoiled
cd ..
cd organizations/processor3/ && mkdir Fresh Spoiled
cd ..
Comment

# Download Dataset! 

pip3 install kaggle
# Got to your kaggle account,e.g: https://www.kaggle.com/ksalmanali/account
# click "Create New API Token" to download kaggle.json
cp kaggle.json ~/.kaggle/
chmod 600 ~/.kaggle/kaggle.json

# OR alternatively set 
export KAGGLE_USERNAME=ksalmanali
export KAGGLE_KEY=xxxxxxxxxxxxxx

# Download dataset 
cd temp
kaggle datasets download crowww/meat-quality-assessment-based-on-deep-learning
unzip meat-quality-assessment-based-on-deep-learning.zip -d data/
cd ..

# Move Dataset to Organizations! 

i=0
copy_unit=315
k=1
for j in {1..3}; do   
  for file in temp/data/Fresh/*; do
    path="organizations/processor${k}/Fresh/"
    mv "$file" $path
    if [[ "$i" -eq "$copy_unit" ]]; then
      echo "done copying fresh meat images"
      i=0
      ((k++))
      break
    fi
    ((i++))
  done
done


i=0
copy_unit=315
k=1
for j in {1..3}; do   
  for file in temp/data/Spoiled/*; do
    path="organizations/processor${k}/Spoiled/"
    mv "$file" $path
    if [[ "$i" -eq "$copy_unit" ]]; then
      echo "done copying spoiled meat images"
      i=0
      ((k++))
      break
    fi
    ((i++))
  done
done
Comment

# Start Containers! 
#<<Comment
docker compose up -f /organizations/processor1/docker-compose.yml up -d
docker compose up -f /organizations/processor2/docker-compose.yml up -d
docker compose up -f /organizations/processor3/docker-compose.yml up -d
docker compose up -f /organizations/processorAggregator/docker-compose.yml up -d
docker compose up -f /organizations/processorMainserver/docker-compose.yml up -d
#Comment

# Start Machine Learning Locally! 
#<<Comment
# Results will be saved in local_storage
echo "Starting Machine Learning Locally"
result=$(docker exec -it processor1-app python -c "import requests;x=requests.get('http://localhost:5501/learnmodel');print(x.status_code)")
# Ok code should be 200!
echo $result

result=$(docker exec -it processor2-app python -c "import requests;x=requests.get('http://localhost:5502/learnmodel');print(x.status_code)")
# Ok code should be 200!
echo $result

result=$(docker exec -it processor3-app python -c "import requests;x=requests.get('http://localhost:5503/learnmodel');print(x.status_code)")
# Ok code should be 200!
echo $result

#Comment

# Send Status to Server! 
#<<Comment
echo "Sending Status to Server"
result=$(docker exec -it processor1-app python -c "import requests;x=requests.get('http://localhost:5501/transmitcondition');print(x.status_code)")
# Ok code should be 200!
echo $result

result=$(docker exec -it processor2-app python -c "import requests;x=requests.get('http://localhost:5502/transmitcondition');print(x.status_code)")
# Ok code should be 200!
echo $result

result=$(docker exec -it processor3-app python -c "import requests;x=requests.get('http://localhost:5503/transmitcondition');print(x.status_code)")
# Ok code should be 200!
echo $result

#Comment 

# Send ML model to Aggregator! 
#<<Comment
echo "Sending ML Model to Aggregator"
result=$(docker exec -it processor1-app python -c "import requests;x=requests.get('http://localhost:5501/transmitmodel');print(x.status_code)")
# Ok code should be 200!
echo $result

result=$(docker exec -it processor2-app python -c "import requests;x=requests.get('http://localhost:5502/transmitmodel');print(x.status_code)")
# Ok code should be 200!
echo $result

result=$(docker exec -it processor3-app python -c "import requests;x=requests.get('http://localhost:5503/transmitmodel');print(x.status_code)")
# Ok code should be 200!
echo $result

#Comment

# Combine ML models at Aggregator! 
#<<Comment
echo "Combining ML models at Aggregator"
result=$(docker exec -it processor-agg-app python -c "import requests;x=requests.get('http://localhost:5504/combine_models');print(x.status_code)")
# Ok code should be 200!
echo $result

#Comment

# Send Aggregated model to Distribution Server! 
#<<Comment
echo "Sending Aggregated model to Distribution Server"
result=$(docker exec -it processor-agg-app python -c "import requests;x=requests.get('http://localhost:5504/transmit_combined_model');print(x.status_code)")
# Ok code should be 200!
echo $result

#Comment

# Send Aggregated model from Server to Local Processor Clients! 
#<<Comment
echo "Sending Aggregated model from Server to Local Processor Clients"
result=$(docker exec -it processor-server-app python -c "import requests;x=requests.get('http://localhost:5500/distribute_new_model');print(x.status_code)")
# Ok code should be 200!
echo $result

# Read results from ML model at local client, last reported is the latest! 
#<<Comment
echo " Read results from ML model at local client, last reported is the latest! "
result=$(docker exec -it processor1-app python -c "file=open('local_storage/results.txt','r'); lines = [line.rstrip() for line in file];print(lines)")
echo $result

result=$(docker exec -it processor2-app python -c "file=open('local_storage/results.txt','r'); lines = [line.rstrip() for line in file];print(lines)")
echo $result

result=$(docker exec -it processor3-app python -c "file=open('local_storage/results.txt','r'); lines = [line.rstrip() for line in file];print(lines)")
echo $result
#Comment

# Breeder data details in Breeder folder under organization 
# Run the breeder application as a notebook with ipython

#docker run -d -p 443:8888 -e "PASSWORD=MakeAPassword" ipython/notebook

docker run -d -p 443:8888 -e ipython/notebook

#docker run -p 8888:8888 -v $(pwd):/organizations/breeder/BreederFederated


