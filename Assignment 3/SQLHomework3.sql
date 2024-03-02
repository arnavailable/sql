-- Part 2
SELECT *
FROM hw3_airbnb
LIMIT 10;

SELECT listing_url,
       name
FROM hw3_airbnb
WHERE address -> '$.market' = "Oahu"
  AND "Wifi" MEMBER OF(amenities)
  AND property_type IN ('Apartment', 'House', 'Condominium')
  AND bed_type = 'Real Bed'
  AND minimum_nights <= 7
  AND maximum_nights >= 7
  AND LOWER(summary) LIKE '%ocean view%';
-- Returned 19 rows

-- Part 1
SELECT *
FROM hw3_heartrate
LIMIT 10;

SELECT *
FROM hw3_step
LIMIT 5;

-- Part 1(a)
SELECT p.user_id, p.tstamp
FROM (SELECT t.user_id,
             t.tstamp,
             ROW_NUMBER() OVER (PARTITION BY t.user_id, DAY(t.tstamp) ORDER BY t.tstamp ASC) AS num
      FROM (SELECT user_id,
                   tstamp,
                   SUM(steps) OVER (PARTITION BY user_id, DAY(tstamp) ORDER BY tstamp ASC) AS sum
            FROM hw3_step) AS t
      WHERE t.sum >= 10000) AS p
WHERE p.num = 1
ORDER BY p.user_id, p.tstamp;

SELECT DISTINCT NTH_VALUE(t.user_id, 1) OVER (PARTITION BY t.user_id, DAY(t.tstamp) ORDER BY t.tstamp ASC) AS user_id,
                NTH_VALUE(t.tstamp, 1) OVER (PARTITION BY t.user_id, DAY(t.tstamp) ORDER BY t.tstamp ASC)  AS tstamp
FROM (SELECT user_id,
             tstamp,
             SUM(steps) OVER (PARTITION BY user_id, DAY(tstamp) ORDER BY tstamp ASC) AS sum
      FROM hw3_step) AS t
WHERE t.sum >= 10000;

-- Part 1(b)
SELECT user_id,
       tstamp,
       heartrate,
       ROUND((AVG(heartrate)
                  OVER ( PARTITION BY user_id
                         ORDER BY seq
                         ROWS BETWEEN 4 PRECEDING AND 4 FOLLOWING )), 1)
                  AS avg
FROM
    hw3_heartrate;


-- Part 1(c)
SELECT DISTINCT
    HOUR(tstamp) AS hour,
    AVG(steps) AS avg
FROM
    hw3_step
WHERE
    DATE(tstamp) = '2016-04-16'
GROUP BY
    HOUR(tstamp)
ORDER BY
    hour;

SELECT
user_id,
tstamp,
AVG(heartrate) OVER (PARTITION BY user_id ORDER BY tstamp ROWS BETWEEN 4 PRECEDING AND 4 FOLLOWING) AS smoothed_reading,
heartrate AS cur_rate
FROM hw3_heartrate
HAVING AVG(heartrate) > 120;

SELECT
    user_id,
    date,
    MIN(tstamp) AS tstamp
FROM
    (SELECT
        user_id,
        tstamp,
        DATE(tstamp) AS date,
        SUM(steps) OVER (PARTITION BY user_id, DATE(tstamp)
                         ORDER BY tstamp)
            AS steps
     FROM
         hw3_step
    ) t
WHERE
    t.steps > 10000
GROUP BY
    user_id,
    date;

SELECT DISTINCT
    HOUR(tstamp) AS hour,
    AVG(steps) AS avg
FROM
    hw3_step
WHERE
    DATE(tstamp) = '2016-04-16'
GROUP BY
    HOUR(tstamp)
ORDER BY
    hour;

SELECT user_id,
       tstamp,
       heartrate,
       ROUND((AVG(heartrate)
                  OVER ( PARTITION BY user_id
                         ORDER BY seq
                         ROWS BETWEEN 4 PRECEDING AND 4 FOLLOWING )), 1)
                  AS avg
FROM
    hw3_heartrate;
