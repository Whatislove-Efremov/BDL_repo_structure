-- Часть 1
-- Задача 1: Вывести для каждой продажи название продукта, его категорию и магазин (предполагается shops.address и связь идёт через employee -> shop)

SELECT s.sales_id, p.product_name AS item_name, s.total_price AS amount,
       sh.address
FROM sales s
LEFT JOIN products p ON s.product_id = p.product_id
LEFT JOIN employees e ON s.employee_id = e.employee_id
LEFT JOIN shops sh ON e.shop_id = sh.shop_id

--sales_id	item_name	amount	address
--1	Baby Wet Wipes #13	37.6	SHOP0038 Thomas Crest
--2	Wholegrain Bread	14.46	SHOP0069 Cooper Wells
--3	Sourdough Baguette Premium	35.32	SHOP0057 Emily Way
--4	Granola Bar Classic	37.19	SHOP0005 Lopez Groves
--5	Sesame Crackers Premium #27	70.87	SHOP0062 Paula Mills
--6	Tomatoes Premium #14	8.81	SHOP0012 Horn Points
--7	Dish Soap Premium	69.46	SHOP0032 Stephanie Meadow
--8	Baby Wet Wipes Family Pack	14.09	SHOP0005 Lopez Groves
--9	Bananas Family Pack #15	92.53	SHOP0020 Martinez Trail
--10	Red Onions Classic	47.17	SHOP0057 Emily Way


-- Часть 2
-- Задача 1: Вывести все магазины расположенные в 'Poland'. Необходимые колонки: shop_id, address, city_name, country.
SELECT s.shop_id, s.address, c.city_name, co.country_name AS country
FROM shops s
JOIN cities c ON s.city_id = c.city_id
JOIN countries co ON c.country_id = co.country_id
WHERE co.country_name = 'Poland';

--shop_id	address	city_name	country
--69	SHOP0069 Cooper Wells	Warsaw	Poland
--70	SHOP0070 Moses Land	Krakow	Poland
--71	SHOP0071 Candace Plaza	Gdansk	Poland
--72	SHOP0072 Kiara Gardens	Wroclaw	Poland

-- Задача 2: Вывести все транзакции с суммой продажи выше 1500 (total_price > 1500) для продуктов класса B (class = 'B'), выполнить сортировку по номеру транзакции
SELECT transaction_number, product_name, total_price AS amount, customer_id, sales_timestamp
FROM sales
INNER JOIN products ON sales.product_id = products.product_id
WHERE total_price > 1500 and class = 'B'
ORDER BY transaction_number;

--transaction_number	product_name	amount	customer_id	sales_timestamp
--T0000065754	Rice Drink #19	2489.0	68738	2022-02-01 09:52:09
--T0000138175	Chickpeas in Brine Classic	5199.03	26841	2022-12-20 23:03:48
--T0000200718	Apple Juice Cloudy Premium	1606.9	83875	2023-07-22 10:44:08
--T0000201124	Trail Mix Small Pack	27641.57	46164	2023-05-02 04:03:45
--T0000246805	Trail Mix Small Pack	9433.87	97994	2023-05-15 13:20:36
--T0000284570	Baby Cereal Premium	2784.97	34588	2022-07-02 13:28:27
--T0000290202	Toothpaste Natural Family Pack	17752.42	38950	2022-06-30 16:32:13
--T0000341209	Shampoo Herbal Small Pack	24829.27	95509	2022-02-28 06:40:23
--T0000348305	Tomatoes Classic #24	17827.01	63490	2022-11-26 22:38:17
--T0000383895	Pork Tenderloin Family Pack	1995.2	83821	2022-04-20 08:03:41

-- Часть 3
-- Задача 1 Сделать сортировку по убыванию и добавить описание про сортивку (где есть order by) *
SELECT co.country_name, COUNT(*) AS shops_count
FROM shops s
JOIN cities c ON s.city_id = c.city_id
JOIN countries co ON c.country_id = co.country_id
GROUP BY co.country_name
Order BY shops_count Desc;

--country_name	shops_count
--Germany	33
--France	17
--Italy	11
--Spain	7
--Poland	4

-- Часть 4
---- Задача 1: Вывести по каждому продукту сумму продаж и средний чек, где сумма продаж выше 400000. Так же отсортируйте вывод по сумме продаж по убыванию. 
SELECT p.product_name,
       SUM(s.total_price) AS total_revenue,
       AVG(s.total_price) AS avg_sale
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
Having SUM(s.total_price) > 400000.0
ORDER BY total_revenue DESC;

--product_name	total_revenue	avg_sale
--Probiotic Kefir Premium	670348.650061607	173.755482131054
--Ginger Shot Premium #35	641426.790279388	165.486787997778
--Raspberries Classic #33	636396.342625618	165.040545286727
--Kombucha Classic	636296.010206223	160.235711459638
--Apple Juice Cloudy Small Pack #17	612397.039433479	155.509659581889
--Ginger Shot Premium #20	608963.629154205	152.545999287126
--Apple Juice Cloudy Premium	598046.890157223	146.976379984572
--Shrimp Cleaned Family Pack	593417.030457497	151.730255806059
--Cold Pressed Orange Juice Family Pack	588786.032419205	149.022027947154
--Turkey Fillet Family Pack	581475.719855309	145.368929963827

-- Часть 5
-- Задача 1: Вывести Имя и Фамилию продавца, который совершил продажу с максимальной суммой и вывести адрес магазина, в котором он работает.

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

--first_name	last_name	address	max_amount
--David	James	SHOP0009 Hart Locks	113089.86


-- Часть 6
-- Задача 1: Найти выручку всех магазинов в Германии по месяцам и разницу с предыдущим месяцем. Применить сортировку по месяцам по возрастанию.

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

--sale_month	monthly_revenue	previous_month_revenue	revenue_diff_vs_previous
--2022-01-01 00:00:00.000	2,637,839.5	0	2,637,839.5
--2022-02-01 00:00:00.000	2,710,832	2,637,839.5	72,992.5
--2022-03-01 00:00:00.000	2,686,517	2,710,832	-24,315
--2022-04-01 00:00:00.000	2,597,123	2,686,517	-89,394
--2022-05-01 00:00:00.000	2,807,940.5	2,597,123	210,817.5
--2022-06-01 00:00:00.000	3,166,331.8	2,807,940.5	358,391.25
--2022-07-01 00:00:00.000	3,805,562.2	3,166,331.8	639,230.5
--2022-08-01 00:00:00.000	3,066,425.5	3,805,562.2	-739,136.75
--2022-09-01 00:00:00.000	2,750,298	3,066,425.5	-316,127.5
--2022-10-01 00:00:00.000	2,704,759.5	2,750,298	-45,538.5
--2022-11-01 00:00:00.000	3,000,739.5	2,704,759.5	295,980
--2022-12-01 00:00:00.000	3,274,583.8	3,000,739.5	273,844.25
--2023-01-01 00:00:00.000	2,835,318.5	3,274,583.8	-439,265.25
--2023-02-01 00:00:00.000	2,584,139.5	2,835,318.5	-251,179
--2023-03-01 00:00:00.000	2,697,720.2	2,584,139.5	113,580.75
--2023-04-01 00:00:00.000	2,653,246	2,697,720.2	-44,474.25
--2023-05-01 00:00:00.000	2,865,435.5	2,653,246	212,189.5
--2023-06-01 00:00:00.000	3,096,709.8	2,865,435.5	231,274.25
--2023-07-01 00:00:00.000	3,827,584.2	3,096,709.8	730,874.5
--2023-08-01 00:00:00.000	3,035,754.5	3,827,584.2	-791,829.75
--2023-09-01 00:00:00.000	2,829,696	3,035,754.5	-206,058.5
--2023-10-01 00:00:00.000	2,759,848	2,829,696	-69,848
--2023-11-01 00:00:00.000	2,898,614.8	2,759,848	138,766.75
--2023-12-01 00:00:00.000	3,289,171.8	2,898,614.8	390,557

-- Часть 7 Финал
--Для каждого магазина рассчитать агрегаты продаж и аналитические показатели в разрезе страны.
--
--Для каждого магазина посчитать:
--
--количество продаж (COUNT(sales_id))
--общую сумму продаж (SUM(total_price))
--
--Оставить только магазины, у которых не менее 2 продаж.
--
--
--
--Для каждого такого магазина рассчитать:
--
--долю оборота магазина от общего оборота страны
--ранг магазина по сумме продаж внутри своей страны
--накопительный оборот по стране,
--отсортированный по убыванию оборота магазина
--
--Отсортировать результат:
--
--по стране
--по рангу магазина

WITH shop_sales AS (
    SELECT
        sh.shop_id,
        sh.address AS shop_address,
        co.country_name AS country,
        COUNT(sa.sales_id) AS total_sales_count,
        SUM(sa.total_price) AS total_sales_amount
    FROM shops sh
    JOIN cities ci
        ON sh.city_id = ci.city_id
    JOIN countries co
        ON ci.country_id = co.country_id
    JOIN employees e
        ON e.shop_id = sh.shop_id
    JOIN sales sa
        ON sa.employee_id = e.employee_id
    GROUP BY
        sh.shop_id,
        sh.address,
        co.country_name
    HAVING
        COUNT(sa.sales_id) >= 2
),
country_analytics AS (
    SELECT
        shop_id,
        shop_address,
        country,
        total_sales_count,
        total_sales_amount,

        -- Общий оборот страны
        SUM(total_sales_amount) OVER (
            PARTITION BY country
        ) AS country_total_sales_amount,

        -- Доля оборота магазина от оборота страны
        CAST(total_sales_amount AS decimal(18, 4))
            / NULLIF(
                SUM(total_sales_amount) OVER (PARTITION BY country),
                0
            ) AS country_sales_share,

        -- Ранг магазина по обороту внутри страны
        RANK() OVER (
            PARTITION BY country
            ORDER BY total_sales_amount DESC
        ) AS sales_rank_in_country,

        -- Накопительный оборот по стране (по убыванию оборота магазина)
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

--country	shop_id	shop_address	total_sales_count	total_sales_amount	country_total_sales_amount	country_sales_share	sales_rank_in_country	country_running_total
--France	45	SHOP0045 Roberson Passage	44,173	4,623,372	29,386,372	0.1573304115	1	4,623,372
--France	49	SHOP0049 Victor Hill	44,245	2,881,031.8	29,386,372	0.0980396627	2	7,504,404
--France	41	SHOP0041 Thomas Streets	38,238	2,609,654.5	29,386,372	0.0888047698	3	10,114,058
--France	46	SHOP0046 Eric Villages	37,768	2,413,400.8	29,386,372	0.0821265041	4	12,527,459
--France	43	SHOP0043 Samuel Hills	31,558	2,341,045.8	29,386,372	0.0796644785	5	14,868,505
--France	36	SHOP0036 Joseph Walk	24,806	2,191,633.2	29,386,372	0.0745798086	6	17,060,138
--France	39	SHOP0039 Jones Manors	18,908	1,800,006.4	29,386,372	0.0612532231	7	18,860,144
--France	42	SHOP0042 Michele Plains	19,146	1,683,944.9	29,386,372	0.057303433	8	20,544,088
--France	38	SHOP0038 Thomas Crest	31,425	1,631,598.4	29,386,372	0.0555223353	9	22,175,686
--France	44	SHOP0044 Matthew Shore	18,650	1,303,286.4	29,386,372	0.0443501498	10	23,478,972
--France	34	SHOP0034 Pamela Stream	18,635	1,246,823.5	29,386,372	0.0424285107	11	24,725,796
--France	35	SHOP0035 William Roads	18,691	1,240,735.5	29,386,372	0.0422216121	12	25,966,532
--France	40	SHOP0040 Hernandez Trace	12,721	853,241.25	29,386,372	0.0290352617	13	26,819,774
--France	37	SHOP0037 Tyler Union	18,917	800,465.6	29,386,372	0.0272393612	14	27,620,240
--France	47	SHOP0047 Dunn Squares	31,405	663,919.8	29,386,372	0.0225927855	15	28,284,160
--France	48	SHOP0048 Myers Springs	12,577	655,152.25	29,386,372	0.0222944159	16	28,939,312
--France	50	SHOP0050 Jordan Spurs	12,685	447,059.97	29,386,372	0.0152131743	17	29,386,372
--Germany	12	SHOP0012 Horn Points	50,266	6,992,784	70,592,820	0.0990579551	1	6,992,784
--Germany	23	SHOP0023 Rush Manors	62,875	6,029,855	70,592,820	0.0854174736	2	13,022,639
--Germany	26	SHOP0026 Murray Path	44,446	4,583,239.5	70,592,820	0.0649250201	3	17,605,878
--Germany	27	SHOP0027 Karen Falls	43,999	3,729,154.2	70,592,820	0.0528261969	4	21,335,032
--Germany	22	SHOP0022 Baker Via	37,745	3,410,613.5	70,592,820	0.0483138398	5	24,745,646
