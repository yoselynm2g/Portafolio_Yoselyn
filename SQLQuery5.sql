
--NULLs en columnas clave

SELECT 
  COUNT(CASE WHEN Customer_Age IS NULL THEN 1 END) AS nulos_edad,
  COUNT(CASE WHEN Customer_Gender IS NULL THEN 1 END) AS nulos_genero,
  COUNT(CASE WHEN City IS NULL THEN 1 END) AS nulos_ciudad,
  COUNT(CASE WHEN Unit_Price IS NULL THEN 1 END) AS nulos_precio
FROM ecommerce_orders_dataset;