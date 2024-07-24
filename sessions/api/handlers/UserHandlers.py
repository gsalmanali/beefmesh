#!/usr/bin/python
# -*- coding: utf-8 -*-

import logging
from datetime import datetime
import os
from flask import g, request, render_template, send_from_directory, send_file
from flask_restful import Resource
from werkzeug.utils import secure_filename

import api.error.errors as error
from api.conf.auth import auth, refresh_jwt
from api.database.database import db
from api.models.models import Blacklist, User, Beefchaingroup, Uploadfiledb, Userrequests
from api.roles import role_required
from api.schemas.schemas import UserSchema
ALLOWED_EXTENSIONS = {'txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif', 'block', 'json'}

        

class Index(Resource):
    @staticmethod
    def get():
        return "Hello Flask Restful Example!"
        #return render_template('index.html')
        

class Register(Resource):
    @staticmethod
    def post():

        try:
            # Get username, password and email.
            username, password, email = (
                request.json.get("username").strip(),
                request.json.get("password").strip(),
                request.json.get("email").strip(),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Username, password or email is wrong. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422

        # Check if any field is none.
        if username is None or password is None or email is None:
            return error.INVALID_INPUT_422

        # Get user if it is existed.
        user = User.query.filter_by(email=email).first()

        # Check if user is existed.
        if user is not None:
            return error.ALREADY_EXIST

        # Create a new user.
        user = User(username=username, password=password, email=email)

        # Add user to session.
        db.session.add(user)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "registration completed."}


class Login(Resource):
    @staticmethod
    def post():

        try:
            # Get user email and password.
            email, password = (
                request.json.get("email").strip(),
                request.json.get("password").strip(),
            )

        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Email or password is wrong. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422

        # Check if user information is none.
        if email is None or password is None:
            return error.INVALID_INPUT_422

        # Get user if it is existed.
        user = User.query.filter_by(email=email, password=password).first()

        # Check if user is not existed.
        if user is None:
            return error.UNAUTHORIZED

        if user.user_role == "user":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 1 or 0.
            access_token = user.generate_auth_token(0)

        # If user is admin.
        elif user.user_role == "admin":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 1 or 0.
            access_token = user.generate_auth_token(1)

        # If user is super admin.
        elif user.user_role == "sa":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 2, 1, 0.
            access_token = user.generate_auth_token(2)

        else:
            return error.INVALID_INPUT_422

        # Generate refresh token.
        refresh_token = refresh_jwt.dumps({"email": email})

        # Return access token and refresh token.
        return {
            "access_token": access_token.decode(),
            "refresh_token": refresh_token.decode(),
        }


class Logout(Resource):
    @staticmethod
    @auth.login_required
    def post():

        # Get refresh token.
        refresh_token = request.json.get("refresh_token")

        # Get if the refresh token is in blacklist
        ref = Blacklist.query.filter_by(refresh_token=refresh_token).first()

        # Check refresh token is existed.
        if ref is not None:
            return {"status": "already invalidated", "refresh_token": refresh_token}

        # Create a blacklist refresh token.
        blacklist_refresh_token = Blacklist(refresh_token=refresh_token)

        # Add refresh token to session.
        db.session.add(blacklist_refresh_token)

        # Commit session.
        db.session.commit()

        # Return status of refresh token.
        return {"status": "invalidated", "refresh_token": refresh_token}


class RefreshToken(Resource):
    @staticmethod
    @auth.login_required
    def post():

        # Get refresh token.
        refresh_token = request.json.get("refresh_token")

        # Get if the refresh token is in blacklist.
        ref = Blacklist.query.filter_by(refresh_token=refresh_token).first()

        # Check refresh token is existed.
        if ref is not None:

            # Return invalidated token.
            return {"status": "invalidated"}

        try:
            # Generate new token.
            data = refresh_jwt.loads(refresh_token)

        except Exception as why:
            # Log the error.
            logging.error(why)

            # If it does not generated return false.
            return False

        # Create user not to add db. For generating token.
        user = User(email=data["email"])

        # New token generate.
        token = user.generate_auth_token(False)

        # Return new access token.
        return {"access_token": token}


class ResetPassword(Resource):
    @staticmethod
    @auth.login_required
    def post(self):

        # Get old and new passwords.
        old_pass, new_pass = request.json.get("old_pass"), request.json.get("new_pass")

        # Get user. g.user generates email address cause we put email address to g.user in models.py.
        user = User.query.filter_by(email=g.user).first()

        # Check if user password does not match with old password.
        if user.password != old_pass:

            # Return does not match status.
            return {"status": "old password does not match."}

        # Update password.
        user.password = new_pass

        # Commit session.
        db.session.commit()

        # Return success status.
        return {"status": "password changed."}


class UsersData(Resource):
    @staticmethod
    @auth.login_required
    @role_required.permission(1)
    def get(self):
        try:

            # Get usernames.
            usernames = (
                []
                if request.args.get("usernames") is None
                else request.args.get("usernames").split(",")
            )

            # Get emails.
            emails = (
                []
                if request.args.get("emails") is None
                else request.args.get("emails").split(",")
            )

            # Get start date.
            start_date = datetime.strptime(request.args.get("start_date"), "%d.%m.%Y")

            # Get end date.
            end_date = datetime.strptime(request.args.get("end_date"), "%d.%m.%Y")

            print(usernames, emails, start_date, end_date)

            # Filter users by usernames, emails and range of date.
            users = (
                User.query.filter(User.username.in_(usernames))
                .filter(User.email.in_(emails))
                .filter(User.created.between(start_date, end_date))
                .all()
            )

            # Create user schema for serializing.
            user_schema = UserSchema(many=True)

            # Get json data
            data, errors = user_schema.dump(users)

            # Return json data from db.
            return data

        except Exception as why:

            # Log the error.
            logging.error(why)

            # Return error.
            return error.INVALID_INPUT_422


# auth.login_required: Auth is necessary for this handler.
# role_required.permission: Role required user=0, admin=1 and super admin=2.

class RemoveUser(Resource):
    @staticmethod
    @auth.login_required
    @role_required.permission(0)   
    def post():

        try:
            # Get username, password and email.
            username, password, email, refresh_token = (
                request.json.get("username").strip(),
                request.json.get("password").strip(),
                request.json.get("email").strip(),
                request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Username, password or email is wrong. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422

        # Check if any field is none.
        if username is None or password is None or email is None:
            return error.INVALID_INPUT_422
            
        

        # Get user if it is existed.
        user = User.query.filter_by(email=email , password=password).first()

        # Check if user is existed.
        #if user is not None:
            #return error.ALREADY_EXIST
       
            
        if user is None:
            return error.UNAUTHORIZED

       
        # If user is admin.
        elif user.user_role == "admin":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 1 or 0.
            #access_token = user.generate_auth_token(1)
            return error.UNAUTHORIZED

        # If user is super admin.
        elif user.user_role == "sa":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 2, 1, 0.
            #access_token = user.generate_auth_token(2)
            return error.UNAUTHORIZED

       

        # Create a new user.
        #user = User(username=username, password=password, email=email)
        
        elif user.user_role == "user":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 1 or 0.
            #access_token = user.generate_auth_token(0)
            
            # Get if the refresh token is in blacklist
            ref = Blacklist.query.filter_by(refresh_token=refresh_token).first()

            # Check refresh token is existed.
            if ref is not None:
                
                db.session.delete(user)
            
                #return {"status": "already invalidated", "refresh_token": refresh_token}
                
            else:
                                
                # Create a blacklist refresh token.
                blacklist_refresh_token = Blacklist(refresh_token=refresh_token)

                # Add refresh token to session.
                db.session.add(blacklist_refresh_token)
            
                db.session.delete(user)

            # Commit session.
            db.session.commit()
            
            # Return success if registration is completed.
            return {"status": "user successfully removed."}
            
        else:
            return error.INVALID_INPUT_422


        # Add user to session.
        #db.session.add(user)
        
         # Removing user
        
        
class CheckUserPermission(Resource):
    @staticmethod
    @auth.login_required
    @role_required.permission(0)   
    def post():

        try:
            # Get username, password and email.
            password, email, refresh_token = (
                #request.json.get("username").strip(),
                request.json.get("password").strip(),
                request.json.get("email").strip(),
                #request.json.get("access_token"),
                request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Username, password or email is wrong. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422

        # Check if any field is none.
        #if username is None or password is None or email is None:
        if password is None or email is None:
            return error.INVALID_INPUT_422
            
        

        # Get user if it is existed.
        user = User.query.filter_by(email=email , password=password).first()

        # Check if user is existed.
        #if user is not None:
            #return error.ALREADY_EXIST
       
            
        if user is None:
            return error.UNAUTHORIZED

       
        # If user is admin.
        elif user.user_role == "admin":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 1 or 0.
            #access_token = user.generate_auth_token(1)
            return error.UNAUTHORIZED

        # If user is super admin.
        elif user.user_role == "sa":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 2, 1, 0.
            #access_token = user.generate_auth_token(2)
            return error.UNAUTHORIZED

       

        # Create a new user.
        #user = User(username=username, password=password, email=email)
        
        elif user.user_role == "user":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 1 or 0.
            #access_token = user.generate_auth_token(0)
            
            #db.session.delete(user)

            # Commit session.
            #db.session.commit()
            
            # Return success if registration is completed.
            return {"status": "success"}
            
        else:
            #return error.INVALID_INPUT_422
            return {"status": "failure"}


        # Add user to session.
        #db.session.add(user)
        
         # Removing user

class CheckAdminPermission(Resource):
    @staticmethod
    @auth.login_required
    @role_required.permission(1)   
    def post():

        try:
            # Get username, password and email.
            password, email, refresh_token = (
                #request.json.get("username").strip(),
                request.json.get("password").strip(),
                request.json.get("email").strip(),
                #request.json.get("access_token"),
                request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Username, password or email is wrong. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422

        # Check if any field is none.
        #if username is None or password is None or email is None:
        if password is None or email is None:
            return error.INVALID_INPUT_422
            
        

        # Get user if it is existed.
        user = User.query.filter_by(email=email , password=password).first()

        # Check if user is existed.
        #if user is not None:
            #return error.ALREADY_EXIST
       
            
        if user is None:
            return error.UNAUTHORIZED

       
        # If user is admin.
        elif user.user_role == "user":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 1 or 0.
            #access_token = user.generate_auth_token(1)
            return error.UNAUTHORIZED

        # If user is super admin.
        elif user.user_role == "sa":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 2, 1, 0.
            #access_token = user.generate_auth_token(2)
            return error.UNAUTHORIZED

       

        # Create a new user.
        #user = User(username=username, password=password, email=email)
        
        elif user.user_role == "admin":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 1 or 0.
            #access_token = user.generate_auth_token(0)
            
            #db.session.delete(user)

            # Commit session.
            #db.session.commit()
            
            # Return success if registration is completed.
            return {"status": "success"}
            
        else:
            #return error.INVALID_INPUT_422
            return {"status": "failure"}
            
class CheckSuperAdminPermission(Resource):
    @staticmethod
    @auth.login_required
    @role_required.permission(2)   
    def post():

        try:
            # Get username, password and email.
            password, email, refresh_token = (
                #request.json.get("username").strip(),
                request.json.get("password").strip(),
                request.json.get("email").strip(),
                #request.json.get("access_token"),
                request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Username, password or email is wrong. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422

        # Check if any field is none.
        #if username is None or password is None or email is None:
        if password is None or email is None:
            return error.INVALID_INPUT_422
            
        

        # Get user if it is existed.
        user = User.query.filter_by(email=email , password=password).first()

        # Check if user is existed.
        #if user is not None:
            #return error.ALREADY_EXIST
       
            
        if user is None:
            return error.UNAUTHORIZED

       
        # If user is admin.
        elif user.user_role == "user":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 1 or 0.
            #access_token = user.generate_auth_token(1)
            return error.UNAUTHORIZED

        # If user is super admin.
        elif user.user_role == "admin":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 2, 1, 0.
            #access_token = user.generate_auth_token(2)
            return error.UNAUTHORIZED

       

        # Create a new user.
        #user = User(username=username, password=password, email=email)
        
        elif user.user_role == "sa":

            # Generate access token. This method takes boolean value for checking admin or normal user. Admin: 1 or 0.
            #access_token = user.generate_auth_token(0)
            
            #db.session.delete(user)

            # Commit session.
            #db.session.commit()
            
            # Return success if registration is completed.
            return {"status": "success"}
            
        else:
            #return error.INVALID_INPUT_422
            return {"status": "failure"}


class DataUserRequired(Resource):
    @auth.login_required
    def get(self):

        return "Test user data."
        


class DataAdminRequired(Resource):
    @auth.login_required
    @role_required.permission(1)
    def get(self):

        return "Test admin data."
        

class DataSuperAdminRequired(Resource):
    @auth.login_required
    @role_required.permission(2)
    def get(self):

        return "Test super admin data."
        
        
class DataInsertBeefchaingroup(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, description, gluster, ipfs, overlay  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("description").strip(),
                request.json.get("gluster").strip(),
                request.json.get("ipfs").strip(),
                request.json.get("overlay").strip(),
                #request.json.get("gluster").strip(),
                #request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Invalid input. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422

        # Check if any field is none.
        #if username is None or password is None or email is None:
        if name is None:
            return error.INVALID_INPUT_422
            
        #if gluster is None:
         #   return error.INVALID_INPUT_422
            
        #if ipfs is None:
         #   return error.INVALID_INPUT_422

        # Get data if it is existed.
        beefchaingroup = Beefchaingroup.query.filter_by(name=name).first()

        # Check if user is existed.
        #if beefchaingroup is not None:
        #    return error.ALREADY_EXIST
        
        if beefchaingroup is None:
            
            
            # Create a new record.
            beefchaingroup = Beefchaingroup(name=name , description=description)

            # Add user to session.
            db.session.add(beefchaingroup)

            # Commit session.
            db.session.commit()
             
            groupdir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../db_files/"))
            ipfspath = os.path.join(groupdir, name , 'ipfs.txt')
            ipfsdir = os.path.join(groupdir, name)
            glusterpath = os.path.join(groupdir, name , 'gluster.txt')
            glusterdir = os.path.join(groupdir, name)
            overlaypath = os.path.join(groupdir, name , 'overlay.txt')
            overlaydir = os.path.join(groupdir, name)
            print(groupdir)
            print(name)
            print(ipfspath)
            print(glusterpath)
            print(overlaypath)
            os.makedirs(ipfsdir)           
            #os.makedirs(glusterdir)
            #os.makedirs(overlaydir)
            if os.path.exists(ipfsdir):
                if ipfs is not None:
                    fo= open(ipfspath, "a+")
                    #filebuffer = ["ipfs"]
                    fo.writelines("%r\n" %ipfs)
                    fo.close()
            if os.path.exists(glusterdir):
                if gluster is not None:
                    fo= open(glusterpath, "a+")
                    fo.writelines("%r\n" %gluster)
                    fo.close()
            if os.path.exists(overlaydir):   
                if overlay is not None:
                    fo= open(overlaypath, "a+")
                    fo.writelines("%r\n" %overlay)
                    fo.close()
            # Create a database in project and get it's path.
            #SQLALCHEMY_DATABASE_URI = "sqlite:///" + os.path.join(basedir, "beefchain.db")
            return {"status": "successfully added parameters to beefchaingroup"}
        
        if beefchaingroup is not None:
            
            
            # Create a new record.
            #beefchaingroup = Beefchaingroup(name=name)

            # Add user to session.
            #db.session.add(beefchaingroup)

            # Commit session.
            #db.session.commit()
             
            groupdir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../db_files/"))
            ipfspath = os.path.join(groupdir, name , 'ipfs.txt')
            ipfsdir = os.path.join(groupdir, name)
            glusterpath = os.path.join(groupdir, name , 'gluster.txt')
            glusterdir = os.path.join(groupdir, name)
            overlaypath = os.path.join(groupdir, name , 'overlay.txt')
            overlaydir = os.path.join(groupdir, name)
            #os.makedirs(ipfspath)
            #os.makedirs(glusterpath)
            #os.makedirs(overlaypath)
            if os.path.exists(ipfsdir):
                if ipfs is not None:
                    fo= open(ipfspath, "a+")
                    #filebuffer = ["ipfs"]
                    fo.writelines("%r\n" %ipfs)
                    fo.close()
            if os.path.exists(glusterdir):
                if gluster is not None:
                    fo= open(glusterpath, "a+")
                    fo.writelines("%r\n" %gluster)
                    fo.close()
            if os.path.exists(overlaydir):   
                if overlay is not None:
                    fo= open(overlaypath, "a+")
                    fo.writelines("%r\n" %overlay)
                    fo.close()
                    
            return {"status": "successfully added parameters to beefchaingroup"}
            # Create a database in project and get it's path.
            #SQLALCHEMY_DATABASE_URI = "sqlite:///" + os.path.join(basedir, "beefchain.db")
        

        # Return success if registration is completed.
        #return {"status": "successfully added parameters to beefchaingroup"}
        
        
class DataReturnBeefchaingroup(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, description = (
                request.json.get("name").strip(),
                request.json.get("description").strip(),
                #request.json.get("link"),
                #request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Invalid input. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422

        # Check if any field is none.
        #if username is None or password is None or email is None:
        if name is None:
            return error.INVALID_INPUT_422
            
        beefchaingroup = Beefchaingroup.query.filter_by(name=name, description=description).first()
        
         

        # Check if user is existed.
        if beefchaingroup is None:
            return error.NOT_FOUND
        
        if beefchaingroup is not None:
        
            groupdir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../db_files/"))
            ipfspath = os.path.join(groupdir, name , 'ipfs.txt')
            ipfsdir = os.path.join(groupdir, name)
            glusterpath = os.path.join(groupdir, name , 'gluster.txt')
            glusterdir = os.path.join(groupdir, name)
            overlaypath = os.path.join(groupdir, name , 'overlay.txt')
            overlaydir = os.path.join(groupdir, name)
            #os.makedirs(ipfspath)
            #os.makedirs(glusterpath)
            #os.makedirs(overlaypath)
            if os.path.exists(ipfsdir):              
                fo= open(ipfspath, "r")
                ipfsfilebuffer = fo.read()
                fo.close()
            if os.path.exists(glusterdir):
                fo= open(glusterpath, "r")
                glusterfilebuffer = fo.read()
                fo.close()
            if os.path.exists(overlaydir):  
                fo= open(overlaypath, "r")
                overlayfilebuffer = fo.read()
                fo.close()
                
                
            return {
            "ipfs": ipfsfilebuffer,
            "gluster": glusterfilebuffer,
            "overlay": overlayfilebuffer            
            }        
        
            
            

        # Get data if it is existed.
        #electricity = Electricity.query.filter_by(name=name).first()

        # Check if user is existed.
        #if electricity is not None:
            #return error.ALREADY_EXIST
            
        #electricity = Electricity.query.filter_by(name=name).first()
        #factor = electricity.factor

        # Create a new record.
        #electricity = Electricity(name=name, factor=factor, link=link)

        # Add user to session.
        #db.session.add(user)

        # Commit session.
        #db.session.commit()

        # Return success if registration is completed.
        
class Uploadfile(Resource):
    @staticmethod
    #def allowed_file(filename):
     #   return '.' in filename and \
      #         filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
    #if request.method == 'POST':
    def post():
        # check if the post request has the file part
        if 'file' not in request.files:
            #flash('No file part')
            #return redirect(request.url)
            return error.NO_INPUT_400
        """   
        try:
            # Get username, password and email.
            filenameholder, description = (
                request.json.get("filename").strip(),
                request.json.get("description").strip(),
                #request.json.get("link"),
                #request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Invalid input. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422
        """   
        file = request.files['file']
        # If the user does not select a file, the browser submits an
        # empty file without a filename.
        if file.filename == '':
            #flash('No selected file')
            return error.NO_INPUT_400
            #return redirect(request.url)
        filename = file.filename
        #if file and allowed_file(file.filename):
        if file and '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS:
            uploadfiledb = Uploadfiledb.query.filter_by(filename=filename).first()
            if uploadfiledb is not None: 
                return "File with the name already exists, us some other name!"            
            if uploadfiledb is None:  
            
                filename = secure_filename(file.filename)
                groupdir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../uploads/"))
                #file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))   
                file.save(os.path.join(groupdir, filename)) 
                uploadfiledb = Uploadfiledb(filename=filename, description=filename) 
                db.session.add(uploadfiledb)
                db.session.commit()

                return {"Status:": "Uploaded",
                        "Filename:": filename
                 }  
                    
            #return redirect(url_for('download_file', name=filename)) 
        return "Unable to upload files!!!"          
           
           
class Downloadfile(Resource):
    @staticmethod
    #def allowed_file(filename):
     #   return '.' in filename and \
      #         filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
    #if request.method == 'POST':
    def post():
        # check if the post request has the file part
        """
        if 'file' not in request.files:
            #flash('No file part')
            #return redirect(request.url)
            return error.NO_INPUT_400
        """  
        try:
            # Get username, password and email.
            filenameholder, description = (
                request.json.get("filename").strip(),
                request.json.get("description").strip(),
                #request.json.get("link"),
                #request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Invalid input. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422
        # check if the post request has the file part
        if filenameholder is None:
            return error.INVALID_INPUT_422
        uploadfiledb = Uploadfiledb.query.filter_by(filename=filenameholder).first() 
        if uploadfiledb is None:
            return error.DOES_NOT_EXIST  
        groupdir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../uploads/"))   
        #return send_file(download_name=filenameholder, as_attachment=True ) 
        filepath = os.path.join(groupdir, filenameholder)
        if os.path.exists(filepath):          
            return send_from_directory(groupdir, filenameholder, as_attachment=True )
            #return send_file(groupdir, attachment_filename=filenameholder, as_attachment=True )              
        return "File not found! Unable to process request!"
        """            
        if 'file' not in request.files:
            #flash('No file part')
            #return redirect(request.url)
            return error.NO_INPUT_400
        file = request.files['file']
        # If the user does not select a file, the browser submits an
        # empty file without a filename.
        if file.filename == '':
            #flash('No selected file')
            return error.NO_INPUT_400
            #return redirect(request.url)
        filename = file.filename
        #if file and allowed_file(file.filename):
        if file and '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS:
            filename = secure_filename(file.filename)
            groupdir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../uploads/"))
            #file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))   
            file.save(os.path.join(groupdir, filename))  
            return "File successfully uploaded!"    
            #return redirect(url_for('download_file', name=filename)) 
        return "Unable to upload files!!!"
        """
class Removefile(Resource):
    @staticmethod
    #def allowed_file(filename):
     #   return '.' in filename and \
      #         filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
    #if request.method == 'POST':
    def post():
        # check if the post request has the file part
        """
        if 'file' not in request.files:
            #flash('No file part')
            #return redirect(request.url)
            return error.NO_INPUT_400
        """  
        try:
            # Get username, password and email.
            filenameholder, description = (
                request.json.get("filename").strip(),
                request.json.get("description").strip(),
                #request.json.get("link"),
                #request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Invalid input. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422
        # check if the post request has the file part
        if filenameholder is None:
            return error.INVALID_INPUT_422
        uploadfiledb = Uploadfiledb.query.filter_by(filename=filenameholder).first() 
        if uploadfiledb is None:
            return error.DOES_NOT_EXIST  
        groupdir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../uploads/"))   
        #return send_file(download_name=filenameholder, as_attachment=True ) 
        filepath = os.path.join(groupdir, filenameholder)
        if os.path.exists(filepath):    
            db.session.delete(uploadfiledb) 
            # Commit session.
            db.session.commit()    
            if os.path.isfile(filepath):
                os.remove(filepath)
                return {"Status": "Removed",
                        "Filename": filenameholder
                }
            #return send_file(groupdir, attachment_filename=filenameholder, as_attachment=True )                         
        return "File not found! Unable to process request!"
        
        
class Userrequestsadd(Resource):
    @staticmethod
    #def allowed_file(filename):
     #   return '.' in filename and \
      #         filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
    #if request.method == 'POST':
    def post(): 
        try:
            # Get username, password and email.
            requestor, identity, requestinfo = (
                request.json.get("requestor").strip(),
                request.json.get("identity").strip(),
                request.json.get("requestinfo").strip(),
                #request.json.get("link"),
                #request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Invalid input. " + str(why))

            # Return invalid input error.
            
            return error.INVALID_INPUT_422 
            
        if requestor is None:
            return error.INVALID_INPUT_422
            
            
         # Get data if it is existed.
        userrequests = Userrequests.query.filter_by(requestor=requestor).first()
        
        if userrequests is None:
            # Create a new record.
            status = "pending!"
            userrequests = Userrequests(requestor=requestor , identity=identity, requestinfo=requestinfo, status=status)
              # Add user to session.
            db.session.add(userrequests)

            # Commit session.
            db.session.commit()
             
            groupdir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../requests/")) 
            filename = requestor + '.txt'
            requestsdir = os.path.join(groupdir, filename)
            #os.makedirs(requestsdir)   
            if os.path.exists(groupdir):
                if requestor is not None: 
                    fo= open(requestsdir, "a+")
                    fo.writelines("%r\n" %identity)
                    fo.writelines("%r\n" %requestinfo)
                    fo.close()
                    
                    return {"status": "successfully initiated request!"}  
                    
        if userrequests is not None:
            groupdir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../requests/")) 
            filename = requestor + '.txt'
            requestsdir = os.path.join(groupdir, filename)
            #os.makedirs(requestsdir)   
            if os.path.exists(groupdir):
                if requestor is not None: 
                    fo= open(requestsdir, "a+")
                    fo.writelines("%r\n" %identity)
                    fo.writelines("%r\n" %requestinfo)
                    fo.close()
                    
                    return {"status": "successfully initiated request!"} 
            
            
        return {"status": "unable to initiate request!"} 
              
class Getrequeststatus(Resource):
    @staticmethod
    #def allowed_file(filename):
     #   return '.' in filename and \
      #         filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
    #if request.method == 'POST':
    def post():   
        try:
            # Get username, password and email.
            requestor, identity = (
                request.json.get("requestor").strip(),
                request.json.get("identity").strip(),             
                #request.json.get("link"),
                #request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Invalid input. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422
            
        if requestor is None:
            return error.INVALID_INPUT_422
            
        if identity is None:
            return error.INVALID_INPUT_422
            
         # Get data if it is existed.
        userrequests = Userrequests.query.filter_by(requestor=requestor).first() 
        if userrequests.requestor==requestor and userrequests.identity==identity:  
            return  {"requestor": userrequests.requestor,
                     "status": userrequests.status}   
        
        return  "unable to process request!"    
        
        
class Updaterequeststatus(Resource):
    @staticmethod
    #def allowed_file(filename):
     #   return '.' in filename and \
      #         filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
    #if request.method == 'POST':
    def post():   
        try:
            # Get username, password and email.
            requestor, identity, status = (
                request.json.get("requestor").strip(),
                request.json.get("identity").strip(),  
                request.json.get("status").strip(),             
                #request.json.get("link"),
                #request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Invalid input. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422
            
        if requestor is None:
            return error.INVALID_INPUT_422
            
        if identity is None:
            return error.INVALID_INPUT_422
            
             
        if status is None:
            return error.INVALID_INPUT_422
            
         # Get data if it is existed.
        userrequests = Userrequests.query.filter_by(requestor=requestor).first() 
        if userrequests.requestor==requestor and userrequests.identity==identity: 
             # Update record.
            
            userrequests.status = status
            # Commit session.
            db.session.commit()
             
            return  {"requestor": userrequests.requestor,
                     "status": userrequests.status,
                     "info": "sucessfully updated!"}   
        
        return  "unable to update request status!"  
        
        
        

       
