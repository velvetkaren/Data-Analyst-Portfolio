-- Create Database (by Karen Ogiugo)
CREATE DATABASE tesco_ireland_retail;

USE tesco_ireland_retail;

-- Create Customers Table

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);
-- import customers

LOAD DATA LOCAL INFILE 
'/Users/karen/Documents/DATA analytics portfolio /tesco customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- view dataset 
SELECT * FROM customers;


-- Create Stores Table

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(50)
);

-- import stores 

LOAD DATA LOCAL INFILE '/Users/karen/Documents/DATA analytics portfolio /tesco stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- view dataset

SELECT * FROM stores;

-- Create Products Table

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);


-- import products

LOAD DATA LOCAL INFILE '/Users/karen/Documents/DATA analytics portfolio /tesco prodducts .csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- view dataset 

SELECT * FROM products;

-- Create Orders Table

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    store_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- import orders

LOAD DATA LOCAL INFILE '/Users/karen/Documents/DATA analytics portfolio /tesco orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- view dataset

SELECT * FROM orders;

-- Create Order Items Table. Each order contains multiple products.

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- import order_items

LOAD DATA LOCAL INFILE '/Users/karen/Documents/DATA analytics portfolio /tesco order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- view order_items

SELECT * FROM order_items;


-- Data Exploration

-- Count Rows

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM stores;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;

-- Check Order Date Range

SELECT
MIN(order_date) AS first_order,
MAX(order_date) AS last_order
FROM orders;


-- Core Retail Analysis

-- Total Revenue

SELECT 
ROUND(SUM(total_amount),2) AS total_revenue
FROM orders;

-- Total Customers

SELECT
COUNT(DISTINCT customer_id) AS total_customers
FROM orders;

-- Revenue by Store Location (JOIN)

SELECT
s.city,
ROUND(SUM(o.total_amount),2) AS total_revenue
FROM orders o
JOIN stores s
ON o.store_id = s.store_id
GROUP BY s.city
ORDER BY total_revenue DESC;


-- Revenue by Product Category. e.g., Groceries vs Household vs Beverages

SELECT
p.category,
ROUND(SUM(p.price * oi.quantity),2) AS total_revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- Top Customers 

SELECT
c.customer_name,
ROUND(SUM(o.total_amount),2) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_spent DESC
LIMIT 10;


-- Subqueries

-- Customers Spending Above Average

SELECT customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING SUM(total_amount) >
    (SELECT AVG(total_amount) FROM orders)
);

-- Products Never Purchased

SELECT product_name
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM order_items
);

-- Window Functions

-- Rank Top Customers
SELECT
customer_id,
SUM(total_amount) AS total_spent,
RANK() OVER (
ORDER BY SUM(total_amount) DESC
) AS customer_rank
FROM orders
GROUP BY customer_id;


-- Running Revenue Total

SELECT
order_date,
SUM(total_amount) AS daily_revenue,
SUM(SUM(total_amount)) OVER (
ORDER BY order_date
) AS cumulative_revenue
FROM orders
GROUP BY order_date;


-- Product Sales Ranking

SELECT
p.product_name,
SUM(oi.quantity) AS units_sold,
DENSE_RANK() OVER (
ORDER BY SUM(oi.quantity) DESC
) AS product_rank
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name;




