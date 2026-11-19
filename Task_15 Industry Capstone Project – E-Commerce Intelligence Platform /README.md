# Industry Capstone Project: E-Commerce Intelligence Platform

## Overview
A relational Database Management System (DBMS) built in MySQL 8.0+ to manage end-to-end e-commerce operations—integrating customer profiles, product catalogs, multi-seller inventory, order processing, payment tracking, customer reviews, automated triggers, query optimization, and business intelligence reporting[cite: 53, 54].

## Repository Structure
```text
Task_15 Industry Capstone Project – E-Commerce Intelligence Platform/
├── README.md
├── 01_Project_Report/
│   ├── Capstone_Project_Report.md
│   └── ER_Diagram.png
├── 02_SQL_Source_Code/
│   └── mentor_cert_week_15_complete.sql
├── 03_Business_Analytics_Report/
│   └── Business_Analytics_Report.md
└── 04_Presentation/
    └── Capstone_Presentation_Outline.md
```

## Integrated Modules
1. **Customer & Category Management:** Normalized buyer profiles and product classifications[cite: 54].
2. **Product, Seller & Inventory Management:** Multi-supplier stock tracking and availability status monitoring[cite: 54].
3. **Order & Payment Management:** Transactional order headers, many-to-many line items (`Order_Details`), and payment status tracking[cite: 54].
4. **Product Review & Rating System:** Verified 1–5 star customer feedback and product rating analytics[cite: 54].
5. **Database Automation:** Views, Stored Procedures, Stored Functions, and Triggers for automatic stock deduction, payment-driven order confirmation, and audit logging[cite: 56].
6. **Performance Optimization & Business Intelligence:** Composite indexes verified via `EXPLAIN` and analytical SQL reports using window functions (`RANK()`) and nested subqueries[cite: 56, 57].

## Execution & Setup Instructions
1. Open **MySQL Workbench** (MySQL 8.0+).
2. Load `02_SQL_Source_Code/mentor_cert_week_15_complete.sql`.
3. Click **Execute All** (Lightning Bolt icon) to create `ecommerce_capstone_platform`, populate the minimum required business records (`50` Customers, `100` Products, `20` Sellers, `100` Orders, `100` Payments, `50` Reviews), build all database automation objects, and execute all four Business Intelligence reports[cite: 55, 56, 57].
4. Generate and export the visual ER Diagram via **Database → Reverse Engineer**[cite: 54].
