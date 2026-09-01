-- Duplicados reales (mismo pedido + mismo producto repetido)

SELECT Order_ID, Product_ID, COUNT(*) AS veces_repetido
FROM ecommerce_orders_dataset
GROUP BY Order_ID, Product_ID
HAVING COUNT(*) > 1;

SELECT Order_ID, COUNT(*) AS lineas_por_pedido
FROM ecommerce_orders_dataset
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY lineas_por_pedido DESC;

-- Precios inválidos (negativos o en cero)

SELECT COUNT(*) AS precios_invalidos
FROM ecommerce_orders_dataset
WHERE Unit_Price <= 0;

-- NULLs en Columnas City, Customer_Gender

SELECT 
    COUNT(CASE WHEN City = '' THEN 1 END) AS ciudad_vacia,
    COUNT(CASE WHEN Customer_Gender = '' THEN 1 END) AS genero_vacio
FROM ecommerce_orders_dataset;

--NULLs en columnas clave

SELECT 
  COUNT(CASE WHEN Customer_Age IS NULL THEN 1 END) AS nulos_edad,
  COUNT(CASE WHEN Customer_Gender IS NULL THEN 1 END) AS nulos_genero,
  COUNT(CASE WHEN City IS NULL THEN 1 END) AS nulos_ciudad,
  COUNT(CASE WHEN Unit_Price IS NULL THEN 1 END) AS nulos_precio
FROM ecommerce_orders_dataset;
