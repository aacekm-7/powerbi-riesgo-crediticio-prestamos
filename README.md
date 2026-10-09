# 🏦 Análisis de cartera de préstamos bancarios y riesgo crediticio

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge)
![Power Query](https://img.shields.io/badge/Power_Query-217346?style=for-the-badge)
![SQL](https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)

> **¿Dónde se concentra el incumplimiento en una cartera de préstamos y qué decisiones debería tomar el banco?**
> Este proyecto responde esa pregunta con un panel interactivo en Power BI y un informe ejecutivo dirigido a la gerencia de Préstamos y Riesgo Crediticio.

---

## 📌 Contenido

- [Objetivo del proyecto](#-objetivo-del-proyecto)
- [Preguntas que responde este análisis](#-preguntas-que-responde-este-análisis)
- [Herramientas utilizadas](#-herramientas-utilizadas)
- [KPIs generales](#-kpis-generales)
- [Hallazgos principales](#-hallazgos-principales)
- [Recomendaciones](#-recomendaciones)
- [Limitaciones](#limitaciones)
- [Estructura del repositorio](#-estructura-del-repositorio)
- [Dashboards](#dashboards)

---

## 🎯 Objetivo del proyecto

Ofrecer una visión panorámica de la cartera de préstamos y analizar en detalle sus productos, grupos crediticios y el indicador de incumplimiento de cada segmento. El fin es apoyar la toma de decisiones y detectar a tiempo los factores que afectan negativamente al negocio.

## ❓ Preguntas que responde este análisis

- ¿Cuál es el nivel de incumplimiento de la cartera y cómo cambió entre 2024 y 2025?
- ¿Qué productos concentran la mayor parte de los préstamos y cuáles incumplen más?
- ¿Qué ocupaciones y rangos de edad presentan mayor riesgo?
- ¿La clasificación de riesgo actual predice realmente el incumplimiento?
- ¿En qué regiones se concentra el saldo pendiente?
- ¿Qué segmentos conviene revisar, reforzar o priorizar?

## 🛠️ Herramientas utilizadas

| Herramienta | Uso en el proyecto |
|---|---|
| **SQL** | Extracción y preparación de los datos |
| **Power Query** | Limpieza y transformación |
| **DAX** | Medidas e indicadores (saldo pendiente, indicador de incumplimiento, etc.) |
| **Power BI** | Modelo de datos y visualización del panel |

## 📊 KPIs generales

| Total de préstamos | Saldo pendiente | Clientes | Préstamos activos | Indicador de incumplimiento |
|:---:|:---:|:---:|:---:|:---:|
| **270.21 M** | **89.20 M** | **30** | **102** | **12.67%** |

*El indicador de incumplimiento representa la proporción de préstamos en estado Incumplido.*

## 🔍 Hallazgos principales

1. **El producto más grande es también el más seguro.** El préstamo hipotecario concentra el 37.4% de la cartera y tiene 0% de incumplimiento. Esto sugiere que los productos con garantía real y menor riesgo de pérdida son más sólidos para el banco.

2. **El préstamo personal es el punto más débil.** Con 26.92% de incumplimiento, supera a todos los demás productos. Al no tener garantía, el banco absorbe el riesgo completo.

3. **La garantía, por sí sola, no explica el resultado.** El préstamo con garantía de oro tiene 23.08% de incumplimiento, mientras que el de garantía de propiedad (LAP) tiene 4.76% y el hipotecario 0%. Conviene revisar cómo se valoran y gestionan las garantías de oro.

4. **La clasificación de riesgo parece no estar funcionando.** El grupo de Bajo Riesgo domina la cartera (41.18%) y tiene el mayor incumplimiento (15.63%). Además, existen dos clasificaciones con resultados distintos (Grupo Crediticio y Categoría de Riesgo, donde Riesgo Bajo suma 63.4%), lo que refuerza la necesidad de validarlas.

5. **El incumplimiento se concentra en ciertas ocupaciones.** Profesores (80%), empleados públicos (aprox. 33%) y médicos (27.27%) encabezan la lista. Con solo 30 clientes, estos porcentajes pueden depender de muy pocos casos, por lo que deben leerse como una alerta y no como una conclusión definitiva.

6. **Los clientes jóvenes concentran la cartera.** El rango 20-30 representa cerca de la mitad de los montos prestados. Sin embargo, su peso dentro del préstamo hipotecario es de 24%, bastante menor a su peso en la cartera total. Por eso, con estos datos no se puede afirmar que los jóvenes sean los principales compradores de vivienda.

7. **La cartera crece, pero la calidad no mejora.** En 2025 se colocó 14.4% más que en 2024 y el saldo pendiente bajó 11.7%, aunque el incumplimiento subió de 12.50% a 12.86%.

## ✅ Recomendaciones

- Reforzar la evaluación crediticia en préstamos personales y líneas de crédito.
- Revisar y recalibrar el modelo de clasificación de riesgo, y unificar las dos clasificaciones existentes.
- Evaluar el proceso de valoración de las garantías de oro.
- Aplicar una revisión más estricta a los perfiles de mayor incumplimiento, confirmando el patrón con una muestra más grande.
- Priorizar la colocación de préstamos hipotecarios y vigilar la concentración geográfica en Maharashtra.

## Limitaciones

- La muestra es pequeña (30 clientes), por lo que varios porcentajes dependen de pocos casos.
- El periodo analizado es corto (2024-2025).
- Los resultados muestran asociaciones, no causas.
- Los datos geográficos corresponden a estados de la India.

## 📁 Estructura del repositorio

```
├── README.md
├── pbi                        # Archivo de Power BI
├── informe                    
│   └── informe-cartera.pdf    # Informe ejecutivo
├── images/                    # Capturas del panel
├── data/                      # Datos del proyecto
└── sql/                       # Consultas utilizadas
```

## Dashboards

### Resumen

<img width="1339" height="755" alt="image" src="https://github.com/user-attachments/assets/d36496ea-f754-4168-ba2d-b12e29d90ccd" />

### Análisis de Riesgos

<img width="1336" height="751" alt="image" src="https://github.com/user-attachments/assets/17e39b37-6ec2-40f0-9ede-7561b2657367" />


## Autor

**Eddy Contreras**
[LinkedIn](https://www.linkedin.com/in/eddy-contreras-5977b91b4/?isSelfProfile=true) · [Correo](eddycontreras23k@gmail.com)

---

*Proyecto basado en un conjunto de datos bancarios de ejemplo, con fines de portafolio.*
