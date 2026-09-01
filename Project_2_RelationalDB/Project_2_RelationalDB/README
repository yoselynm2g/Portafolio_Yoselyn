# Project 2: Relational Database Design — Universidad (Programa de Ayudantía)

## Introducción

Este proyecto demuestra el diseño e implementación de una base de datos relacional normalizada para un programa real de becas y ayudantía universitaria. Los datos incluyen **82 estudiantes** evaluados a través de **2 trimestres académicos** (T2223-2 y T2223-3), con información sobre sus múltiples carreras, evaluaciones, y decisiones de aprobación.

**Contexto de negocio:** Estudiantes presentan solicitudes para participar en el programa de ayudantía. En la evaluación, se verifica si cumplen requisitos académicos (índice > 14). Si cumplen, se aprueban para el trimestre en curso; si no, se aprueban condicionalmente para el siguiente trimestre esperando que mejoren su desempeño.

---

## 🏗️ Diseño Relacional

El esquema consta de **11 tablas normalizadas**:

### Tablas Maestras (Sin relaciones)
- **ESTUDIANTES**: 82 estudiantes con información demográfica (ID, nombre anónimo, edad, sexo)
- **CARRERAS**: 15 carreras disponibles en la universidad
- **DEPARTAMENTOS**: Áreas académicas que supervisan el programa
- **PERFILES_AYUDANTES**: Tipos de perfiles (Embajador Naranja, etc.)
- **TIPOS_INSCRIPCION**: Principal, Minor
- **PROGRAMAS_BECA**: Tipos de becas disponibles

### Tablas de Relaciones (N:N)
- **ESTUDIANTES_CARRERAS**: Relación N:N entre estudiantes y carreras (permite múltiples carreras por estudiante)
- **ESTUDIANTES_PROGRAMAS_BECA**: Relación N:N entre estudiantes y becas

### Tablas Transaccionales
- **SUPERVISORES**: Supervisores asignados a departamentos
- **ASIGNACIONES_ESTUDIANTES_SUPERVISORES**: Asignación de estudiantes a supervisores con información de plaza
- **APROBACION_BENEFICIOS**: Solicitudes y decisiones por trimestre

---

## 🔑 Decisiones de Normalización

1. **Relación N:N en ESTUDIANTES_CARRERAS**: Muchos estudiantes pueden tener múltiples carreras (principal + minors). Se usó una tabla de unión con clave compuesta para capturar esta relación sin duplicar datos.

2. **Normalización de datos sucios**: Los datos originales tenían carreras concatenadas con "/" (ej: "Ingeniería Química/Ingeniería en Producción"). Se usó `STRING_SPLIT` para parsear correctamente cada carrera como registro independiente.

3. **TIPOS_INSCRIPCION como tabla**: En lugar de strings directos ("Principal", "Minor"), se creó tabla de referencia para garantizar integridad referencial y facilitar búsquedas.

4. **Separación de PROGRAMAS_BECA**: Se normalizó como tabla independiente porque un estudiante puede tener múltiples becas simultáneamente, creando flexibilidad para futuras expansiones.

---

## 📊 Hallazgos Principales

### Métrica General
- **Total de estudiantes únicos**: 82
- **Total de carreras**: 15
- **Estudiantes aprobados**: 37 (45.12%)
- **Estudiantes NO aprobados**: 45 (54.88%)
- **Evaluaciones totales**: 164 (82 estudiantes × 2 trimestres)

### Query 1: Estudiantes con Múltiples Carreras
**Resultado:** 23+ estudiantes inscritos en 2+ carreras simultáneamente

**Hallazgos:**
- La combinación más común: **Ingeniería Química + Ingeniería en Producción** (3 estudiantes registrados)
- Otros pares frecuentes: Ingeniería Mecánica + Matemáticas Industriales, Derecho + Estudios Liberales
- Esto demuestra que muchos estudiantes buscan formación multidisciplinaria
- **Importancia relacional:** Sin la tabla N:N ESTUDIANTES_CARRERAS, sería imposible capturar esta información

### Query 2: Tasa de Aprobación por Carrera y Trimestre
**Resultado:** Variación significativa entre carreras

**Hallazgos clave:**
- **Máxima aprobación:** Educación Inicial (100%, pero solo 1 solicitud en T2223-2)
- **Máxima demanda:** Ingeniería Química (17 solicitudes en T2223-2, 29.41% aprobación)
- **Carreras con 0% aprobación en algún trimestre:** Economía Empresarial (T2223-2), Idiomas Modernos (T2223-3)
- **Patrón observado:** Carreras de ingeniería tienden a tener tasas de aprobación del 25-50%, mientras que algunas carreras humanísticas varían entre 0-100%
- **Implicación:** La carrera es predictor del desempeño académico; carreras técnicas requieren más apoyo

### Query 3: Estudiantes con Documentación Incompleta
**Resultado:** 3 estudiantes únicos con documentación incompleta

**Hallazgos:**
- **Estudiantes afectados:** Estudiante_4, Estudiante_5, Estudiante_53
- **Documentación incompleta en ambos trimestres:** Cada estudiante aparece en T2223-2 y T2223-3
- **Impacto crítico:** **100% fueron rechazados** (Aprobacion = NO)
- **Conclusión:** Documentación incompleta es predictor perfecto de rechazo — indica falta de compromiso administrativo

### Query 4: Resumen General (Métricas Clave)
**Resultado:** 
- Total de estudiantes: 82
- Total de carreras: 15
- Estudiantes aprobados: 37
- **Porcentaje de aprobación: 45.12%**

**Interpretación:** Menos de la mitad de los estudiantes cumplen los requisitos académicos del programa (índice > 14). Esto es realista para un programa académicamente selectivo.

---

## 🔍 SQL Queries Utilizadas

### Query 1: Estudiantes con Múltiples Carreras
```sql
SELECT TOP 60
    e.Estudiante_ID,
    e.Nombre_Anonimo,
    e.Edad,
    STRING_AGG(c.Nombre_Carrera, ' + ') AS Carreras,
    COUNT(DISTINCT c.Carrera_ID) AS Total_Carreras
FROM ESTUDIANTES e
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
GROUP BY e.Estudiante_ID, e.Nombre_Anonimo, e.Edad
HAVING COUNT(DISTINCT c.Carrera_ID) > 1
ORDER BY Total_Carreras DESC, e.Nombre_Anonimo
```

**Demuestra:** La relación N:N en ESTUDIANTES_CARRERAS funcionando correctamente.

---

### Query 2: Tasa de Aprobación por Carrera y Trimestre
```sql
SELECT
    c.Nombre_Carrera,
    ab.Trimestre,
    COUNT(*) AS Solicitudes,
    SUM(CASE WHEN ab.Aprobacion = 'SI' THEN 1 ELSE 0 END) AS Aprobadas,
    CAST(SUM(CASE WHEN ab.Aprobacion = 'SI' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Pct_Aprobacion
FROM APROBACION_BENEFICIOS ab
JOIN ESTUDIANTES e ON ab.Estudiante_ID = e.Estudiante_ID
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
WHERE ec.Tipo_Inscripcion_ID = (SELECT Tipo_Inscripcion_ID FROM TIPOS_INSCRIPCION WHERE Nombre_Tipo_Inscripcion = 'Pregrado')
GROUP BY c.Nombre_Carrera, ab.Trimestre
ORDER BY c.Nombre_Carrera, ab.Trimestre
```

**Demuestra:** JOINs complejos entre 5 tablas para análisis multidimensional.

---

### Query 3: Estudiantes con Documentación Incompleta
```sql
SELECT
    e.Estudiante_ID,
    e.Nombre_Anonimo,
    e.Edad,
    c.Nombre_Carrera,
    ab.Trimestre,
    ab.Validacion_Documentos,
    ab.Aprobacion
FROM APROBACION_BENEFICIOS ab
JOIN ESTUDIANTES e ON ab.Estudiante_ID = e.Estudiante_ID
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
WHERE ab.Validacion_Documentos = 'Incompletos'
ORDER BY ab.Trimestre, e.Nombre_Anonimo
```

**Demuestra:** Filtrado y agregación para identificar excepciones en los datos.

---

### Query 4: Resumen General (Métricas Clave)
```sql
SELECT
    COUNT(DISTINCT e.Estudiante_ID) AS Total_Estudiantes,
    COUNT(DISTINCT c.Carrera_ID) AS Total_Carreras,
    SUM(CASE WHEN ab.Aprobacion = 'SI' THEN 1 ELSE 0 END) / 
    CAST(COUNT(DISTINCT e.Estudiante_ID) AS FLOAT) * 100 AS Pct_Estudiantes_Aprobados
FROM APROBACION_BENEFICIOS ab
JOIN ESTUDIANTES e ON ab.Estudiante_ID = e.Estudiante_ID
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
```

**Demuestra:** Agregaciones con DISTINCT para métricas de negocio precisas.

---

## 💡 Lecciones Aprendidas

1. **Relaciones N:N son cruciales en datos reales:** Sin ESTUDIANTES_CARRERAS, sería imposible capturar que un estudiante tiene múltiples carreras. Muchos datasets empresariales tienen relaciones complejas que requieren tablas de unión.

2. **Normalización de datos sucios es inevitable:** Los datos originales requerían parsing de strings concatenados — tarea común en análisis de datos del mundo real. STRING_SPLIT fue la herramienta clave aquí.

3. **Las claves compuestas previenen duplicados lógicos:** Una clave compuesta en ESTUDIANTES_CARRERAS (Estudiante_ID + Carrera_ID + Tipo_Inscripcion_ID) evita que el mismo estudiante-carrera se registre dos veces.

4. **Métricas por entidad vs. por transacción:** Contar 82 estudiantes es diferente a contar 164 evaluaciones (82 × 2 trimestres). La pregunta de negocio determina la métrica correcta.

5. **La documentación es predictor perfecto de rechazo:** El 100% de estudiantes con documentación incompleta fueron rechazados, indicando que requiere intervención administrativa temprana.

---

## 🛠️ Herramientas Usadas

- **SQL Server** 2016+
- **STRING_SPLIT**: Para normalizar datos con separadores
- **JOINs complejos**: Para consultas multi-tabla (INNER JOIN, relaciones N:N)
- **Funciones de agregación**: COUNT, SUM, CAST para cálculos de porcentajes
- **GROUP BY y HAVING**: Para segmentación y filtrado de datos agregados
- **Claves compuestas**: Para garantizar integridad en relaciones N:N

---

## 📈 Aplicaciones Prácticas

Este diseño sirve como base para:
- **Dashboard de aprobaciones por carrera/trimestre** — Identificar carreras que necesitan más soporte
- **Alertas de documentación incompleta** — Intervenir temprano antes de evaluación
- **Análisis de patrones de rechazo** — Encontrar carreras/estudiantes en riesgo
- **Reportes de participación estudiantil** — Métricas mensuales/semestrales para liderazgo
- **Predicción de desempeño** — Usar carrera + documentación como variables predictivas

---

## 📌 Metodología de Normalización

**Paso 1: Identificar entidades principales**
- ESTUDIANTES, CARRERAS, SUPERVISORES, PROGRAMAS_BECA

**Paso 2: Identificar relaciones**
- Un estudiante → múltiples carreras (N:N)
- Un estudiante → múltiples supervisores (N:N)
- Un estudiante → múltiples becas (N:N)

**Paso 3: Crear tablas de unión**
- ESTUDIANTES_CARRERAS, ASIGNACIONES_ESTUDIANTES_SUPERVISORES, ESTUDIANTES_PROGRAMAS_BECA

**Paso 4: Normalizar datos sucios**
- Parse delimitados con STRING_SPLIT
- Validar valores únicos antes de insertar

**Paso 5: Escribir queries de validación**
- Verificar que relaciones N:N se cargaron correctamente
- Confirmar que no hay duplicados lógicos

---

## ✅ Resumen Ejecutivo

| Métrica | Valor |
|---------|-------|
| Estudiantes únicos | 82 |
| Carreras distintas | 15 |
| Tablas relacionales | 11 |
| Aprobación general | 45.12% |
| Estudiantes multidisciplinarios | 23+ |
| Documentación incompleta | 3 estudiantes (100% rechazados) |

**Conclusión:** El esquema relacional captura exitosamente la complejidad de un programa académico real, permitiendo análisis multi-dimensionales que serían imposibles en datos desnormalizados.

---

**Autor:** Yoselyn Mogollón  
**Fecha:** Septiembre 2026  
**Propósito:** Portfolio — Demostración de diseño relacional, normalización de datos, y análisis SQL real
