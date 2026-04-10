-- Q2. When is demand highest — by hour and day of week?

USE rideshare;

WITH count_stats AS (
    SELECT 
        DAYNAME(requested_at) AS day_of_week,
        HOUR(requested_at) AS hour_of_day,
        COUNT(*) AS trip_count,
        ROUND(COUNT(*) * 100.0 / (
            SELECT COUNT(*) FROM trips WHERE status = 'completed'
        ), 2) AS pct_trip_count,
        ROUND(AVG(total_fare), 2) AS avg_fare
    FROM trips
    WHERE status = 'completed'
    GROUP BY day_of_week, hour_of_day
),
final_dataset AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY day_of_week ORDER BY trip_count DESC) AS rank_within_day,
        ROW_NUMBER() OVER (ORDER BY trip_count DESC) AS overall_rank,
        CASE day_of_week
            WHEN 'Monday' THEN 1
            WHEN 'Tuesday' THEN 2
            WHEN 'Wednesday' THEN 3
            WHEN 'Thursday' THEN 4
            WHEN 'Friday' THEN 5
            WHEN 'Saturday' THEN 6
            WHEN 'Sunday' THEN 7
        END AS day_order
    FROM count_stats
)

-- Pattern View
SELECT 
    day_of_week,
    hour_of_day,
    trip_count,
    pct_trip_count,
    avg_fare
FROM final_dataset
ORDER BY day_order, hour_of_day;

-- Peak Demand (optional)
-- SELECT * FROM final_dataset WHERE overall_rank = 1;