--Cual es el número total de transacciones generadas por navegador y tipo de dispositivo?
SELECT device.deviceCategory,
       device.browser,
       SUM(totals.transactions) AS total_transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20160831'
GROUP BY 1,2
HAVING SUM(totals.transactions) IS NOT NULL
ORDER BY 1, 3 DESC;

--Cual es el porcentaje de rechazo por origen de tráfico?
SELECT source,
        total_visits,
        total_bounces,
        ((total_bounces / total_visits ) * 100 ) AS bounce_rate
FROM (SELECT trafficSource.source AS source,
             COUNT ( trafficSource.source ) AS total_visits,
             SUM ( totals.bounces ) AS total_bounces
      FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
      WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
      GROUP BY 1
      )
ORDER BY 1 DESC;

--Cual es el porcentaje de conversión por operating_system,device_category y browser?
SELECT totals.transactions, SUM(totals.transactionRevenue), COUNT(*)
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
group by 1
order by 1


SELECT 
      IFNULL(device.operatingSystem, "Unknown") AS operating_system,
      device.deviceCategory AS device_category,
      IFNULL(device.browser, "Unknown") AS browser,
      COUNT(*) AS total_sessions,
      SUM(IF(totals.transactions IS NULL, 0, 1)) AS total_transactions,
      ROUND((SUM(IF(totals.transactions IS NULL, 0, 1)) / COUNT(*)) * 100, 2) AS conversion_rate_percentage
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20160831'
GROUP BY 1, 2, 3
ORDER BY 6 DESC;
