-- Lesson 1: SQL Analysis Fundamentals
-- Perfect Implementation

-- Part 1: JOIN (Data Linking)
-- Task 1: Display for each sale the product name, category, and store address
SELECT s.sales_id, p.product_name AS item_name, s.total_price AS amount,
       sh.address
FROM sales s
LEFT JOIN products p ON s.product_id = p.product_id
LEFT JOIN employees e ON s.employee_id = e.employee_id
LEFT JOIN shops sh ON e.shop_id = sh.shop_id;

-- Part 2: WHERE (Data Filtering)
-- Task 1: Display all stores located in 'Poland'
SELECT s.shop_id, s.address, c.city_name, co.country_name AS country
FROM shops s
JOIN cities c ON s.city_id = c.city_id
JOIN countries co ON c.country_id = co.country_id
WHERE co.country_name = 'Poland';

-- Task 2: Display transactions with sales amount above 1500 for class B products, sorted by transaction number
SELECT transaction_number, product_name, total_price AS amount, customer_id, sales_timestamp
FROM sales
INNER JOIN products ON sales.product_id = products.product_id
WHERE total_price > 1500 and class = 'B'
ORDER BY transaction_number;

-- Part 3: GROUP BY (Aggregation)
-- Task 1: Show the count of stores in each country, sorted by store count in descending order
SELECT co.country_name, COUNT(*) AS shops_count
FROM shops s
JOIN cities c ON s.city_id = c.city_id
JOIN countries co ON c.country_id = co.country_id
GROUP BY co.country_name
ORDER BY shops_count DESC;

-- Part 4: HAVING (Filtering Aggregated Data)
-- Task 1: For each product show total sales amount and average sale, where total sales exceed 400,000, sorted by total sales in descending order
SELECT p.product_name,
       SUM(s.total_price) AS total_revenue,
       AVG(s.total_price) AS avg_sale
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(s.total_price) > 400000.0
ORDER BY total_revenue DESC;

-- Part 5: SUBQUERIES (Complex Data Retrieval)
-- Task 1: Show the name and surname of the seller who made the highest-value sale and the address of the store where they work
SELECT
    e.first_name,
    e.last_name,
    sh.address,
    s.total_price AS max_amount
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN shops sh ON e.shop_id = sh.shop_id
WHERE s.total_price = (
    SELECT MAX(total_price)
    FROM sales
);

-- Part 6: WINDOW FUNCTIONS (Analytical Calculations)
-- Task 1: Find revenue of all German stores by month and difference with previous month, sorted by month in ascending order
WITH monthly_revenue AS (
    SELECT
        date_trunc(
            'month',
            NULLIF(s.sales_timestamp, '')::timestamp
        ) AS sale_month,
        SUM(s.total_price) AS monthly_revenue
    FROM sales s
    JOIN employees e ON s.employee_id = e.employee_id
    JOIN shops sh     ON e.shop_id = sh.shop_id
    JOIN cities c     ON sh.city_id = c.city_id
    JOIN countries co ON c.country_id = co.country_id
    WHERE co.country_name = 'Germany'
      AND NULLIF(s.sales_timestamp, '') IS NOT NULL
    GROUP BY 1
)

SELECT
    sale_month,
    monthly_revenue,
    LAG(monthly_revenue, 1, 0) OVER (ORDER BY sale_month) AS previous_month_revenue,
    monthly_revenue
        - LAG(monthly_revenue, 1, 0) OVER (ORDER BY sale_month) AS revenue_diff_vs_previous
FROM monthly_revenue
ORDER BY sale_month;

-- Part 7: COMPREHENSIVE ANALYSIS TASK
-- For each store, calculate sales aggregates and analytical metrics by country
WITH shop_sales AS (
    SELECT
        sh.shop_id,
        sh.shop_address,
        co.country_name AS country,
        COUNT(sa.sales_id) AS total_sales_count,
        SUM(sa.total_price) AS total_sales_amount
    FROM shops sh
    JOIN cities ci ON sh.city_id = ci.city_id
    JOIN countries co ON ci.country_id = co.country_id
    JOIN employees e ON e.shop_id = sh.shop_id
    JOIN sales sa ON sa.employee_id = e.employee_id
    GROUP BY sh.shop_id, sh.shop_address, co.country_name
    HAVING COUNT(sa.sales_id) >= 2
),
country_analytics AS (
    SELECT
        shop_id,
        shop_address,
        country,
        total_sales_count,
        total_sales_amount,

        -- Country's total sales amount
        SUM(total_sales_amount) OVER (
            PARTITION BY country
        ) AS country_total_sales_amount,

        -- Store's share of country's revenue
        CAST(total_sales_amount AS decimal(18, 4))
            / NULLIF(
                SUM(total_sales_amount) OVER (PARTITION BY country),
                0
            ) AS country_sales_share,

        -- Rank store by sales amount within country
        RANK() OVER (
            PARTITION BY country
            ORDER BY total_sales_amount DESC
        ) AS sales_rank_in_country,

        -- Cumulative revenue by country, sorted by descending store revenue
        SUM(total_sales_amount) OVER (
            PARTITION BY country
            ORDER BY total_sales_amount DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS country_running_total
    FROM shop_sales
)

SELECT
    country,
    shop_id,
    shop_address,
    total_sales_count,
    total_sales_amount,
    country_total_sales_amount,
    country_sales_share,
    sales_rank_in_country,
    country_running_total
FROM country_analytics
ORDER BY
    country,
    sales_rank_in_country;