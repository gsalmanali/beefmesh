db = db.getSiblingDB('sample_db');

db.createCollection('sample_collection');

db.sample_collection.insertMany([
 {
    org: 'farmer',
    filter: 'PROCESS_A',
    address: 'http://beef_client_1:9999/auth'
  },
  {
    org: 'breeder',
    filter: 'PROCESS_B',
    address: 'http://beef_client_2:9998/auth'
  },
  {
    org: 'retailer',
    filter: 'PROCESS_C',
    address: 'http://beef_client_3:9997/auth'
  }  
]);
