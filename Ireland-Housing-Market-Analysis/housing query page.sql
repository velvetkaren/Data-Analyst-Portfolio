-- Create a database:

CREATE DATABASE ireland_housing; 

-- Use it:

USE ireland_housing;

-- Create table:
-- drop table housing;

CREATE TABLE housing (
address VARCHAR(255),
price INT,
bedrooms INT,
bathrooms INT,
property_type VARCHAR(255),
area varchar(255),
county VARCHAR(100),
features varchar(10000),
date_of_construction YEAR
);

-- import CSV file 

-- 1. 

SET GLOBAL local_infile = 1;


-- 2. 

LOAD DATA LOCAL INFILE '/Users/karen/Documents/DATA analytics portfolio /daft_housing_data.csv' 
INTO TABLE housing
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- Check counties

SELECT DISTINCT county
FROM housing;


-- Check price range

SELECT 
MIN(price) AS lowest_price,
MAX(price) AS highest_price,
AVG(price) AS avg_price
FROM housing;


-- Price by Location

SELECT 
county,
AVG(price) AS avg_price
FROM housing
GROUP BY county
ORDER BY avg_price DESC;

-- number of properties per county:

SELECT 
county,
COUNT(*) AS number_of_properties
FROM housing
GROUP BY county
ORDER BY number_of_properties DESC;

-- Dublin Deep Dive

-- isolate it.

SELECT *
FROM housing
WHERE county = 'Dublin';

SELECT 
AVG(price) AS avg_dublin_price
FROM housing
WHERE county = 'Dublin';

-- Price vs No. of bedrooms

SELECT 
bedrooms,
AVG(price) AS avg_price
FROM housing
GROUP BY bedrooms
ORDER BY bedrooms;


-- Year-over-Year Housing Growth


SELECT 
YEAR(date_of_construction) AS year,
AVG(price) AS avg_price
FROM housing
GROUP BY year
ORDER BY year;


-- Find properties above average price.

SELECT *
FROM housing
WHERE price >
(
SELECT AVG(price)
FROM housing
);

