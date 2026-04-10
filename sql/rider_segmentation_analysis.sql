-- Q4. Who are our most valuable riders, and are we retaining them?

USE rideshare;

WITH rider_stats AS (
    SELECT
        t.rider_id,
        u.name AS rider_name,
        u.city,
        COUNT(*) AS total_trips,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) AS completed_trips,
        ROUND(COUNT(CASE WHEN t.status = 'completed' THEN 1 END) * 100.0 / COUNT(*), 2) AS completion_rate,
        ROUND(SUM(CASE WHEN t.status = 'completed' THEN t.total_fare ELSE 0 END), 2) AS total_spend,
        ROUND(
            SUM(CASE WHEN t.status = 'completed' THEN t.total_fare ELSE 0 END) * 1.0
            / NULLIF(COUNT(CASE WHEN t.status = 'completed' THEN 1 END), 0),
        2) AS spend_per_trip,
        MAX(t.requested_at) AS last_trip_date
    FROM trips t
    JOIN riders r ON t.rider_id = r.rider_id
    JOIN users u ON r.user_id = u.user_id
    WHERE u.is_driver = 0
    GROUP BY t.rider_id, u.name, u.city
),
ranked_metrics AS (
    SELECT *,
        ROUND(PERCENT_RANK() OVER (ORDER BY total_spend) * 100, 2) AS spend_percentile
    FROM rider_stats
),
final AS (
    SELECT *,
        CASE 
            WHEN spend_percentile >= 80 THEN 'High'
            WHEN spend_percentile >= 40 THEN 'Medium'
            ELSE 'Low'
        END AS value_segment,
        CASE
            WHEN total_trips = 1 THEN 'One-timer'
            WHEN total_trips BETWEEN 2 AND 5 THEN 'Casual'
            WHEN total_trips BETWEEN 6 AND 20 THEN 'Regular'
            ELSE 'Power user'
        END AS rider_segment,
        CASE
            WHEN last_trip_date >= (SELECT MAX(requested_at) FROM trips) - INTERVAL 30 DAY THEN 'Active'
            ELSE 'Churned'
        END AS retention_status
    FROM ranked_metrics
)

SELECT *
FROM final
ORDER BY total_spend DESC;

-- Aggregated summary
-- SELECT rider_segment, value_segment,
-- COUNT(*) AS total_users,
-- ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) AS total_users FROM final), 2) AS user_pct,
-- ROUND(COUNT(CASE WHEN retention_status = 'Churned' THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate
-- FROM final
-- GROUP BY rider_segment, value_segment;