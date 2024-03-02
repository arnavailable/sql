use agarg;

CREATE TABLE scooter (
    scooter_id SMALLINT,
    status ENUM('online', 'offline', 'lost/stolen') NOT NULL DEFAULT 'offline',
    PRIMARY KEY (scooter_id)
);

CREATE TABLE customer (
    user_id MEDIUMINT,
    ccnum CHAR(16),
    expdate CHAR(5),
    email VARCHAR(100) NOT NULL,
    PRIMARY KEY (user_id)
);

CREATE TABLE trip (
    trip_id INT,
    scooter_id SMALLINT NOT NULL,
    user_id MEDIUMINT NOT NULL,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    pickup_long CHAR(10),
    pickup_lat CHAR(10),
    dropoff_long CHAR(10),
    dropoff_lat CHAR(10),
    PRIMARY KEY (trip_id),
    FOREIGN KEY (scooter_id) REFERENCES scooter(scooter_id),
    FOREIGN KEY (user_id) REFERENCES customder(user_id)
);

ALTER TABLE customer
    ADD UNIQUE(email);

drop table trip;

CREATE TABLE trip (
    trip_id BIGINT,
    scooter_id SMALLINT NOT NULL,
    user_id MEDIUMINT NOT NULL,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    pickup POINT,
    dropoff POINT,
    PRIMARY KEY (trip_id),
    FOREIGN KEY (scooter_id) REFERENCES scooter(scooter_id),
    FOREIGN KEY (user_id) REFERENCES customer(user_id)
);