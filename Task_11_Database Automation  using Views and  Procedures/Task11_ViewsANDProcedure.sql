-- WEEK 11 - Database Automation using Views and Procedures
-- Target Database: ecoms_db (MySQL 8.0+ / MySQL Workbench)

USE ecoms_db;

-- TASK 1: CREATE VIEWS FOR FREQUENTLY USED REPORTS 

-- 1. Customer Order Report View
-- Displays: Customer Name, Order ID, Order Date, Total Amount, Order Status
DROP VIEW IF EXISTS Customer_Order_Report;

CREATE VIEW Customer_Order_Report AS
SELECT 
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customer c
JOIN Orders o ON c.Customer_ID = o.Customer_ID;

-- 2. Product Sales Report View
-- Displays: Product Name, Quantity Sold, Total Revenue
DROP VIEW IF EXISTS Product_Sales_Report;

CREATE VIEW Product_Sales_Report AS
SELECT 
    p.Product_Name,
    SUM(od.Quantity) AS Quantity_Sold,
    SUM(od.Quantity * od.Price) AS Total_Revenue
FROM Product p
JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name;

-- 3. Payment Status View
-- Displays: Order ID, Payment Mode, Payment Status, Transaction Amount
DROP VIEW IF EXISTS Payment_Status_View;

CREATE VIEW Payment_Status_View AS
SELECT 
    Order_ID,
    Payment_Mode,
    Payment_Status,
    Transaction_Amount
FROM Payment;


-- TASK 2: DEVELOP STORED PROCEDURES FOR ORDER PROCESSING 

-- 1. Add New Customer Order (Insert order details, add products, calculate total)
DROP PROCEDURE IF EXISTS AddNewCustomerOrder;

DELIMITER //
CREATE PROCEDURE AddNewCustomerOrder(
    IN p_Customer_ID INT,
    IN p_Product_ID INT,
    IN p_Quantity INT
)
BEGIN
    DECLARE v_Price DECIMAL(10, 2);
    DECLARE v_Total DECIMAL(10, 2);
    DECLARE v_Order_ID INT;

    SELECT Price INTO v_Price FROM Product WHERE Product_ID = p_Product_ID;
    SET v_Total = v_Price * p_Quantity;

    INSERT INTO Orders (Customer_ID, Order_Date, Total_Amount, Order_Status)
    VALUES (p_Customer_ID, CURRENT_DATE, v_Total, 'Pending');

    SET v_Order_ID = LAST_INSERT_ID();

    INSERT INTO Order_Details (Order_ID, Product_ID, Quantity, Price)
    VALUES (v_Order_ID, p_Product_ID, p_Quantity, v_Price);
END //
DELIMITER ;

-- 2. Update Order Status (Pending -> Shipped -> Delivered)
DROP PROCEDURE IF EXISTS UpdateOrderStatus;

DELIMITER //
CREATE PROCEDURE UpdateOrderStatus(
    IN p_Order_ID INT,
    IN p_New_Status VARCHAR(20)
)
BEGIN
    UPDATE Orders 
    SET Order_Status = p_New_Status 
    WHERE Order_ID = p_Order_ID;
END //
DELIMITER ;

-- 3. Generate Customer Purchase History (Input: Customer_ID)
DROP PROCEDURE IF EXISTS GetCustomerOrders;

DELIMITER //
CREATE PROCEDURE GetCustomerOrders(IN Cust_ID INT)
BEGIN
    SELECT 
        Order_ID,
        Order_Date,
        Total_Amount,
        Order_Status
    FROM Orders
    WHERE Customer_ID = Cust_ID;
END //
DELIMITER ;


-- TASK 3: CREATE FUNCTIONS FOR SALES CALCULATIONS 

-- 1. Calculate Total Sales (Input: Date range -> Output: Total revenue generated)
DROP FUNCTION IF EXISTS CalculateTotalSales;

DELIMITER //
CREATE FUNCTION CalculateTotalSales(p_Start_Date DATE, p_End_Date DATE)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Total_Sales DECIMAL(10, 2);

    SELECT SUM(Total_Amount) INTO v_Total_Sales
    FROM Orders
    WHERE Order_Date BETWEEN p_Start_Date AND p_End_Date;

    RETURN IFNULL(v_Total_Sales, 0.00);
END //
DELIMITER ;

-- 2. Calculate Customer Total Spending (Input: Customer_ID -> Output: Total amount spent)
DROP FUNCTION IF EXISTS CalculateCustomerSpending;

DELIMITER //
CREATE FUNCTION CalculateCustomerSpending(p_Customer_ID INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Customer_Spend DECIMAL(10, 2);

    SELECT SUM(Total_Amount) INTO v_Customer_Spend
    FROM Orders
    WHERE Customer_ID = p_Customer_ID;

    RETURN IFNULL(v_Customer_Spend, 0.00);
END //
DELIMITER ;

-- 3. Calculate Product Revenue (Input: Product_ID -> Output: Total sales amount)
DROP FUNCTION IF EXISTS CalculateProductRevenue;

DELIMITER //
CREATE FUNCTION CalculateProductRevenue(p_Product_ID INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Product_Rev DECIMAL(10, 2);

    SELECT SUM(Quantity * Price) INTO v_Product_Rev
    FROM Order_Details
    WHERE Product_ID = p_Product_ID;

    RETURN IFNULL(v_Product_Rev, 0.00);
END //
DELIMITER ;


-- TASK 4: AUTOMATE REPETITIVE DATABASE OPERATIONS


-- 1. Order Processing Automation
-- (Insert order details, reduce product stock, create payment record, update status)
DROP PROCEDURE IF EXISTS AutomateOrderProcessing;

DELIMITER //
CREATE PROCEDURE AutomateOrderProcessing(
    IN p_Customer_ID INT,
    IN p_Product_ID INT,
    IN p_Quantity INT,
    IN p_Payment_Mode VARCHAR(30)
)
BEGIN
    DECLARE v_Price DECIMAL(10, 2);
    DECLARE v_Total DECIMAL(10, 2);
    DECLARE v_Order_ID INT;

    SELECT Price INTO v_Price FROM Product WHERE Product_ID = p_Product_ID;
    SET v_Total = v_Price * p_Quantity;

    -- 1. Insert order details
    INSERT INTO Orders (Customer_ID, Order_Date, Total_Amount, Order_Status)
    VALUES (p_Customer_ID, CURRENT_DATE, v_Total, 'Pending');
    SET v_Order_ID = LAST_INSERT_ID();

    INSERT INTO Order_Details (Order_ID, Product_ID, Quantity, Price)
    VALUES (v_Order_ID, p_Product_ID, p_Quantity, v_Price);

    -- 2. Reduce product stock
    UPDATE Product 
    SET Stock_Quantity = Stock_Quantity - p_Quantity 
    WHERE Product_ID = p_Product_ID;

    -- 3. Create payment record
    INSERT INTO Payment (Order_ID, Payment_Mode, Payment_Status, Transaction_Amount)
    VALUES (v_Order_ID, p_Payment_Mode, 'Success', v_Total);

    -- 4. Update order status
    UPDATE Orders 
    SET Order_Status = 'Delivered' 
    WHERE Order_ID = v_Order_ID;
END //
DELIMITER ;

-- 2. Inventory Update Automation (Increase stock after new supply, reduce stock, identify low-stock)
DROP PROCEDURE IF EXISTS AutomateInventoryRestock;

DELIMITER //
CREATE PROCEDURE AutomateInventoryRestock(
    IN p_Product_ID INT,
    IN p_New_Supply_Qty INT
)
BEGIN
    -- Increase stock after new supply
    UPDATE Product 
    SET Stock_Quantity = Stock_Quantity + p_New_Supply_Qty 
    WHERE Product_ID = p_Product_ID;

    -- Identify low-stock products
    SELECT Product_Name AS Product, Stock_Quantity AS Stock, 'Low Stock' AS Status
    FROM Product
    WHERE Stock_Quantity < 10;
END //
DELIMITER ;

-- 3. Report Generation Automation (Daily sales, Monthly revenue, Customer purchase report)
DROP PROCEDURE IF EXISTS GenerateAutomatedReports;

DELIMITER //
CREATE PROCEDURE GenerateAutomatedReports(IN p_Target_Date DATE)
BEGIN
    -- Daily sales report
    SELECT Order_Date, COUNT(Order_ID) AS Total_Orders, SUM(Total_Amount) AS Daily_Sales
    FROM Orders
    WHERE Order_Date = p_Target_Date
    GROUP BY Order_Date;

    -- Monthly revenue report
    SELECT YEAR(Order_Date) AS Year, MONTH(Order_Date) AS Month, SUM(Total_Amount) AS Monthly_Revenue
    FROM Orders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date);

    -- Customer purchase report
    SELECT Customer_Name AS Customer, COUNT(Order_ID) AS Orders, SUM(Total_Amount) AS Amount
    FROM Customer
    JOIN Orders ON Customer.Customer_ID = Orders.Customer_ID
    GROUP BY Customer.Customer_ID, Customer.Customer_Name;
END //
DELIMITER ;


-- TASK 5: TEST DATABASE OBJECTS & EXPECTED REPORTS

-- 1. Test Views
SELECT * FROM Customer_Order_Report;
SELECT * FROM Product_Sales_Report;
SELECT * FROM Payment_Status_View;

-- 2. Test Stored Procedures
CALL AddNewCustomerOrder(1, 2, 2);
CALL UpdateOrderStatus(1, 'Delivered');
CALL GetCustomerOrders(1);
CALL AutomateOrderProcessing(2, 3, 1, 'UPI');
CALL AutomateInventoryRestock(2, 10);
CALL GenerateAutomatedReports(CURRENT_DATE);

-- 3. Test Functions
SELECT CalculateTotalSales('2026-01-01', '2026-12-31') AS Total_Sales;
SELECT CalculateCustomerSpending(1) AS Customer_Total_Spending;
SELECT CalculateProductRevenue(1) AS Product_Total_Revenue;

-- 4. Expected Reports
-- Report 1: Customer Purchase Report
SELECT 
    c.Customer_Name AS Customer,
    COUNT(o.Order_ID) AS Orders,
    SUM(o.Total_Amount) AS Amount
FROM Customer c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;

-- Report 2: Sales Report
SELECT * FROM Product_Sales_Report;

-- Report 3: Inventory Report
SELECT 
    Product_Name AS Product,
    Stock_Quantity AS Stock,
    CASE WHEN Stock_Quantity < 10 THEN 'Low Stock' ELSE 'Available' END AS Status
FROM Product;