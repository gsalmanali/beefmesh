CREATE TABLE cattle_registration (
    HeiferID SERIAL PRIMARY KEY,
    SteerID SERIAL,
    AnimalID VARCHAR(50) NOT NULL,
    ParityRate INTEGER,
    InseminationDate DATE,
    AbortionDate DATE,
    DeadAnimalCount INTEGER,
    AnimalSex CHAR(1),
    InseminationType VARCHAR(50),
    CalvingRate INTEGER
);

INSERT INTO cattle_registration (SteerID, AnimalID, ParityRate, InseminationDate, AbortionDate, DeadAnimalCount, AnimalSex, InseminationType, CalvingRate) 
VALUES 
    (101, 'H123', 2, '2023-01-05', NULL, 0, 'F', 'Natural', 1),
    (102, 'S456', 3, '2023-02-10', NULL, 0, 'M', 'Artificial', 2),
    (103, 'A789', 1, '2023-03-15', '2023-10-20', 1, 'F', 'Natural', 0),
    (NULL, 'B012', NULL, NULL, NULL, NULL, NULL, NULL, NULL); -- Example with missing values

