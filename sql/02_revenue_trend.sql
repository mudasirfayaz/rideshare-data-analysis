-- Q1. How is monthly revenue trending, and how volatile is it?

WITH t1 AS (
		SELECT 
			DATE_FORMAT(requested_at, "%Y-%m") AS month,
			ROUND(SUM(total_fare), 1) AS total_revenue
		FROM trips
		WHERE status = "completed"
		GROUP BY month
	),
     t2 AS (
        SELECT
            month,
            total_revenue,
            LAG(total_revenue) OVER(ORDER BY month) AS prev_month_revenue,
            ROUND(total_revenue - LAG(total_revenue) OVER(ORDER BY month)) AS mom_change
        FROM t1
     )
SELECT
    month,
    total_revenue,
    prev_month_revenue,
    mom_change,
    CASE
        WHEN mom_change > 0  THEN 'Growth'
        WHEN mom_change < 0  THEN 'Decline'
        WHEN mom_change = 0  THEN 'Flat'
        ELSE 'N/A'  -- first month has no previous
    END AS trend
FROM t2
ORDER BY month;