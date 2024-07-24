from flask import Flask
app = Flask(__name__)

@app.route('/')
def welcome():
    return 'Welcome to IPFS Swarm Key Generator Tool'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=7069)
