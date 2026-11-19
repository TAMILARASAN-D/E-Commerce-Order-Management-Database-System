-- WEEK 14: BUSINESS INTELLIGENCE AND AI DATA PREPARATION

-- TASK 1: CREATE ANALYTICAL REPORTS USING SQL

-- 1A. Sales Performance Report (Total sales, orders, AOV, monthly revenue)
SELECT 
    DATE_FORMAT(Order_Date, '%Y-%m') AS Sales_Month,
    COUNT(Order_ID) AS Number_Of_Orders,
    SUM(Total_Amount) AS Monthly_Revenue,
    ROUND(AVG(Total_Amount), 2) AS Average_Order_Value
FROM Orders
WHERE Order_Status != 'Cancelled'
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY Sales_Month;

-- Overall Sales Summary
SELECT 
    COUNT(Order_ID) AS Total_Orders,
    SUM(Total_Amount) AS Total_Sales,
    ROUND(AVG(Total_Amount), 2) AS Overall_Average_Order_Value
FROM Orders
WHERE Order_Status != 'Cancelled';

-- 1B. Customer Analysis Report (Name, total purchases, orders, last purchase date)
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Number_Of_Orders,
    COALESCE(SUM(o.Total_Amount), 0) AS Total_Purchases,
    MAX(o.Order_Date) AS Last_Purchase_Date
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Purchases DESC;

-- 1C. Product Performance Report (Product name, qty sold, revenue, ranking)
SELECT 
    p.Product_Name,
    COALESCE(SUM(od.Quantity), 0) AS Quantity_Sold,
    COALESCE(SUM(od.Quantity * od.Price), 0) AS Revenue_Generated,
    RANK() OVER (ORDER BY COALESCE(SUM(od.Quantity * od.Price), 0) DESC) AS Product_Ranking
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name;


-- TASK 2: APPLY WINDOW FUNCTIONS

-- 2A. Rank Products Based on Sales (RANK and DENSE_RANK)
SELECT 
    od.Product_ID,
    p.Product_Name,
    SUM(od.Quantity) AS Total_Sales,
    RANK() OVER (ORDER BY SUM(od.Quantity) DESC) AS Sales_Rank,
    DENSE_RANK() OVER (ORDER BY SUM(od.Quantity) DESC) AS Dense_Sales_Rank
FROM Order_Details od
JOIN Product p ON od.Product_ID = p.Product_ID
GROUP BY od.Product_ID, p.Product_Name;

-- 2B. Rank Customers Based on Purchase Amount
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    SUM(o.Total_Amount) AS Total_Spending,
    RANK() OVER (ORDER BY SUM(o.Total_Amount) DESC) AS Customer_Spending_Rank
FROM Customer c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;

-- 2C. Generate Latest Order Sequence using ROW_NUMBER()
SELECT 
    Customer_ID,
    Order_ID,
    Order_Date,
    Total_Amount,
    ROW_NUMBER() OVER (PARTITION BY Customer_ID ORDER BY Order_Date DESC, Order_ID DESC) AS Latest_Order_Seq
FROM Orders;


-- TASK 3: GENERATE CUSTOMER SEGMENTATION DATA 

SELECT 
    c.Customer_Name AS Customer,
    COALESCE(SUM(o.Total_Amount), 0) AS Total_Purchase,
    COUNT(o.Order_ID) AS Orders,
    CASE 
        WHEN COALESCE(SUM(o.Total_Amount), 0) >= 100000 OR COUNT(o.Order_ID) >= 10 THEN 'Premium'
        WHEN COALESCE(SUM(o.Total_Amount), 0) >= 15000 OR COUNT(o.Order_ID) >= 3 THEN 'Regular'
        ELSE 'Low Value'
    END AS Segment
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Purchase DESC;


-- TASK 4: PREPARE DATASET FOR AI MODELS 

-- Combines multiple tables, handles missing values (COALESCE), removes duplicates,
-- and encodes categorical attributes (Preferred_Category_ID) into numerical format.

DROP VIEW IF EXISTS AI_Customer_Behavior_Dataset;

CREATE VIEW AI_Customer_Behavior_Dataset AS
WITH CustomerStats AS (
    SELECT 
        c.Customer_ID,
        TIMESTAMPDIFF(YEAR, c.Registration_Date, CURDATE()) AS Account_Tenure_Years,
        COUNT(DISTINCT o.Order_ID) AS Total_Purchases,
        COALESCE(SUM(o.Total_Amount), 0) AS Total_Spending,
        ROUND(COALESCE(AVG(o.Total_Amount), 0), 2) AS Average_Order_Value,
        ROUND(
            COUNT(DISTINCT o.Order_ID) / GREATEST(TIMESTAMPDIFF(MONTH, c.Registration_Date, CURDATE()), 1), 
            2
        ) AS Purchase_Frequency_Per_Month
    FROM Customer c
    LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
    GROUP BY c.Customer_ID, c.Registration_Date
),
PreferredCategory AS (
    SELECT 
        o.Customer_ID,
        p.Category_ID AS Preferred_Category_Encoded,
        ROW_NUMBER() OVER (PARTITION BY o.Customer_ID ORDER BY SUM(od.Quantity) DESC) AS rn
    FROM Orders o
    JOIN Order_Details od ON o.Order_ID = od.Order_ID
    JOIN Product p ON od.Product_ID = p.Product_ID
    GROUP BY o.Customer_ID, p.Category_ID
)
SELECT DISTINCT
    cs.Customer_ID,
    cs.Account_Tenure_Years,
    cs.Total_Purchases,
    cs.Total_Spending,
    cs.Average_Order_Value,
    cs.Purchase_Frequency_Per_Month,
    COALESCE(pc.Preferred_Category_Encoded, 0) AS Preferred_Category_Num
FROM CustomerStats cs
LEFT JOIN PreferredCategory pc ON cs.Customer_ID = pc.Customer_ID AND pc.rn = 1;

-- View final ML-ready dataset
SELECT * FROM AI_Customer_Behavior_Dataset;


-- TASK 5: PERFORM FEATURE EXTRACTION USING SQL 

-- 5A. Customer Features (Orders, total spending, avg purchase value, last purchase)
SELECT 
    Customer_ID,
    COUNT(Order_ID) AS Purchase_Count,
    SUM(Total_Amount) AS Total_Spending,
    ROUND(AVG(Total_Amount), 2) AS Avg_Order_Value,
    MAX(Order_Date) AS Last_Purchase_Date
FROM Orders
GROUP BY Customer_ID;

-- 5B. Product Features (Sales qty, avg rating, revenue, stock availability)
SELECT 
    p.Product_ID,
    p.Product_Name,
    COALESCE(SUM(od.Quantity), 0) AS Total_Sales_Quantity,
    ROUND(COALESCE(AVG(r.Rating), 0), 2) AS Average_Rating,
    COALESCE(SUM(od.Quantity * od.Price), 0) AS Revenue_Generated,
    p.Stock_Quantity AS Stock_Availability
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
LEFT JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Stock_Quantity;

-- 5C. Time-Based Features (Year, month, day of purchase, purchase frequency)
SELECT 
    Order_ID,
    Customer_ID,
    Order_Date,
    YEAR(Order_Date) AS Purchase_Year,
    MONTH(Order_Date) AS Purchase_Month,
    DAY(Order_Date) AS Purchase_Day,
    DAYNAME(Order_Date) AS Purchase_Day_Name,
    COUNT(Order_ID) OVER (PARTITION BY Customer_ID) AS Customer_Purchase_Frequency
FROM Orders;


-- BUSINESS INTELLIGENCE REPORTS 

-- Report 1: Customer Segmentation Report
SELECT 
    Segment AS Customer_Category,
    COUNT(Customer) AS Customer_Count,
    SUM(Orders) AS Total_Orders_Frequency,
    SUM(Total_Purchase) AS Total_Spending
FROM (
    SELECT 
        c.Customer_Name AS Customer,
        COALESCE(SUM(o.Total_Amount), 0) AS Total_Purchase,
        COUNT(o.Order_ID) AS Orders,
        CASE 
            WHEN COALESCE(SUM(o.Total_Amount), 0) >= 100000 OR COUNT(o.Order_ID) >= 10 THEN 'Premium'
            WHEN COALESCE(SUM(o.Total_Amount), 0) >= 15000 OR COUNT(o.Order_ID) >= 3 THEN 'Regular'
            ELSE 'Low Value'
        END AS Segment
    FROM Customer c
    LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
    GROUP BY c.Customer_ID, c.Customer_Name
) AS SegmentedData
GROUP BY Segment;

-- Report 2: Sales Ranking Report
SELECT 
    p.Product_Name,
    COALESCE(SUM(od.Quantity), 0) AS Total_Sales,
    RANK() OVER (ORDER BY COALESCE(SUM(od.Quantity), 0) DESC) AS Sales_Rank
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name;

-- Report 3: AI Dataset Structure Verification Report
DESCRIBE AI_Customer_Behavior_Dataset;