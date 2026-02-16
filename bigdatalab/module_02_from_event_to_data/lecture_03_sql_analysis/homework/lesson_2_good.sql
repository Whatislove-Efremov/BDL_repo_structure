-- Урок 2: Операции обработки данных SQL
-- Хорошая реализация

-- Часть 1 - Операции DML
-- Вставить два новых продукта (с возможными проблемами: например, не указывая все поля)
INSERT INTO products
(product_name, price, category_id, class, resistant, is_allergic, vitality_days)
VALUES
('Organic Mango Box', 19.99, 1, 'B', 'No', 'No', 7),
('Bananas Family Pack', 5.49, 1, 'C', 'No', 'No', 5);

-- Выбрать продукты, где is_allergic = 'Yes' и vitality_days > 0
SELECT *
FROM products
WHERE is_allergic = 'Yes'
  AND vitality_days > 0;

-- Обновить is_allergic для 'Bananas Family Pack' на 'Yes'
UPDATE products
SET is_allergic = 'Yes'
WHERE product_name = 'Bananas Family Pack';

-- Удалить один из добавленных продуктов
DELETE FROM products
WHERE product_name = 'Organic Mango Box';

-- Проверка всех изменений
SELECT * FROM products;

-- Часть 2 - Операции DDL
-- Создать таблицу Data_Layers (без ограничений изначально)
CREATE TABLE data_layers (
    layerid SERIAL,
    layername VARCHAR(50),
    description TEXT
);

-- Добавить PRIMARY KEY позже
ALTER TABLE data_layers ADD PRIMARY KEY (layerid);

-- Заполнить столбец LayerName тремя значениями: 'Bronze', 'Silver', 'Gold'
INSERT INTO data_layers (layername, description)
VALUES
('Bronze', 'Слой необработанных данных'),
('Silver', 'Очищенные и преобразованные данные'),
('Gold', 'Готовый к использованию аналитический слой');

-- Добавить manager_email в data_layers (без ограничений изначально)
ALTER TABLE data_layers
ADD COLUMN manager_email VARCHAR(100);

-- Добавить manager_email в shops (без значений изначально)
ALTER TABLE shops
ADD COLUMN manager_email VARCHAR(100);

-- Заполнить email'ы, чтобы избежать ошибки при добавлении UNIQUE ограничения
UPDATE shops
SET manager_email = 'manager_' || shop_id || '@eco.com';

-- Теперь добавить UNIQUE ограничение
ALTER TABLE shops
ADD CONSTRAINT unique_manager_email UNIQUE (manager_email);

-- Переименовать address → shop_address
ALTER TABLE shops
RENAME COLUMN address TO shop_address;

-- Часть 3 - Операции DCL
-- Создать роль (с более простым паролем)
CREATE ROLE data_engineer_trainee
LOGIN
PASSWORD 'password';

-- Предоставить SELECT на Sales
GRANT SELECT ON sales TO data_engineer_trainee;

-- Часть 4 - Расширенные DML с транзакциями
-- Увеличить цены на Dairy на 10% (менее эффективный способ с JOIN)
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

-- Вставить продажу для этого сотрудника
INSERT INTO sales
(employee_id, customer_id, product_id, quantity, discount, total_price, sales_timestamp, transaction_number)
VALUES
((SELECT employee_id FROM employees WHERE first_name = 'John' AND last_name = 'Smith' ORDER BY employee_id DESC LIMIT 1),
 1, 1, 2, 0.1, 50, NOW()::text, 'TXN_NEW_001');

COMMIT;

-- Часть 5 - Функции и представления для Gold Layer
-- Создать функцию AvgSalesPerEmployee (PL/pgSQL) для вычисления средних продаж для сотрудника
CREATE OR REPLACE FUNCTION AvgSalesPerEmployee(emp_id INT)
RETURNS NUMERIC AS
$$
DECLARE
    avg_sales NUMERIC;
BEGIN
    -- Проверить, существует ли сотрудник
    IF NOT EXISTS (SELECT 1 FROM employees WHERE employee_id = emp_id) THEN
        RETURN NULL;
    END IF;

    SELECT AVG(total_price)
    INTO avg_sales
    FROM sales
    WHERE employee_id = emp_id;

    -- Вернуть 0, если нет продаж
    IF avg_sales IS NULL THEN
        RETURN 0;
    ELSE
        RETURN avg_sales;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Создать представление FullStatShops для агрегированных статистик магазинов со столбцами (shop_id, shop_address, country, total_sales_count, total_sales_amount)
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

-- Часть 6 - Расширенные DML операции
-- Найти сотрудников с продажами > 1000
SELECT employee_id, SUM(total_price) AS total_sales
FROM sales
GROUP BY employee_id
HAVING SUM(total_price) > 1000
ORDER BY total_sales DESC;

-- Обновить классификацию продукта на 'A' для категорий с общей выручкой > 5000 (с использованием курсора - более сложный подход)
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

-- Установить modify_timestamp для продуктов без дат
UPDATE products
SET modify_timestamp = NOW()::text
WHERE modify_timestamp IS NULL
   OR TRIM(COALESCE(modify_timestamp, '')) = '';