WITH rider_stats AS (
    SELECT
        t.rider_id,
        u.name AS rider_name,
        u.city,
        COUNT(t.trip_id) AS total_trips,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) AS completed_trips,
        ROUND(SUM(t.total_fare), 1) AS total_spend,
        ROUND(AVG(t.total_fare), 1) AS avg_fare,
        DATE_FORMAT(MAX(t.requested_at), "%Y-%m-%d") AS last_trip_date
    FROM trips t
    JOIN riders r ON t.rider_id = r.rider_id
    JOIN users u ON r.user_id = u.user_id
    WHERE u.is_driver = 0
    GROUP BY t.rider_id, u.name, u.city
)

SELECT *,
    CASE
        WHEN total_trips = 1 THEN 'One-timer'
        WHEN total_trips BETWEEN 2 AND 5 THEN 'Casual'
        WHEN total_trips BETWEEN 6 AND 20 THEN 'Regular'
        ELSE 'Power user'
    END AS rider_segment,
    
    CASE
        WHEN last_trip_date >= (select max(requested_at) from trips) - INTERVAL 30 DAY THEN 'Active'
        ELSE 'Churned'
    END AS retention_status

FROM rider_stats
ORDER BY total_spend DESC;

