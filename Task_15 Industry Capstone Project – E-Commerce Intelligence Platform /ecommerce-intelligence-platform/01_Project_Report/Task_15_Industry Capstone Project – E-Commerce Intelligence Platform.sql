-- WEEK 15: INDUSTRY CAPSTONE PROJECT - E-COMMERCE INTELLIGENCE PLATFORM

-- TASK 1 & 2: UNIFIED NORMALIZED SCHEMA (3NF) & MODULE INTEGRATION 

DROP DATABASE IF EXISTS ecommerce_capstone_platform;
CREATE DATABASE ecommerce_capstone_platform;
USE ecommerce_capstone_platform;

-- 1. Customer Module
CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(120) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(60) NOT NULL,
    Registration_Date DATE NOT NULL
);

-- 2. Category Module
CREATE TABLE Category (
    Category_ID INT PRIMARY KEY AUTO_INCREMENT,
    Category_Name VARCHAR(80) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

-- 3. Product Module
CREATE TABLE Product (
    Product_ID INT PRIMARY KEY AUTO_INCREMENT,
    Product_Name VARCHAR(120) NOT NULL,
    Category_ID INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL CHECK (Price > 0),
    Stock_Quantity INT NOT NULL DEFAULT 0 CHECK (Stock_Quantity >= 0),
    FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID)
);

-- 4. Seller Module
CREATE TABLE Seller (
    Seller_ID INT PRIMARY KEY AUTO_INCREMENT,
    Seller_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(120) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL,
    Address VARCHAR(255) NOT NULL
);

-- 5. Inventory Module
CREATE TABLE Inventory (
    Inventory_ID INT PRIMARY KEY AUTO_INCREMENT,
    Product_ID INT NOT NULL,
    Seller_ID INT NOT NULL,
    Stock_Quantity INT NOT NULL CHECK (Stock_Quantity >= 0),
    Stock_Status VARCHAR(30) NOT NULL,
    Last_Updated DATE NOT NULL,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
    FOREIGN KEY (Seller_ID) REFERENCES Seller(Seller_ID)
);

-- 6. Orders Module
CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(12, 2) NOT NULL DEFAULT 0 CHECK (Total_Amount >= 0),
    Order_Status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- 7. Order_Details Module (Resolves Many-to-Many Orders-Product in 3NF)
CREATE TABLE Order_Details (
    Order_Detail_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10, 2) NOT NULL CHECK (Price > 0),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- 8. Payment Module
CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL UNIQUE,
    Payment_Date DATE NOT NULL,
    Payment_Mode VARCHAR(30) NOT NULL,
    Payment_Status VARCHAR(30) NOT NULL,
    Transaction_Amount DECIMAL(12, 2) NOT NULL CHECK (Transaction_Amount > 0),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
);

-- 9. Review Module
CREATE TABLE Review (
    Review_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Review_Text VARCHAR(255),
    Review_Date DATE NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- 10. Audit_Log Table (Supports Trigger #3: Maintain audit records)
CREATE TABLE Audit_Log (
    Audit_ID INT PRIMARY KEY AUTO_INCREMENT,
    Table_Name VARCHAR(50) NOT NULL,
    Action_Type VARCHAR(30) NOT NULL,
    Record_ID INT NOT NULL,
    Details VARCHAR(255),
    Logged_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- TASK 3: INSERT REALISTIC BUSINESS DATA (Minimum Record Counts - Page 55)
-- Customer: 50 | Product: 100 | Seller: 20 | Orders: 100 | Payments: 100 | Reviews: 50
-- ============================================================================
INSERT INTO Category (Category_Name, Description) VALUES
('Electronics', 'Laptops, Smartphones, and Gadgets'),
('Clothing', 'Men and Women Apparel and Footwear'),
('Books', 'Academic, Technical, and Fiction Books'),
('Home Appliances', 'Kitchen and Home Electronics'),
('Accessories', 'Computer Peripherals and Mobile Gear');

DELIMITER //
CREATE PROCEDURE PopulateCapstoneData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_cust_id INT;
    DECLARE v_prod_id INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_qty INT;
    DECLARE v_order_id INT;
    DECLARE v_city VARCHAR(50);
    DECLARE v_mode VARCHAR(30);
    DECLARE v_status VARCHAR(30);

    -- 1. Insert 50 Customers
    SET i = 1;
    WHILE i <= 50 DO
        SET v_city = ELT((i % 5) + 1, 'Chennai', 'Bangalore', 'Mumbai', 'Delhi', 'Hyderabad');
        INSERT INTO Customer (Customer_Name, Email, Phone, Address, City, Registration_Date)
        VALUES (
            CONCAT('Customer_', i),
            CONCAT('customer', i, '@ecommerce.in'),
            CONCAT('98400', LPAD(i, 5, '0')),
            CONCAT(i, ', MG Road, ', v_city),
            v_city,
            DATE_SUB('2026-10-01', INTERVAL (i * 5) DAY)
        );
        SET i = i + 1;
    END WHILE;

    -- 2. Insert 20 Sellers
    SET i = 1;
    WHILE i <= 20 DO
        SET v_city = ELT((i % 5) + 1, 'Chennai', 'Bangalore', 'Mumbai', 'Pune', 'Coimbatore');
        INSERT INTO Seller (Seller_Name, Email, Phone, Address)
        VALUES (
            CONCAT('Enterprise_Seller_', i),
            CONCAT('seller', i, '@suppliers.in'),
            CONCAT('99400', LPAD(i, 5, '0')),
            CONCAT('Industrial Estate Plot ', i, ', ', v_city)
        );
        SET i = i + 1;
    END WHILE;

    -- 3. Insert 100 Products & Corresponding Inventory Records
    SET i = 1;
    WHILE i <= 100 DO
        INSERT INTO Product (Product_Name, Category_ID, Price, Stock_Quantity)
        VALUES (
            CONCAT(ELT((i % 5) + 1, 'Pro Laptop ', 'Running Shoes ', 'Data Science Guide ', 'Smart Microwave ', 'Wireless Mouse '), i),
            (i % 5) + 1,
            500.00 + (i * 450.00),
            (i % 45) + 5
        );
        SET v_prod_id = LAST_INSERT_ID();

        INSERT INTO Inventory (Product_ID, Seller_ID, Stock_Quantity, Stock_Status, Last_Updated)
        VALUES (
            v_prod_id,
            (i % 20) + 1,
            (i % 45) + 5,
            IF(((i % 45) + 5) > 0, 'Available', 'Out of Stock'),
            '2026-11-01'
        );
        SET i = i + 1;
    END WHILE;

    -- 4. Insert 100 Orders, 100 Order_Details, and 100 Payments
    SET i = 1;
    WHILE i <= 100 DO
        SET v_cust_id = (i % 50) + 1;
        SET v_prod_id = (i % 100) + 1;
        SET v_qty = (i % 3) + 1;
        SELECT Price INTO v_price FROM Product WHERE Product_ID = v_prod_id;

        INSERT INTO Orders (Customer_ID, Order_Date, Total_Amount, Order_Status)
        VALUES (
            v_cust_id,
            DATE_SUB('2026-11-15', INTERVAL (i % 90) DAY),
            v_price * v_qty,
            ELT((i % 3) + 1, 'Delivered', 'Shipped', 'Pending')
        );
        SET v_order_id = LAST_INSERT_ID();

        INSERT INTO Order_Details (Order_ID, Product_ID, Quantity, Price)
        VALUES (v_order_id, v_prod_id, v_qty, v_price);

        SET v_mode = ELT((i % 4) + 1, 'UPI', 'Credit Card', 'Net Banking', 'Debit Card');
        SET v_status = IF(i % 10 = 0, 'Failed', 'Success');

        INSERT INTO Payment (Order_ID, Payment_Date, Payment_Mode, Payment_Status, Transaction_Amount)
        VALUES (
            v_order_id,
            DATE_SUB('2026-11-15', INTERVAL (i % 90) DAY),
            v_mode,
            v_status,
            v_price * v_qty
        );
        SET i = i + 1;
    END WHILE;

    -- 5. Insert 50 Reviews
    SET i = 1;
    WHILE i <= 50 DO
        INSERT INTO Review (Customer_ID, Product_ID, Rating, Review_Text, Review_Date)
        VALUES (
            i,
            (i * 2) % 100 + 1,
            (i % 5) + 1,
            ELT((i % 5) + 1, 'Average quality', 'Good value for money', 'Very satisfied with performance', 'Excellent build and fast delivery', 'Needs improvement'),
            DATE_SUB('2026-11-15', INTERVAL (i % 30) DAY)
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL PopulateCapstoneData();
DROP PROCEDURE PopulateCapstoneData;

-- Verify Minimum Record Counts (Page 55)
SELECT 'Customer' AS Table_Name, COUNT(*) AS Record_Count FROM Customer
UNION ALL SELECT 'Product', COUNT(*) FROM Product
UNION ALL SELECT 'Seller', COUNT(*) FROM Seller
UNION ALL SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL SELECT 'Payment', COUNT(*) FROM Payment
UNION ALL SELECT 'Review', COUNT(*) FROM Review;


-- ============================================================================
-- TASK 5: DEVELOP DATABASE OBJECTS (Views, Procedures, Functions, Triggers - Page 56)
-- ============================================================================

-- 5A. VIEWS (Customer order history, Sales reports, Product performance)
CREATE VIEW View_Customer_Order_History AS
SELECT c.Customer_ID, c.Customer_Name, c.City, o.Order_ID, o.Order_Date, o.Total_Amount, o.Order_Status
FROM Customer c
JOIN Orders o ON c.Customer_ID = o.Customer_ID;

CREATE VIEW View_Sales_Report AS
SELECT DATE_FORMAT(o.Order_Date, '%Y-%m') AS Sales_Month,
       COUNT(o.Order_ID) AS Total_Orders,
       SUM(o.Total_Amount) AS Total_Revenue
FROM Orders o
GROUP BY DATE_FORMAT(o.Order_Date, '%Y-%m');

CREATE VIEW View_Product_Performance AS
SELECT p.Product_ID, p.Product_Name, c.Category_Name,
       COALESCE(SUM(od.Quantity), 0) AS Total_Units_Sold,
       COALESCE(SUM(od.Quantity * od.Price), 0) AS Total_Revenue,
       ROUND(COALESCE(AVG(r.Rating), 0), 2) AS Avg_Rating
FROM Product p
JOIN Category c ON p.Category_ID = c.Category_ID
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
LEFT JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name, c.Category_Name;

-- 5B. FUNCTIONS (Total customer spending, Product revenue calculation)
DELIMITER //
CREATE FUNCTION Fn_TotalCustomerSpending(p_CustID INT)
RETURNS DECIMAL(12, 2)
DETERMINISTIC
BEGIN
    DECLARE v_Total DECIMAL(12, 2);
    SELECT COALESCE(SUM(Total_Amount), 0.00) INTO v_Total
    FROM Orders
    WHERE Customer_ID = p_CustID;
    RETURN v_Total;
END //

CREATE FUNCTION Fn_ProductRevenue(p_ProdID INT)
RETURNS DECIMAL(12, 2)
DETERMINISTIC
BEGIN
    DECLARE v_Rev DECIMAL(12, 2);
    SELECT COALESCE(SUM(Quantity * Price), 0.00) INTO v_Rev
    FROM Order_Details
    WHERE Product_ID = p_ProdID;
    RETURN v_Rev;
END //
DELIMITER ;

-- 5C. STORED PROCEDURES (Order placement, Stock update, Sales calculation)
DELIMITER //
CREATE PROCEDURE Sp_PlaceOrder(
    IN p_CustomerID INT,
    IN p_ProductID INT,
    IN p_Quantity INT
)
BEGIN
    DECLARE v_UnitPrice DECIMAL(10, 2);
    DECLARE v_NewOrderID INT;

    SELECT Price INTO v_UnitPrice FROM Product WHERE Product_ID = p_ProductID;

    INSERT INTO Orders (Customer_ID, Order_Date, Total_Amount, Order_Status)
    VALUES (p_CustomerID, CURDATE(), v_UnitPrice * p_Quantity, 'Pending');
    SET v_NewOrderID = LAST_INSERT_ID();

    INSERT INTO Order_Details (Order_ID, Product_ID, Quantity, Price)
    VALUES (v_NewOrderID, p_ProductID, p_Quantity, v_UnitPrice);
END //

CREATE PROCEDURE Sp_UpdateStock(
    IN p_ProductID INT,
    IN p_AddedQty INT
)
BEGIN
    UPDATE Product
    SET Stock_Quantity = Stock_Quantity + p_AddedQty
    WHERE Product_ID = p_ProductID;

    UPDATE Inventory
    SET Stock_Quantity = Stock_Quantity + p_AddedQty,
        Stock_Status = 'Available',
        Last_Updated = CURDATE()
    WHERE Product_ID = p_ProductID;
END //

CREATE PROCEDURE Sp_CalculateSales(
    IN p_StartDate DATE,
    IN p_EndDate DATE
)
BEGIN
    SELECT COUNT(Order_ID) AS Orders_Count,
           COALESCE(SUM(Total_Amount), 0) AS Total_Sales_Revenue
    FROM Orders
    WHERE Order_Date BETWEEN p_StartDate AND p_EndDate;
END //
DELIMITER ;

-- 5D. TRIGGERS (1. Reduce stock after order, 2. Update order status after payment, 3. Maintain audit records)
DELIMITER //
CREATE TRIGGER Trg_ReduceStockAfterOrder
AFTER INSERT ON Order_Details
FOR EACH ROW
BEGIN
    UPDATE Product
    SET Stock_Quantity = Stock_Quantity - NEW.Quantity
    WHERE Product_ID = NEW.Product_ID;

    UPDATE Inventory
    SET Stock_Quantity = Stock_Quantity - NEW.Quantity,
        Stock_Status = IF((Stock_Quantity - NEW.Quantity) > 0, 'Available', 'Out of Stock'),
        Last_Updated = CURDATE()
    WHERE Product_ID = NEW.Product_ID;

    INSERT INTO Audit_Log (Table_Name, Action_Type, Record_ID, Details)
    VALUES ('Order_Details', 'STOCK_REDUCED', NEW.Product_ID, CONCAT('Reduced stock by ', NEW.Quantity, ' for Order ', NEW.Order_ID));
END //

CREATE TRIGGER Trg_UpdateOrderStatusAfterPayment
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    IF NEW.Payment_Status = 'Success' THEN
        UPDATE Orders
        SET Order_Status = 'Confirmed'
        WHERE Order_ID = NEW.Order_ID;
    ELSE
        UPDATE Orders
        SET Order_Status = 'Payment Failed'
        WHERE Order_ID = NEW.Order_ID;
    END IF;

    INSERT INTO Audit_Log (Table_Name, Action_Type, Record_ID, Details)
    VALUES ('Payment', 'PAYMENT_PROCESSED', NEW.Payment_ID, CONCAT('Order ', NEW.Order_ID, ' status updated via payment trigger'));
END //
DELIMITER ;

-- Test Capstone Automation (Error-Free Session Variable Capture)
CALL Sp_PlaceOrder(1, 1, 2);

SET @NewOrderID = (SELECT MAX(Order_ID) FROM Orders WHERE Customer_ID = 1);
SET @OrderAmt = (SELECT Total_Amount FROM Orders WHERE Order_ID = @NewOrderID);

INSERT INTO Payment (Order_ID, Payment_Date, Payment_Mode, Payment_Status, Transaction_Amount)
VALUES (@NewOrderID, CURDATE(), 'UPI', 'Success', @OrderAmt);

CALL Sp_UpdateStock(1, 10);
CALL Sp_CalculateSales('2026-01-01', '2026-12-31');
SELECT Fn_TotalCustomerSpending(1) AS Customer_1_Spending, Fn_ProductRevenue(1) AS Product_1_Revenue;
SELECT * FROM Audit_Log;


-- ============================================================================
-- TASK 6: IMPLEMENT PERFORMANCE OPTIMIZATION (Indexes & EXPLAIN - Page 56)
-- ============================================================================
CREATE INDEX idx_capstone_product_search ON Product(Product_Name, Category_ID);
CREATE INDEX idx_capstone_customer_lookup ON Customer(Email, City);
CREATE INDEX idx_capstone_order_retrieval ON Orders(Customer_ID, Order_Date);

EXPLAIN SELECT * FROM Product WHERE Product_Name LIKE 'Pro Laptop%' AND Category_ID = 1;
EXPLAIN SELECT * FROM Customer WHERE Email = 'customer1@ecommerce.in';
EXPLAIN SELECT * FROM Orders WHERE Customer_ID = 1 ORDER BY Order_Date DESC;


-- ============================================================================
-- TASK 4 & 7: SQL QUERIES & 4 BUSINESS INTELLIGENCE REPORTS (Pages 55-57)
-- ============================================================================

-- Task 4 Verification: Basic, Intermediate & Advanced Queries (Including Nested Query)
SELECT DISTINCT City FROM Customer ORDER BY City;

SELECT Product_Name, Price FROM Product
WHERE Price BETWEEN 5000 AND 25000 AND Product_Name LIKE '%Laptop%'
ORDER BY Price DESC;

SELECT Customer_ID, Customer_Name
FROM Customer
WHERE Customer_ID IN (
    SELECT Customer_ID
    FROM Orders
    WHERE Order_ID IN (
        SELECT Order_ID
        FROM Order_Details
        WHERE Product_ID = (SELECT Product_ID FROM Product ORDER BY Price DESC LIMIT 1)
    )
);

-- 1. Sales Intelligence Report (Total revenue, monthly trend, best-selling products, top categories)
SELECT * FROM View_Sales_Report ORDER BY Sales_Month;

SELECT c.Category_Name,
       SUM(od.Quantity) AS Units_Sold,
       SUM(od.Quantity * od.Price) AS Category_Revenue,
       RANK() OVER (ORDER BY SUM(od.Quantity * od.Price) DESC) AS Category_Rank
FROM Category c
JOIN Product p ON c.Category_ID = p.Category_ID
JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID, c.Category_Name;

-- 2. Customer Intelligence Report (High-value customers, frequency, segmentation)
SELECT c.Customer_ID,
       c.Customer_Name,
       COUNT(o.Order_ID) AS Purchase_Frequency,
       COALESCE(SUM(o.Total_Amount), 0) AS Total_Spent,
       CASE
           WHEN COALESCE(SUM(o.Total_Amount), 0) >= 50000 THEN 'High-Value'
           WHEN COALESCE(SUM(o.Total_Amount), 0) >= 20000 THEN 'Regular'
           ELSE 'Standard'
       END AS Customer_Segment
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
HAVING Total_Spent > (SELECT AVG(Total_Amount) FROM Orders)
ORDER BY Total_Spent DESC;

-- 3. Inventory Intelligence Report (Low-stock, fast-moving, overstocked products)
SELECT p.Product_ID,
       p.Product_Name,
       p.Stock_Quantity,
       COALESCE(SUM(od.Quantity), 0) AS Total_Sold,
       CASE
           WHEN p.Stock_Quantity < 10 THEN 'Low-Stock'
           WHEN COALESCE(SUM(od.Quantity), 0) >= 4 THEN 'Fast-Moving'
           WHEN p.Stock_Quantity > 40 THEN 'Overstocked'
           ELSE 'Optimal'
       END AS Inventory_Classification
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Stock_Quantity;

-- 4. Product Intelligence Report (Highest-rated, poor-performing, customer feedback trends)
SELECT p.Product_Name,
       ROUND(AVG(r.Rating), 2) AS Average_Rating,
       COUNT(r.Review_ID) AS Total_Reviews,
       CASE
           WHEN AVG(r.Rating) >= 4.0 THEN 'Highest-Rated'
           WHEN AVG(r.Rating) < 2.5 THEN 'Poor-Performing'
           ELSE 'Average-Performing'
       END AS Product_Feedback_Status
FROM Product p
JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Average_Rating DESC;