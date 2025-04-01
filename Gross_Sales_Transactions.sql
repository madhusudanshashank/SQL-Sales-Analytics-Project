-- ***************************************
-- Module: Gross Sales Report - Monthly Product Transactions
-- ***************************************

-- a. Performed joins to pull product information
SELECT 
    s.date, 
    s.product_code, 
    p.product, 
    p.variant, 
    s.sold_quantity 
FROM fact_sales_monthly s
JOIN dim_product p
    ON s.product_code = p.product_code
WHERE 
    customer_code = 90002002 
    AND get_fiscal_year(date) = 2021     
LIMIT 1000000;

-- b. Performed join with 'fact_gross_price' table and generate required fields
SELECT 
    s.date, 
    s.product_code, 
    p.product, 
    p.variant, 
    s.sold_quantity, 
    g.gross_price,
    ROUND(s.sold_quantity * g.gross_price, 2) AS gross_price_total
FROM fact_sales_monthly s
JOIN dim_product p
    ON s.product_code = p.product_code
JOIN fact_gross_price g
    ON g.fiscal_year = get_fiscal_year(s.date)
    AND g.product_code = s.product_code
WHERE 
    customer_code = 90002002 
    AND get_fiscal_year(s.date) = 2021     
LIMIT 1000000;