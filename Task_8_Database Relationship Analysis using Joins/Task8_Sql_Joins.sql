-- Week 8: Database Relationship Analysis using Joins 

-- 1. Implement INNER JOIN
-- An INNER JOIN selects only rows where matching values exist in both participating tables.
-- 1.1 Display Customer Details Along with Their Orders
-- Retrieves customers who have actively placed orders:
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.Email,
    c.City,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
ORDER BY o.Order_Date DESC;

-- 1.2 Display Order Details with Payment Information
-- Pairs order headers with their associated financial transaction state:
SELECT 
    o.Order_ID,
    o.Customer_ID,
    o.Total_Amount AS Billed_Amount,
    o.Order_Status,
    p.Payment_ID,
    p.Payment_Mode,
    p.Transaction_Amount AS Settled_Amount,
    p.Payment_Status,
    p.Payment_Date
FROM Orders o
INNER JOIN Payment p ON o.Order_ID = p.Order_ID
ORDER BY o.Order_ID ASC;

-- 1.3 Retrieve Products Purchased by Customers
-- Links customers to the specific catalog items they purchased:
SELECT 
    c.Customer_Name,
    o.Order_ID,
    p.Product_ID,
    p.Product_Name,
    od.Quantity,
    od.Price AS Purchase_Unit_Price,
    (od.Quantity * od.Price) AS Subtotal
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
INNER JOIN Order_Details od ON o.Order_ID = od.Order_ID
INNER JOIN Product p ON od.Product_ID = p.Product_ID
ORDER BY c.Customer_Name, o.Order_ID;


-- 2. Implement LEFT JOIN
-- A LEFT JOIN returns all rows from the left-hand table along with matching rows from the right-hand table (substituting NULL where no match exists).
-- 2.1 Display All Customers Including Those Who Have Not Placed Orders
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.Email,
    c.City,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
ORDER BY c.Customer_ID ASC;

-- 2.2 Find Customers Without Any Purchases (Zero Orders Placed)
-- Isolates registered accounts that have never completed checkout:
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.Email,
    c.Phone,
    c.City,
    c.Registration_Date
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_ID IS NULL;

-- 2.3 Display All Products Including Products with No Sales
-- Identifies inventory items that have never been added to any customer order:
SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Price,
    p.Stock_Quantity,
    COUNT(od.Order_Detail_ID) AS Times_Sold
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Price, p.Stock_Quantity
HAVING COUNT(od.Order_Detail_ID) = 0
ORDER BY p.Product_ID ASC;


-- 3. Implement RIGHT JOIN
-- A RIGHT JOIN returns all rows from the right-hand table and matched rows from the left-hand table.
-- 3.1 Display All Orders with Customer Information
SELECT 
    c.Customer_Name,
    c.Email,
    c.City,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customer c
RIGHT JOIN Orders o ON c.Customer_ID = o.Customer_ID
ORDER BY o.Order_ID ASC;

-- 3.2 Find Orders Where Customer Details are Missing (Integrity Audit)
-- Detects any orphaned orders missing parent customer references (evaluates referential integrity):
SELECT 
    o.Order_ID,
    o.Customer_ID AS Orphaned_Customer_ID,
    o.Order_Date,
    o.Total_Amount
FROM Customer c
RIGHT JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE c.Customer_ID IS NULL;

-- 3.3 Display All Payment Records with Order Details
SELECT 
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status,
    p.Payment_ID,
    p.Payment_Mode,
    p.Payment_Status,
    p.Transaction_Amount
FROM Orders o
RIGHT JOIN Payment p ON o.Order_ID = p.Order_ID;


-- 4. Retrieve Complete Order Details (Unified Multi-Table Ledger)
-- Combines customer name, product title, ordered units, placement date, order total, and payment verification into a single comprehensive line item report:
SELECT 
    c.Customer_Name,
    p.Product_Name,
    od.Quantity,
    o.Order_Date,
    o.Total_Amount,
    COALESCE(p_pay.Payment_Status, 'Unpaid') AS Payment_Status
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
INNER JOIN Order_Details od ON o.Order_ID = od.Order_ID
INNER JOIN Product p ON od.Product_ID = p.Product_ID
LEFT JOIN Payment p_pay ON o.Order_ID = p_pay.Order_ID
ORDER BY o.Order_Date DESC, o.Order_ID DESC;


-- 5. Display Customer Purchase History
-- 5.1 All Products Purchased by a Specific Customer (e.g., Customer_ID = 1)
SELECT DISTINCT 
    c.Customer_Name,
    p.Product_Name,
    p.Price AS Current_Catalog_Price,
    od.Price AS Purchase_Price,
    od.Quantity
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
INNER JOIN Order_Details od ON o.Order_ID = od.Order_ID
INNER JOIN Product p ON od.Product_ID = p.Product_ID
WHERE c.Customer_ID = 1;

-- 5.2 Total Amount Spent by Each Customer
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.City,
    COALESCE(SUM(o.Total_Amount), 0.00) AS Total_Amount_Spent
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID AND o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.City
ORDER BY Total_Amount_Spent DESC;

-- 5.3 Number of Orders Placed by Each Customer
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Orders DESC;

-- 5.4 Latest Purchase Details of Customers
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    o.Order_ID AS Latest_Order_ID,
    o.Order_Date AS Latest_Order_Date,
    o.Total_Amount AS Latest_Order_Amount,
    o.Order_Status
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Date = (
    SELECT MAX(sub_o.Order_Date)
    FROM Orders sub_o
    WHERE sub_o.Customer_ID = c.Customer_ID
)
ORDER BY o.Order_Date DESC;


-- 6. Multi-Table Business Reports
-- Report 1: Customer Order Report
SELECT 
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Order_Status,
    o.Total_Amount
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
ORDER BY o.Order_Date DESC;


-- Report 2: Sales Report by Product
SELECT 
    p.Product_ID,
    p.Product_Name,
    COALESCE(SUM(od.Quantity), 0) AS Quantity_Sold,
    COALESCE(SUM(od.Quantity * od.Price), 0.00) AS Total_Revenue
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Revenue DESC;


-- Report 3: Payment Analysis Report
SELECT 
    p.Payment_Mode,
    COUNT(p.Payment_ID) AS Total_Transactions,
    SUM(CASE WHEN p.Payment_Status = 'Success' THEN 1 ELSE 0 END) AS Successful_Payments,
    SUM(CASE WHEN p.Payment_Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Payments,
    SUM(CASE WHEN p.Payment_Status = 'Pending' THEN 1 ELSE 0 END) AS Pending_Payments,
    COALESCE(SUM(CASE WHEN p.Payment_Status = 'Success' THEN p.Transaction_Amount ELSE 0 END), 0.00) AS Settled_Revenue
FROM Payment p
GROUP BY p.Payment_Mode
ORDER BY Total_Transactions DESC;


-- Report 4: Customer Purchase Analysis (Executive Aggregation)
-- 4A. Top Purchasing Customers (by Spending)
SELECT 
    c.Customer_Name,
    c.City,
    SUM(o.Total_Amount) AS Total_Spending
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.City
ORDER BY Total_Spending DESC
LIMIT 5;

-- 4B. Customers with Maximum Orders
SELECT 
    c.Customer_Name,
    COUNT(o.Order_ID) AS Order_Count
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Order_Count DESC
LIMIT 5;

-- 4C. Customers with Highest Single Spending Ticket
SELECT 
    c.Customer_Name,
    o.Order_ID,
    o.Total_Amount AS Highest_Single_Order_Amount,
    o.Order_Date
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
ORDER BY o.Total_Amount DESC
LIMIT 3;

