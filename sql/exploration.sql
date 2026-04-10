USE rideshare;

-- ==============================
-- 1. DATA INTEGRITY
-- ==============================

SELECT * FROM trips LIMIT 5;

-- Null checks
SELECT 
    COUNT(CASE WHEN trip_id IS NULL THEN 1 END) AS missing_trips,
    COUNT(CASE WHEN rider_id IS NULL THEN 1 END) AS missing_riders,
    COUNT(CASE WHEN driver_id IS NULL THEN 1 END) AS missing_drivers,
    COUNT(CASE WHEN total_fare IS NULL THEN 1 END) AS missing_fares,
    COUNT(CASE WHEN status IS NULL THEN 1 END) AS missing_status,
    COUNT(CASE WHEN requested_at IS NULL THEN 1 END) AS missing_dates
FROM trips;

-- Duplicate check
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT trip_id) AS distinct_trip_ids
FROM trips;

-- Invalid values
SELECT 
    COUNT(CASE WHEN total_fare < 0 THEN 1 END) AS negative_values,
    COUNT(CASE WHEN status = 'completed' AND total_fare = 0 THEN 1 END) AS zero_fare_completed,
    COUNT(CASE WHEN requested_at > CURRENT_DATE THEN 1 END) AS future_dates
FROM trips;


-- ==============================
-- 2. DATE COVERAGE
-- ==============================

SELECT 
    MIN(requested_at) AS start_date,
    MAX(requested_at) AS end_date,
    TIMESTAMPDIFF(MONTH, MIN(requested_at), MAX(requested_at)) + 1 AS total_months
FROM trips;

-- Daily trip volume (to detect anomalies / missing periods)
SELECT 
    DATE(requested_at) AS trip_date,
    COUNT(*) AS trips_per_day
FROM trips
GROUP BY trip_date
ORDER BY trip_date;


-- ==============================
-- 3. CORE BUSINESS METRICS
-- ==============================

-- Trip outcomes
SELECT 
    COUNT(*) AS total_trips,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed_trips,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_trips,
    ROUND(COUNT(CASE WHEN status = 'completed' THEN 1 END) * 100.0 / COUNT(*), 2) AS completion_rate,
    ROUND(COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 / COUNT(*), 2) AS cancellation_rate
FROM trips;

-- Cancellation breakdown
SELECT 
    cancelled_by,
    COUNT(*) AS cancellations,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cancellations), 2) AS pct
FROM cancellations
GROUP BY cancelled_by;

-- Cancellation reason
SELECT 
    reason,
    COUNT(*) AS total_cancellations,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cancellations), 2) AS pct
FROM cancellations
GROUP BY reason
ORDER BY total_cancellations DESC;

-- Revenue baseline
SELECT 
    ROUND(SUM(total_fare), 2) AS total_revenue,
    ROUND(AVG(total_fare), 2) AS avg_fare,
    ROUND(STDDEV(total_fare), 2) AS std_dev,
    COUNT(*) AS total_completed_trips
FROM trips
WHERE status = 'completed';


-- ==============================
-- 4. DISTRIBUTIONS
-- ==============================

-- Trips per rider + churn
WITH rider_trips AS (
    SELECT 
        rider_id,
        COUNT(*) AS total_trips,
        MAX(requested_at) AS last_trip_date
    FROM trips
    GROUP BY rider_id
)
SELECT 
    CASE 
        WHEN total_trips = 1 THEN 'one_timer'
        WHEN total_trips BETWEEN 2 AND 5 THEN 'mid'
        ELSE 'many'
    END AS rider_segment,
    COUNT(*) AS total_riders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT rider_id) FROM trips), 2) AS pct_of_active_riders,
    COUNT(CASE WHEN last_trip_date < (SELECT MAX(requested_at) FROM trips) - INTERVAL 30 DAY THEN 1 END) AS churned,
    ROUND(
        COUNT(CASE WHEN last_trip_date < (SELECT MAX(requested_at) FROM trips) - INTERVAL 30 DAY THEN 1 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM rider_trips
GROUP BY rider_segment;


-- Trips per driver distribution
WITH driver_trips AS (
    SELECT 
        driver_id,
        COUNT(*) AS total_trips
    FROM trips
    GROUP BY driver_id
)
SELECT 
    CASE 
        WHEN total_trips = 0 THEN 'no_trips'
        WHEN total_trips BETWEEN 1 AND 10 THEN 'low'
        WHEN total_trips BETWEEN 11 AND 50 THEN 'medium'
        ELSE 'high'
    END AS driver_segment,
    COUNT(*) AS total_drivers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT driver_id) FROM trips), 2) AS pct
FROM driver_trips
GROUP BY driver_segment;


-- ==============================
-- 5. REVENUE CONCENTRATION
-- ==============================

WITH rider_revenue AS (
    SELECT 
        rider_id,
        SUM(total_fare) AS total_spend
    FROM trips
    WHERE status = 'completed'
    GROUP BY rider_id
),
ranked AS (
    SELECT *,
        NTILE(10) OVER (ORDER BY total_spend DESC) AS decile
    FROM rider_revenue
)
SELECT 
    decile,
    COUNT(*) AS riders,
    ROUND(SUM(total_spend), 2) AS revenue,
    ROUND(SUM(total_spend) * 100.0 / (SELECT SUM(total_fare) FROM trips WHERE status='completed'), 2) AS pct_revenue
FROM ranked
GROUP BY decile
ORDER BY decile;


-- ==============================
-- 6. OBSERVATIONS
-- ==============================

-- 1. ~15% trips are cancelled, with majority by riders → potential UX or intent issue
-- 2. Most cancellations attributed to 'personal emergency' → may indicate placeholder or low-signal reason
-- 3. Combining 'too long wait'and 'waited too long', it becomes the leading driver of cancellations (~18%) → wait time sensitivity
-- 4. One-time riders show extremely high churn → weak first experience or low retention hooks
-- 5. Mid-frequency riders also churn heavily → retention problem is not limited to one-timers
-- 6. Driver activity likely uneven → requires distribution validation 
-- 7. Revenue likely concentrated among top rider segments → dependency risk on small user base

