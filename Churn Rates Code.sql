WITH months AS(
SELECT  
    '2017-01-01' AS first_day, 
    '2017-01-31' AS last_day 
  UNION 
  SELECT 
    '2017-02-01' AS first_day, 
    '2017-02-28' AS last_day 
  UNION 
  SELECT 
    '2017-03-01' AS first_day, 
    '2017-03-31' AS last_day ), 
cross_join AS(
SELECT *
FROM subscriptions
CROSS JOIN months),
status AS(
SELECT id, first_day as 'month', 
CASE 
WHEN (segment == 87) 
  AND(subscription_start < first_day)
  AND(subscription_end > first_day OR subscription_end IS NULL) THEN 1
  ELSE 0
  END as 'is_active87', 
CASE 
WHEN (segment == 30) 
  AND(subscription_start < first_day)
  AND(subscription_end > first_day OR subscription_end IS NULL) THEN 1
  ELSE 0
  END as 'is_active30',
  CASE
  WHEN (segment == 87) 
  AND(subscription_end BETWEEN first_day AND last_day) THEN 1
  ELSE 0
  END as 'is_canceled87',
  CASE
  WHEN segment == 30
  AND(subscription_end BETWEEN first_day AND last_day) THEN 1
  ELSE 0
  END as 'is_canceled30'
  FROM cross_join),
  status_aggregate AS(
  SELECT month,SUM(is_active87) as 'sum_active87', SUM(is_active30) as 'sum_active30', SUM(is_canceled87) as 'sum_canceled87', SUM(is_canceled30) as 'sum_canceled30'
FROM status
GROUP BY 1)
SELECT month, 1.0 * sum_canceled30/sum_active30, 1.0 * sum_canceled87/sum_active87
FROM status_aggregate;

      