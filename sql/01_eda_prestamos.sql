/* 
     0. Exploración inicial
     1. Calidad de datos (filas, nulos, duplicados)
     2. Tasa de incumplimiento general
     3. Incumplimiento por segmento categórico
     4. Perfil financiero: incumplimiento vs. no incumplimiento
     5. Distribución del importe del préstamo
     6. Distribución por rango de edad

   NOTA: IsDefault = 1 -> el prestatario incurrió en impago
         IsDefault = 0 -> el prestatario cumplió
*/

USE BancoRCrediticio;
GO


/* ---------------------------------------------------------------------
   0. EXPLORACIÓN INICIAL
   Se usa TOP en lugar de SELECT * para no traer toda la tabla.
   --------------------------------------------------------------------- */
SELECT TOP 10 *
FROM B_Prestamos;


/* ---------------------------------------------------------------------
   1. CALIDAD DE DATOS
   --------------------------------------------------------------------- */

-- 1.1 Total de filas y duplicados de ID en una sola consulta
SELECT
    COUNT(*)                                AS TotalFilas,
    COUNT(DISTINCT ID_Prestamo)             AS IDsUnicos,
    COUNT(*) - COUNT(DISTINCT ID_Prestamo)  AS IDsDuplicados
FROM B_Prestamos;
-- Resultado: 255,347 registros | 0 duplicados

-- 1.2 Nulos por columna clave
SELECT
    SUM(CASE WHEN ID_Prestamo    IS NULL THEN 1 ELSE 0 END) AS Nulos_ID_Prestamo,
    SUM(CASE WHEN IsDefault      IS NULL THEN 1 ELSE 0 END) AS Nulos_IsDefault,
    SUM(CASE WHEN TipoEmpleo     IS NULL THEN 1 ELSE 0 END) AS Nulos_TipoEmpleo,
    SUM(CASE WHEN Educacion      IS NULL THEN 1 ELSE 0 END) AS Nulos_Educacion,
    SUM(CASE WHEN Edad           IS NULL THEN 1 ELSE 0 END) AS Nulos_Edad,
    SUM(CASE WHEN Ingresos       IS NULL THEN 1 ELSE 0 END) AS Nulos_Ingresos,
    SUM(CASE WHEN ImportePrestamo IS NULL THEN 1 ELSE 0 END) AS Nulos_ImportePrestamo,
    SUM(CASE WHEN VCrediticio    IS NULL THEN 1 ELSE 0 END) AS Nulos_VCrediticio,
    SUM(CASE WHEN DTIRatio       IS NULL THEN 1 ELSE 0 END) AS Nulos_DTIRatio,
    SUM(CASE WHEN TasaInteres    IS NULL THEN 1 ELSE 0 END) AS Nulos_TasaInteres
FROM B_Prestamos;
-- Resultado: ID_Prestamo sin nulos


/* ---------------------------------------------------------------------
   2. TASA DE INCUMPLIMIENTO GENERAL
   --------------------------------------------------------------------- */
SELECT
    CASE WHEN IsDefault = 1 THEN 'Incumplimiento'
         ELSE 'No incumplimiento' END                         AS Cumplimiento,
    COUNT(*)                                                  AS Total,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS Porcentaje
FROM B_Prestamos
GROUP BY IsDefault
ORDER BY IsDefault;
-- Resultado: ~88% no incurrió en impago | ~12% sí


/* ---------------------------------------------------------------------
   3. INCUMPLIMIENTO POR SEGMENTO CATEGÓRICO
   Se calcula la TASA de incumplimiento por categoría (no solo el conteo),
   que es lo que permite comparar segmentos de distinto tamaño.
   --------------------------------------------------------------------- */

-- 3.1 Por tipo de empleo
SELECT
    TipoEmpleo,
    COUNT(*)                                                          AS TotalPrestamos,
    SUM(CAST(IsDefault AS INT))                                       AS Incumplimientos,
    CAST(100.0 * SUM(CAST(IsDefault AS INT)) / COUNT(*) AS DECIMAL(5,2)) AS TasaIncumplimiento
FROM B_Prestamos
GROUP BY TipoEmpleo
ORDER BY TasaIncumplimiento DESC;

-- 3.2 Por nivel educativo (misma estructura; se puede replicar con otra columna categórica)
SELECT
    Educacion,
    COUNT(*)                                                          AS TotalPrestamos,
    SUM(CAST(IsDefault AS INT))                                       AS Incumplimientos,
    CAST(100.0 * SUM(CAST(IsDefault AS INT)) / COUNT(*) AS DECIMAL(5,2)) AS TasaIncumplimiento
FROM B_Prestamos
GROUP BY Educacion
ORDER BY TasaIncumplimiento DESC;


/* ---------------------------------------------------------------------
   4. PERFIL FINANCIERO: INCUMPLIMIENTO VS. NO INCUMPLIMIENTO
   AVG sobre columnas enteras trunca decimales en SQL Server,
   por eso se convierte a DECIMAL antes de promediar.
   --------------------------------------------------------------------- */
SELECT
    CASE WHEN IsDefault = 1 THEN 'Incumplimiento'
         ELSE 'No incumplimiento' END                                   AS Cumplimiento,
    COUNT(*)                                                            AS Total,
    CAST(AVG(CAST(VCrediticio AS DECIMAL(18,2))) AS DECIMAL(18,2))      AS AVG_VCrediticio,
    CAST(AVG(CAST(Ingresos    AS DECIMAL(18,2))) AS DECIMAL(18,2))      AS AVG_Ingresos,
    CAST(AVG(CAST(DTIRatio    AS DECIMAL(18,4))) AS DECIMAL(18,4))      AS AVG_DTIRatio,
    CAST(AVG(CAST(TasaInteres AS DECIMAL(18,4))) AS DECIMAL(18,4))      AS AVG_TasaInteres
FROM B_Prestamos
GROUP BY IsDefault
ORDER BY IsDefault DESC;


/* ---------------------------------------------------------------------
   5. DISTRIBUCIÓN DEL IMPORTE DEL PRÉSTAMO
   PERCENTILE_CONT como función de ventana + DISTINCT devuelve una sola fila
   sin necesidad de CTE ni MAX() artificiales.
   --------------------------------------------------------------------- */
SELECT DISTINCT
    MIN(ImportePrestamo) OVER ()                                            AS Minimo,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ImportePrestamo) OVER ()   AS P25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ImportePrestamo) OVER ()   AS Mediana,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ImportePrestamo) OVER ()   AS P75,
    MAX(ImportePrestamo) OVER ()                                            AS Maximo,
    AVG(CAST(ImportePrestamo AS DECIMAL(18,2))) OVER ()                     AS Promedio
FROM B_Prestamos;

-- Min: 5,000 | P25: 66,156 | Mediana: 127,556 | P75: 188,985 | Max: 249,999 | Promedio: 127,578



/* ---------------------------------------------------------------------
   6. DISTRIBUCIÓN POR RANGO DE EDAD
   Rangos de ancho uniforme y con categoría para valores nulos o fuera de rango.
   El CASE se define una sola vez en un CTE (antes estaba repetido en el GROUP BY).
   --------------------------------------------------------------------- */
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
    COUNT(*)                                                              AS Total,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2))        AS PorcentajeCartera,
    CAST(100.0 * SUM(CAST(IsDefault AS INT)) / COUNT(*) AS DECIMAL(5,2))  AS TasaIncumplimiento
FROM BaseEdad
GROUP BY RangoEdad
ORDER BY RangoEdad;

-- 6.2 Por rango de edad y nivel educativo
-- (un CTE solo vale para la sentencia que le sigue, por eso se vuelve a declarar)
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
    COUNT(*)                                                              AS Total,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2))        AS PorcentajeCartera,
    CAST(100.0 * SUM(CAST(IsDefault AS INT)) / COUNT(*) AS DECIMAL(5,2))  AS TasaIncumplimiento
FROM BaseEdad
GROUP BY RangoEdad, Educacion
ORDER BY RangoEdad, TasaIncumplimiento DESC;
