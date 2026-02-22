-- ===============================
-- SCHEMA CREATION
-- ===============================

DROP SCHEMA IF EXISTS itunes CASCADE;
CREATE SCHEMA itunes;
SET search_path TO itunes;

CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    name TEXT
);
CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title TEXT,
    artist_id INT
);
CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    name TEXT
);
CREATE TABLE media_type (
    media_type_id INT PRIMARY KEY,
    name TEXT
);
CREATE TABLE track (
    track_id INT PRIMARY KEY,
    name TEXT,
    album_id INT,
    media_type_id INT,
    genre_id INT,
    composer TEXT,
    milliseconds INT,
    bytes INT,
    unit_price NUMERIC(10,2)
);
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name TEXT,
    first_name TEXT,
    title TEXT,
    reports_to INT,
    birthdate TIMESTAMP,
    hire_date TIMESTAMP,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    postal_code TEXT,
    phone TEXT,
    fax TEXT,
    email TEXT
);
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    company TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    postal_code TEXT,
    phone TEXT,
    fax TEXT,
    email TEXT,
    support_rep_id INT
);
CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    invoice_date TIMESTAMP,
    billing_address TEXT,
    billing_city TEXT,
    billing_state TEXT,
    billing_country TEXT,
    billing_postal_code TEXT,
    total NUMERIC(10,2)
);
CREATE TABLE invoice_line (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT,
    track_id INT,
    unit_price NUMERIC(10,2),
    quantity INT
);
CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name TEXT
);
CREATE TABLE playlist_track (
    playlist_id INT,
    track_id INT
);


ALTER TABLE album
ADD FOREIGN KEY (artist_id) REFERENCES artist(artist_id);

ALTER TABLE track
ADD FOREIGN KEY (album_id) REFERENCES album(album_id),
ADD FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id),
ADD FOREIGN KEY (genre_id) REFERENCES genre(genre_id);

ALTER TABLE customer
ADD FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id);

ALTER TABLE invoice
ADD FOREIGN KEY (customer_id) REFERENCES customer(customer_id);

ALTER TABLE invoice_line
ADD FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
ADD FOREIGN KEY (track_id) REFERENCES track(track_id);

ALTER TABLE playlist_track
ADD FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id),
ADD FOREIGN KEY (track_id) REFERENCES track(track_id);

SELECT COUNT(*) FROM track;
SELECT COUNT(*) FROM invoice;
SELECT COUNT(*) FROM customer;
-- ==========================================
-- ANALYSIS QUERIES
-- ==========================================

-- SECTION 1: Customer Analytics

-- Q1: Customers who spent the most money

SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC
LIMIT 10;
--Q2: Average Customer Lifetime Value

SELECT 
    ROUND(AVG(total_spent), 2) AS avg_customer_lifetime_value
FROM (
    SELECT 
        customer_id,
        SUM(total) AS total_spent
    FROM invoice
    GROUP BY customer_id
) t;
-- Q3: Repeat vs One-time purchasers

SELECT 
    CASE 
        WHEN purchase_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM (
    SELECT customer_id, COUNT(*) AS purchase_count
    FROM invoice
    GROUP BY customer_id
) t
GROUP BY customer_type;
-- Q4: Country generating highest revenue per customer

SELECT 
    c.country,
    ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue_per_customer DESC;

-- Q5: Customers inactive in last 6 months

SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    MAX(i.invoice_date) AS last_purchase_date
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
HAVING MAX(i.invoice_date) < (
    SELECT MAX(invoice_date) - INTERVAL '6 months' FROM invoice
);


-- SECTION 2: Sales & Revenue Analysis

--- Q6: Monthly revenue trends for the last 2 years
SELECT 
    DATE_TRUNC('month', invoice_date) AS month,
    ROUND(SUM(total), 2) AS monthly_revenue
FROM invoice
GROUP BY month
ORDER BY month;

-- Q7: Average invoice value

SELECT 
    ROUND(AVG(total), 2) AS avg_invoice_value
FROM invoice;

-- Q8: Revenue contribution by employee

SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    ROUND(SUM(i.total), 2) AS total_revenue
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.employee_id, employee_name
ORDER BY total_revenue DESC;

-- Q9: Months with highest sales

SELECT 
    TO_CHAR(invoice_date, 'Month') AS month_name,
    ROUND(SUM(total), 2) AS revenue
FROM invoice
GROUP BY month_name
ORDER BY revenue DESC;


-- SECTION 3: Product & CONTENT Analysis

-- Q10: Tracks generating most revenue

SELECT 
    t.name AS track_name,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
GROUP BY track_name
ORDER BY revenue DESC
LIMIT 10;

-- Q11: Most purchased albums

SELECT 
    a.title AS album_name,
    COUNT(il.track_id) AS purchase_count
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
GROUP BY album_name
ORDER BY purchase_count DESC
LIMIT 10;

-- Q12: Tracks never purchased

SELECT 
    t.track_id,
    t.name
FROM track t
LEFT JOIN invoice_line il ON t.track_id = il.track_id
WHERE il.track_id IS NULL;

-- Q13: Average track price by genre

SELECT 
    g.name AS genre,
    ROUND(AVG(t.unit_price), 2) AS avg_price
FROM track t
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY genre
ORDER BY avg_price DESC;

-- Q14: Tracks per genre vs sales correlation

SELECT 
    g.name AS genre,
    COUNT(DISTINCT t.track_id) AS total_tracks,
    SUM(il.quantity) AS total_tracks_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue
FROM genre g
LEFT JOIN track t ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY genre
ORDER BY total_revenue DESC;

-- SECTION 4 — ARTIST & GENRE PERFORMANCE

-- Q15: Top 5 artists by revenue

SELECT 
    ar.name AS artist_name,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
GROUP BY artist_name
ORDER BY revenue DESC
LIMIT 5;

-- Q16: Genre popularity by tracks sold

SELECT 
    g.name AS genre,
    SUM(il.quantity) AS tracks_sold
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY genre
ORDER BY tracks_sold DESC;

-- Q17: Genres popular in specific countries

SELECT 
    i.billing_country,
    g.name AS genre,
    SUM(il.quantity) AS tracks_sold
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY i.billing_country, genre
ORDER BY billing_country, tracks_sold DESC;

--SECTION 5- Employee & Operational Efficiency

--Q18: Employees handling high-value customers

SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    ROUND(SUM(i.total), 2) AS total_customer_revenue
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.employee_id, employee_name
ORDER BY total_customer_revenue DESC;

--Q19: Avg customers handled per employee

SELECT 
    ROUND(AVG(customer_count), 2) AS avg_customers_per_employee
FROM (
    SELECT 
        support_rep_id,
        COUNT(*) AS customer_count
    FROM customer
    GROUP BY support_rep_id
) t;

--Q20:  Revenue by employee region

SELECT 
    e.country AS employee_country,
    ROUND(SUM(i.total), 2) AS revenue
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY employee_country
ORDER BY revenue DESC;

-- SECTION 6 — GEOGRAPHIC ANALYSIS

-- Q21: Countries with highest customers

SELECT 
    country,
    COUNT(*) AS total_customers
FROM customer
GROUP BY country
ORDER BY total_customers DESC;

-- Q22: Cities with highest customers

SELECT 
    city,
    COUNT(*) AS total_customers
FROM customer
GROUP BY city
ORDER BY total_customers DESC;

-- Q22: Revenue by country

SELECT 
    billing_country,
    billing_city,
    ROUND(SUM(total), 2) AS revenue
FROM invoice
GROUP BY billing_country, billing_city
ORDER BY revenue DESC;

--Q23: Underserved Regions(High customers but low revenue regions)

WITH customer_counts AS (
    SELECT country, COUNT(*) AS total_customers
    FROM customer
    GROUP BY country
),
revenue_data AS (
    SELECT billing_country AS country, SUM(total) AS total_revenue
    FROM invoice
    GROUP BY billing_country
)

SELECT 
    c.country,
    c.total_customers,
    COALESCE(r.total_revenue, 0) AS total_revenue
FROM customer_counts c
LEFT JOIN revenue_data r ON c.country = r.country
ORDER BY c.total_customers DESC, total_revenue ASC;

-- SECTION 7 — CUSTOMER RETENTION AND PURCHASE PATTERNS

-- Q24: Purchase frequency distribution

SELECT 
    purchase_count,
    COUNT(*) AS customer_count
FROM (
    SELECT customer_id, COUNT(*) AS purchase_count
    FROM invoice
    GROUP BY customer_id
) t
GROUP BY purchase_count
ORDER BY purchase_count;

-- Q25: Average time between purchases

SELECT 
    ROUND(AVG(days_between), 2) AS avg_days_between_purchases
FROM (
    SELECT 
        customer_id,
        EXTRACT(DAY FROM invoice_date - LAG(invoice_date) 
        OVER (PARTITION BY customer_id ORDER BY invoice_date)) AS days_between
    FROM invoice
) t
WHERE days_between IS NOT NULL;

-- Q26: Customers purchasing multiple genres

SELECT 
    COUNT(*) AS multi_genre_customers
FROM (
    SELECT 
        c.customer_id,
        COUNT(DISTINCT g.genre_id) AS genre_count
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY c.customer_id
    HAVING COUNT(DISTINCT g.genre_id) > 1
) t;

-- SECTION 8. Operational Optimization

--Q27: Most common track pairs purchased together

SELECT 
    il1.track_id AS track_1,
    il2.track_id AS track_2,
    COUNT(*) AS times_bought_together
FROM invoice_line il1
JOIN invoice_line il2 
    ON il1.invoice_id = il2.invoice_id
    AND il1.track_id < il2.track_id
GROUP BY track_1, track_2
ORDER BY times_bought_together DESC
LIMIT 10;

--Q28. Price vs sales relationship

SELECT 
    t.unit_price,
    SUM(il.quantity) AS total_sold
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.unit_price
ORDER BY t.unit_price;

-- Q29: Media type popularity((Growth/Decline))

SELECT 
    mt.name AS media_type,
    COUNT(il.track_id) AS total_sales
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN media_type mt ON t.media_type_id = mt.media_type_id
GROUP BY media_type
ORDER BY total_sales DESC;
