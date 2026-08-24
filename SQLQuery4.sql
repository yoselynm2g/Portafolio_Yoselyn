-- NULLs en Columnas City, Customer_Gender

SELECT 
    COUNT(CASE WHEN City = '' THEN 1 END) AS ciudad_vacia,
    COUNT(CASE WHEN Customer_Gender = '' THEN 1 END) AS genero_vacio
FROM ecommerce_orders_dataset;