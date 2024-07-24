-- Create table
CREATE TABLE cattle_transport (
    DateofDeparture DATE,
    DateofNotification DATE,
    DepartureFarmID INT,
    ArrivalFarmID INT,
    AnimalCount INT,
    HaulersID INT,
    DriverID INT,
    ConsginmentDetail TEXT,
    ConsginmentCondition TEXT,
    DateofDelivery DATE,
    BillofLanding TEXT,
    ExportDocument TEXT,
    BeefArrivalDate DATE,
    ColdStorageData TEXT
);

-- Insert dummy data
INSERT INTO cattle_transport (DateofDeparture, DateofNotification, DepartureFarmID, ArrivalFarmID, AnimalCount, HaulersID, DriverID, ConsginmentDetail, ConsginmentCondition, DateofDelivery, BillofLanding, ExportDocument, BeefArrivalDate, ColdStorageData)
VALUES
    ('2023-01-15', '2023-01-10', 101, 201, 50, 1001, 2001, 'Cattle', 'Healthy', '2023-01-20', 'BL123', 'Doc123', '2023-01-25', 'Frozen'),
    ('2023-02-20', '2023-02-15', 102, 202, 75, 1002, 2002, 'Pigs', 'Injured', '2023-02-25', 'BL456', 'Doc456', '2023-03-01', 'Refrigerated'),
    ('2023-03-10', '2023-03-05', 103, 203, 100, 1003, 2003, 'Sheep', 'Healthy', '2023-03-15', 'BL789', 'Doc789', '2023-03-20', 'Frozen'),
    ('2023-04-05', '2023-04-01', 104, 204, 60, 1004, 2004, 'Goats', 'Sick', '2023-04-10', 'BL012', 'Doc012', '2023-04-15', 'Refrigerated'),
    ('2023-05-12', '2023-05-07', 105, 205, 80, 1005, 2005, 'Chickens', 'Healthy', '2023-05-17', 'BL345', 'Doc345', '2023-05-22', 'Frozen');

