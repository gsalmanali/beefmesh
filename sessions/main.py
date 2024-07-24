#!/usr/bin/python
# -*- coding: utf-8 -*-

import os

from flask import Flask
from gevent.pywsgi import WSGIServer
from waitress import serve
import ssl
from werkzeug import serving
from flask import flash, request, redirect, url_for
from werkzeug.utils import secure_filename

from api.conf.config import SQLALCHEMY_DATABASE_URI
#from api.conf.config import UPLOAD_FOLDER
from api.conf.routes import generate_routes
from api.database.database import db
from api.db_initializer.db_initializer import (create_admin_user,
                                               create_super_admin,
                                               create_test_user,
                                               create_beefsupply_user                                               
                                               )


def create_app():

    # Create a flask app.
    app = Flask(__name__)

    # Set debug true for catching the errors.
    app.config['DEBUG'] = True

    # Set database url.
    app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI
    
    #app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True

    # Generate routes.
    generate_routes(app)

    # Database initialize with app.
    db.init_app(app)

    # Check if there is no database.
    if not os.path.exists(SQLALCHEMY_DATABASE_URI):

        # New db app if no database.
        db.app = app

        # Create all database tables.
        db.create_all()

        # Create default super admin user in database.
        create_super_admin()

        # Create default admin user in database.
        create_admin_user()

        # Create default test user in database.
        create_test_user()
        
        #Create default beefsupply user in database.
        create_beefsupply_user()
        
      

    # Return app.
    return app
    
def main():
    # Create app.
    app = create_app()
    
    #serve(app, ssl_context='adhoc', debug=True, host="0.0.0.0", port=7001, use_reloader=True)
    # Run app. For production use another web server.
    # Set debug and use_reloader parameters as False.
    #context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    #context.verify_mode = ssl.CERT_REQUIRED
    #context.load_verify_locations("ca.crt")
    #context.load_cert_chain("server.crt", "server.key")
    #context.load_verify_locations("ca.crt")
    #context.load_cert_chain("server.crt", "server.key")
    #serving.run_simple("0.0.0.0", 8000, app, ssl_context=context)
    context = ('certificates/cert.pem', 'certificates/key.pem')
    #app.run(ssl_context='adhoc',port=7001, debug=True, host='0.0.0.0', use_reloader=True)
    app.run(ssl_context=context,port=7001, debug=True, host='0.0.0.0', use_reloader=True)


if __name__ == '__main__':
    main()

    
