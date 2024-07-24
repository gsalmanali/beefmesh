CREATE DATABASE IF NOT EXISTS cattle_db;

USE cattle_db;

CREATE TABLE IF NOT EXISTS cattle (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    breed VARCHAR(50),
    age INT,
    gender ENUM('Male', 'Female'),
    weight DECIMAL(5, 2)
);

INSERT INTO cattle (name, breed, age, gender, weight) VALUES
('Bessie', 'Holstein', 4, 'Female', 650.00),
('Moo Moo', 'Angus', 2, 'Male', 550.50),
('Spot', 'Hereford', 3, 'Female', 600.25),
('Daisy', 'Jersey', 5, 'Female', 500.75),
('Rocky', 'Limousin', 6, 'Male', 700.00);
