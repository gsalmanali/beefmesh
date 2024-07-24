from flask import Flask, request
import requests, json
import ast
from federated_learning import model_combine

app = Flask(__name__)

@app.route('/')
def welcome():
	return "Processor Server Running!"

@app.route('/usercondition', methods=['GET','POST'])
def user_condition():
        link = "http://host.docker.internal:5501/ackservermain"
        if request.method == 'POST':
                user_port = request.json['user_interface']
                with open('user_clients.txt', 'a+') as f:
                        f.write('http://host.docker.internal:' + user_port + '/\n')
                print("User being served at port:",user_port)
                if user_port:
                        ackservermain = {'main_ack': '1'}
                        return str(ackservermain)
                else:
                        return "Client status not OK!"
                
        else:
           return "Success! GET request received from processor user clients!"
        

		
@app.route('/combined_secure_model', methods=['POST'])
def receive_secure_model():
	if request.method == 'POST':
		file = request.files['pmodel'].read()
		modelname = request.files['json'].read()

		# user = request.files['identity'].read()

		modelname = ast.literal_eval(modelname.decode("utf-8"))
                # Get identity 
		user = modelname['identity']+'\n'
		modelname = modelname['modelname']

		# with open('user_clients.txt', 'a+') as f:
		# 	f.write(user)
		
		# print(modelname, user)
		wfile = open("aggregated_model/"+modelname, 'wb')
                # Save file
		wfile.write(file)
			
		return "Processor model received successfully!"
	else:
                # Report Error
		return "Error! No model file received!"

# @app.route('/combine_models')
# def execute_model_combine():
# 	model_combine()
# 	return 'Success in aggregation and file storage!'
         
@app.route('/distribute_new_model')
def distribute_combined_to_users():
	users = ''
	with open('user_clients.txt', 'r') as f:
		users = f.read()
	users = users.split('\n')
	
	for i in users:
		if i != '':
			file = open("aggregated_model/aggregated_model.h5", 'rb')

			payload = {'modelname':'aggregated_model.h5'}
			files = {
				'json': ('json_data', json.dumps(payload), 'application/json'),
				'pmodel': ('aggregated_model.h5', file, 'application/octet-stream')
			}
			print("Aggregate Model!")
			print(i+'aggregatemodel')
                        # Post a request!
			response = requests.post(url=i+'aggregatemodel', files=files)
                        # Print response! 
			print(response.status_code)
	
	# print("Response text: ", reponse.text)
        # Return Success!
	return "Combined learning model sent succesfully!"




if __name__ == '__main__':
	app.run(host='0.0.0.0', port=5500, debug=False, use_reloader=True)















