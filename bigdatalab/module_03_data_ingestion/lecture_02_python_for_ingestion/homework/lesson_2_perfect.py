# Инициализация исходных переменных товара
product_name = "Морковь мытая"  # Название продукта
price = 2.5                      # Цена за единицу
stock_quantity = 150              # Количество на складе
is_local_farm = True             # Товар от местного фермера
supplier = None                  # Поставщик не указан

# -------------------------------
# Проверки логических условий
# -------------------------------

# Является ли товар хитом?
is_hit = price < 3 and is_local_farm
print("Является ли товар хитом?", is_hit)

# Поставщик указан?
has_supplier = supplier is not None
print("Поставщик указан?", has_supplier)

# Показываем товар в приложении, если есть в наличии и поставщик указан
can_show_in_app = stock_quantity > 0 and has_supplier
print("Показывать в приложении?", can_show_in_app)

# Нужно пополнение, если остаток <= 20 или товар хитом
needs_restock = stock_quantity <= 20 or is_hit
print("Нужно пополнение?", needs_restock)

# Товар не участвует в акции, если не от местного фермера
is_blocked = not is_local_farm
print("Товар заблокирован для акции?", is_blocked)

# -------------------------------
# Проверка приоритетов операторов (скидка)
# -------------------------------

has_coupon = True
has_card = False
total = 10

# Без скобок
discount_without_brackets = has_coupon or has_card and total > 50
# Со скобками
discount_with_brackets = (has_coupon or has_card) and total > 50

print("Скидка без скобок:", discount_without_brackets)
print("Скидка со скобками:", discount_with_brackets)

# -------------------------------
# Изменение значений через расширенные операторы присваивания
# -------------------------------

price += 1.0                # Увеличиваем цену на 1
stock_quantity *= 2          # Удваиваем остаток на складе
boxes = stock_quantity       # Создаём переменную boxes
boxes //= 10                 # Считаем полные коробки по 10 кг

print("Цена после изменения:", price)
print("Остаток после изменения:", stock_quantity)
print("Полных коробок по 10 кг:", boxes)

# -------------------------------
# Повторный расчёт ключевых проверок после изменений
# -------------------------------

is_hit = price < 3 and is_local_farm
needs_restock = stock_quantity <= 20 or is_hit

print("Является ли товар хитом (после изменений)?", is_hit)
print("Нужно пополнение (после изменений)?", needs_restock)
