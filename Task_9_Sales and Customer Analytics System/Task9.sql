-- Week 9 Sales & Customer Analytics System

USE ecoms_db;

-- TASK 1: GENERATE TOTAL SALES REPORTS

-- 1.1 Total number of orders placed (excluding cancelled orders)
SELECT COUNT(Order_ID) AS Total_Orders_Placed
FROM Orders
WHERE Order_Status != 'Cancelled';

-- 1.2 Total revenue generated from sales
SELECT SUM(Total_Amount) AS Total_Sales_Revenue
FROM Orders
WHERE Order_Status != 'Cancelled';

-- 1.3 Average Order Value (AOV)
SELECT ROUND(AVG(Total_Amount), 2) AS Average_Order_Value
FROM Orders
WHERE Order_Status != 'Cancelled';

-- 1.4 Highest and lowest order amount
SELECT
MIN(Total_Amount) AS Lowest_Order_Amount,
MAX(Total_Amount) AS Highest_Order_Amount
FROM Orders
WHERE Order_Status != 'Cancelled';

-- 1.5 Total sales for a specific period (e.g., February 2026)
SELECT
COUNT(Order_ID) AS Period_Orders_Count,
COALESCE(SUM(Total_Amount), 0.00) AS Period_Sales_Revenue,
COALESCE(ROUND(AVG(Total_Amount), 2), 0.00) AS Period_Average_Order_Value
FROM Orders
WHERE Order_Date BETWEEN '2026-02-01' AND '2026-02-28'
AND Order_Status != 'Cancelled';

-- 1.6 Unified Executive Sales Summary Report (Dashboard Card)
SELECT
COUNT(Order_ID) AS Total_Orders,
SUM(Total_Amount) AS Total_Revenue,
ROUND(AVG(Total_Amount), 2) AS Average_Order_Value,
MIN(Total_Amount) AS Lowest_Order_Value,
MAX(Total_Amount) AS Highest_Order_Value
FROM Orders
WHERE Order_Status != 'Cancelled';

-- TASK 2: CUSTOMER PURCHASE ANALYSIS

-- 2.1 Total number of orders placed & total amount spent by each customer
SELECT
c.Customer_ID,
c.Customer_Name,
c.City,
COUNT(o.Order_ID) AS Total_Orders_Placed,
COALESCE(SUM(o.Total_Amount), 0.00) AS Total_Amount_Spent
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID AND o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.City
ORDER BY Total_Amount_Spent DESC;

-- 2.2 Average spending per customer (Storewide Benchmark)
SELECT
ROUND(SUM(Total_Amount) / COUNT(DISTINCT Customer_ID), 2) AS Storewide_Avg_Spend_Per_Customer
FROM Orders
WHERE Order_Status != 'Cancelled';

-- 2.3 Customers with maximum purchase amount (Subquery)
SELECT
c.Customer_ID,
c.Customer_Name,
c.Email,
c.City,
SUM(o.Total_Amount) AS Total_Spending
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.Email, c.City
HAVING SUM(o.Total_Amount) = (
SELECT MAX(Total_Sales)
FROM (
SELECT SUM(Total_Amount) AS Total_Sales
FROM Orders
WHERE Order_Status != 'Cancelled'
GROUP BY Customer_ID
) AS Sub
);

-- 2.4 Customers with fewer purchases (Low engagement: 0 or 1 order)
SELECT
c.Customer_ID,
c.Customer_Name,
c.Email,
c.City,
COUNT(o.Order_ID) AS Order_Count,
COALESCE(SUM(o.Total_Amount), 0.00) AS Total_Spent
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID AND o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.Email, c.City
HAVING COUNT(o.Order_ID) <= 1
ORDER BY Order_Count ASC, c.Customer_Name ASC;

-- TASK 3: FIND TOP CUSTOMERS BASED ON PURCHASE AMOUNT

-- 3.1 Top 5 customers based on total spending
SELECT
c.Customer_ID,
c.Customer_Name,
c.City,
COALESCE(SUM(o.Total_Amount), 0.00) AS Total_Spending
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.City
ORDER BY Total_Spending DESC;

-- 3.2 Customers with maximum number of orders
SELECT
c.Customer_ID,
c.Customer_Name,
COUNT(o.Order_ID) AS Total_Orders
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Orders DESC
LIMIT 5;

-- 3.3 Frequent customers (Placed more than 1 order)
SELECT
c.Customer_ID,
c.Customer_Name,
c.Email,
COUNT(o.Order_ID) AS Order_Frequency,
SUM(o.Total_Amount) AS Cumulative_Spend
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name, c.Email
HAVING COUNT(o.Order_ID) > 1
ORDER BY Order_Frequency DESC;

-- 3.4 High-value customers (Spending above predefined threshold of ₹20,000)
SELECT
c.Customer_ID,
c.Customer_Name,
c.Email,
c.City,
SUM(o.Total_Amount) AS Total_Spent
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.Email, c.City
HAVING SUM(o.Total_Amount) >= 20000.00
ORDER BY Total_Spent DESC;

-- TASK 4: IDENTIFY BEST-SELLING PRODUCTS

-- 4.1 Products with maximum sales quantity (Top 5 Volume)
SELECT
p.Product_ID,
p.Product_Name,
COALESCE(SUM(od.Quantity), 0) AS Total_Units_Sold
FROM Product p
INNER JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Units_Sold DESC
LIMIT 5;

-- 4.2 Products generating highest revenue (Top 5 Revenue)
SELECT
p.Product_ID,
p.Product_Name,
COALESCE(SUM(od.Quantity * od.Price), 0.00) AS Total_Product_Revenue
FROM Product p
INNER JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Product_Revenue DESC
LIMIT 5;

-- 4.3 Least-selling products
SELECT
p.Product_ID,
p.Product_Name,
p.Price,
COALESCE(SUM(od.Quantity), 0) AS Total_Units_Sold
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Price
ORDER BY Total_Units_Sold ASC, p.Product_Name ASC
LIMIT 5;

-- 4.4 Products requiring promotion (Low sales < 5 units with inventory in stock)
SELECT
p.Product_ID,
p.Product_Name,
p.Price,
p.Stock_Quantity,
COALESCE(SUM(od.Quantity), 0) AS Units_Sold
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Price, p.Stock_Quantity
HAVING Units_Sold < 5
ORDER BY p.Stock_Quantity DESC;

-- TASK 5: PERFORM CATEGORY-WISE SALES ANALYSIS

-- 5.1 Total sales generated & number of products sold by each category
SELECT
c.Category_ID,
c.Category_Name,
COUNT(DISTINCT p.Product_ID) AS Total_Catalog_Products,
COALESCE(SUM(od.Quantity), 0) AS Total_Products_Sold,
COALESCE(SUM(od.Quantity * od.Price), 0.00) AS Category_Revenue
FROM Category c
LEFT JOIN Product p ON c.Category_ID = p.Category_ID
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID, c.Category_Name
ORDER BY Category_Revenue DESC;

-- 5.2 Highest revenue-generating category (Top 1)
SELECT
c.Category_ID,
c.Category_Name,
SUM(od.Quantity * od.Price) AS Highest_Category_Revenue
FROM Category c
INNER JOIN Product p ON c.Category_ID = p.Category_ID
INNER JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID, c.Category_Name
ORDER BY Highest_Category_Revenue DESC
LIMIT 1;

-- 5.3 Average sales revenue per category (Storewide Benchmark)
SELECT
ROUND(AVG(Category_Revenue), 2) AS Average_Sales_Per_Category
FROM (
SELECT
c.Category_ID,
SUM(od.Quantity * od.Price) AS Category_Revenue
FROM Category c
INNER JOIN Product p ON c.Category_ID = p.Category_ID
INNER JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID
) AS CatRev;

-- TASK 6: GENERATE BUSINESS ANALYTICS REPORTS

-- Report 1: Sales Performance Report
SELECT
SUM(Total_Amount) AS Total_Sales,
COUNT(Order_ID) AS Number_Of_Orders,
ROUND(AVG(Total_Amount), 2) AS Average_Order_Value,
MAX(Total_Amount) AS Highest_Order_Value
FROM Orders
WHERE Order_Status != 'Cancelled';

-- Report 2: Customer Analytics Report
SELECT
c.Customer_Name,
COUNT(o.Order_ID) AS Number_Of_Orders,
COALESCE(SUM(o.Total_Amount), 0.00) AS Total_Spending,
CASE
WHEN COUNT(o.Order_ID) >= 3 THEN 'High Frequency'
WHEN COUNT(o.Order_ID) BETWEEN 1 AND 2 THEN 'Moderate Frequency'
ELSE 'Inactive'
END AS Purchase_Frequency
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID AND o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;

-- Report 3: Product Performance Report
SELECT
p.Product_Name,
COALESCE(SUM(od.Quantity), 0) AS Quantity_Sold,
COALESCE(SUM(od.Quantity * od.Price), 0.00) AS Revenue_Generated
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Revenue_Generated DESC;

-- Report 4: Category Analysis Report
SELECT
c.Category_Name,
COALESCE(SUM(od.Quantity), 0) AS Total_Products_Sold,
COALESCE(SUM(od.Quantity * od.Price), 0.00) AS Total_Revenue
FROM Category c
LEFT JOIN Product p ON c.Category_ID = p.Category_ID
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID, c.Category_Name
ORDER BY Total_Revenue DESC;