from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    file_path = f"/opt/gopath/src/github.com/BeefChain/IPFS/p2p/peer/{file.filename}"
    file.save(file_path)
    
    try:
        result = subprocess.run(
            ['docker', 'exec', 'manager.ipfs.com', 'ipfs', 'add', file_path],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )
        if result.returncode != 0:
            return jsonify({'error': result.stderr}), 500
        
        cid = result.stdout.split()[-2]
        return jsonify({'cid': cid}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

