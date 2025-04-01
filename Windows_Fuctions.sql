-- ==============================================
-- SQL Sales Analytics Project: Window Functions
-- ==============================================

-- ==============================================
-- Find Customer-Wise Net Sales Percentage Contribution
-- ==============================================

WITH cte1 AS (
    SELECT 
        c.customer, 
        ROUND(SUM(s.net_sales) / 1000000, 2) AS net_sales_mln
    FROM net_sales s
    JOIN dim_customer c
        ON s.customer_code = c.customer_code
    WHERE s.fiscal_year = 2021
    GROUP BY c.customer
)
SELECT 
    *,
    net_sales_mln * 100 / SUM(net_sales_mln) OVER() AS pct_net_sales
FROM cte1
ORDER BY net_sales_mln DESC;

-- ==============================================
-- Find Customer-Wise Net Sales Distribution Per Region for FY 2021
-- ==============================================

WITH cte1 AS (
    SELECT 
        c.customer,
        c.region,
        ROUND(SUM(n.net_sales) / 1000000, 2) AS net_sales_mln
    FROM gdb0041.net_sales n
    JOIN dim_customer c
        ON n.customer_code = c.customer_code
    WHERE n.fiscal_year = 2021
    GROUP BY c.customer, c.region
)
SELECT
    *,
    net_sales_mln * 100 / SUM(net_sales_mln) OVER (PARTITION BY region) AS pct_share_region
FROM cte1
ORDER BY region, pct_share_region DESC;

-- ==============================================
-- Find Top 3 Products from Each Division by Total Quantity Sold in a Given Year
-- ==============================================

WITH cte1 AS (
    SELECT
        p.division,
        p.product,
        SUM(s.sold_quantity) AS total_qty
    FROM fact_sales_monthly s
    JOIN dim_product p
        ON p.product_code = s.product_code
    WHERE s.fiscal_year = 2021
    GROUP BY p.product
),
cte2 AS (
    SELECT 
        *,
        DENSE_RANK() OVER (PARTITION BY division ORDER BY total_qty DESC) AS drnk
    FROM cte1
)
SELECT * 
FROM cte2 
WHERE drnk <= 3;

-- ==============================================
-- Stored Procedure: Get Top N Products Per Division by Quantity Sold
-- ==============================================

CREATE PROCEDURE `get_top_n_products_per_division_by_qty_sold`(
    IN in_fiscal_year INT,
    IN in_top_n INT
)
BEGIN
    WITH cte1 AS (
        SELECT
            p.division,
            p.product,
            SUM(s.sold_quantity) AS total_qty
        FROM fact_sales_monthly s
        JOIN dim_product p
            ON p.product_code = s.product_code
        WHERE s.fiscal_year = in_fiscal_year
        GROUP BY p.product
    ),            
    cte2 AS (
        SELECT 
            *,
            DENSE_RANK() OVER (PARTITION BY division ORDER BY total_qty DESC) AS drnk
        FROM cte1
    )
    SELECT * 
    FROM cte2 
    WHERE drnk <= in_top_n;
END;