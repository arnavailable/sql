use mgmtmsa402;

SELECT *
FROM lax_pax
LIMIT 2;

SELECT
    MIN(report_month) AS earliest_record,
    MAX(report_month) AS latest_record
FROM
    lax_pax;
-- earliest_record is 2006-01-01
-- latest_record is 2023-08-01


SELECT
    terminal,
    movement,
    flight,
    COUNT(report_month) AS num_rows
FROM
    lax_pax
GROUP BY
    terminal,
    movement,
    flight;


SELECT
    terminal,
    movement,
    SUM(throughput) AS total_pax
FROM
    lax_pax
GROUP BY
    terminal,
    movement;


SELECT
    terminal,
    SUM(throughput) AS total_pax
FROM
    lax_pax
GROUP BY
    terminal;


SELECT
    terminal,
    SUM(throughput) AS total_pax
FROM
    lax_pax
GROUP BY
    terminal
ORDER BY
    total_pax DESC
LIMIT
    1;


SELECT
    terminal,
    YEAR(report_month) AS YEAR,
    SUM(throughput)/12 AS average
FROM
    lax_pax
WHERE
    movement = "Departure"
GROUP BY
    terminal,
    YEAR(report_month)
HAVING
    SUM(throughput) > 1000000;

SELECT
    terminal,
    YEAR(report_month) AS YEAR,
    SUM(throughput)/12 AS average
FROM lax_pax
WHERE
    movement = "Arrival"
    AND terminal = "TBIT"
    AND ((report_month >= "2016-01-01"
            AND report_month <= "2020-02-01")
        OR report_month >= "2021-10-01")
GROUP BY terminal,
         YEAR(report_month);

SELECT
    terminal,
    YEAR(report_month) AS YEAR,
    AVG(throughput) AS average
FROM
    lax_pax
WHERE
    movement = "Departure"
GROUP BY
    terminal,
    YEAR(report_month)
HAVING
    SUM(throughput) > 1000000;

select * from lax_pax limit 10;

SELECT
    terminal,
    YEAR(report_month) AS YEAR,
    SUM(throughput)/12 AS average
FROM lax_pax
WHERE
    movement = "Arrival"
    AND terminal = "TBIT"
    AND ((report_month >= "2016-01-01"
            AND report_month < "2020-01-01")
        OR report_month >= "2022-01-01")
GROUP BY terminal,
         YEAR(report_month);

