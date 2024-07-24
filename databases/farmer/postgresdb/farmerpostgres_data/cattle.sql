-- Create a new database
CREATE DATABASE cattle_db1;

-- Connect to the newly created database
\c cattle_db1;

-- Create a table to store cattle information
CREATE TABLE cattle (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    breed VARCHAR(100),
    age INT,
    weight DECIMAL(6,2),
    owner VARCHAR(100),
    birth_date DATE,
    gender CHAR(1),
    color VARCHAR(50),
    health_status VARCHAR(50)
);

-- Insert sample data into the cattle table
INSERT INTO cattle (name, breed, age, weight, owner, birth_date, gender, color, health_status)
VALUES
    ('Bessie', 'Holstein', 5, 1500.00, 'John Doe', '2017-03-15', 'F', 'Black and White', 'Healthy'),
    ('Moo Moo', 'Jersey', 3, 1200.50, 'Jane Smith', '2019-05-20', 'F', 'Brown', 'Stable'),
    ('Spot', 'Hereford', 4, 1400.75, 'Mike Johnson', '2018-09-10', 'M', 'Red and White', 'Under Observation'),
    ('Daisy', 'Simmental', 2, 1300.25, 'Emily Wilson', '2020-11-25', 'F', 'Yellow', 'Healthy'),
    ('Rocky', 'Angus', 6, 1600.00, 'David Brown', '2016-07-02', 'M', 'Black', 'Stable'),
    ('Cocoa', 'Limousin', 4, 1350.80, 'Sarah Green', '2018-02-14', 'F', 'Brown', 'Healthy'),
    ('Thunder', 'Charolais', 3, 1250.40, 'Michael Lee', '2019-10-30', 'M', 'White', 'Stable'),
    ('Rosie', 'Dexter', 5, 1100.60, 'Jessica Miller', '2017-01-08', 'F', 'Black', 'Under Observation'),
    ('Max', 'Texas Longhorn', 7, 1700.90, 'Ryan Taylor', '2015-04-12', 'M', 'Brown and White', 'Healthy'),
    ('Luna', 'Highland', 1, 950.30, 'Sophia Martinez', '2021-02-18', 'F', 'Red', 'Stable');

