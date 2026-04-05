-- Q3. Who are the top-performing drivers, and who is underperforming?

USE rideshare;

WITH driver_stats AS (
    SELECT
        d.driver_id,
        u.name AS driver_name,
        d.rating AS avg_rating,
        COUNT(*) AS total_trips,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) AS completed_trips,
        ROUND(COUNT(CASE WHEN t.status = 'completed' THEN 1 END) * 100.0 / COUNT(*), 2) AS completion_rate,
        ROUND(COUNT(CASE WHEN t.status = 'cancelled' THEN 1 END) * 100.0 / COUNT(*), 2) AS cancellation_rate,
        ROUND(SUM(CASE WHEN t.status = 'completed' THEN t.total_fare ELSE 0 END), 2) AS total_revenue,
        ROUND(
            SUM(CASE WHEN t.status = 'completed' THEN t.total_fare ELSE 0 END) * 1.0
            / NULLIF(COUNT(CASE WHEN t.status = 'completed' THEN 1 END), 0),
        2) AS revenue_per_trip
    FROM drivers d
    JOIN users u ON u.user_id = d.user_id
    JOIN trips t ON d.driver_id = t.driver_id
    GROUP BY d.driver_id, u.name, d.rating
    HAVING COUNT(*) > 10
),
ranked_metrics AS (
    SELECT *,
        ROUND(PERCENT_RANK() OVER (ORDER BY revenue_per_trip) * 100, 2) AS revenue_percentile
    FROM driver_stats
),
final AS (
    SELECT *,
        ROUND(
            (completion_rate * 0.35) +
            (revenue_percentile * 0.35) +
            (avg_rating * 20 * 0.20) +
            (-1 * cancellation_rate * 0.10),
        2) AS performance_score
    FROM ranked_metrics
)

SELECT *,
    ROW_NUMBER() OVER (ORDER BY performance_score DESC) AS performance_rank,
    CASE
        WHEN performance_score >= 75 THEN 'Top performer'
        WHEN performance_score >= 60 THEN 'Average'
        WHEN performance_score >= 50 THEN 'Under Performer'
        ELSE 'Needs Improvement'
    END AS performance_segment
FROM final
ORDER BY performance_rank;
