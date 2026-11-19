# Capstone Presentation: E-Commerce Intelligence Platform

## Slide 1: Title & Project Objectives
* **Project:** Industry Capstone Project — E-Commerce Intelligence Platform
* **Core Objectives:** Integrate all e-commerce modules into a normalized 3NF schema, automate operations via database objects, optimize queries with indexes, and deliver business intelligence insights.

## Slide 2: Database Design & Normalization (3NF)
* **Entities Integrated:** `Customer`, `Category`, `Product`, `Seller`, `Inventory`, `Orders`, `Order_Details`, `Payment`, `Review`, and `Audit_Log`.
* **Integrity Enforcement:** Primary Keys, Foreign Keys, `UNIQUE` constraints, and `CHECK` constraints across prices, quantities, and 1–5 star ratings.

## Slide 3: Realistic Data & Multi-Level SQL Queries
* **Verified Data Volume:** `50` Customers, `100` Products, `20` Sellers, `100` Orders, `100` Payments, and `50` Reviews.
* **Query Capabilities:** Basic filtering (`BETWEEN`, `LIKE`, `DISTINCT`), multi-table `JOIN` reports, `GROUP BY`/`HAVING` aggregations, nested subqueries, and `RANK()` window functions.

## Slide 4: Database Automation Architecture
* **Views:** `View_Customer_Order_History`, `View_Sales_Report`, `View_Product_Performance`.
* **Procedures & Functions:** `Sp_PlaceOrder`, `Sp_UpdateStock`, `Sp_CalculateSales`, `Fn_TotalCustomerSpending`, and `Fn_ProductRevenue`.
* **Triggers:** `Trg_ReduceStockAfterOrder` and `Trg_UpdateOrderStatusAfterPayment` with automated `Audit_Log` entries.

## Slide 5: Performance Optimization (`EXPLAIN`)
* **Indexes Created:** `idx_capstone_product_search`, `idx_capstone_customer_lookup`, and `idx_capstone_order_retrieval`.
* **Verification:** Analyzed execution plans using `EXPLAIN` to confirm index usage and reduced row scans.

## Slide 6: Business Insights & Strategic Recommendations
* **Sales & Product Intelligence:** Focus inventory investment on top-ranked revenue categories and promote highest-rated products (`>= 4.0` stars).
* **Customer & Inventory Intelligence:** Reward High-Value repeat customers and automate restocking for Low-Stock SKUs (`< 10` units).
