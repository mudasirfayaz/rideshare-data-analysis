-- Q2. When is demand highest — by hour and day of week?

-- Peak Hours
SELECT 
	HOUR(requested_at) AS hour_of_day,
    COUNT(*) AS trip_count,
    ROUND(AVG(total_fare), 2) AS avg_fare
FROM trips
WHERE status = "completed"
GROUP BY hour_of_day
ORDER BY trip_count DESC;

-- Peak Days
SELECT 
	DAYNAME(requested_at) AS day_of_week,
    COUNT(*) AS trip_count,
    ROUND(AVG(total_fare), 2) AS avg_fare
FROM trips
WHERE status = "completed"
GROUP BY day_of_week
ORDER BY trip_count DESC;