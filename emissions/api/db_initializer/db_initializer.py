#!/usr/bin/python
# -*- coding: utf-8 -*-

import logging
import os

from api.database.database import db
from api.models.models import User
from api.models.models import Electricity, Diesel, Gasoline, Fossil, Naturalgas, Biogas, Solar, Windturbine, Steam, Feed, Byproducts, Packaging, Consumption, Water, Plantation, Chemicals, Processes, Generic


def create_super_admin():

    # Check if admin is existed in db.
    user = User.query.filter_by(email="email_superadmin@emissions.com").first()

    # If user is none.
    if user is None:

        # Create admin user if it does not existed.
        user = User(
            username="username_superadmin",
            #password="password_superadmin",
            password=os.environ["EMISSION_SUPERADMIN_PASSWORD"],
            email="email_superadmin@emissions.com",
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
    user = User.query.filter_by(email="email_admin@emissions.com").first()

    # If user is none.
    if user is None:

        # Create admin user if it does not existed.
        user = User(
            username="username_admin",
            #password="password_admin",
            password=os.environ["EMISSION_ADMIN_PASSWORD"],
            email="email_admin@emissions.com",
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
    password=os.environ["EMISSION_TEST_USER_PASSWORD"],
    email="email_test@emissions.com",
    user_role="user",
):

    # Check if admin is existed in db.
    user = User.query.filter_by(email="email_test@emissions.com").first()

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
        
        
def create_emissions_user(
    username="username_emissions",
    #password="password_beefsupply",
    password=os.environ["EMISSION_GENERIC_USER_PASSWORD"],
    email="email_emissions@emissions.com",
    user_role="user",
):

    # Check if admin is existed in db.
    user = User.query.filter_by(email="email_emissions@emissions.com").first()

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
        logging.info("emissions generic user was set.")

        # Return user.
        return user

    else:

        # Print admin user status.
        logging.info("User already set.")
        
def create_electricity_data(
    name="electricity",
    #password="password_beefsupply",
    #password=os.environ["SESSION_GENERIC_USER_PASSWORD"],
    #factor=4.33*(10**(-4)),
    factor="0.000433",
    link="https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references",
    code="v01",
    region="michigan",
    unit="kWh",
    info="92.7% efficiency"    
):

    # Check if admin is existed in db.
    electricity = Electricity.query.filter_by(name="electricity").first()

    # If user is none.
    if electricity is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        electricity = Electricity(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(electricity)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("electricity data was set.")

        # Return user.
        return electricity

    else:

        # Print admin user status.
        logging.info("electricity data already set.")       


def create_diesel_data(
    name="diesel",  
    factor="0.001219",
    link="https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references",
    code="v01",
    region="michigan",
    unit="lb",
    info="none"    
):

    # Check if admin is existed in db.
    diesel = Diesel.query.filter_by(name="diesel").first()

    # If user is none.
    if diesel is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        diesel = Diesel(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(diesel)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("diesel data was set.")

        # Return user.
        return diesel

    else:

        # Print admin user status.
        logging.info("diesel data already set.")    
        
        
def create_gasoline_data(
    name="gasoline",  
    factor="0.0010617",
    link="https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references",
    code="v01",
    region="michigan",
    unit="lb",
    info="none"    
):

    # Check if admin is existed in db.
    gasoline = Gasoline.query.filter_by(name="gasoline").first()

    # If user is none.
    if gasoline is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        gasoline = Gasoline(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(gasoline)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("gasoline data was set.")

        # Return user.
        return gasoline

    else:

        # Print admin user status.
        logging.info("gasoline data already set.")   
        
def create_fossil_data(
    name="fossil",  
    factor="0.000904",
    link="https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references",
    code="v01",
    region="michigan",
    unit="lb",
    info="none"    
):

    # Check if admin is existed in db.
    fossil = Fossil.query.filter_by(name="fossil").first()

    # If user is none.
    if fossil is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        fossil = Fossil(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(fossil)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("fossil data was set.")

        # Return user.
        return fossil

    else:

        # Print admin user status.
        logging.info("fossil data already set.")   
        
        
def create_naturalgas_data(
    name="naturalgas",  
    factor="0.00005301",
    link="https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references",
    code="v01",
    region="michigan",
    unit="feet^3",
    info="none"    
):

    # Check if admin is existed in db.
    naturalgas = Naturalgas.query.filter_by(name="naturalgas").first()

    # If user is none.
    if naturalgas is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        naturalgas = Naturalgas(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(naturalgas)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("naturalgas data was set.")

        # Return user.
        return naturalgas

    else:

        # Print admin user status.
        logging.info("naturalgas data already set.")    
        
def create_biogas_data(
    name="biogas",  
    factor="0.0000247",
    link="https://www.quora.com/How-much-cow-dung-is-required-to-produce-1-kg-of-biogas",
    code="v01",
    region="michigan",
    unit="feet^3",
    info="carbon reduction by (electricity*0.0571) assuming 1 cubic meterbiogas = 2kWh energy"    
):

    # Check if admin is existed in db.
    biogas = Biogas.query.filter_by(name="biogas").first()

    # If user is none.
    if biogas is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        biogas = Biogas(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(biogas)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("biogas data was set.")

        # Return user.
        return biogas

    else:

        # Print admin user status.
        logging.info("biogas data already set.")   
        
        
def create_solar_data(
    name="solar",  
    factor="0.00005",
    link="https://freedomforever.com/blog/environmental-offset-solar-power/",
    code="v01",
    region="michigan",
    unit="kWh",
    info="solar panels offset 50 grams of CO2 for every kilowatt-hour of power produced"    
):

    # Check if admin is existed in db.
    solar = Solar.query.filter_by(name="solar").first()

    # If user is none.
    if solar is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        solar = Solar(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(solar)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("solar data was set.")

        # Return user.
        return solar

    else:

        # Print admin user status.
        logging.info("solar data already set.")           
        
        
def create_windturbine_data(
    name="windturbine",  
    factor="0.000006",
    link="https://www.eia.gov/outlooks/aeo/pdf/AEO_Narrative_2021.pdf",
    code="v01",
    region="michigan",
    unit="kWh",
    info="offsets 6 grams of CO2/KWh compared to coal based fuel"    
):

    # Check if admin is existed in db.
    windturbine = Windturbine.query.filter_by(name="windturbine").first()

    # If user is none.
    if windturbine is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        windturbine = Windturbine(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(windturbine)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("windturbine data was set.")

        # Return user.
        return windturbine

    else:

        # Print admin user status.
        logging.info("windturbine data already set.") 
        
        
def create_steam_data(
    name="steam",  
    factor="0.000006",
    link="https://www.law.cornell.edu/cfr/text/40/98.33",
    code="v01",
    region="michigan",
    unit="lb",
    info="assuming 80% efficient boiler and converting used steam to natural gas, also assuming water is coming in at 60F (about 15C) with 28 btu"    
):

    # Check if admin is existed in db.
    steam = Steam.query.filter_by(name="steam").first()

    # If user is none.
    if steam is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        steam = Steam(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(steam)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("steam data was set.")

        # Return user.
        return steam

    else:

        # Print admin user status.
        logging.info("steam data already set.")       
        
        
def create_feed_data(
    name="feed",  
    factor="0.000006",
    link="Rajaniemi, M., Mikkola, H., Ahokas, J., et al., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="v01",
    region="michigan",
    unit="lb",
    info="from 80% dry matter"    
):

    # Check if admin is existed in db.
    feed = Feed.query.filter_by(code=code).first()

    # If user is none.
    if feed is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        feed = Feed(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(feed)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("feed data was set.")

        # Return user.
        return feed

    else:

        # Print admin user status.
        logging.info("feed data already set.")   
        
        
def create_byproducts_data(
    name="byproducts",  
    factor="0.000006",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="v01",
    region="michigan",
    unit="lb",
    info="5500 pounds of CO2-eq per cow/year"    
):

    # Check if admin is existed in db.
    byproducts = Byproducts.query.filter_by(code=code).first()

    # If user is none.
    if byproducts is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        byproducts = Byproducts(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(byproducts)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("byproducts data was set.")

        # Return user.
        return byproducts

    else:

        # Print admin user status.
        logging.info("byproducts data already set.")          
        
        
def create_packaging_data(
    name="packaging",  
    factor="0.000006",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="v01",
    region="michigan",
    unit="lb",
    info="5500 pounds of CO2-eq per cow/year"    
):

    # Check if admin is existed in db.
    packaging = Packaging.query.filter_by(code=code).first()

    # If user is none.
    if packaging is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        packaging = Packaging(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(packaging)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("packaging data was set.")

        # Return user.
        return packaging

    else:

        # Print admin user status.
        logging.info("packaging data already set.") 
        
def create_consumption_data(
    name="consumption",  
    factor="0.000006",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="v01",
    region="michigan",
    unit="lb",
    info="5500 pounds of CO2-eq per cow/year"    
):

    # Check if admin is existed in db.
    consumption = Consumption.query.filter_by(code=code).first()

    # If user is none.
    if consumption is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        consumption = Consumption(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(consumption)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("consumption data was set.")

        # Return user.
        return consumption

    else:

        # Print admin user status.
        logging.info("consumption data already set.")       
        
        
def create_water_data(
    name="water",  
    factor="0.000006",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="v01",
    region="michigan",
    unit="lb",
    info="5500 pounds of CO2-eq per cow/year"    
):

    # Check if admin is existed in db.
    water = Water.query.filter_by(code=code).first()

    # If user is none.
    if water is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        water = Water(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(water)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("water data was set.")

        # Return user.
        return water

    else:

        # Print admin user status.
        logging.info("water data already set.")       
        
def create_plantation_data(
    name="plantation",  
    factor="0.000006",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="v01",
    region="michigan",
    unit="lb",
    info="5500 pounds of CO2-eq per cow/year"    
):

    # Check if admin is existed in db.
    plantation = Plantation.query.filter_by(code=code).first()

    # If user is none.
    if plantation is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        plantation = Plantation(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(plantation)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("plantation data was set.")

        # Return user.
        return plantation

    else:

        # Print admin user status.
        logging.info("plantation data already set.")                  
        
def create_chemicals_data(
    name="chemicals",  
    factor="0.000006",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="v01",
    region="michigan",
    unit="lb",
    info="5500 pounds of CO2-eq per cow/year"    
):

    # Check if admin is existed in db.
    chemicals = Chemicals.query.filter_by(code=code).first()

    # If user is none.
    if chemicals is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        chemicals = Chemicals(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(chemicals)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("chemicals data was set.")

        # Return user.
        return chemicals

    else:

        # Print admin user status.
        logging.info("chemicals data already set.")                  
                
def create_processes_data(
    name="processes",  
    factor="0.000006",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="v01",
    region="michigan",
    unit="lb",
    info="5500 pounds of CO2-eq per cow/year"    
):

    # Check if admin is existed in db.
    processes = Processes.query.filter_by(code=code).first()

    # If user is none.
    if processes is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        processes = Processes(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(processes)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("processes data was set.")

        # Return user.
        return processes

    else:

        # Print admin user status.
        logging.info("processes data already set.")        
        
        
def create_generic_data(
    name="generic",
    #password="password_beefsupply",
    #password=os.environ["SESSION_GENERIC_USER_PASSWORD"],
    #factor=4.33*(10**(-4)),
    factor="0.000433",
    link="https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references",
    code="electricity",
    region="michigan",
    unit="kWh",
    info="92.7% efficiency over distribution lines"    
):

    # Check if admin is existed in db.
    generic = Generic.query.filter_by(code=code).first()

    # If user is none.
    if generic is None:

        # Create admin user if it does not existed.
        # user = User(username=username, password=password, email=email, user_role=user_role)
        generic = Generic(
            name=name,
            factor=factor,
            link=link,
            code=code,
            region=region,
            info=info,
            unit=unit,
        )

        # Add user to session.
        db.session.add(generic)

        # Commit session.
        db.session.commit()

        # Print admin user status.
        logging.info("generic data was set.")

        # Return user.
        return generic

    else:

        # Print admin user status.
        logging.info("generic data already set.")              
                                                                                                                                                                                                                                              
