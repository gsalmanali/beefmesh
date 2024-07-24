#!/usr/bin/python
# -*- coding: utf-8 -*-

from flask_restful import Api

from api.handlers.UserHandlers import (
    DataAdminRequired,
    DataUserRequired,
    Index,
    Login,
    Logout,
    RefreshToken,
    Register,
    ResetPassword,
    #UsersData,
    DataSuperAdminRequired,
    RemoveUser,
    CheckUserPermission,
    CheckAdminPermission,
    CheckSuperAdminPermission,
    DataInsertBeefchaingroup,
    DataReturnBeefchaingroup,
    Uploadfile,
    Downloadfile,
    Removefile,
    Userrequestsadd,
    Getrequeststatus,
    Updaterequeststatus)


def generate_routes(app):

    # Create api.
    api = Api(app)

    # Add all routes resources.
    # Index page.
    api.add_resource(Index, "/")

    # Register page.
    api.add_resource(Register, "/beefchain/v1/auth/register")

    # Login page.
    api.add_resource(Login, "/beefchain/v1/auth/login")

    # Logout page.
    api.add_resource(Logout, "/beefchain/v1/auth/logout")

    # Refresh page.
    api.add_resource(RefreshToken, "/beefchain/v1/auth/refresh")

    # Password reset page. Not forgot.
    api.add_resource(ResetPassword, "/beefchain/v1/auth/password_reset")

    # Example user handler for user permission.
    api.add_resource(DataUserRequired, "/beefchain/v1/auth/data_user")

    # Example admin handler for admin permission.
    api.add_resource(DataAdminRequired, "/beefchain/v1/auth/data_admin")

    # Example user handler for user permission.
    api.add_resource(DataSuperAdminRequired, "/beefchain/v1/auth/data_super_admin")
    
    # Example user handler for user permission.
    api.add_resource(CheckUserPermission, "/beefchain/v1/auth/check_user_permission")
    
     # Example user handler for user permission.
    api.add_resource(CheckAdminPermission, "/beefchain/v1/auth/check_admin_permission")
    
     #Example user handler for user permission.
    api.add_resource(CheckSuperAdminPermission, "/beefchain/v1/auth/check_sadmin_permission")

    # Get users page with admin permissions.
    #api.add_resource(UsersData, "/beefchain/v1/auth/users")
    
    # Get users page with admin permissions.
    api.add_resource(RemoveUser, "/beefchain/v1/auth/remove_user")
    
     # Get users page with admin permissions.
    api.add_resource(DataInsertBeefchaingroup, "/beefchain/v1/auth/insert_group_info")
    
     # Get users page with admin permissions.
    api.add_resource(DataReturnBeefchaingroup, "/beefchain/v1/auth/get_group_info")
    
    # Get users page with admin permissions.
    api.add_resource(Uploadfile, "/beefchain/v1/auth/upload_file")
    
     # Get users page with admin permissions.
    api.add_resource(Downloadfile, "/beefchain/v1/auth/download_file")
    
    # Get users page with admin permissions.
    api.add_resource(Removefile, "/beefchain/v1/auth/remove_file")
    
     # Get users page with admin permissions.
    api.add_resource(Userrequestsadd, "/beefchain/v1/auth/add_user_requests")
    
    # Get users page with admin permissions.
    api.add_resource(Getrequeststatus, "/beefchain/v1/auth/user_requests_status")
    
    # Get users page with admin permissions.
    api.add_resource(Updaterequeststatus, "/beefchain/v1/auth/user_requests_update")
 
 
   
   
   
