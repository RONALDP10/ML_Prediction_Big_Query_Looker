# BigQuery Model with Looker 🛒📊

Este repositorio muestra cómo trabajar con los datos públicos de **Google Analytics** (Google Store) para crear un modelo de predicción de compra y visualizar los resultados en **Looker**. El proyecto se divide en varias etapas, desde el preprocesamiento de los datos hasta la creación de un modelo predictivo y su visualización en un dashboard interactivo.

---

## 🚀 Estructura del Proyecto

El proyecto se divide en las siguientes secciones:

### 1. **Preprocesamiento de Datos** 🛠️
En esta etapa, se realizan consultas a los datos de Google Analytics para explorar y preparar los datos antes de su análisis. Se incluyen consultas para:
- Conocer los datos de una partición específica.
- Consultar datos de múltiples particiones.
- Convertir diccionarios a columnas para facilitar el análisis.

### 2. **Análisis de Datos** 📈
Se realizan varias consultas para analizar los datos, como las siguientes:
- Número total de transacciones por navegador y tipo de dispositivo.
- Porcentaje de rechazo (**bounce rate**) por origen de tráfico.
- Porcentaje de conversión por sistema operativo, categoría de dispositivo y navegador.
- Porcentaje de visitantes que realizaron una compra en el sitio web.

### 3. **Creación del Modelo Predictivo** 🤖
Se crea un modelo Random Forest **BigQuery ML**:
- En la argumentación del modelo se establecen parámetros como: Número de árboles en paralelo (NUM_PARALLEL_TREE), profundidad del modelo (MAX_TREE_DEPTH )
- Para el entrenamiento se realiza un balanceamiento de los datos con un método UnderSampling para optimizar el entrenamiento del modelo.

Se evalúan el modelo utilizando métricas como la **matriz de confusión** y otras métricas de evaluación proporcionadas por BigQuery ML.

### 4. **Tabla de Dashboard en Looker** 📊
Se crea una tabla en BigQuery para almacenar las predicciones diarias del modelo. Esta tabla se utiliza para alimentar un **dashboard en Looker**, donde se visualizan métricas clave.

Accede al Dahboard aquí: https://lookerstudio.google.com/reporting/5ad7f1f4-efba-4196-906a-630cbcd3877d
