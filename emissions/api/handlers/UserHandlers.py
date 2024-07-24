#!/usr/bin/python
# -*- coding: utf-8 -*-

import logging, json
from fastapi.encoders import jsonable_encoder
from datetime import datetime
import os
from flask import g, request, render_template, send_from_directory, send_file, jsonify
from flask_restful import Resource
from werkzeug.utils import secure_filename

import api.error.errors as error
from api.conf.auth import auth, refresh_jwt
from api.database.database import db
from api.models.models import Blacklist, User, Electricity, Diesel, Gasoline, Fossil, Naturalgas, Biogas, Solar, Windturbine, Steam, Feed, Byproducts, Packaging, Consumption, Water, Plantation, Chemicals, Processes, Generic
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
        
        
class DataInsertElectricity(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        electricity = Electricity.query.filter_by(code=code).first()

        # Check if user is existed.
        if electricity is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        electricity = Electricity(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(electricity)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to electrcitiy data"}
        
        
class DataReturnElectricity(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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

        # Get data if it is existed.
        #electricity = Electricity.query.filter_by(name=name).first()

        # Check if user is existed.
        #if electricity is not None:
            #return error.ALREADY_EXIST
            
        electricity = Electricity.query.filter_by(code=code).first()
        factor = electricity.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

        # Create a new record.
        #electricity = Electricity(name=name, factor=factor, link=link)

        # Add user to session.
        #db.session.add(user)

        # Commit session.
        #db.session.commit()

        # Return success if registration is completed.
        return {"factor": electricity.factor,
                "result": total_emissions,
                "info": electricity.info,
                "unit": electricity.unit,
                "scale": "metric ton CO2-equivalent"
                }    
                
class DataInsertDiesel(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        diesel = Diesel.query.filter_by(code=code).first()

        # Check if user is existed.
        if diesel is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        diesel = Diesel(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(diesel)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to diesel data"}
        
        
class DataReturnDiesel(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        diesel = Diesel.query.filter_by(code=code).first()
        factor = diesel.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": diesel.factor,
                "result": total_emissions,
                "info": diesel.info,
                "unit": diesel.unit,
                "scale": "metric ton CO2-equivalent"
                }    
                               
class DataInsertGasoline(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        gasoline = Gasoline.query.filter_by(code=code).first()

        # Check if user is existed.
        if gasoline is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        gasoline = Gasoline(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(gasoline)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to gasoline data"}
        
        
class DataReturnGasoline(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        gasoline = Gasoline.query.filter_by(code=code).first()
        factor = gasoline.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": gasoline.factor,
                "result": total_emissions,
                "info": gasoline.info,
                "unit": gasoline.unit,
                "scale": "metric ton CO2-equivalent"
                }    


class DataInsertFossil(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        fossil = Fossil.query.filter_by(code=code).first()

        # Check if user is existed.
        if fossil is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        fossil = Fossil(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(fossil)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to fossil data"}
        
        
class DataReturnFossil(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        fossil = Fossil.query.filter_by(code=code).first()
        factor = fossil.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": fossil.factor,
                "result": total_emissions,
                "info": fossil.info,
                "unit": fossil.unit,
                "scale": "metric ton CO2-equivalent"
                }    
class DataInsertNaturalgas(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        naturalgas = Naturalgas.query.filter_by(code=code).first()

        # Check if user is existed.
        if naturalgas is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        naturalgas = Naturalgas(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(naturalgas)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to Naturalgas data"}
        
        
class DataReturnNaturalgas(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        naturalgas = Naturalgas.query.filter_by(code=code).first()
        factor = naturalgas.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": naturalgas.factor,
                "result": total_emissions,
                "info": naturalgas.info,
                "unit": naturalgas.unit,
                "scale": "metric ton CO2-equivalent"
                }  
                
                
class DataInsertBiogas(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        biogas = Biogas.query.filter_by(code=code).first()

        # Check if user is existed.
        if biogas is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        biogas = Biogas(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(biogas)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to biogas data"}
        
        
class DataReturnBiogas(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        biogas = Biogas.query.filter_by(code=code).first()
        factor = biogas.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": biogas.factor,
                "result": total_emissions,
                "info": biogas.info,
                "unit": biogas.unit,
                "scale": "metric ton CO2-equivalent"
                }     
                                                  
class DataInsertSolar(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        solar = Solar.query.filter_by(code=code).first()

        # Check if user is existed.
        if solar is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        solar = Solar(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(solar)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to solar data"}
        
        
class DataReturnSolar(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        solar = Solar.query.filter_by(code=code).first()
        factor = solar.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": solar.factor,
                "result": total_emissions,
                "info": solar.info,
                "unit": solar.unit,
                "scale": "metric ton CO2-equivalent"
                }   
                
class DataInsertWindturbine(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        windturbine = Windturbine.query.filter_by(code=code).first()

        # Check if user is existed.
        if windturbine is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        windturbine = Windturbine(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(windturbine)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to windturbine data"}
        
        
class DataReturnWindturbine(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        windturbine = Windturbine.query.filter_by(code=code).first()
        factor = windturbine.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": windturbine.factor,
                "result": total_emissions,
                "info": windturbine.info,
                "unit": windturbine.unit,
                "scale": "metric ton CO2-equivalent"
                }   
                
                
class DataInsertSteam(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        steam = Steam.query.filter_by(code=code).first()

        # Check if user is existed.
        if steam is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        steam = Steam(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(steam)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to steam data"}
        
        
class DataReturnSteam(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        steam = Steam.query.filter_by(code=code).first()
        factor = steam.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": steam.factor,
                "result": total_emissions,
                "info": steam.info,
                "unit": steam.unit,
                "scale": "metric ton CO2-equivalent"
                }     
                
                
class DataInsertFeed(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        feed = Feed.query.filter_by(code=code).first()

        # Check if user is existed.
        if feed is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        feed = Feed(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(feed)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to feed data"}
        
        
class DataReturnFeed(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        feed = Feed.query.filter_by(code=code).first()
        factor = feed.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": feed.factor,
                "result": total_emissions,
                "info": feed.info,
                "unit": feed.unit,
                "scale": "metric ton CO2-equivalent"
                }    
                
                
class DataInsertByproducts(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        byproducts = Byproducts.query.filter_by(code=code).first()

        # Check if user is existed.
        if byproducts is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        byproducts = Byproducts(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(byproducts)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to byproducts data"}
        
        
class DataReturnByproducts(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        byproducts = Byproducts.query.filter_by(code=code).first()
        factor = byproducts.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": byproducts.factor,
                "result": total_emissions,
                "info": byproducts.info,
                "unit": byproducts.unit,
                "scale": "metric ton CO2-equivalent"
                }  
                
class DataInsertPackaging(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        packaging = Packaging.query.filter_by(code=code).first()

        # Check if user is existed.
        if packaging is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        packaging = Packaging(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(packaging)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to packaging data"}
        
        
class DataReturnPackaging(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        packaging = Packaging.query.filter_by(code=code).first()
        factor = packaging.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": packaging.factor,
                "result": total_emissions,
                "info": packaging.info,
                "unit": packaging.unit,
                "scale": "metric ton CO2-equivalent"
                }                       
 
 
class DataInsertConsumption(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        consumption = Consumption.query.filter_by(code=code).first()

        # Check if user is existed.
        if consumption is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        consumption = Consumption(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(consumption)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to consumption data"}
        
        
class DataReturnConsumption(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        consumption = Consumption.query.filter_by(code=code).first()
        factor = consumption.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": consumption.factor,
                "result": total_emissions,
                "info": consumption.info,
                "unit": consumption.unit,
                "scale": "metric ton CO2-equivalent"
                }    
                
                
class DataInsertWater(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        water = Water.query.filter_by(code=code).first()

        # Check if user is existed.
        if water is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        water = Water(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(water)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to water data"}
        
        
class DataReturnWater(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        water = Water.query.filter_by(code=code).first()
        factor = water.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": water.factor,
                "result": total_emissions,
                "info": water.info,
                "unit": water.unit,
                "scale": "metric ton CO2-equivalent"
                }   
                
                
class DataInsertPlantation(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        plantation = Plantation.query.filter_by(code=code).first()

        # Check if user is existed.
        if plantation is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        plantation = Plantation(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(plantation)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to plantation data"}
        
        
class DataReturnPlantation(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        plantation = Plantation.query.filter_by(code=code).first()
        factor = plantation.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": plantation.factor,
                "result": total_emissions,
                "info": plantation.info,
                "unit": plantation.unit,
                "scale": "metric ton CO2-equivalent"
                }  
                
                
class DataInsertChemicals(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        chemicals = Chemicals.query.filter_by(code=code).first()

        # Check if user is existed.
        if chemicals is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        chemicals = Chemicals(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(chemicals)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to chemicals data"}
        
        
class DataReturnChemicals(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        chemicals = Chemicals.query.filter_by(code=code).first()
        factor = chemicals.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": chemicals.factor,
                "result": total_emissions,
                "info": chemicals.info,
                "unit": chemicals.unit,
                "scale": "metric ton CO2-equivalent"
                }                  
                                  

class DataInsertProcesses(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        processes = Processes.query.filter_by(code=code).first()

        # Check if user is existed.
        if processes is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        processes = Processes(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(processes)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to processes data"}
        
        
class DataReturnProcesses(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        processes = Processes.query.filter_by(code=code).first()
        factor = processes.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": processes.factor,
                "result": total_emissions,
                "info": processes.info,
                "unit": processes.unit,
                "scale": "metric ton CO2-equivalent"
                }                  
                                  
class DataInsertGeneric(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, factor, link, code, region, info, unit  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("factor").strip(),
                request.json.get("link").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("info").strip(),
                request.json.get("unit").strip(),
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

        # Get data if it is existed.
        generic = Generic.query.filter_by(code=code).first()

        # Check if user is existed.
        if generic is not None:
            return error.ALREADY_EXIST

        # Create a new record.
        generic = Generic(name=name, factor=factor, link=link, code=code, region=region, info=info, unit=unit)

        # Add user to session.
        db.session.add(generic)

        # Commit session.
        db.session.commit()

        # Return success if registration is completed.
        return {"status": "successfully added parameters to generic data"}
        
        
class DataReturnGeneric(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():

        try:
            # Get username, password and email.
            name, code, region, value  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                request.json.get("code").strip(),
                request.json.get("region").strip(),
                request.json.get("value").strip(),
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
            
        generic = Generic.query.filter_by(code=code).first()
        factor = generic.factor
        total_emissions = 0
        total_emissions = float(value)*float(factor)

   
        # Return success if registration is completed.
        return {"factor": generic.factor,
                "result": total_emissions,
                "info": generic.info,
                "unit": generic.unit,
                "scale": "metric ton CO2-equivalent"
                }                  
                                  
                                                                                                                      

class GetAllDataEmissions(Resource):
    @staticmethod
    #@auth.login_required
    #@role_required.permission(0)
    #def get(self):
    def post():
        name = request.json.get("name").strip()
        """
        try:
            # Get username, password and email.
            name  = (
                #request.json.get("username").strip(),
                request.json.get("name").strip(),
                #request.json.get("code").strip(),
                #request.json.get("refresh_token"),
            )
        except Exception as why:

            # Log input strip or etc. errors.
            logging.info("Invalid input. " + str(why))

            # Return invalid input error.
            return error.INVALID_INPUT_422
        """
       
        # Check if any field is none.
        #if username is None or password is None or email is None:
        if name is None:
            return error.INVALID_INPUT_422
            
        if ((name=="electricity") or (name=="Electricity") or (name=="ELECTRICITY")):
            name = "electricity"
            finder = Electricity.query.filter_by(name=name).all()
        elif (name=="diesel"):
            name = "diesel"
            finder = Diesel.query.filter_by(name=name).all()
            
        elif (name=="gasoline"):
            name = "gasoline"
            finder = Gasoline.query.filter_by(name=name).all()
            
        elif (name=="fossil"):
            name = "fossil"
            finder = Fossil.query.filter_by(name=name).all()
        
        elif (name=="naturalgas"):
            name = "naturalgas"
            finder = Naturalgas.query.filter_by(name=name).all()  
            
        elif (name=="biogas"):
            name = "biogas"
            finder = Biogas.query.filter_by(name=name).all() 
            
        elif (name=="solar"):
            name = "solar"
            finder = Solar.query.filter_by(name=name).all()   
            
        elif (name=="windturbine"):
            name = "windturbine"
            finder = Windturbine.query.filter_by(name=name).all()   
            
        elif (name=="steam"):
            name = "steam"
            finder = Steam.query.filter_by(name=name).all() 
            
        elif (name=="feed"):
            name = "feed"
            finder = Feed.query.filter_by(name=name).all()    
            
        elif (name=="byproducts"):
            name = "byproducts"
            finder = Byproducts.query.filter_by(name=name).all()  
            
        elif (name=="packaging"):
            name = "packaging"
            finder = Packaging.query.filter_by(name=name).all()  
            
        elif (name=="consumption"):
            name = "consumption"
            finder = Consumption.query.filter_by(name=name).all()   
            
        elif (name=="water"):
            name = "water"
            finder = Water.query.filter_by(name=name).all() 
            
        elif (name=="plantation"):
            name = "plantation"
            finder = Plantation.query.filter_by(name=name).all()             
                                     
        elif (name=="chemicals"):
            name = "chemicals"
            finder = Chemicals.query.filter_by(name=name).all()             
                          
        elif (name=="processes"):
            name = "processes"
            finder = Processes.query.filter_by(name=name).all()             
        
        elif (name=="generic"):
            name = "generic"
            finder = Generic.query.filter_by(name=name).all()             
                      
            
        else: 
            return "unable to find data"
      
      
        return jsonable_encoder(finder)
     
           
