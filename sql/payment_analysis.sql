-- Q5. Are payments completing successfully, and which methods dominate?

USE rideshare;

SELECT 
    t.payment_method,
    COUNT(*) AS total_transactions,
    ROUND(SUM(CASE WHEN t.status = 'completed' THEN t.total_fare ELSE 0 END), 2) AS total_revenue,
    COUNT(CASE WHEN p.status = 'success' THEN 1 END) AS successful,
    COUNT(CASE WHEN p.status = 'failed' THEN 1 END) AS failed,
    COUNT(CASE WHEN p.status = 'refunded' THEN 1 END) AS refunded,

    ROUND(COUNT(CASE WHEN p.status = 'success' THEN 1 END) * 100.0 / COUNT(*), 2) AS success_rate,
    ROUND(COUNT(CASE WHEN p.status = 'failed' THEN 1 END) * 100.0 / COUNT(*), 2) AS failure_rate,
    ROUND(COUNT(CASE WHEN p.status = 'refunded' THEN 1 END) * 100.0 / COUNT(*), 2) AS refunded_rate

FROM trips t
JOIN payments p ON t.trip_id = p.trip_id
GROUP BY t.payment_method
ORDER BY total_transactions DESC;