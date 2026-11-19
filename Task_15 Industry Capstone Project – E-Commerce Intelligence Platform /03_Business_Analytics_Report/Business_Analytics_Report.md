# Business Analytics & Intelligence Report

## 1. Sales Intelligence Report
* **Metrics Tracked:** Monthly order volume, gross monthly revenue (`View_Sales_Report`), category unit volume, and revenue rankings (`RANK() OVER (ORDER BY SUM(od.Quantity * od.Price) DESC)`).
* **Key Insight:** Identifies top revenue-generating product categories and tracks monthly order momentum to guide seasonal promotional budgets.

## 2. Customer Intelligence Report
* **Segmentation Criteria:** Evaluates purchase frequency and cumulative spending per customer, classifying buyers into **High-Value** (`>= ₹50,000`), **Regular** (`>= ₹20,000`), and **Standard** tiers while filtering above-average spenders via `HAVING Total_Spent > (SELECT AVG(Total_Amount) FROM Orders)`.
* **Key Insight:** Enables targeted retention campaigns for High-Value customers and upsell incentives for Regular-tier buyers.

## 3. Inventory Intelligence Report
* **Stock Classification Logic:** Audits live stock levels alongside historical order volume to classify catalog items into **Low-Stock** (`Stock_Quantity < 10`), **Fast-Moving** (`Total_Sold >= 4`), **Overstocked** (`Stock_Quantity > 40`), and **Optimal**.
* **Key Insight:** Prevents stockouts on Fast-Moving and Low-Stock items via `Sp_UpdateStock` replenishment while identifying Overstocked products for bundled discounting.

## 4. Product Intelligence Report
* **Quality & Feedback Metrics:** Aggregates customer review scores (`AVG(Rating)`) and review counts per product to classify catalog items as **Highest-Rated** (`>= 4.0`), **Average-Performing**, or **Poor-Performing** (`< 2.5`).
* **Key Insight:** Highlights top-rated products for storefront placement and flags poor-performing SKUs for seller quality audits.
