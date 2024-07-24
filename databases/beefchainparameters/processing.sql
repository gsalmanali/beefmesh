-- Create table
CREATE TABLE cattle_breeding (
    RegistrationID SERIAL PRIMARY KEY,
    GeneticMakeup VARCHAR(100),
    AnimalOutDate DATE,
    AnimalPhenotypeInfo TEXT,
    AnimalTraits VARCHAR(100),
    AnimalColor VARCHAR(50),
    BreederID INT,
    AnimalDam VARCHAR(100),
    AnimalBirthWeight DECIMAL(5,2),
    AnimalFinishingWeight DECIMAL(5,2),
    EstimatedBreedingValue DECIMAL(8,2)
);

-- Insert dummy data
INSERT INTO cattle_breeding (GeneticMakeup, AnimalOutDate, AnimalPhenotypeInfo, AnimalTraits, AnimalColor, BreederID, AnimalDam, AnimalBirthWeight, AnimalFinishingWeight, EstimatedBreedingValue)
VALUES
    ('AB123', '2023-01-15', 'Healthy and active', 'Friendly, energetic', 'Brown', 101, 'XYZ123', 10.5, 200.5, 3500.00),
    ('CD456', '2023-02-20', 'Some allergies', 'Intelligent, playful', 'Black', 102, 'PQR456', 8.2, 180.3, 3200.00),
    ('EF789', '2023-03-10', 'Excellent muscle tone', 'Loyal, strong', 'White', 103, 'STU789', 12.0, 220.0, 3800.00),
    ('GH012', '2023-04-05', 'Mild temperament', 'Calm, obedient', 'Golden', 104, 'VWX012', 9.8, 190.2, 3400.00),
    ('IJ345', '2023-05-12', 'High energy levels', 'Agile, fast', 'Spotted', 105, 'YZA345', 11.3, 210.7, 3600.00);

