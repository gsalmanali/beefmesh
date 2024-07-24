#!/usr/bin/python
# -*- coding: utf-8 -*-

from datetime import datetime

from flask import g

from api.conf.auth import auth, jwt
from api.database.database import db


class User(db.Model):

    # Generates default class name for table. For changing use
    # __tablename__ = 'users'

    # User id.
    id = db.Column(db.Integer, primary_key=True)

    # User name.
    username = db.Column(db.String(length=80))

    # User password.
    password = db.Column(db.String(length=80))

    # User email address.
    email = db.Column(db.String(length=80))

    # Creation time for user.
    created = db.Column(db.DateTime, default=datetime.utcnow)

    # Unless otherwise stated default role is user.
    user_role = db.Column(db.String, default="user")

    # Generates auth token.
    def generate_auth_token(self, permission_level):

        # Check if admin.
        if permission_level == 1:

            # Generate admin token with flag 1.
            token = jwt.dumps({"email": self.email, "admin": 1})

            # Return admin flag.
            return token

            # Check if admin.
        elif permission_level == 2:

            # Generate admin token with flag 1.
            token = jwt.dumps({"email": self.email, "admin": 2})

            # Return admin flag.
            return token

        # Return normal user flag.
        return jwt.dumps({"email": self.email, "admin": 0})

    # Generates a new access token from refresh token.
    @staticmethod
    @auth.verify_token
    def verify_auth_token(token):

        # Create a global none user.
        g.user = None

        try:
            # Load token.
            data = jwt.loads(token)

        except:
            # If any error return false.
            return False

        # Check if email and admin permission variables are in jwt.
        if "email" and "admin" in data:

            # Set email from jwt.
            g.user = data["email"]

            # Set admin permission from jwt.
            g.admin = data["admin"]

            # Return true.
            return True

        # If does not verified, return false.
        return False

    def __repr__(self):

        # This is only for representation how you want to see user information after query.
        return "<User(id='%s', name='%s', password='%s', email='%s', created='%s')>" % (
            self.id,
            self.username,
            self.password,
            self.email,
            self.created,
        )


class Blacklist(db.Model):

    # Generates default class name for table. For changing use
    # __tablename__ = 'users'

    # Blacklist id.
    id = db.Column(db.Integer, primary_key=True)

    # Blacklist invalidated refresh tokens.
    refresh_token = db.Column(db.String(length=255))

    def __repr__(self):

        # This is only for representation how you want to see refresh tokens after query.
        return "<User(id='%s', refresh_token='%s', status='invalidated.')>" % (
            self.id,
            self.refresh_token,
        )
       
        
class Beefchaingroup(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    #factor = db.Column(db.Float)
    #link = db.Column(db.Unicode)
    description = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80), unique=True)
    #gluster = db.Column(db.Unicode)
    #ipfs = db.Column(db.Unicode)
    #overlay = db.Column(db.Unicode)
    #creator = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
    #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
        """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
        return "<Electricity(id='%s', description='%s', name='%s')>" % (
            self.id,
            self.description,
            self.name,
        )
        
        
class Uploadfiledb(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    #factor = db.Column(db.Float)
    #link = db.Column(db.Unicode)
    description = db.Column(db.String(length=80))
    filename = db.Column(db.String(length=80), unique=True)
    #gluster = db.Column(db.Unicode)
    #ipfs = db.Column(db.Unicode)
    #overlay = db.Column(db.Unicode)
    #creator = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
    #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
        """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
        return "<Electricity(id='%s', filename='%s', description='%s')>" % (
            self.id,
            self.filename,
            self.description,
        )
               
               
class Userrequests(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    #factor = db.Column(db.Float)
    #link = db.Column(db.Unicode)
    requestor = db.Column(db.String(length=80),unique=True)
    identity = db.Column(db.String(length=80))
    status = db.Column(db.String(length=80))
    requestinfo = db.Column(db.Text)
    #gluster = db.Column(db.Unicode)
    #ipfs = db.Column(db.Unicode)
    #overlay = db.Column(db.Unicode)
    #creator = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
    #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
        """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
        return "<Electricity(id='%s', requestor='%s', identity='%s', requestinfo='%s', status='%s')>" % (
            self.id,
            self.requestor,
            self.identity,
            self.requestinfo,
            self.status,
        )
               

