import os
import sys
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

# =====================================================
# Configuration
# =====================================================

DB_CONFIG = {
    "user": "postgres",
    "password": "1111",
    "host": "localhost",
    "port": "5432",
    "database": "postgres"
}

CSV_DIR = "data"
BRONZE_SCHEMA = "bronze"
BRONZE_PREFIX = "bronze_"

# Порядок загрузки CSV-файлов для соблюдения FK
TABLE_LOAD_ORDER = [
    "countries",
    "cities",
    "categories",
    "products",
    "shops",
    "employees",
    "customers",
    "sales"
]

CSV_SEPARATOR = ";"  # Разделитель EcoMarket CSV


# =====================================================
# Database connection
# =====================================================

def create_db_engine():
    """
    Создаёт соединение с PostgreSQL через SQLAlchemy.

    Возвращает:
        engine (sqlalchemy.Engine): объект подключения к БД
    При ошибке подключения завершает выполнение программы.
    """
    try:
        engine = create_engine(
            f"postgresql+psycopg2://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
            f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
        )

        # Проверка соединения
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))

        print("Database connection established.")
        return engine

    except SQLAlchemyError as exc:
        print("Failed to connect to the database.")
        print(exc)
        sys.exit(1)


# =====================================================
# Load single table
# =====================================================

def load_table(engine, table_name):
    """
    Загружает CSV-файл в таблицу Bronze слоя.

    Аргументы:
        engine (sqlalchemy.Engine): подключение к базе данных
        table_name (str): имя таблицы без префикса bronze_

    Процесс:
        - Чтение CSV через pandas
        - Проверка существования файла и пустого DataFrame
        - Загрузка через df.to_sql() с if_exists='append'
        - Указание схемы bronze
        - Обработка ошибок
    """
    csv_path = os.path.join(CSV_DIR, f"{table_name}.csv")
    target_table = BRONZE_PREFIX + table_name

    try:
        if not os.path.exists(csv_path):
            raise FileNotFoundError(f"CSV file not found: {csv_path}")

        df = pd.read_csv(csv_path, sep=CSV_SEPARATOR)

        if df.empty:
            print(f"Table '{table_name}': CSV file is empty. Skipping.")
            return

        df.to_sql(
            name=target_table,
            con=engine,
            schema=BRONZE_SCHEMA,
            if_exists="append",
            index=False
        )

        print(f"Table '{BRONZE_SCHEMA}.{target_table}' loaded successfully.")

    except FileNotFoundError as exc:
        print(exc)

    except pd.errors.ParserError as exc:
        print(f"CSV parsing error for '{table_name}': {exc}")

    except SQLAlchemyError as exc:
        print(f"Database error while loading '{target_table}': {exc}")

    except Exception as exc:
        print(f"Unexpected error while loading '{table_name}': {exc}")


# =====================================================
# Main process
# =====================================================

def main():
    """
    Основной процесс загрузки всех CSV-файлов в Bronze слой.
    """
    engine = create_db_engine()

    for table in TABLE_LOAD_ORDER:
        load_table(engine, table)

    print("Bronze layer loading completed.")


if __name__ == "__main__":
    main()
