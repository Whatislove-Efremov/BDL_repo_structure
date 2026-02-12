--Часть 1 - DML (Perfect Implementation)
--Вставить два новых продукта

INSERT INTO products
(product_name, price, category_id, class, modify_timestamp, resistant, is_allergic, vitality_days)
VALUES
('Organic Mango Box', 19.99, 1, 'B', NOW()::text, 'No', 'No', 7),
('Bananas Family Pack', 5.49, 1, 'C', NOW()::text, 'No', 'No', 5);

--Выбрать продукты где is_allergic = 'Yes' и vitality_days > 0
SELECT *
FROM products
WHERE is_allergic = 'Yes'
  AND vitality_days > 0;

--Обновить is_allergic для 'Bananas Family Pack' на 'Yes'
UPDATE products
SET is_allergic = 'Yes',
    modify_timestamp = NOW()::text
WHERE product_name = 'Bananas Family Pack';

--Удалить один из добавленных продуктов
DELETE FROM products
WHERE product_name = 'Organic Mango Box';

--Проверка
SELECT * FROM products;

--Часть 2 — DDL (Perfect Implementation)
-- Создать таблицу Data_Layers с правильной структурой сразу
CREATE TABLE IF NOT EXISTS data_layers (
    layerid SERIAL PRIMARY KEY,
    layername VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- Заполнить слоями
INSERT INTO data_layers (layername, description)
VALUES
('Bronze', 'Raw data layer'),
('Silver', 'Cleaned and transformed data'),
('Gold', 'Business-ready analytical layer');

-- Добавить manager_email в data_layers
ALTER TABLE data_layers
ADD COLUMN IF NOT EXISTS manager_email VARCHAR(100);

-- Добавить manager_email в shops и сразу сделать UNIQUE (с правильным заполнением)
ALTER TABLE shops
ADD COLUMN IF NOT EXISTS manager_email VARCHAR(100);

-- Заполняем email'ы уникальными значениями
UPDATE shops
SET manager_email = 'manager_' || shop_id || '@eco.com'
WHERE manager_email IS NULL;

-- Добавляем ограничение UNIQUE
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unique_manager_email') THEN
        ALTER TABLE shops ADD CONSTRAINT unique_manager_email UNIQUE (manager_email);
    END IF;
END $$;

-- Переименовать address → shop_address
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shops' AND column_name = 'address') THEN
        ALTER TABLE shops RENAME COLUMN address TO shop_address;
    END IF;
END $$;

--Часть 3 — DCL (Perfect Implementation)
-- Создать роль с безопасным паролем
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='data_engineer_trainee') THEN
      CREATE ROLE data_engineer_trainee LOGIN PASSWORD 'SecurePass123!';
   END IF;
END$$;

-- Дать SELECT на Sales
GRANT SELECT ON sales TO data_engineer_trainee;

--Часть 4 — DML + Транзакции (Perfect Implementation)
-- Увеличить цены Dairy на 10% (эффективный способ с JOIN)
UPDATE products p
SET price = price * 1.10,
    modify_timestamp = NOW()::text
FROM categories c
WHERE p.category_id = c.category_id
  AND c.category_name = 'Dairy';

-- Удалить сотрудников без продаж (эффективный способ с NOT EXISTS)
DELETE FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.employee_id = e.employee_id
);

-- Вставить сотрудника и продажу в транзакции с возвратом ID
BEGIN;
WITH inserted_employee AS (
    INSERT INTO employees
    (first_name, middle_initial, last_name, birth_date, gender, city_id, hire_date, shop_id)
    VALUES
    ('John', 'A', 'Smith', '1995-05-10', 'M', 1, NOW()::text, 1)
    RETURNING employee_id
)
INSERT INTO sales
(employee_id, customer_id, product_id, quantity, discount, total_price, sales_timestamp, transaction_number)
SELECT 
    ie.employee_id,
    1, 1, 2, 0.1, 50, NOW()::text, 'TXN_NEW_001'
FROM inserted_employee ie;
COMMIT;

--Часть 5 — Функции и Views (Gold Layer) (Perfect Implementation)
-- Функция AvgSalesPerEmployee (оптимизированная)
CREATE OR REPLACE FUNCTION AvgSalesPerEmployee(emp_id INT)
RETURNS NUMERIC AS
$$
DECLARE
    avg_sales NUMERIC;
BEGIN
    SELECT AVG(total_price)
    INTO avg_sales
    FROM sales
    WHERE employee_id = emp_id;

    RETURN COALESCE(avg_sales, 0);
END;
$$ LANGUAGE plpgsql;

-- Пример вызова:
-- SELECT AvgSalesPerEmployee(1);

-- View FullStatShops (оптимизированная с эффективными JOIN)
CREATE OR REPLACE VIEW FullStatShops AS
SELECT
    sh.shop_id,
    sh.shop_address,
    co.country_name AS country,
    COUNT(s.sales_id) AS total_sales_count,
    COALESCE(SUM(s.total_price), 0) AS total_sales_amount
FROM shops sh
JOIN cities ci ON sh.city_id = ci.city_id
JOIN countries co ON ci.country_id = co.country_id
LEFT JOIN employees e ON e.shop_id = sh.shop_id
LEFT JOIN sales s ON s.employee_id = e.employee_id
GROUP BY sh.shop_id, sh.shop_address, co.country_name, co.country_name;

--Часть 6 — Продвинутый DML (Perfect Implementation)
-- Найти сотрудников с продажами > 1000
SELECT employee_id, SUM(total_price) AS total_sales
FROM sales
GROUP BY employee_id
HAVING SUM(total_price) > 1000
ORDER BY total_sales DESC;

-- Обновить класс на 'A' для категорий с выручкой > 5000 (эффективный способ)
UPDATE products
SET class = 'A',
    modify_timestamp = NOW()::text
WHERE category_id = ANY(
    SELECT p.category_id
    FROM products p
    JOIN sales s ON p.product_id = s.product_id
    GROUP BY p.category_id
    HAVING SUM(s.total_price) > 5000
);

-- Установить modify_timestamp если NULL или пустой
UPDATE products
SET modify_timestamp = NOW()::text
WHERE modify_timestamp IS NULL
   OR TRIM(BOTH FROM COALESCE(modify_timestamp, '')) = '';