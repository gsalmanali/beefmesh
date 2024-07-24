
from flask import Flask, request
import requests
import ast
import json
from learn_model import learnmodel

app = Flask(__name__)

@app.route('/')
def welcome():
	return "Processor1 is Up and Running!"

@app.route('/transmitcondition', methods=['GET'])
def transmit_condition():
	interface_url = 'http://host.docker.internal:5500/usercondition'

	payload = {'user_interface': '5501'}

	print("Payload:", payload)

	response = requests.post(url=interface_url, json=payload)

	print("Code:", response.status_code, "Reason:", response.reason, "Text:", response.text, "Payalod:", response)

	if response.status_code == 200:
		print("status Ok!")
	
	return "Status is ok! Up and Running !"

@app.route('/transmitmodel')
def transmit_model():
	file = open("local_storage/processor_model1.npy", 'rb')

	payload = {'modelname':'processormodel1.npy', 'identity':'http://0.0.0.0:5501/'}
	files = {
		'json': ('json_data', json.dumps(payload), 'application/json'),
		'pmodel': ('processormodel1.npy', file, 'application/octet-stream')
	}

	reply = requests.post(url='http://host.docker.internal:5504/combinemodel', files=files)

	print("Reply:", reply.text)

	return "Model succesfully transmitted for aggregation !"

@app.route('/aggregatemodel', methods=['POST'])
def receive_aggregate_model():
	if request.method == 'POST':
		file = request.files['pmodel'].read()
		modelname = request.files['json'].read()

		modelname = ast.literal_eval(modelname.decode("utf-8"))

		modelname = modelname['modelname']

		print("Model filename:", modelname)

		writablefile = open("new_model/"+modelname, 'wb')

		writablefile.write(file)
			
		return "Processor model file received without errors!"

	else:
		return "File Receive Error! model file was not received!"

@app.route('/learnmodel')
def learn_model():
        # call training function 
	learnmodel()

	return "Learning new model completed without errors!"


if __name__ == '__main__':
	app.run(host='0.0.0.0', port=5501, debug=False, use_reloader=True)


















