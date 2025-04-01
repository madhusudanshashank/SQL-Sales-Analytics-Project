# 📊 SQL Sales Analytics Project

## 📌 Project Overview
This project focuses on analyzing sales data using SQL. It involves creating **user-defined functions, stored procedures, and reports** to generate insights from transactional data. The key objectives include:
- Extracting **customer sales data** efficiently.
- Automating fiscal year calculations using **user-defined functions**.
- Generating **gross sales reports** for products and markets.
- Implementing **stored procedures** for reusable analytics.
- Classifying markets based on **total sales performance**.

## 🚀 Features Implemented

### 1️⃣ User-Defined Functions
- ✅ **get_fiscal_year(date)**: Created a function to determine the **fiscal year** dynamically.
- ✅ Used the function to filter **sales data** by fiscal year without manual date calculations.

### 2️⃣ Gross Sales Reports
- ✅ Extracted **monthly product sales transactions** with product details.
- ✅ Calculated **gross sales revenue** using `sold_quantity * gross_price`.
- ✅ Generated a **monthly gross sales report** for any given customer.

### 3️⃣ Stored Procedures
- ✅ **get_monthly_gross_sales_for_customer**: Fetches monthly sales for any customer.
- ✅ **get_market_badge**: Classifies markets as **Gold/Silver** based on total sales volume.

### 4️⃣ Sales Analysis Using CTEs and Views
- **Net Sales Calculation**:
  - Used **Common Table Expressions (CTEs)** to calculate **net invoice sales** by applying discounts.
  - Created **views** for both **pre** and **post invoice deductions** to streamline sales calculations.

### 5️⃣ Top Markets and Customers
- Created reports to identify the **top 5 markets** by **net sales** in fiscal year 2021.
- ✅ **Stored procedures** to fetch the top N markets and customers dynamically.

### 6️⃣ Window Functions
- **Customer-Wise Net Sales Percentage Contribution**:
  - Used window functions to calculate the percentage contribution of each customer to the total net sales.
- **Net Sales Distribution Per Region**:
  - Applied window functions to partition data by region and calculate the share of net sales per region.
- **Top 3 Products Per Division**:
  - Implemented **DENSE_RANK()** to find the top 3 products per division based on total quantity sold in 2021.

### 7️⃣ Advanced Stored Procedures
- **`get_top_n_markets_by_net_sales`**: Fetches the top N markets by net sales for a given fiscal year.
- **`get_top_n_customers_by_net_sales`**: Fetches the top N customers by net sales for a given market and fiscal year.
- **`get_top_n_products_per_division_by_qty_sold`**: Fetches the top N products by quantity sold in a given fiscal year and division.

---

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
```

## 2️⃣ **Generating Monthly Gross Sales Report**
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
```

## 3️⃣ **Stored Procedure for Market Classification**
**Objective**: Classify markets as "Gold" or "Silver" based on total sales volume.

```sql
CREATE PROCEDURE `get_market_badge`(
    IN in_market VARCHAR(45),
    IN in_fiscal_year YEAR,
    OUT out_level VARCHAR(45)
)
BEGIN
    DECLARE qty INT DEFAULT 0;
    IF in_market = "" THEN SET in_market = "India"; END IF;
    SELECT SUM(s.sold_quantity) INTO qty
    FROM fact_sales_monthly s
    JOIN dim_customer c ON s.customer_code = c.customer_code
    WHERE get_fiscal_year(s.date) = in_fiscal_year AND c.market = in_market;
    IF qty > 5000000 THEN SET out_level = 'Gold'; ELSE SET out_level = 'Silver'; END IF;
END;
```

## 4️⃣ **Sales Analysis Query**
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
```

## 5️⃣ **Sales Pre-Invoice Discount View**
**Objective**: Create a view for sales data with pre-invoice discount details.

```sql
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
```

## 6️⃣ **Top 5 Markets by Net Sales**
**Objective**: Fetch the top 5 markets by net sales in fiscal year 2021.

```sql
SELECT
    market,
    ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
FROM gdb0041.net_sales
WHERE fiscal_year = 2021
GROUP BY market
ORDER BY net_sales_mln DESC
LIMIT 5;
```

## 7️⃣ **Window Function for Customer Net Sales Contribution**
**Objective**: Calculate the net sales contribution percentage for each customer.

```sql
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
```

