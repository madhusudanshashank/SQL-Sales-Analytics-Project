-- ***************************************
-- User-Defined SQL Functions for Sales Analysis
-- ***************************************

-- a. Retrieved customer codes for 'Croma' in the India market
SELECT * 
FROM dim_customer 
WHERE customer LIKE "%croma%" 
AND market = "india";

-- b. Got all sales transaction data from fact_sales_monthly 
--    for the customer 'Croma' (customer_code: 90002002) in fiscal year 2021
SELECT * 
FROM fact_sales_monthly 
WHERE customer_code = 90002002 
AND YEAR(DATE_ADD(date, INTERVAL 4 MONTH)) = 2021 
ORDER BY date ASC
LIMIT 100000;

-- c. Created a function 'get_fiscal_year' to calculate the fiscal year
--    based on the given calendar date
DELIMITER $$
CREATE FUNCTION get_fiscal_year(calendar_date DATE) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE fiscal_year INT;
    SET fiscal_year = YEAR(DATE_ADD(calendar_date, INTERVAL 4 MONTH));
    RETURN fiscal_year;
END $$
DELIMITER ;

-- d. Used the created function to replace the fiscal year calculation in step (b)
SELECT * 
FROM fact_sales_monthly 
WHERE customer_code = 90002002 
AND get_fiscal_year(date) = 2021 
ORDER BY date ASC
LIMIT 100000;
