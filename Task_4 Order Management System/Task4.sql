USE ecoms_db;

DROP TABLE IF EXISTS Order_Details;
DROP TABLE IF EXISTS Orders;

-- 1. Create Orders Table
CREATE TABLE Orders (
    Order_ID INT AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL DEFAULT (CURRENT_DATE),
    Total_Amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    Order_Status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Pending',
    
    CONSTRAINT pk_orders PRIMARY KEY (Order_ID),
    CONSTRAINT chk_total_amount CHECK (Total_Amount >= 0.00),
    CONSTRAINT fk_orders_customer 
        FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2. Create Order_Details Table
CREATE TABLE Order_Details (
    Order_Detail_ID INT AUTO_INCREMENT,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    
    CONSTRAINT pk_order_details PRIMARY KEY (Order_Detail_ID),
    CONSTRAINT chk_detail_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_detail_price CHECK (Price >= 0.00),
    CONSTRAINT fk_details_order 
        FOREIGN KEY (Order_ID) REFERENCES Orders (Order_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_details_product 
        FOREIGN KEY (Product_ID) REFERENCES Product (Product_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Indexes for performance optimization
CREATE INDEX idx_orders_customer ON Orders (Customer_ID);
CREATE INDEX idx_details_order ON Order_Details (Order_ID);
CREATE INDEX idx_details_product ON Order_Details (Product_ID);

-- 3. Seed Sample Orders and Line Items
INSERT INTO Orders (Customer_ID, Order_Date, Total_Amount, Order_Status) VALUES
(1, '2026-02-10', 55800.00, 'Delivered'),
(2, '2026-02-11', 2500.00, 'Shipped'),
(3, '2026-02-12', 32450.00, 'Pending'),
(4, '2026-02-13', 650.00, 'Cancelled');

INSERT INTO Order_Details (Order_ID, Product_ID, Quantity, Price) VALUES
(1, 1, 1, 55000.00),  -- Laptop Pro 15
(1, 2, 1, 800.00),     -- Wireless Mouse
(2, 6, 1, 2500.00),    -- Running Shoes
(3, 3, 1, 32000.00),   -- Smartphone X12
(3, 9, 1, 450.00),     -- Python Guide
(4, 8, 1, 650.00);     -- DB Concepts Book


-- Order Operations Implementation
-- --------------------------------------------------------------------
-- INSERT OPERATION: Customer (Customer_ID = 5) places a new order
-- --------------------------------------------------------------------
-- Step 1: Create Order Header
INSERT INTO Orders (Customer_ID, Order_Date, Total_Amount, Order_Status) VALUES
(5, '2026-02-14', 6800.00, 'Pending');

-- Step 2: Insert Order Detail line item
INSERT INTO Order_Details (Order_ID, Product_ID, Quantity, Price) VALUES
(LAST_INSERT_ID(), 10, 1, 6800.00);   -- Microwave Oven

-- --------------------------------------------------------------------
-- UPDATE OPERATIONS:
-- --------------------------------------------------------------------
-- 1. Change order status from Pending to Delivered
UPDATE Orders 
SET Order_Status = 'Delivered' 
WHERE Order_ID = 3;

-- 2. Modify product quantity and recalculate order detail
UPDATE Order_Details 
SET Quantity = 2 
WHERE Order_ID = 1 AND Product_ID = 2;

-- --------------------------------------------------------------------
-- DELETE OPERATION: Remove cancelled orders (Cascades to Order_Details)
-- --------------------------------------------------------------------
DELETE FROM Orders 
WHERE Order_Status = 'Cancelled';


-- Order History & Business Reports
-- Report 1: Comprehensive Customer Order History
SELECT 
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
ORDER BY o.Order_Date DESC;

-- Report 2: Product-wise Order Analytics
SELECT 
    p.Product_ID,
    p.Product_Name,
    COUNT(od.Order_ID) AS Times_Ordered,
    COALESCE(SUM(od.Quantity), 0) AS Total_Quantity_Sold,
    COALESCE(SUM(od.Quantity * od.Price), 0.00) AS Total_Product_Revenue
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Quantity_Sold DESC;

-- Report 3: Customer Purchase & Spending Analysis
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders_Placed,
    COALESCE(SUM(o.Total_Amount), 0.00) AS Total_Spending,
    ROUND(COALESCE(AVG(o.Total_Amount), 0.00), 2) AS Average_Order_Value
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;

-- Total Gross Revenue Query (excluding cancelled orders)
SELECT 
    SUM(Total_Amount) AS Total_Sales_Revenue,
    COUNT(*) AS Total_Successful_Orders 
FROM Orders 
WHERE Order_Status != 'Cancelled';
