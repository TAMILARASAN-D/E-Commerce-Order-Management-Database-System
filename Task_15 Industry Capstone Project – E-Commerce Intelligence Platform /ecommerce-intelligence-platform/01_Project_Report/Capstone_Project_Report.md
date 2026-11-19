# Project Report: E-Commerce Intelligence Platform

## 1. Problem Statement & Requirement Analysis
Modern e-commerce operations require real-time coordination across customer accounts, multi-vendor inventory, order processing, payment verification, and customer feedback. Disconnected data tables cause overselling of out-of-stock items, manual order-status bottlenecks, and slow analytical reporting. This project implements a unified, Third Normal Form (3NF) relational database system that automates order-to-payment workflows, enforces referential and domain integrity, optimizes query execution, and produces actionable business intelligence.

## 2. Database Normalization (1NF → 3NF)
* **First Normal Form (1NF):** Every table stores atomic column values with no repeating groups and uses a dedicated `PRIMARY KEY` (`AUTO_INCREMENT`).
* **Second Normal Form (2NF):** Partial dependencies are eliminated by separating order-level metadata (`Orders`) from product-level line items (`Order_Details`), resolving the many-to-many relationship between `Orders` and `Product`.
* **Third Normal Form (3NF):** Transitive dependencies are removed by isolating `Category` attributes from `Product` and separating supplier-specific stock records into `Inventory`.

## 3. Relational Schema & Constraints
| Table Name | Primary Key | Foreign Keys | Key Integrity Constraints |
| :--- | :--- | :--- | :--- |
| `Customer` | `Customer_ID` | — | `Email UNIQUE`, `NOT NULL` across profile attributes |
| `Category` | `Category_ID` | — | `Category_Name UNIQUE`, `NOT NULL` |
| `Product` | `Product_ID` | `Category_ID` | `CHECK (Price > 0)`, `CHECK (Stock_Quantity >= 0)` |
| `Seller` | `Seller_ID` | — | `Email UNIQUE`, `NOT NULL` across supplier attributes |
| `Inventory` | `Inventory_ID` | `Product_ID`, `Seller_ID` | `CHECK (Stock_Quantity >= 0)`, `Stock_Status NOT NULL` |
| `Orders` | `Order_ID` | `Customer_ID` | `CHECK (Total_Amount >= 0)`, `Order_Status DEFAULT 'Pending'` |
| `Order_Details` | `Order_Detail_ID` | `Order_ID`, `Product_ID` | `CHECK (Quantity > 0)`, `CHECK (Price > 0)` |
| `Payment` | `Payment_ID` | `Order_ID` (`UNIQUE`) | `CHECK (Transaction_Amount > 0)` |
| `Review` | `Review_ID` | `Customer_ID`, `Product_ID` | `CHECK (Rating BETWEEN 1 AND 5)` |
| `Audit_Log` | `Audit_ID` | — | Automated audit trail populated by database triggers |

## 4. Implementation Details
* **Realistic Business Data Volume:** Populated via `PopulateCapstoneData()` with `50` Customers, `100` Products, `20` Sellers, `100` Orders, `100` Payments, and `50` Reviews.
* **SQL Query Coverage:** Implements filtering (`WHERE`, `BETWEEN`, `LIKE`, `DISTINCT`, `ORDER BY`), multi-table `JOIN` operations, aggregations (`GROUP BY`, `HAVING`), single-row and nested subqueries, and window functions (`RANK()`).
* **Database Automation Objects:**
  * **Views:** `View_Customer_Order_History`, `View_Sales_Report`, `View_Product_Performance`.
  * **Stored Procedures:** `Sp_PlaceOrder`, `Sp_UpdateStock`, `Sp_CalculateSales`.
  * **Functions:** `Fn_TotalCustomerSpending`, `Fn_ProductRevenue`.
  * **Triggers:** `Trg_ReduceStockAfterOrder` (automatically deducts `Product` and `Inventory` stock upon order insertion and logs to `Audit_Log`) and `Trg_UpdateOrderStatusAfterPayment` (automatically updates `Orders.Order_Status` to `Confirmed` or `Payment Failed` upon payment insertion and logs to `Audit_Log`).
* **Performance Optimization:** Created composite indexes (`idx_capstone_product_search`, `idx_capstone_customer_lookup`, `idx_capstone_order_retrieval`) and verified index scan efficiency via `EXPLAIN`.
