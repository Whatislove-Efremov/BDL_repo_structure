-- =========================================
-- ECO MARKET — BRONZE LAYER INITIALIZATION
-- =========================================

-- Опционально: создать отдельную схему
CREATE SCHEMA IF NOT EXISTS bronze;

SET search_path TO bronze;

-- =========================================
-- 1. COUNTRIES
-- =========================================
CREATE TABLE IF NOT EXISTS bronze_countries (
    country_id      INTEGER PRIMARY KEY,
    country_name    VARCHAR(100) NOT NULL,
    country_code    VARCHAR(10)
);

-- =========================================
-- 2. CITIES
-- =========================================
CREATE TABLE IF NOT EXISTS bronze_cities (
    city_id     INTEGER PRIMARY KEY,
    city_name   VARCHAR(100) NOT NULL,
    zipcode     VARCHAR(20),
    country_id  INTEGER NOT NULL,
    CONSTRAINT fk_cities_country
        FOREIGN KEY (country_id)
        REFERENCES bronze_countries(country_id)
);

-- =========================================
-- 3. CATEGORIES
-- =========================================
CREATE TABLE IF NOT EXISTS bronze_categories (
    category_id     INTEGER PRIMARY KEY,
    category_name   VARCHAR(100) NOT NULL
);

-- =========================================
-- 4. PRODUCTS
-- =========================================
CREATE TABLE IF NOT EXISTS bronze_products (
    product_id         INTEGER PRIMARY KEY,
    product_name       VARCHAR(255) NOT NULL,
    price              NUMERIC(10,2),
    category_id        INTEGER NOT NULL,
    class              VARCHAR(10),
    modify_timestamp   VARCHAR(50), -- остаётся текстом (Bronze)
    resistant          VARCHAR(10),
    is_allergic        VARCHAR(10),
    vitality_days      INTEGER,
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES bronze_categories(category_id)
);

-- =========================================
-- 5. SHOPS
-- =========================================
CREATE TABLE IF NOT EXISTS bronze_shops (
    shop_id     INTEGER PRIMARY KEY,
    city_id     INTEGER NOT NULL,
    address     VARCHAR(255),
    CONSTRAINT fk_shops_city
        FOREIGN KEY (city_id)
        REFERENCES bronze_cities(city_id)
);

-- =========================================
-- 6. EMPLOYEES
-- =========================================
CREATE TABLE IF NOT EXISTS bronze_employees (
    employee_id     INTEGER PRIMARY KEY,
    first_name      VARCHAR(100),
    middle_initial  VARCHAR(10),
    last_name       VARCHAR(100),
    birth_date      VARCHAR(50), -- текст (есть ошибки в данных)
    gender          VARCHAR(10),
    city_id         INTEGER,
    hire_date       VARCHAR(50), -- текст
    shop_id         INTEGER,
    CONSTRAINT fk_employees_city
        FOREIGN KEY (city_id)
        REFERENCES bronze_cities(city_id),
    CONSTRAINT fk_employees_shop
        FOREIGN KEY (shop_id)
        REFERENCES bronze_shops(shop_id)
);

-- =========================================
-- 7. CUSTOMERS
-- =========================================
CREATE TABLE IF NOT EXISTS bronze_customers (
    customer_id     INTEGER PRIMARY KEY,
    first_name      VARCHAR(100),
    middle_initial  VARCHAR(10),
    last_name       VARCHAR(100),
    city_id         INTEGER,
    address         VARCHAR(255),
    CONSTRAINT fk_customers_city
        FOREIGN KEY (city_id)
        REFERENCES bronze_cities(city_id)
);

-- =========================================
-- 8. SALES (FACT-LIKE TABLE IN BRONZE)
-- =========================================
CREATE TABLE IF NOT EXISTS bronze_sales (
    sales_id           BIGINT PRIMARY KEY,
    employee_id        INTEGER,
    customer_id        INTEGER,
    product_id         INTEGER,
    quantity           INTEGER,
    discount           NUMERIC(5,4),
    total_price        NUMERIC(12,2),
    sales_timestamp    VARCHAR(50), -- текст, будет преобразовано позже
    transaction_number VARCHAR(100),
    CONSTRAINT fk_sales_employee
        FOREIGN KEY (employee_id)
        REFERENCES bronze_employees(employee_id),
    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_id)
        REFERENCES bronze_customers(customer_id),
    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_id)
        REFERENCES bronze_products(product_id)
);

-- =========================================
-- INDEXES (для ускорения последующих JOIN)
-- =========================================
CREATE INDEX IF NOT EXISTS idx_sales_employee
    ON bronze_sales(employee_id);

CREATE INDEX IF NOT EXISTS idx_sales_customer
    ON bronze_sales(customer_id);

CREATE INDEX IF NOT EXISTS idx_sales_product
    ON bronze_sales(product_id);

CREATE INDEX IF NOT EXISTS idx_sales_timestamp
    ON bronze_sales(sales_timestamp);

