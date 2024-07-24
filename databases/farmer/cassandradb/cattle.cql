-- Create keyspace
CREATE KEYSPACE IF NOT EXISTS cattle_keyspace 
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- Use keyspace
USE cattle_keyspace;

-- Create table for cattle data
CREATE TABLE IF NOT EXISTS cattle_data (
    id UUID PRIMARY KEY,
    name TEXT,
    breed TEXT,
    age INT,
    gender TEXT,
    weight FLOAT,
    color TEXT,
    birth_date TIMESTAMP,
    vaccination_history MAP<TEXT, TIMESTAMP>
);

-- Insert sample cattle data
INSERT INTO cattle_data (id, name, breed, age, gender, weight, color, birth_date, vaccination_history) 
VALUES (
    uuid(),
    'Bessie',
    'Holstein',
    4,
    'Female',
    1200.5,
    'Black and White',
    '2018-05-15',
    {'Bovine Flu': '2020-01-10', 'BVD': '2021-02-20'}
);

INSERT INTO cattle_data (id, name, breed, age, gender, weight, color, birth_date, vaccination_history) 
VALUES (
    uuid(),
    'Daisy',
    'Angus',
    3,
    'Female',
    1100.2,
    'Black',
    '2019-08-20',
    {'Bovine Flu': '2020-03-12'}
);

INSERT INTO cattle_data (id, name, breed, age, gender, weight, color, birth_date, vaccination_history) 
VALUES (
    uuid(),
    'Spot',
    'Hereford',
    5,
    'Male',
    1300.8,
    'Red and White',
    '2017-12-10',
    {'Bovine Flu': '2020-02-05', 'BRSV': '2021-01-15', 'BVD': '2021-03-25'}
);

