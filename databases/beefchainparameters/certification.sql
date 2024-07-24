-- Create table
CREATE TABLE cattle_certification (
    AnimalHistory TEXT,
    AnimalLifeCycleDetail TEXT,
    OptionsData JSONB,
    ConsumerRating DECIMAL(3,2),
    HalalCertification BOOLEAN,
    KosherCertification BOOLEAN,
    OtherCertification TEXT
);

-- Insert dummy data
INSERT INTO cattle_certification (AnimalHistory, AnimalLifeCycleDetail, OptionsData, ConsumerRating, HalalCertification, KosherCertification, OtherCertification)
VALUES
    ('Bred in captivity', 'Growth monitored closely', '{"diet": "High protein", "exercise": "Regular"}', 4.5, true, false, 'Organic certified'),
    ('Wild caught', 'Life cycle not fully known', '{"diet": "Varied", "habitat": "Natural"}', 3.8, false, true, 'Free range'),
    ('Bred in controlled environment', 'Life cycle closely studied', '{"diet": "Vegetarian", "exercise": "Limited"}', 4.2, true, false, 'Non-GMO'),
    ('Rescued from natural disaster', 'Rehabilitated before release', '{"diet": "Specialized", "exercise": "Rehabilitation"}', 4.7, false, false, 'Grass-fed'),
    ('Sourced from sustainable farms', 'Certified sustainable practices', '{"diet": "Organic", "habitat": "Sustainable"}', 4.6, true, true, 'Pasture-raised');

