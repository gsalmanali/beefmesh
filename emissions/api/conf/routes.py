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
    DataReturnElectricity,
    DataInsertElectricity,
    GetAllDataEmissions,
    DataReturnDiesel,
    DataInsertDiesel,
    DataReturnGasoline,
    DataInsertGasoline,
    DataReturnFossil,
    DataInsertFossil,
    DataReturnNaturalgas,
    DataInsertNaturalgas,
    DataReturnBiogas,
    DataInsertBiogas,
    DataReturnSolar,
    DataInsertSolar,
    DataReturnWindturbine,
    DataInsertWindturbine,
    DataReturnSteam,
    DataInsertSteam,
    DataReturnFeed,
    DataInsertFeed,
    DataReturnByproducts,
    DataInsertByproducts, 
    DataReturnPackaging,
    DataInsertPackaging,
    DataReturnConsumption,
    DataInsertConsumption,
    DataReturnWater,
    DataInsertWater,
    DataReturnPlantation,
    DataInsertPlantation,
    DataReturnChemicals,
    DataInsertChemicals,
    DataReturnProcesses,
    DataInsertProcesses,
    DataReturnGeneric,
    DataInsertGeneric       
    )


def generate_routes(app):

    # Create api.
    api = Api(app)

    # Add all routes resources.
    # Index page.
    api.add_resource(Index, "/")

    # Register page.
    api.add_resource(Register, "/emissions/v1/auth/register")

    # Login page.
    api.add_resource(Login, "/emissions/v1/auth/login")

    # Logout page.
    api.add_resource(Logout, "/emissions/v1/auth/logout")

    # Refresh page.
    api.add_resource(RefreshToken, "/emissions/v1/auth/refresh")

    # Password reset page. Not forgot.
    api.add_resource(ResetPassword, "/emissions/v1/auth/password_reset")

    # Example user handler for user permission.
    api.add_resource(DataUserRequired, "/emissions/v1/auth/data_user")

    # Example admin handler for admin permission.
    api.add_resource(DataAdminRequired, "/emissions/v1/auth/data_admin")

    # Example user handler for user permission.
    api.add_resource(DataSuperAdminRequired, "/emissions/v1/auth/data_super_admin")
    
    # Example user handler for user permission.
    api.add_resource(CheckUserPermission, "/emissions/v1/auth/check_user_permission")
    
     # Example user handler for user permission.
    api.add_resource(CheckAdminPermission, "/emissions/v1/auth/check_admin_permission")
    
     #Example user handler for user permission.
    api.add_resource(CheckSuperAdminPermission, "/emissions/v1/auth/check_sadmin_permission")

    # Get users page with admin permissions.
    #api.add_resource(UsersData, "/beefchain/v1/auth/users")
    
    # Get users page with admin permissions.
    api.add_resource(RemoveUser, "/emissions/v1/auth/remove_user")
    
     #Get  page with  permissions.
    api.add_resource(GetAllDataEmissions, "/emissions/v1/auth/get_all_emission_factors")
    
    # Get  page with  permissions.
    api.add_resource(DataInsertElectricity, "/emissions/v1/auth/insert_data_electricity")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnElectricity, "/emissions/v1/auth/get_data_electricity")
    
    # Get  page with  permissions.
    api.add_resource(DataInsertDiesel, "/emissions/v1/auth/insert_data_diesel")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnDiesel, "/emissions/v1/auth/get_data_diesel")
    
    # Get  page with permissions.
    api.add_resource(DataInsertGasoline, "/emissions/v1/auth/insert_data_gasoline")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnGasoline, "/emissions/v1/auth/get_data_gasoline")
    
     # Get  page with permissions.
    api.add_resource(DataInsertFossil, "/emissions/v1/auth/insert_data_fossil")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnFossil, "/emissions/v1/auth/get_data_fossil")
    
     # Get  page with permissions.
    api.add_resource(DataInsertNaturalgas, "/emissions/v1/auth/insert_data_naturalgas")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnNaturalgas, "/emissions/v1/auth/get_data_naturalgas")
    
      # Get  page with permissions.
    api.add_resource(DataInsertBiogas, "/emissions/v1/auth/insert_data_biogas")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnBiogas, "/emissions/v1/auth/get_data_biogas")
      
       # Get  page with permissions.
    api.add_resource(DataInsertSolar, "/emissions/v1/auth/insert_data_solar")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnSolar, "/emissions/v1/auth/get_data_solar")
    
    api.add_resource(DataInsertWindturbine, "/emissions/v1/auth/insert_data_windturbine")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnWindturbine, "/emissions/v1/auth/get_data_windturbine")
   
    
    api.add_resource(DataInsertSteam, "/emissions/v1/auth/insert_data_steam")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnSteam, "/emissions/v1/auth/get_data_steam")
    
    api.add_resource(DataInsertFeed, "/emissions/v1/auth/insert_data_feed")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnFeed, "/emissions/v1/auth/get_data_feed")
    
    
    api.add_resource(DataInsertByproducts, "/emissions/v1/auth/insert_data_byproducts")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnByproducts, "/emissions/v1/auth/get_data_byproducts")
    
    api.add_resource(DataInsertPackaging, "/emissions/v1/auth/insert_data_packaging")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnPackaging, "/emissions/v1/auth/get_data_packaging")
    
    
    api.add_resource(DataInsertConsumption, "/emissions/v1/auth/insert_data_consumption")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnConsumption, "/emissions/v1/auth/get_data_consumption")
    
    
    api.add_resource(DataInsertWater, "/emissions/v1/auth/insert_data_water")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnWater, "/emissions/v1/auth/get_data_water")
    
    
    api.add_resource(DataInsertPlantation, "/emissions/v1/auth/insert_data_plantation")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnPlantation, "/emissions/v1/auth/get_data_plantation")
    
    api.add_resource(DataInsertChemicals, "/emissions/v1/auth/insert_data_chemicals")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnChemicals, "/emissions/v1/auth/get_data_chemicals")
    
    
    api.add_resource(DataInsertProcesses, "/emissions/v1/auth/insert_data_processes")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnProcesses, "/emissions/v1/auth/get_data_processes")
    
    
    api.add_resource(DataInsertGeneric, "/emissions/v1/auth/insert_data_generic")
 
    #Get  page with  permissions.
    api.add_resource(DataReturnGeneric, "/emissions/v1/auth/get_data_generic")
    
    
   
    
    
   
   
   
   
