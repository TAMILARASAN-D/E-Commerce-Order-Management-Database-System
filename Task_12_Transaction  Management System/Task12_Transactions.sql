-- WEEK 12 Transaction Management System 
-- Target Database: ecoms_db (MySQL 8.0+ / MySQL Workbench - InnoDB)

USE ecoms_db;

-- TASK 1 & 2: ORDER PLACEMENT TRANSACTION & COMMIT OPERATION
-- Scenario: "A customer purchases a laptop and makes payment using UPI."
-- Operations: Insert order, insert ordered products, reduce stock,
--             insert payment details, update order status, and COMMIT.

-- Check initial stock before transaction
SELECT Product_ID, Product_Name, Price, Stock_Quantity 
FROM Product 
WHERE Product_ID = 1;

START TRANSACTION;

-- 1. Insert order details
INSERT INTO Orders (Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES (1, '2026-07-22', 54000.00, 'Pending');

SET @Order_ID = LAST_INSERT_ID();

-- 2. Insert ordered products
INSERT INTO Order_Details (Order_ID, Product_ID, Quantity, Price)
VALUES (@Order_ID, 1, 1, 54000.00);

-- 3. Reduce inventory stock
UPDATE Product 
SET Stock_Quantity = Stock_Quantity - 1 
WHERE Product_ID = 1 AND Stock_Quantity >= 1;

-- 4. Insert payment details
INSERT INTO Payment (Order_ID, Payment_Mode, Payment_Status, Transaction_Amount)
VALUES (@Order_ID, 'UPI', 'Success', 54000.00);

-- 5. Update order status as Completed ('Delivered' in schema ENUM)
UPDATE Orders 
SET Order_Status = 'Delivered' 
WHERE Order_ID = @Order_ID;

-- Apply COMMIT to permanently save all changes
COMMIT;

-- Verify committed state (Durability & Consistency)
SELECT Product_ID, Product_Name, Stock_Quantity FROM Product WHERE Product_ID = 1;
SELECT * FROM Orders WHERE Order_ID = @Order_ID;
SELECT * FROM Payment WHERE Order_ID = @Order_ID;


-- TASK 2 & 4 (SCENARIO 2): FAILED ORDER & ROLLBACK OPERATION 
-- Scenario: Customer places an order, stock is reduced, payment fails -> ROLLBACK

-- Check initial stock of Product 2 before failed transaction
SELECT Product_ID, Product_Name, Stock_Quantity 
FROM Product 
WHERE Product_ID = 2;

START TRANSACTION;

-- 1. Create temporary order
INSERT INTO Orders (Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES (2, CURRENT_DATE, 800.00, 'Pending');

SET @Failed_Order_ID = LAST_INSERT_ID();

INSERT INTO Order_Details (Order_ID, Product_ID, Quantity, Price)
VALUES (@Failed_Order_ID, 2, 1, 800.00);

-- 2. Reduce stock
UPDATE Product 
SET Stock_Quantity = Stock_Quantity - 1 
WHERE Product_ID = 2;

-- 3. Payment fails
INSERT INTO Payment (Order_ID, Payment_Mode, Payment_Status, Transaction_Amount)
VALUES (@Failed_Order_ID, 'Net Banking', 'Failed', 800.00);

-- 4. Cancel order insertion, restore stock, remove incomplete payment via ROLLBACK
ROLLBACK;

-- Verify Atomicity (Must return Empty set for Orders & Payment, and original stock)
SELECT * FROM Orders WHERE Order_ID = @Failed_Order_ID;
SELECT * FROM Payment WHERE Order_ID = @Failed_Order_ID;
SELECT Product_ID, Product_Name, Stock_Quantity FROM Product WHERE Product_ID = 2;


-- TASK 3: DEMONSTRATE ACID PROPERTIES

-- A - Atomicity & D - Durability: Verified via InnoDB engine and COMMIT/ROLLBACK above
SHOW TABLE STATUS WHERE Name IN ('Orders', 'Order_Details', 'Product', 'Payment');

-- C - Consistency: Verify CHECK constraint prevents negative stock
-- (Attempting to set negative stock is blocked by chk_product_stock)
SELECT Product_ID, Product_Name, Stock_Quantity 
FROM Product 
WHERE Stock_Quantity < 0;

-- I - Isolation: Verify active transaction isolation level (REPEATABLE-READ)
SELECT @@GLOBAL.transaction_isolation AS Global_Isolation,
       @@SESSION.transaction_isolation AS Session_Isolation;


-- TASK 5: ENSURE DATABASE CONSISTENCY (5 Verification Queries)

-- 1. Orders should have valid customer IDs
SELECT o.Order_ID, o.Customer_ID 
FROM Orders o
LEFT JOIN Customer c ON o.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

-- 2. Payments should have valid order IDs
SELECT p.Payment_ID, p.Order_ID 
FROM Payment p
LEFT JOIN Orders o ON p.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;

-- 3. Stock quantity should not become negative
SELECT Product_ID, Product_Name, Stock_Quantity 
FROM Product 
WHERE Stock_Quantity < 0;

-- 4. Completed orders should have successful payments
SELECT o.Order_ID, o.Order_Status, p.Payment_Status 
FROM Orders o
LEFT JOIN Payment p ON o.Order_ID = p.Order_ID
WHERE o.Order_Status = 'Delivered' 
  AND (p.Payment_Status IS NULL OR p.Payment_Status != 'Success');

-- 5. Cancelled orders should not reduce inventory (Audit check)
SELECT Order_ID, Customer_ID, Total_Amount, Order_Status 
FROM Orders 
WHERE Order_Status = 'Cancelled';


-- GENERATE TRANSACTION REPORTS

-- Report 1: Order Transaction Report
-- Display: Order ID, Customer Name, Amount, Payment Status, Order Status
SELECT 
    o.Order_ID,
    c.Customer_Name,
    o.Total_Amount AS Amount,
    COALESCE(p.Payment_Status, 'Unpaid') AS Payment_Status,
    o.Order_Status
FROM Orders o
INNER JOIN Customer c ON o.Customer_ID = c.Customer_ID
LEFT JOIN Payment p ON o.Order_ID = p.Order_ID
ORDER BY o.Order_ID DESC;

-- Report 2: Failed Transaction Report
-- Display: Failed payments, Cancelled orders, Stock restoration details
SELECT 
    o.Order_ID,
    c.Customer_Name,
    o.Total_Amount,
    o.Order_Status,
    COALESCE(p.Payment_Status, 'Rolled Back / No Record') AS Payment_Status,
    'Stock Restored via ROLLBACK' AS Stock_Restoration_Status
FROM Orders o
INNER JOIN Customer c ON o.Customer_ID = c.Customer_ID
LEFT JOIN Payment p ON o.Order_ID = p.Order_ID
WHERE o.Order_Status = 'Cancelled' OR p.Payment_Status = 'Failed';

-- Report 3: Inventory Update Report
-- Display: Product name, Previous stock, Current stock, Quantity sold
SELECT 
    p.Product_Name,
    (p.Stock_Quantity + COALESCE(SUM(od.Quantity), 0)) AS Previous_Stock,
    p.Stock_Quantity AS Current_Stock,
    COALESCE(SUM(od.Quantity), 0) AS Quantity_Sold
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Stock_Quantity
ORDER BY Quantity_Sold DESC;