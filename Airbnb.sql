use AirbnbAnalysisDB

select * from airbnb_listings

--Check each column for values that CANNOT be safely converted to their intended data type.
SELECT price 
FROM airbnb_listings
WHERE TRY_CAST(price AS FLOAT) IS NULL AND price IS NOT NULL;

SELECT minimum_nights 
FROM airbnb_listings
WHERE TRY_CAST(minimum_nights AS INT) IS NULL AND minimum_nights IS NOT NULL;

SELECT number_of_reviews 
FROM airbnb_listings
WHERE TRY_CAST(number_of_reviews AS INT) IS NULL AND number_of_reviews IS NOT NULL;

SELECT reviews_per_month 
FROM airbnb_listings
WHERE TRY_CAST(reviews_per_month AS FLOAT) IS NULL AND reviews_per_month IS NOT NULL;

SELECT reviews_per_month 
FROM airbnb_listings
WHERE TRY_CAST(reviews_per_month AS FLOAT) IS NULL AND reviews_per_month IS NOT NULL;

-- REPLACE commas with periods to confirm the fix works
SELECT reviews_per_month,
       REPLACE(reviews_per_month, ',', '.') AS fixed_value,
       TRY_CAST(REPLACE(reviews_per_month, ',', '.') AS FLOAT) AS converted
FROM airbnb_listings
WHERE TRY_CAST(reviews_per_month AS FLOAT) IS NULL 
  AND reviews_per_month IS NOT NULL;

UPDATE airbnb_listings
SET reviews_per_month = REPLACE(reviews_per_month, ',', '.')
WHERE reviews_per_month IS NOT NULL;

-- Check 'minimum_nights'
SELECT minimum_nights FROM airbnb_listings
WHERE TRY_CAST(minimum_nights AS INT) IS NULL AND minimum_nights IS NOT NULL;

-- Check 'number_of_reviews'
SELECT number_of_reviews FROM airbnb_listings
WHERE TRY_CAST(number_of_reviews AS INT) IS NULL AND number_of_reviews IS NOT NULL;

-- Check 'calculated_host_listings_count'
SELECT calculated_host_listings_count FROM airbnb_listings
WHERE TRY_CAST(calculated_host_listings_count AS INT) IS NULL AND calculated_host_listings_count IS NOT NULL;

-- Check 'calculated_host_listings_count'
SELECT calculated_host_listings_count FROM airbnb_listings
WHERE TRY_CAST(calculated_host_listings_count AS INT) IS NULL AND calculated_host_listings_count IS NOT NULL;

-- Check 'availability_365'
SELECT availability_365 FROM airbnb_listings
WHERE TRY_CAST(availability_365 AS INT) IS NULL AND availability_365 IS NOT NULL;

-- Check 'days_since_last_review'
SELECT days_since_last_review FROM airbnb_listings
WHERE TRY_CAST(days_since_last_review AS INT) IS NULL AND days_since_last_review IS NOT NULL;

-- Check 'last_review'
SELECT last_review FROM airbnb_listings
WHERE TRY_CAST(last_review AS DATETIME2) IS NULL AND last_review IS NOT NULL;

-- Check latitude for values that fail to convert to FLOAT
SELECT latitude FROM airbnb_listings
WHERE TRY_CAST(latitude AS FLOAT) IS NULL AND latitude IS NOT NULL;

-- Check longitude for values that fail to convert to FLOAT
SELECT longitude FROM airbnb_listings
WHERE TRY_CAST(longitude AS FLOAT) IS NULL AND longitude IS NOT NULL;

-- Fix latitude: replace comma with period
UPDATE airbnb_listings
SET latitude = REPLACE(latitude, ',', '.')
WHERE latitude IS NOT NULL;

-- Fix longitude: replace comma with period
UPDATE airbnb_listings
SET longitude = REPLACE(longitude, ',', '.')
WHERE longitude IS NOT NULL;

-- Convert price from text to FLOAT (decimal number)
ALTER TABLE airbnb_listings 
ALTER COLUMN price FLOAT;

-- Convert minimum_nights from text to INT (whole number)
ALTER TABLE airbnb_listings 
ALTER COLUMN minimum_nights INT;

-- Convert number_of_reviews from text to INT
ALTER TABLE airbnb_listings 
ALTER COLUMN number_of_reviews INT;

-- Convert reviews_per_month from text to FLOAT
ALTER TABLE airbnb_listings 
ALTER COLUMN reviews_per_month FLOAT;

-- Convert calculated_host_listings_count from text to INT
ALTER TABLE airbnb_listings 
ALTER COLUMN calculated_host_listings_count INT;

-- Convert availability_365 from text to INT
ALTER TABLE airbnb_listings 
ALTER COLUMN availability_365 INT;

-- Convert days_since_last_review from text to INT
ALTER TABLE airbnb_listings 
ALTER COLUMN days_since_last_review INT;

-- Convert last_review from text to DATETIME2 (proper date/time type)
ALTER TABLE airbnb_listings 
ALTER COLUMN last_review DATETIME2;

ALTER TABLE airbnb_listings ALTER COLUMN latitude FLOAT;
ALTER TABLE airbnb_listings ALTER COLUMN longitude FLOAT;

-- Confirm the new data types took effect
EXEC sp_columns airbnb_listings;

SELECT * FROM airbnb_listings;

-- Average price per borough
SELECT
    neighbourhood_group,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS listing_count
FROM airbnb_listings
GROUP BY neighbourhood_group
ORDER BY avg_price DESC;

-- Median price per borough (SQL Server supports this via window function)
SELECT DISTINCT
    neighbourhood_group,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price)
        OVER (PARTITION BY neighbourhood_group) AS median_price
FROM airbnb_listings
ORDER BY median_price DESC;

-- 2. Room Type breakdown (count + avg price)
SELECT
    room_type,
    COUNT(*) AS listing_count,
    ROUND(AVG(price), 2) AS avg_price
FROM airbnb_listings
GROUP BY room_type
ORDER BY avg_price DESC;

-- 3. Top 10 Neighborhoods by listing count
SELECT TOP 10
    neighbourhood,
    neighbourhood_group,
    COUNT(*) AS listing_count
FROM airbnb_listings
GROUP BY neighbourhood, neighbourhood_group
ORDER BY listing_count DESC;

-- 4. Host concentration: % of listings from hosts who own multiple properties
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN calculated_host_listings_count > 1 THEN 1 ELSE 0 END) 
        / COUNT(*), 1
    ) AS pct_multi_listing_hosts
FROM airbnb_listings;

-- 5. Top 10 busiest hosts
SELECT TOP 10
    host_id,
    host_name,
    COUNT(*) AS num_listings,
    ROUND(AVG(price), 2) AS avg_price,
    SUM(number_of_reviews) AS total_reviews
FROM airbnb_listings
GROUP BY host_id, host_name
ORDER BY num_listings DESC;

-- 6. Price category mix by borough (%)
SELECT
    neighbourhood_group,
    price_per_night_category,
    COUNT(*) AS listing_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY neighbourhood_group), 1
    ) AS pct_of_borough
FROM airbnb_listings
GROUP BY neighbourhood_group, price_per_night_category
ORDER BY neighbourhood_group, pct_of_borough DESC;

-- 7. Review activity by borough
SELECT
    neighbourhood_group,
    SUM(number_of_reviews) AS total_reviews,
    ROUND(AVG(number_of_reviews), 2) AS avg_reviews_per_listing,
    ROUND(AVG(reviews_per_month), 2) AS avg_reviews_per_month
FROM airbnb_listings
GROUP BY neighbourhood_group
ORDER BY total_reviews DESC;

-- 8. Minimum nights outliers (data quality check)
SELECT
    id, name, neighbourhood_group, minimum_nights, price
FROM airbnb_listings
WHERE minimum_nights >= 30
ORDER BY minimum_nights DESC;



