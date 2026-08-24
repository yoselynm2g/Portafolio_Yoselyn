SELECT Order_ID, COUNT(*) AS lineas_por_pedido
FROM ecommerce_orders_dataset
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY lineas_por_pedido DESC;