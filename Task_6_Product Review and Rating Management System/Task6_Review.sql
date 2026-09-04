USE ecoms_db;

-- Drop table if exists to ensure clean execution
DROP TABLE IF EXISTS Review;

--  Create Review Table
CREATE TABLE Review (
    Review_ID INT AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Rating INT NOT NULL,
    Review_Text TEXT,
    Review_Date DATE NOT NULL DEFAULT (CURRENT_DATE),
    
    CONSTRAINT pk_review PRIMARY KEY (Review_ID),
    CONSTRAINT chk_review_rating CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT fk_review_customer 
        FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_review_product 
        FOREIGN KEY (Product_ID) REFERENCES Product (Product_ID)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

select * from customer;

select * from product;


-- Sample Data Seeding
-- Seed sample customer reviews across catalog products
INSERT INTO Review (Customer_ID, Product_ID, Rating, Review_Text, Review_Date) VALUES
(1, 1, 5, 'Exceptional performance and battery life! Well worth the price.', '2026-02-15'),
(2, 1, 4, 'Very fast and lightweight laptop. Screen could be a bit brighter.', '2026-02-16'),
(3, 2, 5, 'Ergonomic, smooth tracking, and connects seamlessly over Bluetooth.', '2026-02-16'),
(4, 2, 4, 'Great mouse for office productivity at a reasonable price.', '2026-02-17'),
(5, 3, 4, 'Crisp display, sleek body, and cameras are clear.', '2026-02-18'),
(1, 3, 5, 'Top-tier phone! Battery easily lasts 1.5 days under heavy usage.', '2026-02-19'),
(2, 4, 2, 'Noise cancellation is average, ear pads get warm after an hour.', '2026-02-20'),
(3, 5, 5, 'Super soft cotton fabric, true to size, fits comfortably.', '2026-02-20'),
(4, 6, 4, 'Comfortable running shoes with good grip and cushioning.', '2026-02-21'),
(5, 8, 5, 'The best textbook for mastering database design and normalization!', '2026-02-22'),
(6, 8, 5, 'Clear explanations, practical query examples. Highly recommended.', '2026-02-23'),
(7, 10, 1, 'Microwave heating element failed within 2 weeks. Disappointed.', '2026-02-24');


select * from review;

-- Review & Rating Operations (CRUD)
-- 1 Add Reviews for Purchased Products (CREATE)
INSERT INTO Review (Customer_ID, Product_ID, Rating, Review_Text, Review_Date) 
VALUES (6, 9, 5, 'Comprehensive Python programming guide with hands-on projects.', CURRENT_DATE);

-- 2 Retrieve Review Details (READ)
-- 2.1: Display all reviews for a specific product
SELECT 
    r.Review_ID,
    p.Product_Name,
    r.Rating,
    r.Review_Text,
    r.Review_Date
FROM Product p
JOIN Review r ON p.Product_ID = r.Product_ID
WHERE p.Product_ID = 1;


-- 2.2: Display customer name along with their posted reviews
SELECT 
    c.Customer_Name,
    p.Product_Name,
    r.Rating,
    r.Review_Text,
    r.Review_Date
FROM Review r
INNER JOIN Customer c ON r.Customer_ID = c.Customer_ID
INNER JOIN Product p ON r.Product_ID = p.Product_ID
ORDER BY r.Review_Date DESC;


-- 2.3: Find products having maximum reviews
SELECT 
    p.Product_ID,
    p.Product_Name,
    COUNT(r.Review_ID) AS Total_Reviews
FROM Product p
INNER JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING COUNT(r.Review_ID) = (
    SELECT MAX(Review_Count) 
    FROM (
        SELECT COUNT(Review_ID) AS Review_Count 
        FROM Review 
        GROUP BY Product_ID
    ) AS Sub
);


-- 2.4: Display recent customer feedback (Latest 5 Reviews)
SELECT 
    r.Review_ID,
    c.Customer_Name,
    p.Product_Name,
    r.Rating,
    r.Review_Text,
    r.Review_Date
FROM Review r
INNER JOIN Customer c ON r.Customer_ID = c.Customer_ID
INNER JOIN Product p ON r.Product_ID = p.Product_ID
ORDER BY r.Review_Date DESC, r.Review_ID DESC
LIMIT 5;


-- 2.5: Retrieve reviews with ratings strictly above 4 stars
SELECT 
    c.Customer_Name,
    p.Product_Name,
    r.Rating,
    r.Review_Text
FROM Review r
INNER JOIN Customer c ON r.Customer_ID = c.Customer_ID
INNER JOIN Product p ON r.Product_ID = p.Product_ID
WHERE r.Rating > 4;


-- 3 Update Review Comments (UPDATE)
UPDATE Review 
SET Review_Text = 'Updated: After firmware update, noise cancellation works much better.',
    Rating = 3
WHERE Review_ID = 7 AND Customer_ID = 2;

-- Verify update
SELECT * FROM Review WHERE Review_ID = 7;


-- 4 Remove Inappropriate or Invalid Reviews (DELETE)
DELETE FROM Review 
WHERE Review_ID = 12;

-- Calculate Average Product Ratings
-- 1 Calculate Average Rating & Count per Product
SELECT 
    p.Product_ID,
    p.Product_Name,
    COUNT(r.Review_ID) AS Review_Count,
    ROUND(AVG(r.Rating), 2) AS Average_Rating
FROM Product p
INNER JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Average_Rating DESC;


-- 2 Find Highest-Rated Products
SELECT 
    p.Product_ID,
    p.Product_Name,
    ROUND(AVG(r.Rating), 2) AS Highest_Avg_Rating
FROM Product p
INNER JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) = (
    SELECT MAX(Avg_Rating) 
    FROM (
        SELECT AVG(Rating) AS Avg_Rating 
        FROM Review 
        GROUP BY Product_ID
    ) AS Temp
);


-- 3 Identify Products with Average Rating Above 4.0
SELECT 
    p.Product_ID,
    p.Product_Name,
    COUNT(r.Review_ID) AS Review_Count,
    ROUND(AVG(r.Rating), 2) AS Average_Rating
FROM Product p
INNER JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) > 4.0
ORDER BY Average_Rating DESC;

-- Business Reports
-- Report 1: Product Rating Analysis
-- Displays product name, number of reviews, and average rating:
SELECT 
    p.Product_Name,
    COUNT(r.Review_ID) AS Number_Of_Reviews,
    COALESCE(ROUND(AVG(r.Rating), 2), 0.00) AS Average_Rating
FROM Product p
LEFT JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Average_Rating DESC, Number_Of_Reviews DESC;


-- Report 2: Customer Feedback Analysis
-- 2A. Most Reviewed Products
SELECT 
    p.Product_Name,
    COUNT(r.Review_ID) AS Review_Count
FROM Product p
INNER JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Review_Count DESC
LIMIT 3;


-- 2B. Highly Rated Products (Average Rating >= 4.5)
SELECT 
    p.Product_Name,
    ROUND(AVG(r.Rating), 2) AS Average_Rating
FROM Product p
INNER JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) >= 4.5
ORDER BY Average_Rating DESC;


-- 2C. Products Requiring Improvement (Average Rating < 3.0)
SELECT 
    p.Product_Name,
    ROUND(AVG(r.Rating), 2) AS Average_Rating,
    COUNT(r.Review_ID) AS Dissatisfied_Reviews
FROM Product p
INNER JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) < 3.0;


-- Report 3: Rating Distribution Analysis
-- Analyzes 5-star ratings, 4-star ratings, and low-rated products (<= 2 stars):
SELECT 
    COUNT(Review_ID) AS Total_Reviews,
    SUM(CASE WHEN Rating = 5 THEN 1 ELSE 0 END) AS Five_Star_Ratings,
    SUM(CASE WHEN Rating = 4 THEN 1 ELSE 0 END) AS Four_Star_Ratings,
    SUM(CASE WHEN Rating = 3 THEN 1 ELSE 0 END) AS Three_Star_Ratings,
    SUM(CASE WHEN Rating <= 2 THEN 1 ELSE 0 END) AS Low_Rated_Products_Count,
    ROUND((SUM(CASE WHEN Rating >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(Review_ID)), 2) AS Customer_Satisfaction_Rate_Pct
FROM Review;
