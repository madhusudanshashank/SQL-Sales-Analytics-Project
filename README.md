# SQL Sales Analytics Project

## 📌 Project Overview
This project focuses on analyzing sales data using SQL. It involves creating **user-defined functions, stored procedures, and reports** to generate insights from transactional data. The key objectives include:
- Extracting **customer sales data** efficiently.
- Automating fiscal year calculations using **user-defined functions**.
- Generating **gross sales reports** for products and markets.
- Implementing **stored procedures** for reusable analytics.
- Classifying markets based on **total sales performance**.



## 🚀 Features Implemented


## 1️⃣ User-Defined Functions
- ✅ **get_fiscal_year(date)**: Created a function to determine the **fiscal year** dynamically.
- ✅ Used the function to filter **sales data** by fiscal year without manual date calculations.

## 2️⃣ Gross Sales Reports
- ✅ Extracted **monthly product sales transactions** with product details.
- ✅ Calculated **gross sales revenue** using `sold_quantity * gross_price`.
- ✅ Generated a **monthly gross sales report** for any given customer.

## 3️⃣ Stored Procedures
- ✅ **get_monthly_gross_sales_for_customer**: Fetches monthly sales for any customer.
- ✅ **get_market_badge**: Classifies markets as **Gold/Silver** based on total sales volume.

## 4️⃣ Sales Analysis Using CTEs and Views
- **Net Sales Calculation**: 
  - Used **Common Table Expressions (CTEs)** to calculate **net invoice sales** by applying discounts.
  - Created **views** for both **pre** and **post invoice deductions** to streamline sales calculations.

## 5️⃣ Top Markets and Customers
- Created reports to identify the **top 5 markets** by **net sales** in fiscal year 2021.
- ✅ **Stored procedures** to fetch the top N markets and customers dynamically.

## 6️⃣ Window Functions
- **Customer-Wise Net Sales Percentage Contribution**:
  - Used window functions to calculate the percentage contribution of each customer to the total net sales.
- **Net Sales Distribution Per Region**:
  - Applied window functions to partition data by region and calculate the share of net sales per region.
- **Top 3 Products Per Division**:
  - Implemented **DENSE_RANK()** to find the top 3 products per division based on total quantity sold in 2021.

## 7️⃣ Advanced Stored Procedures
- **`get_top_n_markets_by_net_sales`**: Fetches the top N markets by net sales for a given fiscal year.
- **`get_top_n_customers_by_net_sales`**: Fetches the top N customers by net sales for a given market and fiscal year.
- **`get_top_n_products_per_division_by_qty_sold`**: Fetches the top N products by quantity sold in a given fiscal year and division.



# 📊 SQL Queries & Explanations


## 1️⃣ Fetching Customer Sales Data
**Objective**: Retrieve sales transactions for Croma India.
```sql
SELECT * 
FROM fact_sales_monthly
WHERE
    customer_code = 90002002
    AND get_fiscal_year(date) = 2021
ORDER BY date ASC
LIMIT 100000;

## 2️⃣ Generating Monthly Gross Sales Report
**Objective**: Generate a report for monthly gross sales based on customer and product details.
```sql
SELECT
    s.date,
    SUM(ROUND(s.sold_quantity * g.gross_price, 2)) AS monthly_sales
FROM fact_sales_monthly s
JOIN fact_gross_price g
    ON g.fiscal_year = get_fiscal_year(s.date)
    AND g.product_code = s.product_code
WHERE customer_code = 90002002
GROUP BY s.date;
