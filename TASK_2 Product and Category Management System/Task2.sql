USE ecoms_db;

-- Drop tables in proper dependency order
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Category;

-- 1. Create Category Table
CREATE TABLE Category (
    Category_ID INT AUTO_INCREMENT,
    Category_Name VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT,
    
    CONSTRAINT pk_category PRIMARY KEY (Category_ID)
) ENGINE=InnoDB;

-- 2. Create Product Table
CREATE TABLE Product (
    Product_ID INT AUTO_INCREMENT,
    Product_Name VARCHAR(150) NOT NULL,
    Category_ID INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Stock_Quantity INT NOT NULL DEFAULT 0,
    
    CONSTRAINT pk_product PRIMARY KEY (Product_ID),
    CONSTRAINT chk_product_price CHECK (Price >= 0.00),
    CONSTRAINT chk_product_stock CHECK (Stock_Quantity >= 0),
    CONSTRAINT fk_product_category 
        FOREIGN KEY (Category_ID) 
        REFERENCES Category (Category_ID)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Index on Category_ID foreign key for JOIN performance
CREATE INDEX idx_product_category ON Product (Category_ID);

-- 3. Seed Category Data
INSERT INTO Category (Category_Name, Description) VALUES
('Electronics', 'Gadgets, computers, smartphones, and electronic accessories'),
('Clothing', 'Apparel, footwear, and fashion accessories'),
('Books', 'Academic textbooks, fiction, non-fiction, and literature'),
('Home Appliances', 'Kitchen appliances and electrical household devices');

-- 4. Seed 10 Product Records
INSERT INTO Product (Product_Name, Category_ID, Price, Stock_Quantity) VALUES
('Laptop Pro 15', 1, 55000.00, 20),
('Wireless Bluetooth Mouse', 1, 800.00, 150),
('Smartphone X12', 1, 32000.00, 45),
('Noise Cancelling Headphones', 1, 4500.00, 60),
('Men Cotton T-Shirt', 2, 750.00, 200),
('Running Shoes', 2, 2500.00, 50),
('Denim Jeans', 2, 1800.00, 80),
('Database System Concepts Book', 3, 650.00, 120),
('Python Programming Guide', 3, 450.00, 90),
('Microwave Oven 20L', 4, 6800.00, 15);


-- Product Operations (CRUD)
-- INSERT Operation: Add new products to inventory
INSERT INTO Product (Product_Name, Category_ID, Price, Stock_Quantity) VALUES
('Air Conditioner 1.5 Ton', 4, 38000.00, 10),
('Mechanical Keyboard', 1, 3500.00, 25);

-- UPDATE Operations:
-- 1. Modify product price and increase stock after new shipment arrival
UPDATE Product 
SET Stock_Quantity = Stock_Quantity + 15, Price = 54000.00 
WHERE Product_ID = 1;

-- 2. Apply a 10% promotional price discount on all Books (Category_ID = 3)
UPDATE Product 
SET Price = Price * 0.90 
WHERE Category_ID = 3;

-- DELETE Operation: Remove a discontinued product
DELETE FROM Product 
WHERE Product_ID = 11;

-- Category-Wise Product Reports
-- Report 1: Display all products under each category (FULL CATALOG)
SELECT 
    c.Category_Name, 
    p.Product_ID, 
    p.Product_Name, 
    p.Price, 
    p.Stock_Quantity,
    (p.Price * p.Stock_Quantity) AS Total_Stock_Value
FROM Category c
INNER JOIN Product p ON c.Category_ID = p.Category_ID
ORDER BY c.Category_Name, p.Product_Name;

-- Report 2: Count total number of products in each category
SELECT 
    c.Category_ID,
    c.Category_Name, 
    COUNT(p.Product_ID) AS Total_Products,
    COALESCE(SUM(p.Stock_Quantity), 0) AS Total_Units_In_Stock
FROM Category c
LEFT JOIN Product p ON c.Category_ID = p.Category_ID
GROUP BY c.Category_ID, c.Category_Name;

-- Report 3: Find the highest-priced product in each category (Correlated Subquery)
SELECT 
    c.Category_Name, 
    p.Product_Name, 
    p.Price AS Highest_Price
FROM Product p
INNER JOIN Category c ON p.Category_ID = c.Category_ID
WHERE p.Price = (
    SELECT MAX(Price) 
    FROM Product 
    WHERE Category_ID = p.Category_ID
);

-- Report 4: Display categories having more than 3 products
SELECT 
    c.Category_Name, 
    COUNT(p.Product_ID) AS Total_Products
FROM Category c
JOIN Product p ON c.Category_ID = p.Category_ID
GROUP BY c.Category_ID, c.Category_Name
HAVING COUNT(p.Product_ID) > 3;

-- Report 5: Find average product price category-wise
SELECT 
    c.Category_Name, 
    ROUND(AVG(p.Price), 2) AS Average_Price,
    MIN(p.Price) AS Min_Price,
    MAX(p.Price) AS Max_Price
FROM Category c
LEFT JOIN Product p ON c.Category_ID = p.Category_ID
GROUP BY c.Category_ID, c.Category_Name;

