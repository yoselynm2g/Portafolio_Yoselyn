CREATE TABLE ESTUDIANTES (
    Estudiante_ID INT PRIMARY KEY,
    Nombre_Anonimo NVARCHAR(100) NOT NULL,
    Edad INT,
    Sexo NVARCHAR(20)
);

CREATE TABLE CARRERAS (
    Carrera_ID INT PRIMARY KEY IDENTITY(1,1),
    Nombre_Carrera NVARCHAR(100) NOT NULL
);

CREATE TABLE DEPARTAMENTOS (
    Departamento_ID INT PRIMARY KEY IDENTITY(1,1),
    Nombre_Departamento NVARCHAR(100) NOT NULL
);

CREATE TABLE PERFILES_AYUDANTES (
    Perfil_ID INT PRIMARY KEY IDENTITY(1,1),
    Nombre_Perfil NVARCHAR(100) NOT NULL
);

CREATE TABLE PROGRAMAS_BECA (
    Programa_Beca_ID INT PRIMARY KEY IDENTITY(1,1),
    Nombre_Programa_Beca NVARCHAR(100) NOT NULL
);

CREATE TABLE SUPERVISORES (
    Supervisor_ID INT PRIMARY KEY IDENTITY(1,1),
    Nombre_Supervisor NVARCHAR(100) NOT NULL,
    Departamento_ID INT NOT NULL,
    FOREIGN KEY (Departamento_ID) REFERENCES DEPARTAMENTOS(Departamento_ID)
);

CREATE TABLE ESTUDIANTES_CARRERAS (
    Estudiante_ID INT NOT NULL,
    Carrera_ID INT NOT NULL,
    Tipo_Inscripcion NVARCHAR(20) NOT NULL, -- 'Principal' o 'Minor'
    PRIMARY KEY (Estudiante_ID, Carrera_ID, Tipo_Inscripcion),
    FOREIGN KEY (Estudiante_ID) REFERENCES ESTUDIANTES(Estudiante_ID),
    FOREIGN KEY (Carrera_ID) REFERENCES CARRERAS(Carrera_ID)
);

CREATE TABLE ASIGNACIONES_ESTUDIANTES_SUPERVISORES (
    Asignacion_ID INT PRIMARY KEY IDENTITY(1,1),
    Estudiante_ID INT NOT NULL,
    Supervisor_ID INT NOT NULL,
    Departamento_ID INT NOT NULL,
    Perfil_ID INT NOT NULL,
    Posee_Plaza BIT NOT NULL, -- 1 = Sí, 0 = No
    Trimestre NVARCHAR(20), -- ej: 'T2223-2', 'T2223-3'
    FOREIGN KEY (Estudiante_ID) REFERENCES ESTUDIANTES(Estudiante_ID),
    FOREIGN KEY (Supervisor_ID) REFERENCES SUPERVISORES(Supervisor_ID),
    FOREIGN KEY (Departamento_ID) REFERENCES DEPARTAMENTOS(Departamento_ID),
    FOREIGN KEY (Perfil_ID) REFERENCES PERFILES_AYUDANTES(Perfil_ID)
);

CREATE TABLE ESTUDIANTES_PROGRAMAS_BECA (
    Estudiante_ID INT NOT NULL,
    Programa_Beca_ID INT NOT NULL,
    Trimestre NVARCHAR(20) NOT NULL,
    PRIMARY KEY (Estudiante_ID, Programa_Beca_ID, Trimestre),
    FOREIGN KEY (Estudiante_ID) REFERENCES ESTUDIANTES(Estudiante_ID),
    FOREIGN KEY (Programa_Beca_ID) REFERENCES PROGRAMAS_BECA(Programa_Beca_ID)
);

CREATE TABLE APROBACION_BENEFICIOS (
    Beneficio_ID INT PRIMARY KEY IDENTITY(1,1),
    Estudiante_ID INT NOT NULL,
    Trimestre NVARCHAR(20) NOT NULL,
    Asistencia_Entrevista BIT NOT NULL, -- 1 = Asistió, 0 = No asistió
    Validacion_Documentos NVARCHAR(20), -- 'Completos', 'Incompletos'
    Aprobacion NVARCHAR(5), -- 'SI', 'NO'
    FOREIGN KEY (Estudiante_ID) REFERENCES ESTUDIANTES(Estudiante_ID)
);

-- Borrar la tabla anterior (sin datos aún, así que es seguro)
DROP TABLE ESTUDIANTES_CARRERAS;

GO

-- Recrearla con la FK correcta
CREATE TABLE ESTUDIANTES_CARRERAS (
    Estudiante_ID INT NOT NULL,
    Carrera_ID INT NOT NULL,
    Tipo_Inscripcion_ID INT NOT NULL,
    PRIMARY KEY (Estudiante_ID, Carrera_ID, Tipo_Inscripcion_ID),
    FOREIGN KEY (Estudiante_ID) REFERENCES ESTUDIANTES(Estudiante_ID),
    FOREIGN KEY (Carrera_ID) REFERENCES CARRERAS(Carrera_ID),
    FOREIGN KEY (Tipo_Inscripcion_ID) REFERENCES TIPOS_INSCRIPCION(Tipo_Inscripcion_ID)
);

GO

CREATE TABLE TIPOS_INSCRIPCION (
    Tipo_Inscripcion_ID INT PRIMARY KEY IDENTITY(1,1),
    Nombre_Tipo_Inscripcion NVARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO TIPOS_INSCRIPCION (Nombre_Tipo_Inscripcion) VALUES ('Pregrado');
INSERT INTO TIPOS_INSCRIPCION (Nombre_Tipo_Inscripcion) VALUES ('Postgrado');
INSERT INTO TIPOS_INSCRIPCION (Nombre_Tipo_Inscripcion) VALUES ('Miniors');

CREATE TABLE ESTUDIANTES_CARRERAS (
    Estudiante_ID INT NOT NULL,
    Carrera_ID INT NOT NULL,
    Tipo_Inscripcion_ID INT NOT NULL,
    PRIMARY KEY (Estudiante_ID, Carrera_ID, Tipo_Inscripcion_ID),
    FOREIGN KEY (Estudiante_ID) REFERENCES ESTUDIANTES(Estudiante_ID),
    FOREIGN KEY (Carrera_ID) REFERENCES CARRERAS(Carrera_ID),
    FOREIGN KEY (Tipo_Inscripcion_ID) REFERENCES TIPOS_INSCRIPCION(Tipo_Inscripcion_ID)
);

-- 1. CARRERAS (extraer de TablaAnonimizada)
INSERT INTO CARRERAS (Nombre_Carrera)
SELECT DISTINCT Carrera
FROM TablaAnonimizada
WHERE Carrera IS NOT NULL;

-- 2. DEPARTAMENTOS (extraer de area en asignaciones)
INSERT INTO DEPARTAMENTOS (Nombre_Departamento)
SELECT DISTINCT 'Departamento Default'  -- Placeholder, los detalles están en otra columna
UNION ALL
SELECT DISTINCT 'Departamento de Contabilidad, Banca y Auditoría'
UNION ALL
SELECT DISTINCT 'Otras áreas';

-- 3. PERFILES_AYUDANTES (extraer de Perfil_Ayudantia)
INSERT INTO PERFILES_AYUDANTES (Nombre_Perfil)
SELECT DISTINCT perfil_solicitado
FROM TablaAnonimizada
WHERE perfil_solicitado IS NOT NULL;

-- 4. PROGRAMAS_BECA (extraer de Programa_o_institución_que_le_otorga_la_beca_y_el_porcentaje)
INSERT INTO PROGRAMAS_BECA (Nombre_Programa_Beca)
SELECT DISTINCT beca_adicional
FROM TablaAnonimizada
WHERE beca_adicional IS NOT NULL;

-- Insertar estudiantes desde TablaAnonimizada
INSERT INTO ESTUDIANTES (Estudiante_ID, Nombre_Anonimo, Edad, Sexo)
SELECT DISTINCT Estudiante_ID, Nombre_Anonimo, Edad, Sexo
FROM TablaAnonimizada;

-- Cada estudiante tiene su carrera como 'Principal'
INSERT INTO ESTUDIANTES_CARRERAS (Estudiante_ID, Carrera_ID, Tipo_Inscripcion_ID)
SELECT DISTINCT 
    t.Estudiante_ID,
    c.Carrera_ID,
    (SELECT Tipo_Inscripcion_ID FROM TIPOS_INSCRIPCION WHERE Nombre_Tipo_Inscripcion = 'Pregrado') AS Tipo_Inscripcion_ID
FROM TablaAnonimizada t
JOIN CARRERAS c ON t.Carrera = c.Nombre_Carrera;

-- Insertar beneficios: T2223-2 y T2223-3
INSERT INTO APROBACION_BENEFICIOS (Estudiante_ID, Trimestre, Asistencia_Entrevista, Validacion_Documentos, Aprobacion)
SELECT 
    Estudiante_ID,
    'T2223-2' AS Trimestre,
    CASE WHEN aprobado_T2223_2 = 'SI' THEN 1 ELSE 0 END AS Asistencia_Entrevista,
    validar_documentos,
    aprobado_T2223_2
FROM TablaAnonimizada

UNION ALL

SELECT 
    Estudiante_ID,
    'T2223-3' AS Trimestre,
    CASE WHEN aprobado_T2223_3 = 'SI' THEN 1 ELSE 0 END AS Asistencia_Entrevista,
    validar_documentos,
    aprobado_T2223_3
FROM TablaAnonimizada;


-- ¿Cuántos estudiantes tenemos?
SELECT COUNT(*) AS Total_Estudiantes FROM ESTUDIANTES;

-- ¿Cuántas carreras?
SELECT COUNT(*) AS Total_Carreras FROM CARRERAS;

-- ¿Cuántos registros en ESTUDIANTES_CARRERAS?
SELECT COUNT(*) AS Total_Inscripciones FROM ESTUDIANTES_CARRERAS;

-- ¿Cuántos beneficios aprobados?
SELECT COUNT(*) AS Total_Beneficios FROM APROBACION_BENEFICIOS
WHERE Aprobacion = 'SI';

-- QUERY 1: Estudiantes con sus carreras (relación N:N en acción)
SELECT TOP 10
    e.Nombre_Anonimo,
    e.Edad,
    c.Nombre_Carrera,
    ti.Nombre_Tipo_Inscripcion
FROM ESTUDIANTES e
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
JOIN TIPOS_INSCRIPCION ti ON ec.Tipo_Inscripcion_ID = ti.Tipo_Inscripcion_ID
ORDER BY e.Nombre_Anonimo;

-- ¿Cuántos estudiantes tienen registro en ESTUDIANTES_CARRERAS?
SELECT COUNT(DISTINCT Estudiante_ID) AS Estudiantes_con_Carrera
FROM ESTUDIANTES_CARRERAS;

-- ¿Cuántos registros totales en ESTUDIANTES_CARRERAS?
SELECT COUNT(*) AS Total_Registros_ESTUDIANTES_CARRERAS
FROM ESTUDIANTES_CARRERAS;

-- Comparar con total de estudiantes
SELECT COUNT(*) AS Total_Estudiantes FROM ESTUDIANTES;

SELECT
    e.Nombre_Anonimo,
    e.Edad,
    c.Nombre_Carrera,
    ti.Nombre_Tipo_Inscripcion
FROM ESTUDIANTES e
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
JOIN TIPOS_INSCRIPCION ti ON ec.Tipo_Inscripcion_ID = ti.Tipo_Inscripcion_ID
ORDER BY e.Nombre_Anonimo;

SELECT TOP 30 
    Estudiante_ID, 
    Nombre_Anonimo, 
    Carrera
FROM TablaAnonimizada
WHERE Carrera LIKE '%,%' OR Carrera LIKE '%/%' OR Carrera LIKE '%y %'
ORDER BY Carrera;

-- Extraer carreras individuales de las combinaciones y insertarlas si no existen
WITH CarrerasIndividuales AS (
    SELECT DISTINCT 
        TRIM(value) AS Nombre_Carrera
    FROM TablaAnonimizada
    CROSS APPLY STRING_SPLIT(Carrera, '/') AS cs
    WHERE TRIM(value) IS NOT NULL AND TRIM(value) != ''
)
INSERT INTO CARRERAS (Nombre_Carrera)
SELECT ci.Nombre_Carrera
FROM CarrerasIndividuales ci
WHERE NOT EXISTS (SELECT 1 FROM CARRERAS c WHERE c.Nombre_Carrera = ci.Nombre_Carrera);

DELETE FROM ESTUDIANTES_CARRERAS;

-- Ahora cada carrera separada por "/" es un registro individual
INSERT INTO ESTUDIANTES_CARRERAS (Estudiante_ID, Carrera_ID, Tipo_Inscripcion_ID)
SELECT DISTINCT
    t.Estudiante_ID,
    c.Carrera_ID,
    (SELECT Tipo_Inscripcion_ID FROM TIPOS_INSCRIPCION WHERE Nombre_Tipo_Inscripcion = 'Pregrado') AS Tipo_Inscripcion_ID
FROM TablaAnonimizada t
CROSS APPLY STRING_SPLIT(t.Carrera, '/') AS cs
JOIN CARRERAS c ON TRIM(cs.value) = c.Nombre_Carrera;

-- Verificar que ahora hay más registros en ESTUDIANTES_CARRERAS
SELECT COUNT(*) AS Total_Registros FROM ESTUDIANTES_CARRERAS;

-- Ver un estudiante con múltiples carreras
SELECT 
    e.Nombre_Anonimo,
    c.Nombre_Carrera
FROM ESTUDIANTES e
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
WHERE e.Estudiante_ID IN (9, 51, 57, 65, 66)
ORDER BY e.Nombre_Anonimo, c.Nombre_Carrera;

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

-- QUERY 4: Resumen general (métricas clave)
SELECT 
    COUNT(DISTINCT e.Estudiante_ID) AS Total_Estudiantes,
    COUNT(DISTINCT c.Carrera_ID) AS Total_Carreras,
    COUNT(DISTINCT ab.Beneficio_ID) AS Total_Solicitudes,
    SUM(CASE WHEN ab.Aprobacion = 'SI' THEN 1 ELSE 0 END) AS Aprobadas,
    CAST(SUM(CASE WHEN ab.Aprobacion = 'SI' THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT ab.Beneficio_ID) AS DECIMAL(5,2)) AS Tasa_Aprobacion_General
FROM ESTUDIANTES e
JOIN ESTUDIANTES_CARRERAS ec ON e.Estudiante_ID = ec.Estudiante_ID
JOIN CARRERAS c ON ec.Carrera_ID = c.Carrera_ID
JOIN APROBACION_BENEFICIOS ab ON e.Estudiante_ID = ab.Estudiante_ID;

-- Ver cuántos registros hay por trimestre
SELECT Trimestre, COUNT(*) AS Total
FROM APROBACION_BENEFICIOS
GROUP BY Trimestre;

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

