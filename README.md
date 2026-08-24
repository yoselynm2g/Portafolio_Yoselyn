# Project 1: SQL Data Profiling — E-commerce Orders Dataset

## Dataset
Dataset de órdenes de e-commerce, 30,000 registros, con información de 
clientes, productos, fechas y precios.

## Objetivo
Evaluar la calidad de los datos mediante SQL: detectar valores nulos, 
registros duplicados y valores inválidos.

## Nota metodológica
Durante la importación, las columnas del dataset quedaron configuradas 
como NOT NULL, por lo que una verificación estándar de valores NULL no 
sería suficiente para detectar datos faltantes. Por este motivo, se 
amplió la verificación para incluir strings vacíos ('') como una forma 
alternativa de detectar ausencia de datos en columnas de texto.

## Hallazgos

| Verificación | Resultado |
|--------------|-----------|
| Registros totales | 30,000 |
| Valores NULL (columnas configuradas NOT NULL) | 0 |
| Strings vacíos (City, Customer_Gender) | 0 |
| Duplicados (Order_ID repetido) | 0 |
| Duplicados (Order_ID + Product_ID) | 0 |
| Precios inválidos (≤ 0) | 0 |

## Conclusión
El dataset presenta una estructura limpia: cada Order_ID es único 
(una fila por pedido), sin duplicados, sin valores nulos o vacíos en 
columnas clave, y sin precios fuera de rango.

Este análisis demuestra la capacidad de aplicar verificaciones sistemáticas 
de calidad de datos usando SQL (NULLs, duplicados, valores vacíos, rangos 
válidos), incluyendo la capacidad de adaptar el enfoque de verificación 
cuando las restricciones de la tabla (NOT NULL) requieren un método 
alternativo. Aunque no se detectaron anomalías, este tipo de validación 
es parte esencial del trabajo de un analista de calidad de datos: 
confirmar la integridad de los datos con evidencia, no asumirla.

## Herramientas usadas
SQL Server, SQL Server Management Studio (SSMS)

## Autora
Yoselyn Mogollón González