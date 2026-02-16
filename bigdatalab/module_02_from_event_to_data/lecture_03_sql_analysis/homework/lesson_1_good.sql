-- Lesson 1: SQL Analysis Fundamentals
-- Good Implementation

-- Part 1: JOIN (Data Linking)
-- Task 1: Display for each sale the product name, category, and store address
SELECT s.sales_id, p.product_name AS item_name, c.category_name AS category, sh.address
FROM sales s, products p, categories c, employees e, shops sh
WHERE s.product_id = p.product_id
AND p.category_id = c.category_id
AND s.employee_id = e.employee_id
AND e.shop_id = sh.shop_id;

-- Part 2: WHERE (Data Filtering)
-- Task 1: Display all stores located in 'Poland'
SELECT s.shop_id, s.address, ci.city_name, co.country_name AS country
FROM shops s, cities ci, countries co
WHERE s.city_id = ci.city_id
AND ci.country_id = co.country_id
AND co.country_name = 'Poland';

-- Task 2: Display transactions with sales amount above 1500 for class B products, sorted by transaction number
SELECT s.transaction_number, p.product_name, s.total_price AS amount, s.customer_id, s.sales_timestamp
FROM sales s, products p
WHERE s.product_id = p.product_id
AND s.total_price > 1500
AND p.class = 'B'
ORDER BY s.transaction_number;

-- Part 3: GROUP BY (Aggregation)
-- Task 1: Show the count of stores in each country, sorted by store count in descending order
SELECT co.country_name, COUNT(s.shop_id) AS shops_count
FROM shops s, cities ci, countries co
WHERE s.city_id = ci.city_id
AND ci.country_id = co.country_id
GROUP BY co.country_name
ORDER BY COUNT(s.shop_id) DESC;

-- Part 4: HAVING (Filtering Aggregated Data)
-- Task 1: For each product show total sales amount and average sale, where total sales exceed 400,000, sorted by total sales in descending order
SELECT p.product_name,
       SUM(s.total_price) AS total_revenue,
       AVG(s.total_price) AS avg_sale
FROM sales s, products p
WHERE s.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(s.total_price) > 400000.00
ORDER BY SUM(s.total_price) DESC;

-- Part 5: SUBQUERIES (Complex Data Retrieval)
-- Task 1: Show the name and surname of the seller who made the highest-value sale and the address of the store where they work
SELECT e.first_name, e.last_name, sh.address, s.total_price AS max_amount
FROM sales s, employees e, shops sh
WHERE s.employee_id = e.employee_id
AND e.shop_id = sh.shop_id
AND s.total_price >= ALL (SELECT total_price FROM sales);

-- Part 6: WINDOW FUNCTIONS (Analytical Calculations)
-- Task 1: Find revenue of all German stores by month and difference with previous month, sorted by month in ascending order
SELECT
    DATE_TRUNC('month', TO_TIMESTAMP(sales_timestamp, 'YYYY-MM-DD HH24:MI:SS')) AS sale_month,
    SUM(s.total_price) AS monthly_revenue,
    LAG(SUM(s.total_price), 1) OVER (ORDER BY DATE_TRUNC('month', TO_TIMESTAMP(sales_timestamp, 'YYYY-MM-DD HH24:MI:SS'))) AS previous_month_revenue,
    SUM(s.total_price) - LAG(SUM(s.total_price), 1) OVER (ORDER BY DATE_TRUNC('month', TO_TIMESTAMP(sales_timestamp, 'YYYY-MM-DD HH24:MI:SS'))) AS revenue_diff_vs_previous
FROM sales s, employees e, shops sh, cities ci, countries co
WHERE s.employee_id = e.employee_id
AND e.shop_id = sh.shop_id
AND sh.city_id = ci.city_id
AND ci.country_id = co.country_id
AND co.country_name = 'Germany'
GROUP BY DATE_TRUNC('month', TO_TIMESTAMP(sales_timestamp, 'YYYY-MM-DD HH24:MI:SS'))
ORDER BY DATE_TRUNC('month', TO_TIMESTAMP(sales_timestamp, 'YYYY-MM-DD HH24:MI:SS'));

-- Part 7: COMPREHENSIVE ANALYSIS TASK
-- For each store, calculate sales aggregates and analytical metrics by country
WITH shop_sales AS (
    SELECT
        sh.shop_id,
        sh.shop_address,
        co.country_name AS country,
        COUNT(s.sales_id) AS total_sales_count,
        SUM(s.total_price) AS total_sales_amount
    FROM shops sh, cities ci, countries co, employees e, sales s
    WHERE sh.city_id = ci.city_id
    AND ci.country_id = co.country_id
    AND e.shop_id = sh.shop_id
    AND s.employee_id = e.employee_id
    GROUP BY sh.shop_id, sh.shop_address, co.country_name
    HAVING COUNT(s.sales_id) >= 2
),
country_totals AS (
    SELECT
        country,
        SUM(total_sales_amount) AS country_total_sales
    FROM shop_sales
    GROUP BY country
),
final_result AS (
    SELECT
        ss.country,
        ss.shop_id,
        ss.shop_address,
        ss.total_sales_count,
        ss.total_sales_amount,
        ct.country_total_sales,
        ROUND(ss.total_sales_amount / ct.country_total_sales, 4) AS country_sales_share
    FROM shop_sales ss
    JOIN country_totals ct ON ss.country = ct.country
)
SELECT
    country,
    shop_id,
    shop_address,
    total_sales_count,
    total_sales_amount,
    country_total_sales,
    country_sales_share,
    (SELECT COUNT(*) + 1
     FROM final_result fr2
     WHERE fr2.country = fr.country
     AND fr2.total_sales_amount > fr.total_sales_amount) AS sales_rank_in_country
FROM final_result fr
ORDER BY country, sales_rank_in_country;