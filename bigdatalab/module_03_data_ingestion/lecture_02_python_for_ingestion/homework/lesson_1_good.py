category_a="Vegetables"
category_b="Fruits"
price_per_unit_a=150
quantity_a=40
vat_rate=0.2

category_a,category_b = category_b,category_a  # поменяли категории
total_value = price_per_unit_a*quantity_a+price_per_unit_a*quantity_a*vat_rate
print("Текущая категория A:",category_a)
print("Общая стоимость партии с НДС:",total_value)
