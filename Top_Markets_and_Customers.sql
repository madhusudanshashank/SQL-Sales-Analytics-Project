-- ==============================================
-- SQL Sales Analytics Project: Top Markets and Customers
-- ==============================================

-- Get the top 5 markets by net sales in fiscal year 2021
SELECT 
    market, 
    ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
FROM gdb0041.net_sales
WHERE fiscal_year = 2021
GROUP BY market
ORDER BY net_sales_mln DESC
LIMIT 5;

-- ==============================================
-- Stored Procedure: Get Top N Markets by Net Sales
-- ==============================================

CREATE PROCEDURE `get_top_n_markets_by_net_sales`(
    IN in_fiscal_year INT,
    IN in_top_n INT
)
BEGIN
    SELECT 
        market, 
        ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
    FROM net_sales
    WHERE fiscal_year = in_fiscal_year
    GROUP BY market
    ORDER BY net_sales_mln DESC
    LIMIT in_top_n;
END;

-- ==============================================
-- Stored Procedure: Get Top N Customers by Net Sales in a Given Market
-- ==============================================

CREATE PROCEDURE `get_top_n_customers_by_net_sales`(
    IN in_market VARCHAR(45),
    IN in_fiscal_year INT,
    IN in_top_n INT
)
BEGIN
    SELECT 
        c.customer, 
        ROUND(SUM(s.net_sales) / 1000000, 2) AS net_sales_mln
    FROM net_sales s
    JOIN dim_customer c 
        ON s.customer_code = c.customer_code
    WHERE 
        s.fiscal_year = in_fiscal_year 
        AND s.market = in_market
    GROUP BY c.customer
    ORDER BY net_sales_mln DESC
    LIMIT in_top_n;
END;