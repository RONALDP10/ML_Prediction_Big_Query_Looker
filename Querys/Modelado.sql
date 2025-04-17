-- Creación del Modelo

CREATE OR REPLACE MODEL `bqml_gaSessions.modelo_final_RF`
OPTIONS(
  model_type='RANDOM_FOREST_CLASSIFIER',
  NUM_PARALLEL_TREE = 60,
  MAX_TREE_DEPTH = 8,
  min_split_loss = 0.1,
  data_split_method='RANDOM',
  data_split_eval_fraction=0.2
) AS
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
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170531'
AND (Totals.transactions IS NOT NULL OR RAND() < 0.1);

--Metricas y Evaluación con base de prueba
WITH TEST_DATA AS (
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
  WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'
)

--Matriz de confusion
SELECT *
FROM ml.CONFUSION_MATRIX(MODEL `bqml_gaSessions.modelo_final_RF`, (SELECT * FROM TEST_DATA));

--Evaluación del modelo 
SELECT   *
FROM   ml.EVALUATE(MODEL `bqml_gaSessions.modelo_final_RF`, (SELECT * FROM TEST_DATA));
