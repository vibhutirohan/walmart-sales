show databases;
use walmart_db;
select * from walmart limit 15;
select count(*) from walmart;

select payment_method,count(*) from walmart
group by payment_method;

select branch 
from walmart;

select min(quantity)from walmart;

-- Businees problems -- 
-- 1.Find different payment method and number of transactions , number of qty sold

select 
payment_method,
count(*) as no_payments,
sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- 2.identify the highest rated category in each branch , displayimg the branch, category and avg rating

select 
branch,
category,
avg(rating) as avg_rating,
RANK() over (partition by branch order by avg(rating) desc) AS rannk
from walmart
group by branch , category

-- 3.identify the busiest day for each branch based on the number of transactions

SELECT branch, 
       DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name, 
       COUNT(*) AS no_transactions
FROM walmart
GROUP BY branch, day_name
HAVING no_transactions = (
    SELECT MAX(transaction_count) 
    FROM (
        SELECT branch, DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name, COUNT(*) AS transaction_count
        FROM walmart
        GROUP BY branch, day_name
    ) AS branch_transactions
    WHERE branch_transactions.branch = walmart.branch
);


-- 4. calculate the total quantity of items sold per payment method and list payment_method and total_quantity

select 
payment_method,
sum(quantity) as no_qty_sold
from walmart
group by payment_method

-- 5.Determine the average , minimum and maximum rating of products for each city.list the city,average_rating,min_rating and max_rating and list the city,average_rating,min_rating and max_rating 
select 
city,
category,
min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating
from walmart
group by city , category;


-- 6. calculate the total profit for each category by considering total_profit as (unit_price*quantity * profit_margin) and also list the category and total_profit,ordered from highest to lowest profit.

select 
category,
sum(total) as total_revenue,
sum(total*profit_margin) as profit
from walmart
group by category


-- 7.determine the most common payment method for each branch.
-- display branch and the preferred_payment_method.

SELECT branch, 
       payment_method, 
       total_trans
FROM (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY branch, payment_method
) AS ranked_payments
WHERE rnk = 1;

-- 8.categorize the sales into 3 group morning , afternoon and evening
-- find out which of the shift and number of invoices 

SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;



-- 9. Identify 5 branch with highest decrease ratio in revenue comapre to last year(current year 2023 and last year 2022)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;





