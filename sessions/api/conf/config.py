#!/usr/bin/python
# -*- coding: utf-8 -*-

import os

basedir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../db_files/"))

# Create a database in project and get it's path.
SQLALCHEMY_DATABASE_URI = "sqlite:///" + os.path.join(basedir, "beefchain.db")

basedir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../uploads/"))

ALLOWED_EXTENSIONS = {'txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif', 'block', 'json'}
UPLOAD_FOLDER = basedir
