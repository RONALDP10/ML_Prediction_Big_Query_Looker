-- Creando una tabla para guardar los datos
CREATE OR REPLACE TABLE `bqml_gaSessions.final_prediction` (
  label INT64,
  operatingSystem STRING,
  isMobile BOOLEAN,
  country STRING,
  region STRING,
  deviceCategory STRING,
  browser STRING,
  isBounce INT64,
  hits INT64,
  timeOnSite INT64,
  trafficSource STRING,
  trafficMedium STRING,
  visitNumber INT64,
  visitHour INT64,
  is_working_hours INT64,
  visit_day_of_week INT64,
  avgTimePerPage FLOAT64,
  interactions_per_minute FLOAT64,
  products_interacted INT64,
  predictedLabel INT64,
  predictedProbability FLOAT64,
  predictionDate DATE
)
PARTITION BY predictionDate;

-- Insertando los resultados de la predicción en la tabla de resultados
INSERT INTO `bqml_gaSessions.final_prediction`
WITH 
predictions AS (
  SELECT 
    predicted_label,
    predicted_label_probs[OFFSET(0)].prob AS predicted_probability,
    label,
    os,
    is_mobile,
    country,
    region,
    device_category,
    browser,
    is_bounce,
    hits,
    time_on_site,
    traffic_source,
    traffic_medium,
    visit_Number,
    visit_hour,
    is_working_hours,
    visit_day_of_week,
    avg_time_per_page,
    interactions_per_minute,
    products_interacted

  FROM
    ML.PREDICT(MODEL `eco-span-392619.bqml_gaSessions.modelo_final_RF`,
    (
      SELECT
        IF(totals.transactions IS NULL, 0, 1) AS label,
        IFNULL(device.operatingSystem, "") AS os,
        device.isMobile AS is_mobile,
        IFNULL(geoNetwork.country, "") AS country,
        IFNULL(geoNetwork.region, "") AS region,
        device.deviceCategory AS device_category,
        CASE 
          WHEN device.browser IN ("Chrome", "Firefox", "Safari", "Edge") THEN device.browser
          ELSE "Other"
        END AS browser,
        IF(IFNULL(totals.pageviews, 0) = 1, 1, 0) AS is_bounce,
        IFNULL(totals.hits, 0) AS hits,
        IFNULL(totals.timeOnSite, 0) AS time_on_site,
        IFNULL(trafficSource.source, "") AS traffic_source,
        IFNULL(trafficSource.medium, "") AS traffic_medium,
        visitNumber AS visit_Number,
        EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime)) AS visit_hour,
        IF(EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime)) BETWEEN 9 AND 17, 1, 0) AS is_working_hours,
        EXTRACT(DAYOFWEEK FROM PARSE_DATE('%Y%m%d', date)) AS visit_day_of_week,
        SAFE_DIVIDE(IFNULL(totals.timeOnSite, 0), IFNULL(totals.pageviews, 1)) AS avg_time_per_page,
        SAFE_DIVIDE(IFNULL(totals.hits, 0), GREATEST(IFNULL(totals.timeOnSite, 1)/60, 1)) AS interactions_per_minute,
        (
          SELECT COUNT(*)
          FROM UNNEST(hits) AS h
          CROSS JOIN UNNEST(h.product) AS p
          WHERE p.productSKU IS NOT NULL
        ) AS products_interacted

      FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
      WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801')
    ) ORDER BY predicted_probability DESC
)
SELECT
  label,
  os AS operatingSystem,
  is_mobile AS isMobile,
  country,
  region,
  device_category AS deviceCategory,
  browser,
  is_bounce AS isBounce,
  hits,
  time_on_site AS timeOnSite,
  traffic_source AS trafficSource,
  traffic_medium AS trafficMedium,
  visit_Number AS visitNumber,
  visit_hour AS visitHour,
  is_working_hours,
  visit_day_of_week,
  avg_time_per_page AS avgTimePerPage,
  interactions_per_minute,
  products_interacted,
  predicted_label AS predictedLabel,
  predicted_probability AS predictedProbability,
  CURRENT_DATE() AS predictionDate
FROM predictions;
