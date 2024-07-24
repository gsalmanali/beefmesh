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
        
    
                
class Electricity(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Electricity(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )
               
class Diesel(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Diesel(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )
        
class Gasoline(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Gasoline(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )
                       
class Fossil(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Fossil(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )       
        
        
class Naturalgas(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Naturalgas(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )     
        
class Biogas(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Biogas(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )     
        
        
class Solar(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Solar(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )     
        
        
class Windturbine(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Windturbine(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )     
        
        
class Steam(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Steam(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )     
                
                
class Feed(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Feed(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )     
        
class Byproducts(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Byproducts(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )     
             
class Packaging(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Packaging(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )    
        
        
class Consumption(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Consumption(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )    
        
        
class Water(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Water(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )    
        
class Plantation(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Plantation(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )    
    
    
class Chemicals(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Chemicals(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )    
        
class Processes(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Processes(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )    
                      
class Generic(db.Model):
    """Define an Address."""

    #__tablename__ = "addresses"

    id = db.Column(db.Integer, primary_key=True)
    factor = db.Column(db.Float)
    link = db.Column(db.String(length=80))
    name = db.Column(db.String(length=80))
    code = db.Column(db.String(length=80))
    region = db.Column(db.String(length=80))
    info = db.Column(db.String(length=80))
    unit = db.Column(db.String(length=80))
    #description = db.Column(db.Unicode, unique=True)
    #user_id = db.Column(db.Integer, db.ForeignKey("users.id"))

    #def __unicode__(self):
        #"""Give a readable representation of an instance."""
     #   return "{}".format(self.id)

    def __repr__(self):
         """Give a unambiguous representation of an instance."""
     #   return "<{}#{}>".format(self.__class__.__name__, self.id)
     
         return "<Generic(id='%s', factor='%s', link='%s', name='%s', code='%s', region='%s, , info='%s', unit='%s')>" % (
            self.id,
            self.factor,
            self.link,
            self.name,
            self.code,
            self.region,
            self.info,
            self.unit,
        )                                                                                                               
