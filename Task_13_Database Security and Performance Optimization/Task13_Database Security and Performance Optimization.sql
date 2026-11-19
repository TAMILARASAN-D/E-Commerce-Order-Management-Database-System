-- WEEK 13 Database Security and Performance Optimization 

USE ecoms_db;

-- TASK 1: CREATE DATABASE USERS AND ROLES
-- Users: Admin User, Sales User, Inventory User, Customer Support User

-- Clean up existing users and roles for clean execution
DROP USER IF EXISTS 'admin_user'@'localhost';
DROP USER IF EXISTS 'sales_user'@'localhost';
DROP USER IF EXISTS 'inventory_user'@'localhost';
DROP USER IF EXISTS 'support_user'@'localhost';

DROP ROLE IF EXISTS role_admin;
DROP ROLE IF EXISTS role_sales;
DROP ROLE IF EXISTS role_inventory;
DROP ROLE IF EXISTS role_support;

-- Create Roles
CREATE ROLE role_admin;
CREATE ROLE role_sales;
CREATE ROLE role_inventory;
CREATE ROLE role_support;

-- Create Users
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin@Pass123';
CREATE USER 'sales_user'@'localhost' IDENTIFIED BY 'Sales@Pass123';
CREATE USER 'inventory_user'@'localhost' IDENTIFIED BY 'Inv@Pass123';
CREATE USER 'support_user'@'localhost' IDENTIFIED BY 'Supp@Pass123';


-- TASK 2 & TASK 3: IMPLEMENT GRANT, REVOKE & APPLY ACCESS CONTROL 

-- 1. Admin Role: Full Access (Create tables, modify structure, manage users)
GRANT ALL PRIVILEGES ON ecoms_db.* TO role_admin WITH GRANT OPTION;

-- 2. Sales Role: View Orders & Reports
GRANT SELECT ON ecoms_db.Orders TO role_sales;
GRANT SELECT ON ecoms_db.Order_Details TO role_sales;
GRANT SELECT ON ecoms_db.Product TO role_sales;

-- 3. Inventory Role: View and Update Product Stock
GRANT SELECT, UPDATE (Stock_Quantity) ON ecoms_db.Product TO role_inventory;
GRANT SELECT, UPDATE (Stock_Quantity, Stock_Status) ON ecoms_db.Inventory TO role_inventory;

-- 4. Customer Support Role: View Customer and Order Details
GRANT SELECT ON ecoms_db.Customer TO role_support;
GRANT SELECT ON ecoms_db.Orders TO role_support;

-- Assign Roles to Users and Set Default Roles
GRANT role_admin TO 'admin_user'@'localhost';
GRANT role_sales TO 'sales_user'@'localhost';
GRANT role_inventory TO 'inventory_user'@'localhost';
GRANT role_support TO 'support_user'@'localhost';

SET DEFAULT ROLE role_admin TO 'admin_user'@'localhost';
SET DEFAULT ROLE role_sales TO 'sales_user'@'localhost';
SET DEFAULT ROLE role_inventory TO 'inventory_user'@'localhost';
SET DEFAULT ROLE role_support TO 'support_user'@'localhost';

-- Demonstrate GRANT & REVOKE explicitly on sales_user 
GRANT SELECT ON Orders TO 'sales_user'@'localhost';
GRANT INSERT ON Payment TO 'sales_user'@'localhost';
REVOKE INSERT ON Payment FROM 'sales_user'@'localhost';

FLUSH PRIVILEGES;

-- Verify Access Control & Permissions
SHOW GRANTS FOR 'admin_user'@'localhost';
SHOW GRANTS FOR 'sales_user'@'localhost';
SHOW GRANTS FOR 'inventory_user'@'localhost';
SHOW GRANTS FOR 'support_user'@'localhost';


-- TASK 4: CREATE INDEXES FOR FASTER SEARCHING

-- Safe cleanup helper (works cleanly in all MySQL 8.0+ versions)
DROP PROCEDURE IF EXISTS SafeDropIndex;
DELIMITER //
CREATE PROCEDURE SafeDropIndex(IN tblName VARCHAR(64), IN idxName VARCHAR(64))
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = tblName
          AND index_name = idxName
    ) THEN
        SET @sql = CONCAT('DROP INDEX ', idxName, ' ON ', tblName);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END //
DELIMITER ;

-- Drop existing indexes safely before recreating
CALL SafeDropIndex('Product', 'idx_product_name');
CALL SafeDropIndex('Product', 'idx_product_category');
CALL SafeDropIndex('Customer', 'idx_customer_email');
CALL SafeDropIndex('Customer', 'idx_customer_phone');
CALL SafeDropIndex('Orders', 'idx_order_date');
CALL SafeDropIndex('Orders', 'idx_order_customer');
DROP PROCEDURE IF EXISTS SafeDropIndex;

-- 1. Product Search Indexes
CREATE INDEX idx_product_name ON Product(Product_Name);
CREATE INDEX idx_product_category ON Product(Category_ID);

-- 2. Customer Search Indexes
CREATE INDEX idx_customer_email ON Customer(Email);
CREATE INDEX idx_customer_phone ON Customer(Phone);

-- 3. Order Search Indexes
CREATE INDEX idx_order_date ON Orders(Order_Date);
CREATE INDEX idx_order_customer ON Orders(Customer_ID);

-- TASK 5: ANALYZE AND OPTIMIZE QUERY PERFORMANCE

-- Sample Execution Plan Check
EXPLAIN SELECT * FROM Product WHERE Product_Name = 'Laptop';

-- Query 1: Search products by category
EXPLAIN SELECT Product_ID, Product_Name, Price, Stock_Quantity
FROM Product
WHERE Category_ID = 1;

-- Query 2: Retrieve customer order history
EXPLAIN SELECT Order_ID, Order_Date, Total_Amount, Order_Status
FROM Orders
WHERE Customer_ID = 101
ORDER BY Order_Date DESC;

-- Query 3: Generate sales reports
EXPLAIN SELECT Order_Date, COUNT(Order_ID) AS Total_Orders, SUM(Total_Amount) AS Daily_Revenue
FROM Orders
WHERE Order_Date BETWEEN '2026-01-01' AND '2026-12-31'
GROUP BY Order_Date;

-- Query 4: Find top-selling products
EXPLAIN SELECT p.Product_Name, SUM(od.Quantity) AS Total_Sold
FROM Product p
JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Sold DESC;

-- SECURITY & PERFORMANCE REPORTS

-- Report 1: User Access Report
SELECT User, Host, account_locked AS Account_Locked
FROM mysql.user
WHERE User IN ('admin_user', 'sales_user', 'inventory_user', 'support_user');

-- Report 2: Query Performance / Index Verification Report
SHOW INDEX FROM Product;
SHOW INDEX FROM Customer;
SHOW INDEX FROM Orders;

-- Report 3: Database Security Report
SELECT GRANTEE AS User_Account, TABLE_NAME AS Table_Name, PRIVILEGE_TYPE AS Granted_Privilege
FROM information_schema.TABLE_PRIVILEGES
WHERE GRANTEE LIKE '%sales_user%'
   OR GRANTEE LIKE '%inventory_user%'
   OR GRANTEE LIKE '%support_user%';