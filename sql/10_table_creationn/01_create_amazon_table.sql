---2. CREATE TABLE 
CREATE TABLE AMAZONREPORT_BACKUP (
    OrderID VARCHAR (50) PRIMARY KEY,
    Sale_Date DATE, 
    Order_Status VARCHAR (100),
    Fulfilment VARCHAR (50),
    SalesChannel VARCHAR(50),
    Ship_Service_Level VARCHAR (20),
    Style VARCHAR (50),
    SKU VARCHAR (100),
    Category VARCHAR (50),
    Product_Size VARCHAR (20),
    Asin VARCHAR (50),
    Courier_Status VARCHAR (20),
    Qty INT, 
    Currency VARCHAR(10),
    Amount DECIMAL(10,2),
    ShipCity VARCHAR (100),
    ShipState VARCHAR (100),
    ShipPostalCode VARCHAR(20),
    ShipCountry VARCHAR(10),
    Promotion_ids VARCHAR (MAX),
    B2B VARCHAR (10),
    Fulfilledby VARCHAR (20), 
    Unnamed22 VARCHAR (20)
);

----3. IMPORT DATA
--CSV File:
--Amazon Sale Report.csv

ALTER TABLE AMAZONREPORT_BACKUP
DROP COLUMN [index];

