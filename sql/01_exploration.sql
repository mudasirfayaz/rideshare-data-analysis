USE rideshare;

SELECT * FROM trips LIMIT 5;

-- 1. How many trips exist per status, and what % of total does each represent?
SELECT 
    status, 
    COUNT(trip_id) as total_trips,
    COUNT(trip_id) * 100.0 / (SELECT COUNT(*) FROM trips) AS percentage
FROM trips 
GROUP BY status;

-- 2. What is the date range of the data, and how many distinct months does it cover?
SELECT 
    DISTINCT DATE_FORMAT(requested_at, "%Y-%m") AS months
FROM trips
ORDER BY months;

-- 3. What is the average, min, and max total_fare for completed trips?
SELECT 
    ROUND(AVG(total_fare), 2) AS avg_fare, 
    MIN(total_fare) AS min_fare, 
    MAX(total_fare) AS max_fare
FROM trips
WHERE status = 'completed'