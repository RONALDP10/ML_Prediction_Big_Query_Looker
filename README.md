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
Se realizan varias consultas para analizar los datos, incluyendo:
- Número total de transacciones por navegador y tipo de dispositivo.
- Porcentaje de rechazo (**bounce rate**) por origen de tráfico.
- Porcentaje de conversión por sistema operativo, categoría de dispositivo y navegador.
- Porcentaje de visitantes que realizaron una compra en el sitio web.

### 3. **Creación del Modelo Predictivo** 🤖
Se crean dos modelos de regresión logística utilizando **BigQuery ML**:
- En la argumentación del modelo se establece un número de profundidad de 8. También se incluye regularización L1 y L2
- e realiza un balanceamiento de los datos con un método UnderSampling para optimizar el entrenamiento del modelo.

Se evalúan el modelo utilizando métricas como la **matriz de confusión** y otras métricas de evaluación proporcionadas por BigQuery ML.

### 4. **Tabla de Dashboard en Looker** 📊
Se crea una tabla en BigQuery para almacenar las predicciones diarias del modelo. Esta tabla se utiliza para alimentar un **dashboard en Looker**, donde se visualizan métricas clave.

Accede al Dahboard aquí: https://lookerstudio.google.com/reporting/80c7ce14-bba5-4177-9ef6-a8fd79749111
