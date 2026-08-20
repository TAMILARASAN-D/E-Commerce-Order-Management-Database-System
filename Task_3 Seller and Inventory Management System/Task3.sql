USE ecoms_db;

DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Seller;

-- 1. Create Seller Table
CREATE TABLE Seller (
    Seller_ID INT AUTO_INCREMENT,
    Seller_Name VARCHAR(120) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL,
    Address VARCHAR(150) NOT NULL,
    
    CONSTRAINT pk_seller PRIMARY KEY (Seller_ID),
    CONSTRAINT chk_seller_email CHECK (Email LIKE '%@%.%')
) ENGINE=InnoDB;

-- 2. Create Inventory Table
CREATE TABLE Inventory (
    Inventory_ID INT AUTO_INCREMENT,
    Product_ID INT NOT NULL UNIQUE,
    Seller_ID INT NOT NULL,
    Stock_Quantity INT NOT NULL DEFAULT 0,
    Stock_Status ENUM('Available', 'Out of Stock') NOT NULL DEFAULT 'Available',
    Last_Updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_inventory PRIMARY KEY (Inventory_ID),
    CONSTRAINT chk_inventory_qty CHECK (Stock_Quantity >= 0),
    CONSTRAINT fk_inventory_product 
        FOREIGN KEY (Product_ID) REFERENCES Product (Product_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_inventory_seller 
        FOREIGN KEY (Seller_ID) REFERENCES Seller (Seller_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Indexing for lookup performance
CREATE INDEX idx_inventory_seller ON Inventory (Seller_ID);
CREATE INDEX idx_inventory_status ON Inventory (Stock_Status);

-- 3. Seed Seller Records
INSERT INTO Seller (Seller_Name, Email, Phone, Address) VALUES
('ABC Electronics Hub', 'contact@abcelectronics.com', '9811122233', 'Industrial Area, Bangalore'),
('Fashion World Traders', 'support@fashionworld.com', '9822233344', 'Textile Park, Surat'),
('BookLand Publishers', 'sales@bookland.com', '9833344455', 'Daryaganj, Delhi'),
('Home Comforts Appliances', 'info@homecomforts.com', '9844455566', 'GIDC Estate, Ahmedabad');

-- 4. Seed Inventory Records
INSERT INTO Inventory (Product_ID, Seller_ID, Stock_Quantity, Stock_Status) VALUES
(1, 1, 35, 'Available'),
(2, 1, 150, 'Available'),
(3, 1, 45, 'Available'),
(4, 1, 0, 'Out of Stock'),
(5, 2, 200, 'Available'),
(6, 2, 8, 'Available'),
(7, 2, 80, 'Available'),
(8, 3, 120, 'Available'),
(9, 3, 5, 'Available'),
(10, 4, 0, 'Out of Stock');


-- Operational Maintenance & Tracking Scripts
-- 1. Add new seller details
INSERT INTO Seller (Seller_Name, Email, Phone, Address) VALUES
('Global Tech Imports', 'admin@globaltech.com', '9855566677', 'SEZ Hub, Chennai');

-- 2. Update seller contact details
UPDATE Seller 
SET Phone = '9811199900', Address = 'Electronic City, Bangalore' 
WHERE Seller_ID = 1;

-- 3. Track Product Availability: Display all available products
SELECT p.Product_Name, i.Stock_Quantity, i.Stock_Status 
FROM Product p 
JOIN Inventory i ON p.Product_ID = i.Product_ID 
WHERE i.Stock_Status = 'Available' AND i.Stock_Quantity > 0;

-- 4. Track Product Availability: Display out-of-stock products
SELECT p.Product_Name, s.Seller_Name, i.Last_Updated 
FROM Product p 
JOIN Inventory i ON p.Product_ID = i.Product_ID 
JOIN Seller s ON i.Seller_ID = s.Seller_ID 
WHERE i.Stock_Quantity = 0 OR i.Stock_Status = 'Out of Stock';

-- 5. Identify Low Stock Products (Stock_Quantity < 10)
SELECT p.Product_ID, p.Product_Name, i.Stock_Quantity, s.Seller_Name 
FROM Inventory i 
JOIN Product p ON i.Product_ID = p.Product_ID 
JOIN Seller s ON i.Seller_ID = s.Seller_ID 
WHERE i.Stock_Quantity < 10;

-- 6. Restock Operation (Update stock arrival and state shift)
UPDATE Inventory 
SET Stock_Quantity = 25, Stock_Status = 'Available' 
WHERE Product_ID = 4;

-- 7. Remove discontinued inventory record
DELETE FROM Inventory WHERE Product_ID = 10;


-- Inventory Status Reports
-- Report 1: Seller-wise Product Report
SELECT 
    s.Seller_Name,
    COUNT(i.Product_ID) AS Products_Supplied,
    COALESCE(SUM(i.Stock_Quantity), 0) AS Total_Available_Stock
FROM Seller s
LEFT JOIN Inventory i ON s.Seller_ID = i.Seller_ID
GROUP BY s.Seller_ID, s.Seller_Name;

-- Report 2: Stock Availability Report
SELECT 
    p.Product_Name,
    i.Stock_Quantity,
    i.Stock_Status,
    i.Last_Updated
FROM Product p
INNER JOIN Inventory i ON p.Product_ID = i.Product_ID
ORDER BY i.Stock_Status ASC, i.Stock_Quantity ASC;

-- Report 3: Inventory Analysis Summary
SELECT 
    COUNT(CASE WHEN Stock_Quantity > 0 THEN 1 END) AS Total_Products_Available,
    COUNT(CASE WHEN Stock_Quantity = 0 THEN 1 END) AS Products_Out_Of_Stock,
    MAX(Stock_Quantity) AS Highest_Stock_Quantity,
    ROUND(AVG(Stock_Quantity), 2) AS Average_Inventory_Quantity
FROM Inventory;
