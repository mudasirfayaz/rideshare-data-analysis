USE rideshare;

-- ==========================================
-- Q2. Demand Patterns
-- ==========================================

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
        day_of_week,
        hour_of_day,
        trip_count,
        pct_trip_count,
        avg_fare,
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
            ELSE 99
        END AS day_order
    FROM count_stats
)

-- ==============================
-- Pattern View (Chronological)
-- ==============================
SELECT 
    day_of_week,
    hour_of_day,
    trip_count,
    pct_trip_count,
    avg_fare,
    rank_within_day
FROM final_dataset
ORDER BY day_order;


-- ==============================
-- Ranking View (Peak Demand)
-- ==============================
-- Uncomment to use
-- SELECT 
--     day_of_week,
--     hour_of_day,
--     trip_count,
--     pct_trip_count,
--     avg_fare,
--     rank_within_day,
--     overall_rank
-- FROM final_dataset
-- ORDER BY overall_rank;



-- ===============================================
--  Observations
-- ===============================================

-- 1. Demand peaks during weekday morning and evening hours, indicating strong commuter-driven usage patterns. 
--    These time windows consistently rank highest across multiple weekdays, suggesting predictable, routine-based demand.

-- 2. Peak demand hours do not consistently align with the highest average fares, suggesting that pricing is not
--    strictly driven by volume and may depend on additional factors such as distance or supply conditions.

-- 3. Weekend demand patterns differ from weekdays, showing more distributed activity and peak hours 
--    shifting toward late-night and midday periods, reflecting more flexible, non-commute usage
