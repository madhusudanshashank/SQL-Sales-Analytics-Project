-- ==============================================
-- SQL Sales Analytics Project: Sales Analysis
-- ==============================================

-- Get the net_invoice_sales amount using CTEs
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
    JOIN fact_gross_price g 
        ON g.fiscal_year = s.fiscal_year 
        AND g.product_code = s.product_code
    JOIN fact_pre_invoice_deductions pre
        ON pre.customer_code = s.customer_code 
        AND pre.fiscal_year = s.fiscal_year
    WHERE s.fiscal_year = 2021
) 
SELECT 
    *, 
    (gross_price_total - pre_invoice_discount_pct * gross_price_total) AS net_invoice_sales
FROM cte1
LIMIT 1500000;

-- ==============================================
-- Creating Views: Pre-Invoice Discount Sales
-- ==============================================

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
JOIN fact_gross_price g 
    ON g.fiscal_year = s.fiscal_year 
    AND g.product_code = s.product_code
JOIN fact_pre_invoice_deductions pre
    ON pre.customer_code = s.customer_code 
    AND pre.fiscal_year = s.fiscal_year;

-- Generated net_invoice_sales using the created view
SELECT 
    *, 
    (gross_price_total - pre_invoice_discount_pct * gross_price_total) AS net_invoice_sales
FROM gdb0041.sales_preinv_discount;

-- ==============================================
-- Creating Views: Post Invoice Discount & Net Sales
-- ==============================================

-- Created a view for post invoice deductions
CREATE VIEW sales_postinv_discount AS
SELECT 
    s.date, 
    s.fiscal_year,
    s.customer_code, 
    s.market,
    s.product_code, 
    s.product, 
    s.variant,
    s.sold_quantity, 
    s.gross_price_total,
    s.pre_invoice_discount_pct,
    (s.gross_price_total - s.pre_invoice_discount_pct * s.gross_price_total) AS net_invoice_sales,
    (po.discounts_pct + po.other_deductions_pct) AS post_invoice_discount_pct
FROM sales_preinv_discount s
JOIN fact_post_invoice_deductions po
    ON po.customer_code = s.customer_code 
    AND po.product_code = s.product_code 
    AND po.date = s.date;

-- Created a report for net sales
SELECT 
    *, 
    net_invoice_sales * (1 - post_invoice_discount_pct) AS net_sales
FROM gdb0041.sales_postinv_discount;

-- Create the final net_sales view
CREATE VIEW net_sales AS
SELECT 
    *, 
    net_invoice_sales * (1 - post_invoice_discount_pct) AS net_sales
FROM gdb0041.sales_postinv_discount;
