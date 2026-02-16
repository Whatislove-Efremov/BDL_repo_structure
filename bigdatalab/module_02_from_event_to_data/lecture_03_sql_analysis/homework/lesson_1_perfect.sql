-- Урок 1: Основы SQL-анализа
-- Идеальная реализация

-- Часть 1: JOIN (Соединение данных)
-- Задача 1: Отобразить для каждой продажи название продукта, категорию и адрес магазина
SELECT s.sales_id, p.product_name AS item_name, s.total_price AS amount,
       sh.address
FROM sales s
LEFT JOIN products p ON s.product_id = p.product_id
LEFT JOIN employees e ON s.employee_id = e.employee_id
LEFT JOIN shops sh ON e.shop_id = sh.shop_id;

-- Часть 2: WHERE (Фильтрация данных)
-- Задача 1: Отобразить все магазины, расположенные в 'Poland'
SELECT s.shop_id, s.address, c.city_name, co.country_name AS country
FROM shops s
JOIN cities c ON s.city_id = c.city_id
JOIN countries co ON c.country_id = co.country_id
WHERE co.country_name = 'Poland';

-- Задача 2: Отобразить транзакции с суммой продаж выше 1500 для продуктов класса B, отсортированные по номеру транзакции
SELECT transaction_number, product_name, total_price AS amount, customer_id, sales_timestamp
FROM sales
INNER JOIN products ON sales.product_id = products.product_id
WHERE total_price > 1500 and class = 'B'
ORDER BY transaction_number;

-- Часть 3: GROUP BY (Агрегация)
-- Задача 1: Показать количество магазинов в каждой стране, отсортированное по количеству магазинов по убыванию
SELECT co.country_name, COUNT(*) AS shops_count
FROM shops s
JOIN cities c ON s.city_id = c.city_id
JOIN countries co ON c.country_id = co.country_id
GROUP BY co.country_name
ORDER BY shops_count DESC;

-- Часть 4: HAVING (Фильтрация агрегированных данных)
-- Задача 1: Для каждого продукта показать общую сумму продаж и среднюю продажу, где общая сумма продаж превышает 400 000, отсортированную по общей сумме продаж по убыванию
SELECT p.product_name,
       SUM(s.total_price) AS total_revenue,
       AVG(s.total_price) AS avg_sale
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(s.total_price) > 400000.0
ORDER BY total_revenue DESC;

-- Часть 5: ПОДЗАПРОСЫ (Сложное получение данных)
-- Задача 1: Показать имя и фамилию продавца, совершившего продажу с наибольшей стоимостью, и адрес магазина, в котором он работает
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

-- Часть 6: ОКОННЫЕ ФУНКЦИИ (Аналитические вычисления)
-- Задача 1: Найти выручку всех немецких магазинов по месяцам и разницу с предыдущим месяцем, отсортированную по месяцам по возрастанию
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

-- Часть 7: КОМПЛЕКСНОЕ АНАЛИТИЧЕСКОЕ ЗАДАНИЕ
-- Для каждого магазина рассчитать агрегаты продаж и аналитические метрики по странам
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

        -- Общая сумма продаж страны
        SUM(total_sales_amount) OVER (
            PARTITION BY country
        ) AS country_total_sales_amount,

        -- Доля магазина в доходе страны
        CAST(total_sales_amount AS decimal(18, 4))
            / NULLIF(
                SUM(total_sales_amount) OVER (PARTITION BY country),
                0
            ) AS country_sales_share,

        -- Ранг магазина по сумме продаж внутри страны
        RANK() OVER (
            PARTITION BY country
            ORDER BY total_sales_amount DESC
        ) AS sales_rank_in_country,

        -- Накопительная выручка по стране, отсортированная по убыванию выручки магазина
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