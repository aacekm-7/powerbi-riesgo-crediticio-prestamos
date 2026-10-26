/*
    Análisis exploratorio de cartera - Banco R Crediticio
    Objetivo: Evaluar calidad de datos y factores de riesgo de impago (IsDefault).
*/

USE BancoRCrediticio;
GO

-- ==========================================
-- 0. Exploración inicial
-- ==========================================
SELECT TOP 10 *
FROM B_Prestamos;


-- ==========================================
-- 1. Calidad de datos
-- ==========================================

-- 1.1 Total de registros y validación de IDs únicos
SELECT
    COUNT(*)                    AS TotalFilas,
    COUNT(DISTINCT ID_Prestamo) AS IDsUnicos,
    COUNT(*) - COUNT(DISTINCT ID_Prestamo) AS IDsDuplicados
FROM B_Prestamos;

-- 1.2 Conteo de nulos por columna clave
SELECT
    SUM(CASE WHEN ID_Prestamo IS NULL THEN 1 ELSE 0 END)      AS Nulos_ID,
    SUM(CASE WHEN IsDefault IS NULL THEN 1 ELSE 0 END)        AS Nulos_IsDefault,
    SUM(CASE WHEN TipoEmpleo IS NULL THEN 1 ELSE 0 END)       AS Nulos_TipoEmpleo,
    SUM(CASE WHEN Educacion IS NULL THEN 1 ELSE 0 END)        AS Nulos_Educacion,
    SUM(CASE WHEN Edad IS NULL THEN 1 ELSE 0 END)             AS Nulos_Edad,
    SUM(CASE WHEN Ingresos IS NULL THEN 1 ELSE 0 END)         AS Nulos_Ingresos,
    SUM(CASE WHEN ImportePrestamo IS NULL THEN 1 ELSE 0 END)  AS Nulos_Importe,
    SUM(CASE WHEN VCrediticio IS NULL THEN 1 ELSE 0 END)      AS Nulos_VCrediticio,
    SUM(CASE WHEN DTIRatio IS NULL THEN 1 ELSE 0 END)         AS Nulos_DTI,
    SUM(CASE WHEN TasaInteres IS NULL THEN 1 ELSE 0 END)      AS Nulos_TasaInteres
FROM B_Prestamos;


-- ==========================================
-- 2. Tasa de incumplimiento general
-- ==========================================
SELECT
    CASE WHEN IsDefault = 1 THEN 'Incumplimiento' ELSE 'No incumplimiento' END AS Estado,
    COUNT(*)                                                                  AS Total,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2))            AS Porcentaje
FROM B_Prestamos
GROUP BY IsDefault
ORDER BY IsDefault;


-- ==========================================
-- 3. Incumplimiento por segmentos
-- ==========================================

-- 3.1 Por tipo de empleo
SELECT
    TipoEmpleo,
    COUNT(*)                                                    AS TotalPrestamos,
    SUM(CAST(IsDefault AS INT))                                 AS Incumplimientos,
    CAST(100.0 * SUM(CAST(IsDefault AS INT)) / COUNT(*) AS DECIMAL(5,2)) AS TasaIncumplimiento
FROM B_Prestamos
GROUP BY TipoEmpleo
ORDER BY TasaIncumplimiento DESC;

-- 3.2 Por nivel educativo
SELECT
    Educacion,
    COUNT(*)                                                    AS TotalPrestamos,
    SUM(CAST(IsDefault AS INT))                                 AS Incumplimientos,
    CAST(100.0 * SUM(CAST(IsDefault AS INT)) / COUNT(*) AS DECIMAL(5,2)) AS TasaIncumplimiento
FROM B_Prestamos
GROUP BY Educacion
ORDER BY TasaIncumplimiento DESC;


-- ==========================================
-- 4. Perfil financiero: Impago vs Cumplimiento
-- ==========================================
SELECT
    CASE WHEN IsDefault = 1 THEN 'Incumplimiento' ELSE 'No incumplimiento' END AS Estado,
    COUNT(*)                                                    AS Total,
    CAST(AVG(CAST(VCrediticio AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS Avg_VCrediticio,
    CAST(AVG(CAST(Ingresos    AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS Avg_Ingresos,
    CAST(AVG(CAST(DTIRatio    AS DECIMAL(18,4))) AS DECIMAL(18,4)) AS Avg_DTIRatio,
    CAST(AVG(CAST(TasaInteres AS DECIMAL(18,4))) AS DECIMAL(18,4)) AS Avg_TasaInteres
FROM B_Prestamos
GROUP BY IsDefault
ORDER BY IsDefault DESC;


-- ==========================================
-- 5. Distribución del importe del préstamo
-- ==========================================
SELECT DISTINCT
    MIN(ImportePrestamo) OVER ()                                            AS Minimo,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ImportePrestamo) OVER ()   AS P25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ImportePrestamo) OVER ()   AS Mediana,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ImportePrestamo) OVER ()   AS P75,
    MAX(ImportePrestamo) OVER ()                                            AS Maximo,
    AVG(CAST(ImportePrestamo AS DECIMAL(18,2))) OVER ()                     AS Promedio
FROM B_Prestamos;


-- ==========================================
-- 6. Distribución por rango de edad
-- ==========================================
WITH BaseEdad AS (
    SELECT
        CASE
            WHEN Edad IS NULL           THEN 'Sin dato'
            WHEN Edad BETWEEN 18 AND 24 THEN '18-24'
            WHEN Edad BETWEEN 25 AND 34 THEN '25-34'
            WHEN Edad BETWEEN 35 AND 44 THEN '35-44'
            WHEN Edad BETWEEN 45 AND 54 THEN '45-54'
            WHEN Edad BETWEEN 55 AND 64 THEN '55-64'
            WHEN Edad >= 65             THEN '65+'
            ELSE 'Fuera de rango'
        END AS RangoEdad,
        Educacion,
        IsDefault
    FROM B_Prestamos
)
-- 6.1 Por rango de edad
SELECT
    RangoEdad,
    COUNT(*)                                                    AS Total,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS PorcentajeCartera,
    CAST(100.0 * SUM(CAST(IsDefault AS INT)) / COUNT(*) AS DECIMAL(5,2)) AS TasaIncumplimiento
FROM BaseEdad
GROUP BY RangoEdad
ORDER BY RangoEdad;

-- 6.2 Por rango de edad y educación
WITH BaseEdad AS (
    SELECT
        CASE
            WHEN Edad IS NULL           THEN 'Sin dato'
            WHEN Edad BETWEEN 18 AND 24 THEN '18-24'
            WHEN Edad BETWEEN 25 AND 34 THEN '25-34'
            WHEN Edad BETWEEN 35 AND 44 THEN '35-44'
            WHEN Edad BETWEEN 45 AND 54 THEN '45-54'
            WHEN Edad BETWEEN 55 AND 64 THEN '55-64'
            WHEN Edad >= 65             THEN '65+'
            ELSE 'Fuera de rango'
        END AS RangoEdad,
        Educacion,
        IsDefault
    FROM B_Prestamos
)
SELECT
    RangoEdad,
    Educacion,
    COUNT(*)                                                    AS Total,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS PorcentajeCartera,
    CAST(100.0 * SUM(CAST(IsDefault AS INT)) / COUNT(*) AS DECIMAL(5,2)) AS TasaIncumplimiento
FROM BaseEdad
GROUP BY RangoEdad, Educacion
ORDER BY RangoEdad, TasaIncumplimiento DESC;