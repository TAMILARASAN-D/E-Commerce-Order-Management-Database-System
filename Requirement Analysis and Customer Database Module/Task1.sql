-- Create Database Architecture
CREATE DATABASE IF NOT EXISTS ecoms_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE ecoms_db;

-- Drop table if exists to ensure clean execution
DROP TABLE IF EXISTS Customer;

-- Create Customer Table
CREATE TABLE Customer (
    Customer_ID INT AUTO_INCREMENT,
    Customer_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL,
    Address VARCHAR(150) NOT NULL,
    City VARCHAR(50) NOT NULL,
    Registration_Date DATE NOT NULL DEFAULT (CURRENT_DATE),
    
    CONSTRAINT pk_customer PRIMARY KEY (Customer_ID),
    CONSTRAINT chk_customer_email CHECK (Email LIKE '%@%.%')
) ENGINE=InnoDB;

-- Index for accelerating email login lookups
CREATE INDEX idx_customer_email ON Customer (Email);
-- Index for accelerating city-based filtering
CREATE INDEX idx_customer_city ON Customer (City);

-- Insert 10 Initial Customer Records
INSERT INTO Customer (Customer_Name, Email, Phone, Address, City, Registration_Date) VALUES
('Arun Kumar', 'arun.kumar@example.com', '9876543210', '12 MG Road', 'Chennai', '2026-01-10'),
('Priya Sharma', 'priya.sharma@example.com', '9876543211', '45 Park Street', 'Bangalore', '2026-01-12'),
('Rahul Verma', 'rahul.verma@example.com', '9876543212', '78 Nehru Nagar', 'Delhi', '2026-01-15'),
('Anita Roy', 'anita.roy@example.com', '9876543213', '23 Sector 17', 'Chandigarh', '2026-01-18'),
('Suresh Patel', 'suresh.patel@example.com', '9876543214', '89 CG Road', 'Ahmedabad', '2026-01-20'),
('Kavita Singh', 'kavita.singh@example.com', '9876543215', '56 Civil Lines', 'Jaipur', '2026-01-22'),
('Vikram Das', 'vikram.das@example.com', '9876543216', '34 Salt Lake', 'Kolkata', '2026-01-25'),
('Deepak Nair', 'deepak.nair@example.com', '9876543217', '11 MG Road', 'Kochi', '2026-01-28'),
('Meena Reddy', 'meena.reddy@example.com', '9876543218', '67 Jubilee Hills', 'Hyderabad', '2026-02-01'),
('Sanjay Gupta', 'sanjay.gupta@example.com', '9876543219', '90 FC Road', 'Pune', '2026-02-05');


-- --------------------------------------------------------------------
-- CREATE: Add a new customer record
-- --------------------------------------------------------------------
INSERT INTO Customer (Customer_Name, Email, Phone, Address, City, Registration_Date) VALUES
('Rohan Mehta', 'rohan.mehta@example.com', '9876543220', '101 Marine Drive', 'Mumbai', '2026-02-10');

-- --------------------------------------------------------------------
-- READ Operations:
-- 1. Display all customer details
SELECT 
    Customer_ID, Customer_Name, Email, Phone, Address, City, Registration_Date
FROM Customer;

-- 2. Search customers by specific city (e.g., Chennai)
SELECT 
    Customer_ID, Customer_Name, Email, Phone, Address, City 
FROM Customer 
WHERE City = 'Chennai';

-- 3. Search customer by unique email credential
SELECT 
    Customer_ID, Customer_Name, Phone, City 
FROM Customer 
WHERE Email = 'priya.sharma@example.com';

-- --------------------------------------------------------------------
-- UPDATE: Modify phone and address details for a specific customer
-- --------------------------------------------------------------------
UPDATE Customer 
SET Phone = '9998887770', Address = '100 Anna Salai, Guindy' 
WHERE Customer_ID = 1;

-- Verify update
SELECT Customer_ID, Customer_Name, Phone, Address FROM Customer WHERE Customer_ID = 1;

-- --------------------------------------------------------------------
-- DELETE: Remove an inactive or obsolete customer record
-- --------------------------------------------------------------------
DELETE FROM Customer 
WHERE Customer_ID = 11;