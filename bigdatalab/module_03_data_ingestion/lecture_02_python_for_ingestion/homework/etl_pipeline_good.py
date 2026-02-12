import pandas as pd
from sqlalchemy import create_engine

# ===============================
# Конфигурация
# ===============================
engine = create_engine(
    "postgresql+psycopg2://postgres:1111@localhost:5432/postgres"
)

# Путь к CSV
CSV_DIR = "data/"

# Таблицы Bronze слоя
tables = [
    "countries",
    "cities",
    "categories",
    "products",
    "shops",
    "employees",
    "customers",
    "sales"
]

BRONZE_PREFIX = "bronze_"

# ===============================
# Загрузка таблиц
# ===============================
for table in tables:
    csv_file = f"{CSV_DIR}{table}.csv"
    target_table = BRONZE_PREFIX + table

    try:
        # Для всех файлов используем стандартный разделитель
        df = pd.read_csv(csv_file)

        # Простейшее переименование колонок (если есть)
        if table == "products" and "ProductName" in df.columns:
            df.rename(columns={"ProductName": "product_name"}, inplace=True)
        if table == "shops" and "ShopName" in df.columns:
            df.rename(columns={"ShopName": "shop_name"}, inplace=True)

        # Загрузка в БД
        df.to_sql(
            name=target_table,
            con=engine,
            index=False,
            if_exists='append',
            schema='bronze'
        )
        print(f"{target_table} загружено {len(df)} строк")

    except Exception as e:
        print(f"Ошибка при загрузке {csv_file}: {e}")
