USE ecoms_db;

DROP TABLE IF EXISTS Payment;

-- Create Payment Table
CREATE TABLE Payment (
    Payment_ID INT AUTO_INCREMENT,
    Order_ID INT NOT NULL UNIQUE,
    Payment_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Payment_Mode ENUM('UPI', 'Credit Card', 'Debit Card', 'Net Banking', 'Cash on Delivery') NOT NULL,
    Payment_Status ENUM('Success', 'Failed', 'Pending') NOT NULL DEFAULT 'Pending',
    Transaction_Amount DECIMAL(10, 2) NOT NULL,
    
    CONSTRAINT pk_payment PRIMARY KEY (Payment_ID),
    CONSTRAINT chk_trans_amount CHECK (Transaction_Amount > 0.00),
    CONSTRAINT fk_payment_order FOREIGN KEY (Order_ID) REFERENCES Orders (Order_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Seed Payment Records
INSERT INTO Payment (Order_ID, Payment_Mode, Payment_Status, Transaction_Amount) VALUES
(1, 'UPI', 'Success', 55800.00),
(2, 'Credit Card', 'Success', 2500.00),
(3, 'Net Banking', 'Failed', 32450.00),
(5, 'Cash on Delivery', 'Pending', 6800.00);

select * from payment;


-- Transaction Operations Scripts
-- 1. Display all successful transactions
SELECT *
FROM Payment 
WHERE Payment_Status = 'Success';

-- 2. Display all failed transactions requiring retry/follow-up
SELECT 
    *
FROM Payment 
WHERE Payment_Status = 'Failed';

-- 3. Display pending transactions (e.g., Cash on Delivery orders)
SELECT 
    Payment_ID, Order_ID, Payment_Mode, Transaction_Amount 
FROM Payment 
WHERE Payment_Status = 'Pending';

-- 4. Count total transactions grouped by status
SELECT 
    Payment_Status, 
    COUNT(*) AS Total_Transactions,
    SUM(Transaction_Amount) AS Total_Value
FROM Payment 
GROUP BY Payment_Status;

-- 5. Update failed payment after successful user retry
UPDATE Payment 
SET Payment_Mode = 'UPI', Payment_Status = 'Success' 
WHERE Payment_ID = 3 AND Order_ID = 3;

-- Verify update
SELECT * FROM Payment WHERE Order_ID = 3;


-- Payment Analytics Reports
-- Report 1: Payment Mode Preference & Revenue Breakdown
SELECT 
    Payment_Mode,
    COUNT(*) AS Transaction_Count,
    SUM(CASE WHEN Payment_Status = 'Success' THEN Transaction_Amount ELSE 0 END) AS Revenue_By_Mode,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Payment)), 2) AS Mode_Percentage
FROM Payment
GROUP BY Payment_Mode
ORDER BY Transaction_Count DESC;

-- Report 2: Total Revenue & Average Transaction Value Analysis
SELECT 
    SUM(Transaction_Amount) AS Total_Gross_Revenue,
    ROUND(AVG(Transaction_Amount), 2) AS Average_Transaction_Value,
    MIN(Transaction_Amount) AS Smallest_Transaction,
    MAX(Transaction_Amount) AS Largest_Transaction
FROM Payment
WHERE Payment_Status = 'Success';

-- Report 3: Comprehensive Customer Payment & Transaction History
SELECT 
    c.Customer_Name,
    o.Order_ID,
    p.Payment_ID,
    p.Payment_Mode,
    p.Transaction_Amount,
    p.Payment_Status,
    p.Payment_Date
FROM Customer c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
INNER JOIN Payment p ON o.Order_ID = p.Order_ID
ORDER BY p.Payment_Date DESC;
