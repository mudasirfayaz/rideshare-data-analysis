-- Payment Methods:
SELECT
	payment_method,
    COUNT(total_fare) AS total_transactions,
    ROUND(SUM(total_fare), 2) AS total_revenue,
    ROUND(AVG(total_fare), 2) AS avg_fare,
    ROUND(COUNT(total_fare) / 
    (	
		SELECT COUNT(total_fare) 
		FROM trips 
        WHERE status = "completed" 
	) * 100, 2) AS pct_of_transactions
FROM trips
WHERE status = "completed"
GROUP BY payment_method
ORDER BY total_transactions DESC;

--  Failure Trend:
SELECT 
	DATE_FORMAT(paid_at, "%Y-%m") AS month,
    COUNT(CASE WHEN status = "success" THEN 1 END) AS successful,
    COUNT(CASE WHEN status = "failed" THEN 1 END) AS failed,
    COUNT(CASE WHEN status = "refunded" THEN 1 END) AS refunded,
    COUNT(status) AS total,
    ROUND(COUNT(CASE WHEN status = "failed" THEN 1 END) / COUNT(status) * 100, 2) AS failure_rate
FROM payments
GROUP BY month
ORDER BY failure_rate;

    