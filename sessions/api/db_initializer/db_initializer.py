#!/usr/bin/python
# -*- coding: utf-8 -*-

import logging
import os

from api.database.database import db
from api.models.models import User
#from api.models.models import Electricity


def create_super_admin():

    # Check if admin is existed in db.
    user = User.query.filter_by(email="email_superadmin@beefsupply.com").first()

    # If user is none.
    if user is None:

        # Create admin user if it does not existed.
        user = User(
            username="username_superadmin",
            #password="password_superadmin",
            password=os.environ["SESSION_SUPERADMIN_PASSWORD"],
            email="email_superadmin@beefsupply.com",
            user_role="sa",
        )

        # Add user to session.
        db.session.add(user)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("Super admin was set.")

    else:

        # Print admin user status.
        logging.info("Super admin already set.")


def create_admin_user():

    # Check if admin is existed in db.
    user = User.query.filter_by(email="email_admin@beefsupply.com").first()

    # If user is none.
    if user is None:

        # Create admin user if it does not existed.
        user = User(
            username="username_admin",
            #password="password_admin",
            password=os.environ["SESSION_ADMIN_PASSWORD"],
            email="email_admin@beefsupply.com",
            user_role="admin",
        )

        # Add user to session.
        db.session.add(user)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("Admin was set.")

    else:
        # Print admin user status.
        logging.info("Admin already set.")


def create_test_user(
    username="username_test",
    #password="password_test",
    password=os.environ["SESSION_TEST_USER_PASSWORD"],
    email="email_test@beefsupply.com",
    user_role="user",
):

    # Check if admin is existed in db.
    user = User.query.filter_by(email="email_test@beefsupply.com").first()

    # If user is none.
    if user is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        user = User(
            username=username,
            password=password,
            email=email,
            user_role=user_role,
        )

        # Add user to session.
        db.session.add(user)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("Test user was set.")

        # Return user.
        return user

    else:

        # Print admin user status.
        logging.info("User already set.")
        
        
def create_beefsupply_user(
    username="username_beefsupply",
    #password="password_beefsupply",
    password=os.environ["SESSION_GENERIC_USER_PASSWORD"],
    email="email_beefsupply@beefsupply.com",
    user_role="user",
):

    # Check if admin is existed in db.
    user = User.query.filter_by(email="email_beefsupply@beefsupply.com").first()

    # If user is none.
    if user is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        user = User(
            username=username,
            password=password,
            email=email,
            user_role=user_role,
        )

        # Add user to session.
        db.session.add(user)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("BeefSupply generic user was set.")

        # Return user.
        return user

    else:

        # Print admin user status.
        logging.info("User already set.")
        

