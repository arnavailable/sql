use mgmtmsa402;

SHOW CREATE TABLE sw_flight;
SHOW CREATE TABLE sf_trip_end;
SHOW CREATE TABLE sf_user;

select count(distinct date, tail) from sw_flight;
select avg(d.count) from(select count(*) as count from sw_flight group by tail, date) as d;

-- Part 1 (a)

SELECT
    start.id AS trip_id,
    CEIL(TIMESTAMPDIFF(SECOND, start.date, end.date)/60) AS trip_length
FROM
    sf_trip_start AS start
LEFT OUTER JOIN
    sf_trip_end AS end
    ON
        start.id = end.id
ORDER BY
    trip_id ASC;

-- Part 1 (b)

SELECT
    COUNT(*) AS stolen_bikes
FROM
    sf_trip_start AS start
LEFT OUTER JOIN
    sf_trip_end AS end
    ON
        start.id = end.id
WHERE
    end.date IS NULL;

-- Part 1 (c)

SELECT
    start.id AS trip_id,
    CASE
        WHEN
            CEIL(TIMESTAMPDIFF(SECOND, start.date, end.date)/60) IS NOT NULL
        THEN
            3.49 + 0.30*CEIL(TIMESTAMPDIFF(SECOND, start.date, end.date)/60)
        ELSE
            1000
    END
        AS trip_charge
FROM
    sf_trip_start AS start
LEFT OUTER JOIN
    sf_trip_end AS end
    ON
        start.id = end.id
ORDER BY
    trip_id ASC;

-- Part 1 (d)

SELECT
    start.id AS trip_id,
    CASE
        WHEN
            CEIL(TIMESTAMPDIFF(SECOND, start.date, end.date)/60) IS NULL
        THEN
            1000
        ELSE
            CASE
                WHEN
                    customer.user_type = 'Subscriber'
                THEN
                    0.20 * CEIL(TIMESTAMPDIFF(SECOND, start.date, end.date)/60)
                ELSE
                    3.49 + 0.30 * CEIL(TIMESTAMPDIFF(SECOND, start.date, end.date)/60)
                END
    END
        AS trip_charge
FROM
    sf_trip_start AS start
LEFT OUTER JOIN
    sf_trip_end AS end
    ON
        start.id = end.id
LEFT OUTER JOIN
    sf_user AS customer
    ON
        customer.trip_id = start.id
ORDER BY
    trip_id ASC;

-- Part 1 (e)

-- One major advantage of using a subquery is that it eliminates redundant code and makes it easier to read.

-- Part 1 (f)

-- If we put the condition as part of the ON (JOIN) criteria, we receive all NULL values which are then interpreted as LOST/STOLEN cases and charges all users $1000. However, if we put the condition as part of the WHERE condition, we receive a legitimate table which correctly computes the cost for trips that started in March 2018. This scenario doesn't charge all users errorneously.

-- ON condition
SELECT
    start.id AS trip_id,
    CASE
        WHEN
            CEIL(TIMESTAMPDIFF(SECOND, start.date, end.date)/60) IS NOT NULL
        THEN
            3.49 + 0.30 * CEIL(TIMESTAMPDIFF(SECOND, start.date, end.date)/60)
        ELSE
            1000
    END
        AS trip_charge
FROM
    sf_trip_start AS start
LEFT OUTER JOIN
    sf_trip_end AS end
    ON
        start.id = end.id
    AND
        MONTH(start.date) = 3
    AND
        YEAR(start.date) = 2018
ORDER BY
    trip_id ASC;

-- WHERE condition
SELECT
    start.id AS trip_id,
    CASE
        WHEN
            CEIL(TIMESTAMPDIFF(SECOND, start.date, end.date)/60) IS NOT NULL
        THEN
            3.49 + 0.30 * CEIL(TIMESTAMPDIFF(SECOND, start.date, end.date)/60)
        ELSE
            1000
    END
        AS trip_charge
FROM
    sf_trip_start AS start
LEFT OUTER JOIN
    sf_trip_end AS end
    ON
        start.id = end.id
WHERE
    MONTH(start.date) = 3
    AND
    YEAR(start.date) = 2018
ORDER BY
    trip_id ASC;

-- Part 2 (a)

SELECT
    COUNT(DISTINCT flight.origin, flight.dest) AS count
FROM
    sw_flight AS flight
INNER JOIN
    sw_aircraft AS aircraft
    ON
    flight.tail = aircraft.tail
GROUP BY
    aircraft.type
WHERE
    aircraft.type IN ('B737', 'B738');

-- Part 2 (b)

SELECT
    sw_aircraft.type AS type,
    CAST(100 * COUNT(DISTINCT sw_flight.origin, sw_flight.dest)/
        (SELECT
            COUNT(DISTINCT origin, dest)
        FROM
            sw_flight)
        AS DECIMAL(4, 2))
        AS percentage
FROM
    sw_flight
LEFT OUTER JOIN
    sw_aircraft
    ON
    sw_flight.tail = sw_aircraft.tail
GROUP BY
    sw_aircraft.type
ORDER BY
    percentage DESC;

-- Part 2 (d, e)

-- (i) NOT IN
SELECT DISTINCT
    flight_num,
    tail
FROM
    sw_flight
WHERE
    tail NOT IN
        (SELECT
            tail
        FROM
            sw_airtran_aircraft)
ORDER BY
    flight_num ASC;

-- (ii) JOIN
SELECT DISTINCT
    flight_num
FROM
    sw_flight AS flight
LEFT OUTER JOIN
        sw_airtran_aircraft AS airtran
        ON
        airtran.tail = flight.tail
WHERE
    airtran.type IS NULL
ORDER BY
    flight_num ASC;

-- (iii) EXISTS
SELECT DISTINCT
    flight_num
FROM
    sw_flight AS flight
WHERE NOT EXISTS (
    SELECT
        1
    FROM
        sw_airtran_aircraft AS airtran
    WHERE
        flight.tail = airtran.tail)
ORDER BY
    flight_num ASC;

-- Part 2 (f)
    L.origin as origin,
    R.origin AS layover,
    R.dest AS final_dest,
    L.flight_num AS first_flight,
    R.flight_num AS second_flight,
    L.departure AS departure_from_lax,
    R.arrival AS arrival_in_sea

SELECT
    L.origin as origin,
    R.origin AS layover,
    R.dest AS final_dest,
    L.flight_num AS first_flight,
    R.flight_num AS second_flight,
    L.departure AS departure_from_lax,
    R.arrival AS arrival_in_sea
FROM
    sw_flight AS L
LEFT OUTER JOIN
    sw_flight AS R
    ON
    L.dest = R.origin
WHERE
    L.origin = 'LAX'
    AND R.dest = 'SEA'
    AND TIMESTAMPDIFF(MINUTE, CAST(CONCAT(L.date, ' ', L.arrival) AS DATETIME), CAST(CONCAT(R.date, ' ', R.departure) AS DATETIME)) BETWEEN 60 AND 180
    AND L.date = '2023-10-18'
ORDER BY
    L.departure ASC;

-- Part 2 (g)

WITH RECURSIVE inspection (num, origin, dest, date, departure, arrival, tail) AS
    (
    SELECT
        t.num,
        t.origin,
        t.dest,
        t.date,
        t.departure,
        t.arrival,
        t.tail
    FROM
        (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY date, tail ORDER BY departure) AS num,
            origin,
            dest,
            date,
            departure,
            arrival,
            tail
        FROM
            sw_flight
        ) AS t
    WHERE
        t.num = 1
    UNION ALL
    SELECT
        num + 1 AS num,
        R.origin,
        R.dest,
        L.date,
        R.departure,
        R.arrival,
        L.tail
    FROM
        inspection AS L
    INNER JOIN
        sw_flight AS R
    ON
        L.tail = R.tail
        AND L.dest = R.origin
        AND L.date = R.date
    WHERE
        num < 4
        AND L.arrival < R.departure
    )
SELECT COUNT(*) FROM inspection WHERE num = 4 ORDER BY tail, date;


SELECT
        t.num,
        t.origin,
        t.dest,
        t.date,
        t.departure,
        t.arrival,
        t.tail
    FROM
        (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY date, tail ORDER BY departure) AS num,
            origin,
            dest,
            date,
            departure,
            arrival,
            tail
        FROM
            sw_flight
        ORDER BY
            arrival ASC
        ) AS t
    WHERE
        t.num = 4
        AND t.num IS NOT NULL;
