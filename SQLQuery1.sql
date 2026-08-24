-- Duplicados reales (mismo pedido + mismo producto repetido)

SELECT Order_ID, Product_ID, COUNT(*) AS veces_repetido
FROM ecommerce_orders_dataset
GROUP BY Order_ID, Product_ID
HAVING COUNT(*) > 1;