from flask import Flask, request
import requests, json
import ast
from federated_learning import model_combine

app = Flask(__name__)

@app.route('/')
def welcome():
	return "Secure Aggregator for Processor up and running !"
		
@app.route('/combinemodel', methods=['POST'])
def receivemodel():
	if request.method == 'POST':
		file = request.files['pmodel'].read()
		modelname = request.files['json'].read()

		# user = request.files['identity'].read()

                # with open('user_client.txt', 'a+') as f:
		# 	f.write(user)

		modelname = ast.literal_eval(modelname.decode("utf-8"))
		user = modelname['identity']+'\n'
		modelname = modelname['modelname']

		# with open('user_client.txt', 'a+') as f:
		# 	f.write(user)
		
		print("Model file stored:", modelname)
		wfile = open("remote_user_models/"+modelname, 'wb')

		wfile.write(file)
			
		return "Remote user model file received successfully!"
	else:

		return "File receive error! Did not receive file correctly!"

@app.route('/combine_models')
def execute_model_combine():
        # call model aggregator function ! 
	model_combine()
        # return success message! 
	return 'Combination of model done successfully! Global model for sharing stored succesfully!'
        

@app.route('/transmit_combined_model')
def transfer_to_combined_server():
        # Option to read from client users config file! 
	# users = ""

	# with open('user_clients.txt', 'r') as f:
	# 	users = f.read()
	# users = users.split('\n')
	
	# for i in users:
	# 	if i != '':

        # Aggregtor storage is persistent!
 
	file = open("aggregator_storage/aggregated_model.h5", 'rb')
	payload = {'modelname':'aggregated_model.h5', 'identity':'processor_secure_aggregator'}
	files = {
		'json': ('json_data', json.dumps(payload), 'application/json'),
		'pmodel': ('aggregated_model.h5', file, 'application/octet-stream')
	}
	
	print('Aggregated Model Details:')

	reply = requests.post(url='http://host.docker.internal:5500/combined_secure_model', files=files)
	print("Reply status code:", reply.status_code)
	
	# print("Reply status text:", reply.text)

	return "Combined model sucecssfully sent to processor serving node!"



if __name__ == '__main__':
	app.run(host='0.0.0.0', port=5504, debug=False, use_reloader=True)















