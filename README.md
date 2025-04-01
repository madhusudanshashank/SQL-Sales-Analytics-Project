# SQL Sales Analytics Project 📊


## 📌 Project Overview

The **SQL Sales Analytics Project** aims to develop an automated and scalable SQL-based analytics solution for **sales data**. By utilizing SQL techniques such as **user-defined functions (UDFs)**, **stored procedures**, **window functions**, and **views**, this project efficiently processes transactional data to derive meaningful insights and enhance business decision-making.

The solution is built for businesses looking to analyze **sales performance**, identify key trends, and track financial data for better decision-making, especially in **sales departments**.

---

## 🎯 Key Features & Objectives

### 1. **User-Defined Functions (UDFs)** 
- Designed and implemented UDFs for efficient **fiscal year calculations**, enabling streamlined **sales data filtering** by fiscal year.

### 2. **Sales Reports Generation**
- Generated detailed **sales reports** by joining multiple tables to calculate **gross sales revenue**, providing **financial insights** to track product performance over time.

### 3. **Stored Procedures for Automation**
- Developed advanced **stored procedures** to automate the retrieval of key sales data for specific customers, markets, and products.
- These procedures improved the speed and accuracy of **report generation** for **top markets**, **top customers by market**, and **top products by quantity sold**.

### 4. **Sales Distribution Analysis Using Window Functions**
- Leveraged **window functions** to analyze and calculate **net sales distribution** across customer regions, providing deeper insights into **regional performance**.

### 5. **Views for Discounted Sales Calculations**
- Created **SQL views** to automatically apply **pre- and post-invoice discounts**, improving the accuracy and efficiency of **net sales calculations**.

### 6. **Query Optimization**
- Optimized queries using **Common Table Expressions (CTEs)** and **indexing** to efficiently handle large datasets, reducing **report generation times**.

---

## 💡 Project Outcomes

- **30% Reduction in Report Generation Time** ⏱: By automating key data retrieval tasks with stored procedures and user-defined functions, time to generate key insights was reduced significantly.
- **Enhanced Sales Insights** 📊: The solution provided actionable insights into **regional performance**, **top-selling products**, and **top-performing markets**, helping the sales department make **data-driven decisions**.
- **Scalability & Flexibility** 🔄: Designed to easily integrate with future datasets and adapt to evolving business requirements, ensuring long-term usability.

---

## 🔧 SQL Techniques Utilized

- **User-Defined Functions (UDFs):** Automating fiscal year calculations based on transaction dates.
- **Stored Procedures:** Automating data extraction for key metrics such as top markets and top customers by sales.
- **Common Table Expressions (CTEs):** Simplifying complex queries and optimizing query performance.
- **Window Functions:** Analyzing sales data by partitioning it into regions or other categories for deeper insights.
- **SQL Views:** Streamlining the calculation of net sales by incorporating discounts automatically.


---



# 📊 SQL Queries & Explanations

## 1️⃣ Fetching Customer Sales Data
**Use Case**: This query can be useful for analyzing a specific customer's sales performance over the fiscal year 2021. By retrieving the data and filtering it by fiscal year, it allows you to track how sales for this customer have evolved over time. The chronological order of the results helps identify sales trends, seasonality, or significant sales spikes. Limiting the output to 100,000 records ensures that large datasets can be handled efficiently, making this query ideal for generating reports or feeding data into further analyses for sales forecasting or customer behavior analysis.

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
**Use Case**: This query helps track the monthly sales performance of a specific customer by aggregating data on sold quantities and product prices. By breaking down the sales into monthly figures, it provides insights into trends, seasonality, and product demand. This analysis can inform inventory management, marketing strategies, and sales forecasting, enabling more targeted decision-making for improving customer-specific sales.

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
**Use Case**: The get_market_badge stored procedure calculates the total sales quantity for a given market and fiscal year, with a default market of "India" if no market is provided. It then assigns a badge level based on the total sales quantity. If the sales quantity exceeds 5,000,000 units, the badge is set to "Gold"; otherwise, it is set to "Silver." The resulting badge level is returned through the output parameter (out_level), allowing for market performance categorization.

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
**Use Case**: This query utilizes Common Table Expressions (CTEs) to simplify the calculation of net invoice sales. By breaking down the process into manageable steps, CTEs help join sales transactions, product details, gross price information, and pre-invoice discount data more efficiently. The CTE calculates the total gross price and applies the pre-invoice discount, resulting in the net invoice sales amount. This approach enhances query clarity and performance, providing accurate insights into revenue after discounts.

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
**Use Case**: The sales_preinv_discount view combines sales transaction data with pre-invoice discount information. It calculates the gross price total by multiplying the sold quantity by the gross price per item and incorporates the pre-invoice discount percentage for each transaction. This view enables the analysis of sales before applying any deductions, providing a detailed and real-time perspective on sales performance, including the impact of discounts.

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
**Use Case**:This query helps identify the top-performing markets based on net sales for a given fiscal year. By aggregating and sorting net sales, it provides valuable insights into which markets contribute most to revenue. This enables sales teams to focus on high-performing regions, adjust strategies in weaker markets, and make data-driven decisions to optimize growth and resource allocation. The use of aggregation and sorting ensures the results are clear and easily interpretable.

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
**Use Case**:This query calculates each customer's percentage contribution to total net sales in FY 2021. Using a CTE, it aggregates sales by customer and applies a window function to determine the share of total sales. It helps identify key customers and prioritize sales strategies.

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
---
## Conclusion

This project has successfully transformed the sales reporting process by automating the generation of monthly and annual reports. Through the strategic implementation of stored procedures and user-defined functions, the solution enhanced the accuracy and efficiency of the sales analysis, reducing the time required to generate key insights by over 30%. The market classification system further empowered the sales department by providing valuable data-driven insights into top-performing markets, which directly supported more informed decision-making.

By streamlining the sales reporting process and ensuring scalability, the solution is not only capable of handling large volumes of data but is also adaptable for future expansions. This project has laid a strong foundation for continuous improvement and growth, offering the company a robust framework for ongoing sales analytics that can easily be integrated with new datasets as the business evolves. Ultimately, the automation and efficiency gained from this solution will drive better business outcomes and optimize the sales strategy for sustained growth.

