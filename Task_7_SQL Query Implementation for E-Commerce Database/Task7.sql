-- Week 7: SQL Query Implementation for E-Commerce Database

-- 1. Basic SQL Data Retrieval (SELECT)
-- 1.1 Display All Customer Details
SELECT 
    Customer_ID,
    Customer_Name,
    Email,
    Phone,
    Address,
    City,
    Registration_Date
FROM Customer;

-- 1.2 Display All Available Products
SELECT 
    Product_ID,
    Product_Name,
    Price,
    Stock_Quantity
FROM Product
WHERE Stock_Quantity > 0;

-- 1.3 Retrieve Product Names and Prices Only
SELECT 
    Product_Name,
    Price
FROM Product;

-- 1.4 Display All Orders Placed by Customers
SELECT 
    Order_ID,
    Customer_ID,
    Order_Date,
    Total_Amount,
    Order_Status
FROM Orders;

-- 1.5 Retrieve Payment Transaction Details
SELECT 
    Payment_ID,
    Order_ID,
    Payment_Date,
    Payment_Mode,
    Payment_Status,
    Transaction_Amount
FROM Payment;


-- 2. Filtering Records Using WHERE

-- 2.1 Find Products with Price Greater than ₹5,000
SELECT 
    Product_ID,
    Product_Name,
    Price
FROM Product
WHERE Price > 5000.00;

-- 2.2 Display Products Available in Stock
SELECT 
    Product_ID,
    Product_Name,
    Stock_Quantity
FROM Product
WHERE Stock_Quantity > 0;

-- 2.3 Find Customers from a Particular City (e.g., Chennai)
SELECT 
    Customer_ID,
    Customer_Name,
    Email,
    Phone,
    City
FROM Customer
WHERE City = 'Chennai';

-- 2.4 Display Completed Orders (Delivered)
SELECT 
    Order_ID,
    Customer_ID,
    Order_Date,
    Total_Amount,
    Order_Status
FROM Orders
WHERE Order_Status = 'Delivered';

-- 2.5 Find Products with Rating Above 4.0
SELECT 
    p.Product_ID,
    p.Product_Name,
    ROUND(AVG(r.Rating), 2) AS Avg_Rating
FROM Product p
INNER JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) > 4.0;


-- 3. Sorting Data Using ORDER BY

-- 3.1 Display Products from Lowest to Highest Price (Ascending)
SELECT 
    Product_ID,
    Product_Name,
    Price
FROM Product
ORDER BY Price ASC;

-- 3.2 Display Customers Alphabetically by Name
SELECT 
    Customer_ID,
    Customer_Name,
    City,
    Registration_Date
FROM Customer
ORDER BY Customer_Name ASC;

-- 3.3 Find Top Expensive Products (Descending)
SELECT 
    Product_ID,
    Product_Name,
    Price
FROM Product
ORDER BY Price DESC
LIMIT 5;

-- 3.4 Display Latest Orders First
SELECT 
    Order_ID,
    Customer_ID,
    Order_Date,
    Total_Amount,
    Order_Status
FROM Orders
ORDER BY Order_Date DESC, Order_ID DESC;


-- 4. Deduplication Using DISTINCT

-- 4.1 Display Unique Product Categories
SELECT DISTINCT 
    Category_ID
FROM Product;

-- 4.2 Find Different Payment Methods Used by Customers
SELECT DISTINCT 
    Payment_Mode
FROM Payment;

-- 4.3 Display Unique Customer Locations (Cities)
SELECT DISTINCT 
    City
FROM Customer
ORDER BY City ASC;


-- 5. Search Products Based on Conditions
-- 5.1 Find Products Within a Specific Price Range (₹1,000 to ₹5,000)
SELECT 
    Product_ID,
    Product_Name,
    Price
FROM Product
WHERE Price BETWEEN 1000.00 AND 5000.00
ORDER BY Price ASC;

-- 5.2 Display Products Belonging to a Particular Category (e.g., Electronics, Category_ID = 1)
SELECT 
    p.Product_ID,
    p.Product_Name,
    c.Category_Name,
    p.Price
FROM Product p
INNER JOIN Category c ON p.Category_ID = c.Category_ID
WHERE c.Category_Name = 'Electronics';

-- 5.3 Find Products Currently Available in Warehouse Inventory
SELECT 
    p.Product_ID,
    p.Product_Name,
    i.Stock_Quantity,
    i.Stock_Status
FROM Product p
INNER JOIN Inventory i ON p.Product_ID = i.Product_ID
WHERE i.Stock_Status = 'Available' AND i.Stock_Quantity > 0;

-- 5.4 Search Products Using Product Name (Substring Search)
SELECT 
    Product_ID,
    Product_Name,
    Price
FROM Product
WHERE Product_Name LIKE '%Book%';

-- 5.5 Find Low-Stock Products (Stock Quantity )
SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Stock_Quantity
FROM Product p
WHERE p.Stock_Quantity < 10;


-- 6. Retrieve Customer and Product Information
-- 6.1 Display Customer Details with Their Orders
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
ORDER BY c.Customer_ID, o.Order_Date DESC;

-- 6.2 Display Product Details with Category Information
SELECT 
    p.Product_ID,
    p.Product_Name,
    c.Category_Name,
    p.Price,
    p.Stock_Quantity
FROM Product p
INNER JOIN Category c ON p.Category_ID = c.Category_ID
ORDER BY c.Category_Name, p.Product_Name;

-- 6.3 Find Customers Who Purchased a Specific Product (e.g., Laptop Pro 15, Product_ID = 1)
SELECT DISTINCT 
    c.Customer_ID,
    c.Customer_Name,
    c.Email,
    c.City,
    o.Order_ID,
    p.Product_Name
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
INNER JOIN Order_Details od ON o.Order_ID = od.Order_ID
INNER JOIN Product p ON od.Product_ID = p.Product_ID
WHERE p.Product_ID = 1;

-- 6.4 Display All Products Purchased by Each Customer
SELECT 
    c.Customer_Name,
    o.Order_ID,
    p.Product_Name,
    od.Quantity,
    od.Price
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
INNER JOIN Order_Details od ON o.Order_ID = od.Order_ID
INNER JOIN Product p ON od.Product_ID = p.Product_ID
ORDER BY c.Customer_Name, o.Order_ID;


-- 7. Compound Filtering (AND, OR, BETWEEN, LIKE, IN)
-- 7.1 Find Electronics Products Costing More than ₹10,000
SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Price
FROM Product p
INNER JOIN Category c ON p.Category_ID = c.Category_ID
WHERE c.Category_ID = 1 
  AND p.Price > 10000.00;

-- 7.2 Find Customers Located in Chennai OR Bangalore
SELECT 
    Customer_ID,
    Customer_Name,
    Email,
    City
FROM Customer
WHERE City IN ('Chennai', 'Bangalore');

-- 7.3 Search Products Containing the Word "Mobile"
SELECT 
    Product_ID,
    Product_Name,
    Price
FROM Product
WHERE Product_Name LIKE '%Mobile%';

-- 7.4 Find Orders Placed Within a Specific Date Range
SELECT 
    Order_ID,
    Customer_ID,
    Order_Date,
    Total_Amount,
    Order_Status
FROM Orders
WHERE Order_Date BETWEEN '2026-02-01' AND '2026-02-15'
ORDER BY Order_Date ASC;


-- Basic Business Reports
-- Report 1: Product Availability Report
-- Displays product name, price, stock quantity, and availability status:
SELECT 
    p.Product_Name,
    p.Price,
    p.Stock_Quantity,
    CASE 
        WHEN p.Stock_Quantity = 0 THEN 'Out of Stock'
        WHEN p.Stock_Quantity < 10 THEN 'Low Stock'
        ELSE 'Available'
    END AS Availability_Status
FROM Product p
ORDER BY p.Stock_Quantity ASC;


-- Report 2: Customer Report
-- 2A. Total Number of Customers
SELECT COUNT(*) AS Total_Customers FROM Customer;


-- 2B. Customer List Grouped by City
SELECT 
    City,
    COUNT(Customer_ID) AS Customer_Count
FROM Customer
GROUP BY City
ORDER BY Customer_Count DESC;


-- 2C. New Customer Registrations (Recent First)
SELECT 
    Customer_ID,
    Customer_Name,
    Email,
    City,
    Registration_Date
FROM Customer
ORDER BY Registration_Date DESC;


-- Report 3: Order Report
-- Displays total orders, completed orders, pending orders, and cancelled orders:
SELECT 
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN Order_Status = 'Delivered' THEN 1 ELSE 0 END) AS Completed_Orders,
    SUM(CASE WHEN Order_Status = 'Pending' THEN 1 ELSE 0 END) AS Pending_Orders,
    SUM(CASE WHEN Order_Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders
FROM Orders;

-- Report 4: Product Performance Report
-- 4A. Highest-Priced Products
SELECT 
    Product_Name, 
    Price 
FROM Product 
ORDER BY Price DESC 
LIMIT 3;

-- 4B. Most Reviewed Products
SELECT 
    p.Product_Name, 
    COUNT(r.Review_ID) AS Review_Count 
FROM Product p
INNER JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Review_Count DESC
LIMIT 3;

-- 4C. Available Products
SELECT 
    Product_Name, 
    Stock_Quantity 
FROM Product 
WHERE Stock_Quantity > 0 
ORDER BY Stock_Quantity DESC;

