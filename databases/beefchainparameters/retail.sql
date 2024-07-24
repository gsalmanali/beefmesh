-- Create table
CREATE TABLE cattle_retail (
    DateOfDelivery DATE,
    SignOffDetails TEXT,
    BeefCutType VARCHAR(100),
    BeefProductPrice DECIMAL(10, 2),
    TotalProductCount INT
);

-- Insert dummy data
INSERT INTO cattle_retail (DateOfDelivery, SignOffDetails, BeefCutType, BeefProductPrice, TotalProductCount)
VALUES
    ('2023-01-15', 'Signed by John Doe', 'Tenderloin', 25.50, 50),
    ('2023-02-20', 'Signed by Jane Smith', 'Ribeye', 22.75, 75),
    ('2023-03-10', 'Signed by Bob Johnson', 'Sirloin', 18.25, 100),
    ('2023-04-05', 'Signed by Alice Brown', 'Brisket', 15.80, 60),
    ('2023-05-12', 'Signed by Michael Davis', 'Chuck', 12.95, 80);

