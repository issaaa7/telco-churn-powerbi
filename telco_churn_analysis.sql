-- Анализ оттока клиентов телеком-компании (SQLite)
-- Данные: Telco Customer Churn (IBM, Kaggle), таблица telco, 7043 клиента
-- Отток = доля клиентов со значением Churn = 'Yes'

-- 1. Общий отток
SELECT
  COUNT(*) AS clients,
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
  ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_pct
FROM telco;

-- 2. Отток по типу договора
SELECT
  Contract,
  COUNT(*) AS clients,
  ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_pct
FROM telco
GROUP BY Contract
ORDER BY churn_pct DESC;

-- 3. Отток по способу оплаты
SELECT
  PaymentMethod,
  COUNT(*) AS clients,
  ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_pct
FROM telco
GROUP BY PaymentMethod
ORDER BY churn_pct DESC;

-- 4. Тип интернета: отток и средний ежемесячный платёж
SELECT
  InternetService,
  COUNT(*) AS clients,
  ROUND(AVG(CAST(MonthlyCharges AS REAL)), 2) AS avg_monthly,
  ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_pct
FROM telco
GROUP BY InternetService
ORDER BY churn_pct DESC;

-- 5. Самые рискованные группы клиентов (группы меньше 50 клиентов не учитываются)
SELECT
  InternetService,
  Contract,
  PaymentMethod,
  COUNT(*) AS clients,
  ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_pct
FROM telco
GROUP BY InternetService, Contract, PaymentMethod
HAVING COUNT(*) >= 50
ORDER BY churn_pct DESC
LIMIT 5;

-- 6. Какую долю всех ушедших клиентов даёт самая рискованная группа
SELECT
  COUNT(*) AS clients_in_group,
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_in_group,
  ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / (SELECT COUNT(*) FROM telco WHERE Churn = 'Yes'), 2) AS share_of_all_churned_pct
FROM telco
WHERE InternetService = 'Fiber optic'
  AND Contract = 'Month-to-month'
  AND PaymentMethod = 'Electronic check';
