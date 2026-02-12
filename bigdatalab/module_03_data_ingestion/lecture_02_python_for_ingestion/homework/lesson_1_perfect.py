# Инициализация переменных с ошибочными значениями категорий и атрибутами товара
category_a = "Vegetables"  # Ошибочно присвоено фруктам
category_b = "Fruits"      # Ошибочно присвоено овощам
price_per_unit_a = 150      # Цена за ящик партии фруктов
quantity_a = 40             # Количество ящиков партии фруктов
vat_rate = 0.2              # Ставка НДС 20%

# Обмен значений категорий без использования временной переменной
category_a, category_b = category_b, category_a

# Расчёт общей стоимости партии с НДС
total_value = (price_per_unit_a * quantity_a) + (price_per_unit_a * quantity_a * vat_rate)

# Вывод исправленной категории и итоговой стоимости
print("Текущая категория A:", category_a)
print("Общая стоимость партии с НДС:", total_value)
