-- =====================================================================
-- RedFlag — Fraud Detection Submission
-- Student: Prerana
-- Batch: DA-DS-1
-- Project: SQL-Based Fraud Detection Engine
-- Database: redflag
-- =====================================================================

USE redflag;
-- =====================================================================
-- PATTERN 1 · VELOCITY FRAUD
-- What I'm looking for:
-- Users making 30 or more transactions on a single calendar day.
-- Expected suspects: approximately 45-55 user-days.
-- =====================================================================
SELECT
    user_id,
    DATE(txn_time) AS attack_date,
    COUNT(*) AS daily_txn_count
FROM transactions
GROUP BY
    user_id,
    DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY daily_txn_count DESC;

-- =====================================================================
-- PATTERN 2 · ROUND-AMOUNT CLUSTERING
-- What I'm looking for:
-- Users with 15 or more transactions using suspicious round amounts.
-- Expected suspects: 25.
-- =====================================================================

SELECT
    user_id,
    COUNT(*) AS round_amount_txns
FROM transactions
WHERE amount IN (100, 200, 500, 1000, 2000, 5000, 10000)
GROUP BY user_id
HAVING COUNT(*) >= 15
ORDER BY round_amount_txns DESC;

-- =====================================================================
-- PATTERN 3 · CARD TESTING
-- What I'm looking for:
-- Users making 30+ transactions below ₹10 in a single day.
-- Expected suspects: 20.
-- =====================================================================

SELECT
    user_id,
    DATE(txn_time) AS attack_date,
    COUNT(*) AS tiny_txn_count
FROM transactions
WHERE amount < 10
GROUP BY
    user_id,
    DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY tiny_txn_count DESC;

-- =====================================================================
-- PATTERN 4 · FAILED-THEN-SUCCEEDED
-- What I'm looking for:
-- Users repeatedly retrying failed transactions until a transaction
-- with the same amount succeeds within two minutes.
-- Expected suspects: 25.
-- =====================================================================

SELECT
    f.user_id,
    COUNT(*) AS failed_success_pairs
FROM transactions AS f
JOIN transactions AS s
    ON f.user_id = s.user_id
    AND f.amount = s.amount
    AND s.txn_time > f.txn_time
    AND TIMESTAMPDIFF(SECOND, f.txn_time, s.txn_time) <= 120
WHERE f.status = 'FAILED'
  AND s.status = 'SUCCESS'
GROUP BY f.user_id
HAVING COUNT(*) >= 20
ORDER BY failed_success_pairs DESC;

SELECT
    user_id,
    COUNT(*) AS failed_txns
FROM transactions
WHERE status = 'FAILED'
GROUP BY user_id
HAVING COUNT(*) >= 20
ORDER BY failed_txns DESC;

-- =====================================================================
-- PATTERN 5 · ODD-HOUR CONCENTRATION
-- What I'm looking for:
-- Users with 30+ transactions where at least 80% occur between
-- 02:00 and 05:00.
-- Expected suspects: 20.
-- =====================================================================

SELECT
    user_id,
    COUNT(*) AS total_txns,
    SUM(
        CASE
            WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1
            ELSE 0
        END
    ) AS odd_hour_txns,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS odd_hour_percentage
FROM transactions
GROUP BY user_id
HAVING COUNT(*) >= 30
   AND SUM(
        CASE
            WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1
            ELSE 0
        END
       ) / COUNT(*) >= 0.80
ORDER BY odd_hour_percentage DESC;

-- =====================================================================
-- PATTERN 6 · MULE ACCOUNTS
-- What I'm looking for:
-- Users receiving money through CREDIT transactions and quickly moving
-- at least 70% of the credited amount out through DEBIT transactions.
-- Expected suspects: 30.
-- =====================================================================

SELECT
    c.user_id,
    COUNT(*) AS mule_instances
FROM transactions AS c
WHERE c.txn_type = 'CREDIT'
  AND EXISTS (
      SELECT 1
      FROM transactions AS d
      WHERE d.user_id = c.user_id
        AND d.txn_type = 'DEBIT'
        AND d.txn_time > c.txn_time
        AND TIMESTAMPDIFF(MINUTE, c.txn_time, d.txn_time) <= 30
        AND d.amount >= 0.70 * c.amount
  )
GROUP BY c.user_id
HAVING COUNT(*) >= 5
ORDER BY mule_instances DESC;

-- =====================================================================
-- PATTERN 7 · REFUND ABUSE
-- What I'm looking for:
-- Users with 20+ transactions where more than 40% are refunds.
-- Expected suspects: approximately 24-25.
-- =====================================================================

SELECT
    user_id,
    COUNT(*) AS total_txns,
    SUM(
        CASE
            WHEN txn_type = 'REFUND' THEN 1
            ELSE 0
        END
    ) AS refund_txns,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN txn_type = 'REFUND' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS refund_percentage
FROM transactions
GROUP BY user_id
HAVING COUNT(*) >= 20
   AND SUM(
        CASE
            WHEN txn_type = 'REFUND' THEN 1
            ELSE 0
        END
       ) / COUNT(*) > 0.40
ORDER BY refund_percentage DESC;

-- =====================================================================
-- PATTERN 8 · MERCHANT COLLUSION
-- What I'm looking for:
-- Merchants where the top 5 users account for more than 60% of
-- the merchant's total transaction value.
-- Expected suspects: 15 merchants.
-- =====================================================================

WITH merchant_user_volume AS (
    SELECT
        merchant_id,
        user_id,
        SUM(amount) AS user_volume
    FROM transactions
    GROUP BY
        merchant_id,
        user_id
),

ranked_users AS (
    SELECT
        merchant_id,
        user_id,
        user_volume,
        ROW_NUMBER() OVER (
            PARTITION BY merchant_id
            ORDER BY user_volume DESC
        ) AS user_rank
    FROM merchant_user_volume
),

merchant_totals AS (
    SELECT
        merchant_id,
        SUM(amount) AS merchant_total
    FROM transactions
    GROUP BY merchant_id
),

top_five AS (
    SELECT
        merchant_id,
        SUM(user_volume) AS top_five_volume
    FROM ranked_users
    WHERE user_rank <= 5
    GROUP BY merchant_id
)

SELECT
    t.merchant_id,
    t.top_five_volume,
    m.merchant_total,
    ROUND(
        100.0 * t.top_five_volume / m.merchant_total,
        2
    ) AS top_five_percentage
FROM top_five AS t
JOIN merchant_totals AS m
    ON t.merchant_id = m.merchant_id
WHERE t.top_five_volume / m.merchant_total > 0.60
ORDER BY top_five_percentage DESC;

-- =====================================================================
-- PATTERN 9 · JUST-UNDER-THRESHOLD
-- What I'm looking for:
-- Users making 10 or more transactions exactly at ₹9,999.
-- Expected suspects: 20.
-- =====================================================================

SELECT
    user_id,
    COUNT(*) AS threshold_txns
FROM transactions
WHERE amount = 9999.00
GROUP BY user_id
HAVING COUNT(*) >= 10
ORDER BY threshold_txns DESC;

-- =====================================================================
-- PATTERN 10 · DORMANT-THEN-ACTIVE
-- What I'm looking for:
-- Users with a 90+ day transaction gap followed by at least
-- 15 transactions after the dormant period.
-- Expected suspects: approximately 25-27.
-- =====================================================================

WITH transaction_gaps AS (
    SELECT
        user_id,
        txn_time,
        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_txn_time
    FROM transactions
),

dormant_points AS (
    SELECT
        user_id,
        txn_time AS reactivation_time
    FROM transaction_gaps
    WHERE previous_txn_time IS NOT NULL
      AND TIMESTAMPDIFF(
          DAY,
          previous_txn_time,
          txn_time
      ) >= 90
)

SELECT
    d.user_id,
    COUNT(t.txn_id) AS post_dormant_txns,
    MIN(d.reactivation_time) AS reactivation_time
FROM dormant_points AS d
JOIN transactions AS t
    ON t.user_id = d.user_id
   AND t.txn_time >= d.reactivation_time
GROUP BY
    d.user_id,
    d.reactivation_time
HAVING COUNT(t.txn_id) >= 15
ORDER BY post_dormant_txns DESC;

-- =====================================================================
-- PATTERN 11 · VELOCITY SPIKE
-- What I'm looking for:
-- Users whose peak monthly transaction count is at least 5 times
-- their average monthly transaction count and whose peak is at least 20.
-- Expected suspects: approximately 35-45 users.
-- =====================================================================

WITH monthly_counts AS (
    SELECT
        user_id,
        DATE_FORMAT(txn_time, '%Y-%m') AS transaction_month,
        COUNT(*) AS monthly_txns
    FROM transactions
    GROUP BY
        user_id,
        DATE_FORMAT(txn_time, '%Y-%m')
),

user_statistics AS (
    SELECT
        user_id,
        AVG(monthly_txns) AS average_monthly_txns,
        MAX(monthly_txns) AS peak_monthly_txns
    FROM monthly_counts
    GROUP BY user_id
)

SELECT
    user_id,
    ROUND(average_monthly_txns, 2) AS average_monthly_txns,
    peak_monthly_txns,
    ROUND(
        peak_monthly_txns / average_monthly_txns,
        2
    ) AS spike_ratio
FROM user_statistics
WHERE peak_monthly_txns >= 20
  AND peak_monthly_txns / average_monthly_txns >= 5
ORDER BY spike_ratio DESC;

-- =====================================================================
-- PATTERN 12 · GEOGRAPHIC IMPOSSIBILITY
-- What I'm looking for:
-- Users making transactions in different cities within 60 minutes.
-- Expected suspects: 15.
-- =====================================================================

WITH transaction_history AS (
    SELECT
        user_id,
        txn_id,
        txn_time,
        city,
        LAG(city) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_city,
        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_txn_time
    FROM transactions
)

SELECT
    user_id,
    txn_id,
    previous_city,
    city AS current_city,
    previous_txn_time,
    txn_time,
    TIMESTAMPDIFF(
        MINUTE,
        previous_txn_time,
        txn_time
    ) AS minutes_between
FROM transaction_history
WHERE previous_city IS NOT NULL
  AND previous_city <> city
  AND TIMESTAMPDIFF(
      MINUTE,
      previous_txn_time,
      txn_time
  ) <= 60
ORDER BY minutes_between ASC;

