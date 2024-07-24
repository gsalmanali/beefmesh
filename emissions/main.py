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
                                               create_emissions_user,
                                               create_electricity_data,
                                               create_diesel_data,
                                               create_gasoline_data,
                                               create_fossil_data,
                                               create_naturalgas_data,
                                               create_biogas_data,
                                               create_solar_data,
                                               create_windturbine_data,
                                               create_steam_data,
                                               create_feed_data,
                                               create_byproducts_data,
                                               create_packaging_data,
                                               create_consumption_data,
                                               create_water_data,
                                               create_plantation_data,
                                               create_chemicals_data,
                                               create_processes_data,
                                               create_generic_data      
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
        create_emissions_user()
        
          #Create default electricity data in database.
        create_electricity_data()
        
         #Create default  data in database.
        create_diesel_data()
        
        #Create default data in database.
        create_gasoline_data()
        
         #Create default  data in database.
        create_fossil_data()
        
         #Create default  data in database.
        create_naturalgas_data()
        
        #Create default  data in database.
        create_biogas_data()
        
        #Create default  data in database.
        create_solar_data()
        
        #Create default  data in database.
        create_windturbine_data()
        
        #Create default  data in database.
        create_steam_data()
         
         #Create default  data in database.
        #create_feed_data()
        
        create_feed_data(
    name="feed",  
    factor="0.000063",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="corn",
    region="michigan",
    unit="lb",
    info="from 80% dry matter")              
        
        create_feed_data(
    name="feed",  
    factor="0.000032",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="alfalfa",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
        create_feed_data(
    name="feed",  
    factor="0.000145",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="soy",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
        create_feed_data(
    name="feed",  
    factor="0.000068",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="hay",
    region="michigan",
    unit="lb",
    info="from 80% dry matter")  
    
        create_feed_data(
    name="feed",  
    factor="0.000259",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="oat",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
    
        create_feed_data(
    name="feed",  
    factor="0.000259",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="barley",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
    
        create_feed_data(
    name="feed",  
    factor="0.000032",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="other",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
    
        create_feed_data(
    name="feed",  
    factor="0.00039",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="grain",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
        create_feed_data(
    name="feed",  
    factor="0.00181",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="milk",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
    
        create_feed_data(
    name="feed",  
    factor="0.000227",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="vitamin",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
        create_feed_data(
    name="feed",  
    factor="0.000227",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="protein",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
        create_feed_data(
    name="feed",  
    factor="0.000227",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="byproduct",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
        create_feed_data(
    name="feed",  
    factor="0.000545",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="seeds",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
    
        create_feed_data(
    name="feed",  
    factor="0.00040",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="rye",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
        create_feed_data(
    name="feed",  
    factor="0.000260",
    link="Rajaniemi, M., 2011. Greenhouse gas emissions from oats, barley, wheat and rye production.",
    code="wheat",
    region="michigan",
    unit="lb",
    info="from 80% dry matter") 
    
        create_byproducts_data(
    name="byproducts",  
    factor="0.01136",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="methane",
    region="michigan",
    unit="lb",
    info="Each year, a single cow will belch about 220 pounds of methane.") 
    
        create_byproducts_data(
    name="byproducts",  
    factor="0.000015",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="manure",
    region="michigan",
    unit="lb",
    info="GHG emissions per ton of manure range from 2200 to 12,000 g CO2-eq for collection, 200 to 2400 g CO2-eq for transportation, 16,000 to 84,000 g CO2-eq for storage, and 16,400 to 33,500 g CO2-eq for land-application") 
    
        create_byproducts_data(
    name="byproducts",  
    factor="0.21822",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="waste",
    region="michigan",
    unit="lb",
    info="We consider rumen content, dry Matter is 20% of total waste! Volatile solids 97% of DM ") 
    
        create_byproducts_data(
    name="byproducts",  
    factor="1.8216",
    link="https://www.ucdavis.edu/food/news/making-cattle-more-sustainable",
    code="blood",
    region="michigan",
    unit="gallon",
    info="slaughter-house blood which usually has a TS of 18~20%, the mean weight of 1 mL of blood is 1.06 g, 250kg of weight produces 21 kg of blood") 
    
    
        create_packaging_data(
    name="packaging",  
    factor="0.0017",
    link="https://8billiontrees.com/carbon-offsets-credits/carbon-ecological-footprint-calculators/plastic-carbon-footprint/",
    code="plastic",
    region="michigan",
    unit="kg",
    info="The cradle to grave carbon footprint of a cardboard box is 0.94 kg CO2e / kg") 
    
        create_packaging_data(
    name="packaging",  
    factor="0.000942",
    link="https://8billiontrees.com/carbon-offsets-credits/carbon-ecological-footprint-calculators/plastic-carbon-footprint/",
    code="paper",
    region="michigan",
    unit="kg",
    info="The cradle to grave carbon footprint of a cardboard box is 0.94 kg CO2e / kg") 
    
        create_packaging_data(
    name="packaging",  
    factor="0.00094",
    link="https://8billiontrees.com/carbon-offsets-credits/carbon-ecological-footprint-calculators/plastic-carbon-footprint/",
    code="cardboard",
    region="michigan",
    unit="kg",
    info="The cradle to grave carbon footprint of a cardboard box is 0.94 kg CO2e / kg") 
    
        create_consumption_data(
    name="consumption",  
    factor="0.00316",
    link="Reynolds, C., 2020. Impacts of home cooking methods and appliances on the ghg emissions of food. Nature Food",
    code="roast",
    region="michigan",
    unit="lb",
    info="using standard equipment for cooking") 
          
        create_consumption_data(
    name="consumption",  
    factor="0.00227",
    link="Reynolds, C., 2020. Impacts of home cooking methods and appliances on the ghg emissions of food. Nature Food",
    code="grill",
    region="michigan",
    unit="lb",
    info="using standard equipment for cooking") 
        create_consumption_data(
    name="consumption",  
    factor="0.000349",
    link="Reynolds, C., 2020. Impacts of home cooking methods and appliances on the ghg emissions of food. Nature Food",
    code="cooker",
    region="michigan",
    unit="lb",
    info="using standard equipment for cooking") 
    
        create_consumption_data(
    name="consumption",  
    factor="0.001474",
    link="Reynolds, C., 2020. Impacts of home cooking methods and appliances on the ghg emissions of food. Nature Food",
    code="fry",
    region="michigan",
    unit="lb",
    info="using standard equipment for cooking") 
    
        create_consumption_data(
    name="consumption",  
    factor="0.001488",
    link="Reynolds, C., 2020. Impacts of home cooking methods and appliances on the ghg emissions of food. Nature Food",
    code="steam",
    region="michigan",
    unit="lb",
    info="using standard equipment for cooking") 
    
        create_consumption_data(
    name="consumption",  
    factor="0.00192",
    link="Reynolds, C., 2020. Impacts of home cooking methods and appliances on the ghg emissions of food. Nature Food",
    code="boil",
    region="michigan",
    unit="lb",
    info="using standard equipment for cooking") 
    
        create_water_data(
    name="water",  
    factor="0.00000046",
    link="Wilson, W., 2009. The carbon footprint of water. River Network, Portland ",
    code="recycled",
    region="michigan",
    unit="gallon",
    info="from life cycle energy used for processing, reactions and and distribution/packaging") 
    
        create_water_data(
    name="water",  
    factor="0.00000083",
    link="Wilson, W., 2009. The carbon footprint of water. River Network, Portland ",
    code="ground",
    region="michigan",
    unit="gallon",
    info="from life cycle energy used for processing, reactions and and distribution/packaging") 
          
          
        create_water_data(
    name="water",  
    factor="0.00000575",
    link="Wilson, W., 2009. The carbon footprint of water. River Network, Portland ",
    code="desalinated",
    region="michigan",
    unit="gallon",
    info="from life cycle energy used for processing, reactions and and distribution/packaging") 
          
          
        create_water_data(
    name="water",  
    factor="0.00000098",
    link="Wilson, W., 2009. The carbon footprint of water. River Network, Portland ",
    code="brackish",
    region="michigan",
    unit="gallon",
    info="from life cycle energy used for processing, reactions and and distribution/packaging") 
          
        create_water_data(
    name="water",  
    factor="0.00000083",
    link="Wilson, W., 2009. The carbon footprint of water. River Network, Portland ",
    code="simple",
    region="michigan",
    unit="gallon",
    info="from life cycle energy used for processing, reactions and and distribution/packaging") 
          
        create_water_data(
    name="water",  
    factor="0.0003171",
    link="https://theecoguide.org/carbon-footprint-household-cleaners",
    code="facilitycleaner",
    region="michigan",
    unit="lb",
    info="from life cycle energy used for processing, reactions and and distribution/packaging") 
          
        create_water_data(
    name="water",  
    factor="0.0002",
    link="https://www.americanchemistry.com/chemistry-in-america/news-trends/blog-post/2021/clariant-innovates-highly-effective-low-carbon-footprint-surfactants-for-personal-care-and-cleaning-products",
    code="cattlecleaner",
    region="michigan",
    unit="lb",
    info="from life cycle energy used for processing, reactions and and distribution/packaging") 
    
        create_plantation_data(
    name="plantation",  
    factor="0.060",
    link="https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references",
    code="trees",
    region="michigan",
    unit="hactre",
    info="redcution from 100 generic trees/hactre, 0.060 metric ton CO2 per urban tree planted") 
    
        create_plantation_data(
    name="plantation",  
    factor="0.000531",
    link="https://healthy.ucla.edu/wp-content/uploads/2019/10/Foodprint-Chapter-2-Carbon-Footprints-of-Foods-Oct-2019.docx",
    code="seedling",
    region="michigan",
    unit="lb",
    info="Pumpkin seeds produce 1.17 kg CO2 equivalent per kg, ") 
    
        create_plantation_data(
    name="plantation",  
    factor="0.000268",
    link="https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references",
    code="liming",
    region="michigan",
    unit="lb",
    info="https://greet.es.anl.gov/files/co2-lming") 
    
        create_chemicals_data(
    name="chemicals",  
    factor="0.00168",
    link="https://mdpi-res.com/d_attachment/agriculture/agriculture-12-00879/article_deploy/agriculture-12-00879-v2.pdf?version=1655714194",
    code="fungicide",
    region="michigan",
    unit="lb",
    info="Imidazole + Trizole 3.90kg CO2 per kg, Organophosphate 3.70kg CO2 per kg") 
    
    
        create_chemicals_data(
    name="chemicals",  
    factor="0.00136",
    link="https://mdpi-res.com/d_attachment/agriculture/agriculture-12-00879/article_deploy/agriculture-12-00879-v2.pdf?version=1655714194",
    code="herbicide",
    region="michigan",
    unit="lb",
    info="Imidazole + Trizole 3.90kg CO2 per kg, Organophosphate 3.70kg CO2 per kg") 
    
        create_chemicals_data(
    name="chemicals",  
    factor="0.00168",
    link="https://mdpi-res.com/d_attachment/agriculture/agriculture-12-00879/article_deploy/agriculture-12-00879-v2.pdf?version=1655714194",
    code="insecticide",
    region="michigan",
    unit="lb",
    info="Imidazole + Trizole 3.90kg CO2 per kg, Organophosphate 3.70kg CO2 per kg") 
    
        create_chemicals_data(
    name="chemicals",  
    factor="0.001145",
    link="https://mdpi-res.com/d_attachment/agriculture/agriculture-12-00879/article_deploy/agriculture-12-00879-v2.pdf?version=1655714194",
    code="nitrogen",
    region="michigan",
    unit="lb",
    info="Imidazole + Trizole 3.90kg CO2 per kg, Organophosphate 3.70kg CO2 per kg") 
    
        create_chemicals_data(
    name="chemicals",  
    factor="0.00033",
    link="https://mdpi-res.com/d_attachment/agriculture/agriculture-12-00879/article_deploy/agriculture-12-00879-v2.pdf?version=1655714194",
    code="phosphate",
    region="michigan",
    unit="lb",
    info="Imidazole + Trizole 3.90kg CO2 per kg, Organophosphate 3.70kg CO2 per kg") 
    
        create_chemicals_data(
    name="chemicals",  
    factor="0.0001045",
    link="https://mdpi-res.com/d_attachment/agriculture/agriculture-12-00879/article_deploy/agriculture-12-00879-v2.pdf?version=1655714194",
    code="potash",
    region="michigan",
    unit="lb",
    info="Imidazole + Trizole 3.90kg CO2 per kg, Organophosphate 3.70kg CO2 per kg") 
    
        create_chemicals_data(
    name="chemicals",  
    factor="0.00022",
    link="https://mdpi-res.com/d_attachment/agriculture/agriculture-12-00879/article_deploy/agriculture-12-00879-v2.pdf?version=1655714194",
    code="otherfertilizer",
    region="michigan",
    unit="lb",
    info="Imidazole + Trizole 3.90kg CO2 per kg, Organophosphate 3.70kg CO2 per kg") 
    
        create_processes_data(
    name="processes",  
    factor="0.00019",
    link="https://www.optimizedthermalsystems.com/images/pdf/about/CA_VRF_Emissions_Study_rev.pdf",
    code="cooling",
    region="michigan",
    unit="kWh",
    info="0.19 Kg CO2 eq per kWh for HVAC") 
    
        create_processes_data(
    name="processes",  
    factor="0.00019",
    link="https://www.optimizedthermalsystems.com/images/pdf/about/CA_VRF_Emissions_Study_rev.pdf",
    code="heating",
    region="michigan",
    unit="kWh",
    info="0.19 Kg CO2 eq per kWh for HVAC") 
    
        create_processes_data(
    name="processes",  
    factor="0.00025",
    link="https://www.optimizedthermalsystems.com/images/pdf/about/CA_VRF_Emissions_Study_rev.pdf",
    code="electrochemical",
    region="michigan",
    unit="kWh",
    info="0.19 Kg CO2 eq per kWh for HVAC") 
    
        create_processes_data(
    name="generic",  
    factor="0.000433",
    link="https://www.optimizedthermalsystems.com/images/pdf/about/CA_VRF_Emissions_Study_rev.pdf",
    code="electronics",
    region="michigan",
    unit="kWh",
    info="from using electricity from distribution lines") 
    
        create_generic_data() 
    
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
    context = ('certificates/cert.pem', 'certificates/key.pem')
    #serving.run_simple("0.0.0.0", 8000, app, ssl_context=context)
    #app.run(ssl_context='adhoc',port=6001, debug=True, host='0.0.0.0', use_reloader=True)
    app.run(ssl_context=context,port=6001, debug=True, host='0.0.0.0', use_reloader=True)

if __name__ == '__main__':
    main()

    
