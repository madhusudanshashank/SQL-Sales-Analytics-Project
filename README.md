# SQL Sales Analytics Project

## 📌 Project Overview
This project focuses on analyzing sales data using SQL. It involves creating **user-defined functions, stored procedures, and reports** to generate insights from transactional data. The key objectives include:
- Extracting **customer sales data** efficiently.
- Automating fiscal year calculations using **user-defined functions**.
- Generating **gross sales reports** for products and markets.
- Implementing **stored procedures** for reusable analytics.
- Classifying markets based on **total sales performance**.

## 📂 Folder Structure
SQL-Sales-Analytics-Project/ │── README.md # Project documentation │── sql_scripts/ # SQL scripts folder │ ├── 01_sales_analysis.sql │ ├── 02_create_views.sql │ ├── 03_top_markets_customers.sql │ ├── 04_window_functions.sql │ ├── 05_stored_procedures.sql │── output_samples/ # Sample output reports (if any) │ ├── monthly_sales_report.xlsx │ ├── top_markets_report.xlsx │── datasets/ (optional) # Sample dataset files ├── sample_data.csv

pgsql
Copy
Edit

## 🚀 Features Implemented

### 1️⃣ **Sales Analysis Using CTEs and Views**
- **Net Sales Calculation**: 
  - Used **Common Table Expressions (CTEs)** to calculate net invoice sales by applying discounts.
  - Created **views** for both **pre** and **post invoice deductions** to streamline sales calculations.

### 2️⃣ **Top Markets and Customers**
- Created reports to identify the **top 5 markets** by net sales in fiscal year 2021.
- **Stored procedures** to fetch the top N markets and customers dynamically.

### 3️⃣ **Window Functions**
- **Customer-Wise Net Sales Percentage Contribution**:
  - Used window functions to calculate the percentage contribution of each customer to the total net sales.
- **Net Sales Distribution Per Region**:
  - Applied window functions to partition data by region and calculate the share of net sales per region.
- **Top 3 Products Per Division**:
  - Implemented **DENSE_RANK()** to find the top 3 products per division based on total quantity sold in 2021.

### 4️⃣ **Stored Procedures**
- **`get_top_n_markets_by_net_sales`**: Fetches the top N markets by net sales for a given fiscal year.
- **`get_top_n_customers_by_net_sales`**: Fetches the top N customers by net sales for a given market and fiscal year.
- **`get_top_n_products_per_division_by_qty_sold`**: Fetches the top N products by quantity sold in a given fiscal year and division.

## 📊 SQL Queries & Explanations

### **1️⃣ Sales Analysis Query**

**Objective**: Calculate net sales after applying discounts (pre and post).

```sql
WITH cte1 AS (
    SELECT 
        s.date, 
        s.customer_code,
        s.product_code, 
        p.product, 
        p.variant, 
        s.sold_quantity, 
        g.gross_price AS gross_price_per_item,
        ROUND(s.sold_quantity * g.gross_price, 2) AS gross_price_total,
        pre.pre_invoice_discount_pct
    FROM fact_sales_monthly s
    JOIN dim_product p ON s.product_code = p.product_code
    JOIN fact_gross_price g ON g.fiscal_year = s.fiscal_year AND g.product_code = s.product_code
    JOIN fact_pre_invoice_deductions pre ON pre.customer_code = s.customer_code AND pre.fiscal_year = s.fiscal_year
    WHERE s.fiscal_year = 2021
)
SELECT 
    *, 
    (gross_price_total - pre_invoice_discount_pct * gross_price_total) AS net_invoice_sales
FROM cte1
LIMIT 1500000;
2️⃣ Sales Pre-Invoice Discount View
Objective: Create a view for sales data with pre-invoice discount details.

sql
Copy
Edit
CREATE VIEW sales_preinv_discount AS
SELECT 
    s.date, 
    s.fiscal_year,
    s.customer_code,
    c.market,
    s.product_code, 
    p.product, 
    p.variant, 
    s.sold_quantity, 
    g.gross_price AS gross_price_per_item,
    ROUND(s.sold_quantity * g.gross_price, 2) AS gross_price_total,
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_customer c ON s.customer_code = c.customer_code
JOIN dim_product p ON s.product_code = p.product_code
JOIN fact_gross_price g ON g.fiscal_year = s.fiscal_year AND g.product_code = s.product_code
JOIN fact_pre_invoice_deductions pre ON pre.customer_code = s.customer_code AND pre.fiscal_year = s.fiscal_year;
3️⃣ Top 5 Markets by Net Sales
Objective: Fetch the top 5 markets by net sales in fiscal year 2021.

sql
Copy
Edit
SELECT 
    market, 
    ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
FROM gdb0041.net_sales
WHERE fiscal_year = 2021
GROUP BY market
ORDER BY net_sales_mln DESC
LIMIT 5;
4️⃣ Window Function for Customer Net Sales Contribution
Objective: Calculate the net sales contribution percentage for each customer.

sql
Copy
Edit
WITH cte1 AS (
    SELECT 
        c.customer, 
        ROUND(SUM(s.net_sales) / 1000000, 2) AS net_sales_mln
    FROM net_sales s
    JOIN dim_customer c ON s.customer_code = c.customer_code
    WHERE s.fiscal_year = 2021
    GROUP BY c.customer
)
SELECT 
    *,
    net_sales_mln * 100 / SUM(net_sales_mln) OVER() AS pct_net_sales
FROM cte1
ORDER BY net_sales_mln DESC;
📌 How to Use
Set up the database schema: Import the required tables (e.g., fact_sales_monthly, dim_product, fact_gross_price, etc.) into your MySQL database.

Execute SQL scripts:

Run the SQL scripts in the order listed to create tables, views, and stored procedures.

Ensure the views and stored procedures are created correctly.

Run the stored procedures: Use stored procedures to generate dynamic reports.

Example: Run get_top_n_markets_by_net_sales with fiscal year and top N values.

View the output: The results can be seen in your SQL client or exported to Excel for analysis.

🛠 Technologies Used
MySQL – Database for querying & data analysis.

SQL Joins & Window Functions – For complex aggregations.

Stored Procedures & Functions – For reusable analytics.

Excel Exports – To generate report outputs.

📈 Sample Reports
Monthly Sales Report – output_samples/monthly_sales_report.xlsx

Top Markets by Sales – output_samples/top_markets_report.xlsx