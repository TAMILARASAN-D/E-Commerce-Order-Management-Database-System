-- Week 10 Advanced SQL Query System
USE ecoms_db;

-- TASK 1: IMPLEMENT SUBQUERIES AND NESTED QUERIES

-- 1.1 Single-Row Subquery: Products priced higher than catalog average
SELECT
Product_ID,
Product_Name,
Price
FROM Product
WHERE Price > (
SELECT AVG(Price)
FROM Product
);
-- 1.2 Multi-Row Subquery: Customers who placed high-value orders (> ₹30,000)
SELECT
Customer_ID,
Customer_Name,
Email,
City
FROM Customer
WHERE Customer_ID IN (
SELECT DISTINCT Customer_ID
FROM Orders
WHERE Total_Amount > 30000.00
AND Order_Status != 'Cancelled'
);
-- 1.3 Nested Subquery (Derived Table): Average customer spend benchmark
SELECT
ROUND(AVG(Customer_Total_Spend), 2) AS Benchmark_Avg_Customer_Spend
FROM (
SELECT
Customer_ID,
SUM(Total_Amount) AS Customer_Total_Spend
FROM Orders
WHERE Order_Status != 'Cancelled'
GROUP BY Customer_ID
) AS CustomerSpendSummary;

-- TASK 2: FIND PRODUCTS ABOVE AVERAGE PRICE

-- 2.1 Products priced above global catalog average price
SELECT
Product_ID,
Product_Name,
Price,
(SELECT ROUND(AVG(Price), 2) FROM Product) AS Catalog_Average_Price,
ROUND(Price - (SELECT AVG(Price) FROM Product), 2) AS Price_Premium
FROM Product
WHERE Price > (
SELECT AVG(Price)
FROM Product
)
ORDER BY Price DESC;
-- 2.2 Display Product Name, Category Name, and Price for premium products
SELECT
p.Product_ID,
p.Product_Name,
c.Category_Name,
p.Price
FROM Product p
INNER JOIN Category c ON p.Category_ID = c.Category_ID
WHERE p.Price > (
SELECT AVG(Price)
FROM Product
)
ORDER BY p.Price DESC;
-- 2.3 Identify the most expensive product in each category (Correlated Subquery)
SELECT
c.Category_Name,
p.Product_ID,
p.Product_Name,
p.Price AS Category_Max_Price
FROM Product p
INNER JOIN Category c ON p.Category_ID = c.Category_ID
WHERE p.Price = (
SELECT MAX(p_sub.Price)
FROM Product p_sub
WHERE p_sub.Category_ID = p.Category_ID
)
ORDER BY p.Price DESC;
-- 2.4 Products with price higher than a selected category average (e.g., Electronics)
SELECT
p.Product_ID,
p.Product_Name,
c.Category_Name,
p.Price,
(
SELECT ROUND(AVG(p_inner.Price), 2)
FROM Product p_inner
INNER JOIN Category c_inner ON p_inner.Category_ID = c_inner.Category_ID
WHERE c_inner.Category_Name = 'Electronics'
) AS Electronics_Avg_Benchmark
FROM Product p
INNER JOIN Category c ON p.Category_ID = c.Category_ID
WHERE p.Price > (
SELECT AVG(p_inner.Price)
FROM Product p_inner
INNER JOIN Category c_inner ON p_inner.Category_ID = c_inner.Category_ID
WHERE c_inner.Category_Name = 'Electronics'
)
ORDER BY p.Price DESC;

-- TASK 3: IDENTIFY CUSTOMERS WITH MAXIMUM PURCHASES 

-- 3.1 Customer who spent the highest amount (Absolute Max Spender)
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
HAVING SUM(o.Total_Amount) = (
SELECT MAX(Total_Sales)
FROM (
SELECT SUM(Total_Amount) AS Total_Sales
FROM Orders
WHERE Order_Status != 'Cancelled'
GROUP BY Customer_ID
) AS SalesSummary
);
-- 3.2 Customers with maximum number of orders
SELECT
c.Customer_ID,
c.Customer_Name,
c.Email,
COUNT(o.Order_ID) AS Max_Orders_Count
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name, c.Email
HAVING COUNT(o.Order_ID) = (
SELECT MAX(Order_Count)
FROM (
SELECT COUNT(Order_ID) AS Order_Count
FROM Orders
GROUP BY Customer_ID
) AS OrderCountSummary
);
-- 3.3 Customers whose spending is above average customer spending
SELECT
c.Customer_ID,
c.Customer_Name,
c.City,
SUM(o.Total_Amount) AS Cumulative_Spending
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.City
HAVING SUM(o.Total_Amount) > (
SELECT AVG(Customer_Spend)
FROM (
SELECT SUM(Total_Amount) AS Customer_Spend
FROM Orders
WHERE Order_Status != 'Cancelled'
GROUP BY Customer_ID
) AS AvgSpendDerived
)
ORDER BY Cumulative_Spending DESC;
-- 3.4 Top 5 valuable customers (Spending Benchmark)
SELECT
c.Customer_ID,
c.Customer_Name,
c.Email,
c.City,
COALESCE(SUM(o.Total_Amount), 0.00) AS Total_Spending
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.Email, c.City
ORDER BY Total_Spending DESC
LIMIT 5;

-- TASK 4: GENERATE COMPLEX BUSINESS QUERIES

-- 4.1 Query 1: Best-Selling Product (Max Units Sold, Revenue, and Product Name)
SELECT
p.Product_ID,
p.Product_Name,
SUM(od.Quantity) AS Total_Quantity_Sold,
SUM(od.Quantity * od.Price) AS Total_Revenue_Generated
FROM Product p
INNER JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING SUM(od.Quantity) = (
SELECT MAX(Units_Sold)
FROM (
SELECT SUM(Quantity) AS Units_Sold
FROM Order_Details
GROUP BY Product_ID
) AS MaxUnitsDerived
);
-- 4.2 Query 2: High-Value Customers (Total Spend Exceeds Storewide Average Spend)
SELECT
c.Customer_ID,
c.Customer_Name,
c.Email,
SUM(o.Total_Amount) AS Total_Purchase_Amount,
(
SELECT ROUND(AVG(Total_Spend), 2)
FROM (
SELECT SUM(Total_Amount) AS Total_Spend
FROM Orders
WHERE Order_Status != 'Cancelled'
GROUP BY Customer_ID
) AS GlobalAvg
) AS Storewide_Avg_Spend
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.Email
HAVING SUM(o.Total_Amount) > (
SELECT AVG(Total_Spend)
FROM (
SELECT SUM(Total_Amount) AS Total_Spend
FROM Orders
WHERE Order_Status != 'Cancelled'
GROUP BY Customer_ID
) AS GlobalAvg
)
ORDER BY Total_Purchase_Amount DESC;
-- 4.3 Query 3: Category Performance Analysis
SELECT
c.Category_ID,
c.Category_Name,
COALESCE(SUM(od.Quantity), 0) AS Total_Units_Sold,
COALESCE(SUM(od.Quantity * od.Price), 0.00) AS Total_Category_Revenue,
(
SELECT ROUND(AVG(p_avg.Price), 2)
FROM Product p_avg
WHERE p_avg.Category_ID = c.Category_ID
) AS Avg_Product_Price_In_Category
FROM Category c
LEFT JOIN Product p ON c.Category_ID = p.Category_ID
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID, c.Category_Name
ORDER BY Total_Category_Revenue DESC;
-- 4.4 Query 4: Customer Purchase History with Most Purchased Product (Correlated Subquery)
SELECT
c.Customer_ID,
c.Customer_Name,
COUNT(DISTINCT o.Order_ID) AS Total_Orders,
COALESCE(SUM(o.Total_Amount), 0.00) AS Total_Purchase_Amount,
COALESCE((
SELECT p_inner.Product_Name
FROM Orders o_inner
INNER JOIN Order_Details od_inner ON o_inner.Order_ID = od_inner.Order_ID
INNER JOIN Product p_inner ON od_inner.Product_ID = p_inner.Product_ID
WHERE o_inner.Customer_ID = c.Customer_ID
AND o_inner.Order_Status != 'Cancelled'
GROUP BY p_inner.Product_ID, p_inner.Product_Name
ORDER BY SUM(od_inner.Quantity) DESC
LIMIT 1
), 'None') AS Most_Purchased_Product
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID AND o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Purchase_Amount DESC;

-- TASK 5: PREPARE ADVANCED SQL REPORTS

-- Report 1: Premium Product Report
SELECT
p.Product_Name,
c.Category_Name,
p.Price,
p.Stock_Quantity,
CASE
WHEN p.Stock_Quantity > 20 THEN 'Well Stocked'
WHEN p.Stock_Quantity BETWEEN 1 AND 20 THEN 'Limited Stock'
ELSE 'Out of Stock'
END AS Stock_Availability
FROM Product p
INNER JOIN Category c ON p.Category_ID = c.Category_ID
WHERE p.Price > (
SELECT AVG(Price)
FROM Product
)
ORDER BY p.Price DESC;
-- Report 2: Customer Value Report
SELECT
c.Customer_Name,
COUNT(o.Order_ID) AS Total_Orders,
COALESCE(SUM(o.Total_Amount), 0.00) AS Total_Spending,
CASE
WHEN COALESCE(SUM(o.Total_Amount), 0.00) >= 50000.00 THEN 'Premium'
WHEN COALESCE(SUM(o.Total_Amount), 0.00) BETWEEN 20000.00 AND 49999.99 THEN 'High Value'
WHEN COUNT(o.Order_ID) >= 1 THEN 'Regular'
ELSE 'Inactive'
END AS Customer_Category
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID AND o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;
-- Report 3: Sales Performance Report
SELECT
p.Product_Name,
c.Category_Name,
COALESCE(SUM(od.Quantity), 0) AS Units_Sold,
COALESCE(SUM(od.Quantity * od.Price), 0.00) AS Product_Revenue,
RANK() OVER (ORDER BY COALESCE(SUM(od.Quantity * od.Price), 0.00) DESC) AS Revenue_Rank
FROM Product p
INNER JOIN Category c ON p.Category_ID = c.Category_ID
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name, c.Category_Name
ORDER BY Product_Revenue DESC;
-- Report 4: Business Decision Report
-- 4A. High-Performing Products
SELECT
p.Product_Name,
c.Category_Name,
SUM(od.Quantity * od.Price) AS Revenue_Generated,
'High-Performing' AS Decision_Status
FROM Product p
INNER JOIN Category c ON p.Category_ID = c.Category_ID
INNER JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name, c.Category_Name
HAVING SUM(od.Quantity * od.Price) >= 20000.00
ORDER BY Revenue_Generated DESC;
-- 4B. Low-Performing Products Requiring Promotion or Discounting
SELECT
p.Product_Name,
p.Stock_Quantity,
p.Price,
COALESCE(SUM(od.Quantity), 0) AS Units_Sold,
'Promote or Discount' AS Recommendation
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Stock_Quantity, p.Price
HAVING Units_Sold < 5
ORDER BY p.Stock_Quantity DESC;
-- 4C. High-Value Customer Retention Targets
SELECT
c.Customer_Name,
c.Email,
c.City,
SUM(o.Total_Amount) AS Lifetime_Value,
'Assign Account Manager / Loyalty Tier' AS Retention_Action
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.Email, c.City
HAVING SUM(o.Total_Amount) >= 30000.00
ORDER BY Lifetime_Value DESC;
