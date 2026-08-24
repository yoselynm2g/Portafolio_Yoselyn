-- Precios inválidos (negativos o en cero)

SELECT COUNT(*) AS precios_invalidos
FROM ecommerce_orders_dataset
WHERE Unit_Price <= 0;