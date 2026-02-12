--Часть 1 - DML (Good Implementation)
--Вставить два новых продукта (с возможными проблемами: например, не указываем все поля)

INSERT INTO products
(product_name, price, category_id, class, resistant, is_allergic, vitality_days)
VALUES
('Organic Mango Box', 19.99, 1, 'B', 'No', 'No', 7),
('Bananas Family Pack', 5.49, 1, 'C', 'No', 'No', 5);

--Выбрать продукты где is_allergic = 'Yes' и vitality_days > 0
SELECT *
FROM products
WHERE is_allergic = 'Yes'
  AND vitality_days > 0;

--Обновить is_allergic для 'Bananas Family Pack' на 'Yes'
UPDATE products
SET is_allergic = 'Yes'
WHERE product_name = 'Bananas Family Pack';

--Удалить один из добавленных продуктов
DELETE FROM products
WHERE product_name = 'Organic Mango Box';

--Проверка
SELECT * FROM products;

--Часть 2 — DDL (Good Implementation)
-- Создать таблицу Data_Layers (сначала без ограничений, потом добавляем)
CREATE TABLE data_layers (
    layerid SERIAL,
    layername VARCHAR(50),
    description TEXT
);

-- Добавляем PRIMARY KEY позже
ALTER TABLE data_layers ADD PRIMARY KEY (layerid);

-- Заполнить слоями
INSERT INTO data_layers (layername, description)
VALUES
('Bronze', 'Raw data layer'),
('Silver', 'Cleaned and transformed data'),
('Gold', 'Business-ready analytical layer');

-- Добавить manager_email (без ограничений сначала)
ALTER TABLE data_layers
ADD COLUMN manager_email VARCHAR(100);

-- Добавить manager_email в shops (сначала без значений)
ALTER TABLE shops
ADD COLUMN manager_email VARCHAR(100);

-- Заполняем email'ы для избежания ошибки при добавлении UNIQUE
UPDATE shops
SET manager_email = 'manager_' || shop_id || '@eco.com';

-- Теперь добавляем ограничение UNIQUE
ALTER TABLE shops
ADD CONSTRAINT unique_manager_email UNIQUE (manager_email);

-- Переименовать address → shop_address
ALTER TABLE shops
RENAME COLUMN address TO shop_address;

--Часть 3 — DCL (Good Implementation)
-- Создать роль (с более простым паролем)
CREATE ROLE data_engineer_trainee
LOGIN
PASSWORD 'password';

-- Дать SELECT на Sales
GRANT SELECT ON sales TO data_engineer_trainee;

-- Тест 1: Подключение как data_engineer_trainee и SELECT из Sales (должно работать)
-- \c your_database_name data_engineer_trainee
-- SELECT * FROM sales LIMIT 5;

-- Попытка INSERT как data_engineer_trainee (должна завершиться ошибкой)
-- INSERT INTO sales VALUES (...); -- Ошибка будет здесь

-- Вернуться к администратору и дать права
-- \c your_database_name your_admin_user
GRANT INSERT, UPDATE ON sales TO data_engineer_trainee;

-- Тест 2: INSERT и UPDATE как data_engineer_trainee (теперь должно работать)
-- \c your_database_name data_engineer_trainee
-- INSERT INTO sales (...) VALUES (...);
-- UPDATE sales SET total_price = total_price * 1.05 WHERE sales_id = 1;

--Часть 4 — DML + Транзакции (Good Implementation)
-- Увеличить цены Dairy на 10% (менее эффективный способ с JOIN)
UPDATE products
SET price = price * 1.10,
    modify_timestamp = NOW()::text
FROM categories
WHERE products.category_id = categories.category_id
  AND categories.category_name = 'Dairy';

-- Удалить сотрудников без продаж (с подзапросом - менее эффективно)
DELETE FROM employees
WHERE NOT EXISTS (
    SELECT 1
    FROM sales
    WHERE sales.employee_id = employees.employee_id
);

-- Вставить сотрудника и продажу в транзакции
BEGIN;

INSERT INTO employees
(first_name, middle_initial, last_name, birth_date, gender, city_id, hire_date, shop_id)
VALUES
('John', 'A', 'Smith', '1995-05-10', 'M', 1, NOW()::text, 1);

-- Вставляем продажу для этого сотрудника
INSERT INTO sales
(employee_id, customer_id, product_id, quantity, discount, total_price, sales_timestamp, transaction_number)
VALUES
((SELECT employee_id FROM employees WHERE first_name = 'John' AND last_name = 'Smith' ORDER BY employee_id DESC LIMIT 1), 
 1, 1, 2, 0.1, 50, NOW()::text, 'TXN_NEW_001');

COMMIT;

--Часть 5 — Функции и Views (Gold Layer) (Good Implementation)
-- Функция AvgSalesPerEmployee (с дополнительными проверками)
CREATE OR REPLACE FUNCTION AvgSalesPerEmployee(emp_id INT)
RETURNS NUMERIC AS
$$
DECLARE
    avg_sales NUMERIC;
BEGIN
    -- Проверяем, существует ли сотрудник
    IF NOT EXISTS (SELECT 1 FROM employees WHERE employee_id = emp_id) THEN
        RETURN NULL;
    END IF;
    
    SELECT AVG(total_price)
    INTO avg_sales
    FROM sales
    WHERE employee_id = emp_id;

    -- Если нет продаж, возвращаем 0
    IF avg_sales IS NULL THEN
        RETURN 0;
    ELSE
        RETURN avg_sales;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Пример вызова:
-- SELECT AvgSalesPerEmployee(1);

-- View FullStatShops (с использованием подзапросов вместо JOIN - менее эффективно)
CREATE OR REPLACE VIEW FullStatShops AS
SELECT
    sh.shop_id,
    sh.shop_address,
    (SELECT co.country_name 
     FROM countries co, cities ci2 
     WHERE ci2.city_id = sh.city_id 
     AND co.country_id = ci2.country_id) AS country,
    (SELECT COUNT(s.sales_id) 
     FROM sales s, employees e2 
     WHERE e2.shop_id = sh.shop_id 
     AND s.employee_id = e2.employee_id) AS total_sales_count,
    (SELECT COALESCE(SUM(s.total_price), 0)
     FROM sales s, employees e2 
     WHERE e2.shop_id = sh.shop_id 
     AND s.employee_id = e2.employee_id) AS total_sales_amount
FROM shops sh;

--Часть 6 — Продвинутый DML (Good Implementation)
-- Найти сотрудников с продажами > 1000
SELECT employee_id, SUM(total_price) AS total_sales
FROM sales
GROUP BY employee_id
HAVING SUM(total_price) > 1000
ORDER BY total_sales DESC;

-- Обновить класс на 'A' для категорий с выручкой > 5000 (с использованием курсора - более сложный способ)
DO $$
DECLARE
    cat_record RECORD;
BEGIN
    FOR cat_record IN
        SELECT p.category_id
        FROM products p
        JOIN sales s ON p.product_id = s.product_id
        GROUP BY p.category_id
        HAVING SUM(s.total_price) > 5000
    LOOP
        UPDATE products
        SET class = 'A',
            modify_timestamp = NOW()::text
        WHERE category_id = cat_record.category_id;
    END LOOP;
END $$;

-- Установить modify_timestamp если NULL или пустой
UPDATE products
SET modify_timestamp = NOW()::text
WHERE modify_timestamp IS NULL
   OR TRIM(COALESCE(modify_timestamp, '')) = '';