-- QUERY 1: Estudiantes con TODAS sus carreras (relación N:N en acción)
SELECT TOP 60
    e.Nombre_Anonimo,
    e.Edad,
    STRING_AGG(c.Nombre_Carrera, ' + ') AS Carreras,
    COUNT(DISTINCT c.Carrera_ID) AS Total_Carreras
FROM ESTUDIANTES e
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
GROUP BY e.Estudiante_ID, e.Nombre_Anonimo, e.Edad
HAVING COUNT(DISTINCT c.Carrera_ID) > 1  -- Solo los que tienen 2+ carreras
ORDER BY Total_Carreras DESC;

-- QUERY 2: Tasa de aprobación por carrera y trimestre
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
ORDER BY c.Nombre_Carrera, ab.Trimestre;

-- QUERY 3: Validación de documentos incompletos (análisis de riesgo)
SELECT 
    e.Nombre_Anonimo,
    e.Edad,
    c.Nombre_Carrera,
    ab.Trimestre,
    ab.Validacion_Documentos,
    ab.Aprobacion
FROM ESTUDIANTES e
JOIN APROBACION_BENEFICIOS ab ON e.Estudiante_ID = ab.Estudiante_ID
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
WHERE ab.Validacion_Documentos = 'Incompletos'
  AND ec.Tipo_Inscripcion_ID = (SELECT Tipo_Inscripcion_ID FROM TIPOS_INSCRIPCION WHERE Nombre_Tipo_Inscripcion = 'Pregrado')
ORDER BY ab.Trimestre, e.Nombre_Anonimo;

-- QUERY 4: Resumen general (métricas de ESTUDIANTES)
SELECT 
    COUNT(DISTINCT e.Estudiante_ID) AS Total_Estudiantes,
    COUNT(DISTINCT c.Carrera_ID) AS Total_Carreras,
    COUNT(DISTINCT 
        CASE WHEN ab.Aprobacion = 'SI' THEN e.Estudiante_ID END
    ) AS Estudiantes_Aprobados,
    CAST(COUNT(DISTINCT 
        CASE WHEN ab.Aprobacion = 'SI' THEN e.Estudiante_ID END
    ) * 100.0 / COUNT(DISTINCT e.Estudiante_ID) AS DECIMAL(5,2)) AS Pct_Estudiantes_Aprobados
FROM ESTUDIANTES e
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
JOIN APROBACION_BENEFICIOS ab ON e.Estudiante_ID = ab.Estudiante_ID;