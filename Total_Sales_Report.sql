-- ***************************************
-- Module: Gross Sales Report - Total Sales Amount
-- ***************************************

-- Generated monthly gross sales report for Croma India for all the years
SELECT 
    s.date, 
    SUM(ROUND(s.sold_quantity * g.gross_price, 2)) AS monthly_sales
FROM fact_sales_monthly s
JOIN fact_gross_price g
    ON g.fiscal_year = get_fiscal_year(s.date) 
    AND g.product_code = s.product_code
WHERE 
    customer_code = 90002002
GROUP BY s.date;
