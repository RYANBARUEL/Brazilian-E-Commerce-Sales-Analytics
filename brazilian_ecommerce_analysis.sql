
CREATE DATABASE Brazilian_Ecommerce_DB;
GO

USE Brazilian_Ecommerce_DB
GO


ALTER TABLE orders_clean
ADD purchase_date_only DATE;


UPDATE orders_clean
SET purchase_date_only = CAST(purchase_date AS DATE);

SELECT * 
FROM customers_raw;


SELECT TOP 10 *
FROM customers_raw;

SELECT COUNT(*)
FROM customers_raw;


SELECT DISTINCT
customer_state
FROM customers_raw;


SELECT
SUM( CASE
	WHEN customer_city IS NULL
	THEN 1
	ELSE 0
	END)
AS null_city
FROM customers_raw;

--Checking Duplicates
SELECT
customer_id,
COUNT(*)
FROM customers_raw
GROUP BY customer_id
HAVING COUNT(*) >1; 


SELECT DISTINCT
customer_city
FROM customers_raw;


SELECT DISTINCT 
customer_id,
customer_unique_id,
CAST(customer_zip_code_prefix AS INT) AS zip_code_prefix,
UPPER(TRIM(customer_city)) AS customer_city,
UPPER(customer_state) AS customer_state
INTO customers_clean
FROM customers_raw;


SELECT TOP 10 *
FROM customers_clean;

--Compare rows
SELECT COUNT(*)
FROM customers_raw;

SELECT COUNT(*)
FROM customers_clean;


--Geolocation Table

SELECT TOP 10 *
FROM geolocation_raw;

SELECT COUNT(*)
FROM geolocation_raw;


SELECT
SUM(CASE WHEN geolocation_lat IS NULL THEN 1
	ELSE 0
	END) AS null_lat
FROM geolocation_raw;

SELECT
geolocation_zip_code_prefix,
COUNT(*) AS count_zip_code
FROM geolocation_raw
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;


SELECT 
CAST(geolocation_zip_code_prefix AS INT) AS zip_code_prefix,
AVG(TRY_CAST(geolocation_lat AS FLOAT)) AS latitude,
AVG(TRY_CAST(geolocation_lng AS FLOAT)) AS longitude,
UPPER(TRIM(geolocation_city)) AS city,
UPPER(geolocation_state) AS state
INTO geolocation_clean
FROM geolocation_raw
WHERE TRY_CAST(geolocation_lat AS FLOAT) IS NOT NULL
AND TRY_CAST(geolocation_lng AS FLOAT) IS NOT NULL
GROUP BY geolocation_zip_code_prefix,
	UPPER(TRIM(geolocation_city)),
	UPPER(geolocation_state);


-- Orders Table

SELECT TOP 10 *
FROM orders_raw;


SELECT COUNT(*)
FROM orders_raw;


SELECT
SUM(CASE
	WHEN order_delivered_customer_date IS NULL
	THEN 1
	ELSE 0
	END
)
AS null_delivery
FROM orders_raw;


SELECT DISTINCT
order_status
FROM orders_raw;


SELECT
order_status,
COUNT(*) AS total_orders
FROM orders_raw
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY total_orders DESC;

SELECT *
FROM orders_raw
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;

SELECT 
order_id,
customer_id,
UPPER(TRIM(order_status)) AS order_status,
TRY_CAST(order_purchase_timestamp AS DATETIME) AS purchase_date,
TRY_CAST(order_approved_at AS DATETIME) AS approved_date,
TRY_CAST(order_delivered_carrier_date AS DATETIME) AS carrier_date,
TRY_CAST(order_delivered_customer_date AS DATETIME) AS delivered_date,
TRY_CAST(order_estimated_delivery_date AS DATETIME) AS estimated_delivery_date
INTO orders_clean
FROM orders_raw;


SELECT TOP 10 *
FROM orders_clean;


SELECT COUNT(*)
FROM orders_clean;


-- Geolocation Lookup Table

SELECT
    zip_code_prefix,
    MIN(city) AS city,
    MIN(state) AS state,
    AVG(latitude) AS latitude,
    AVG(longitude) AS longitude
INTO geolocation_lookup
FROM geolocation_clean
GROUP BY zip_code_prefix;


SELECT
    zip_code_prefix,
    COUNT(*) AS duplicate_count
FROM geolocation_lookup
GROUP BY zip_code_prefix
HAVING COUNT(*) > 1;


-- Orders Item Table

SELECT TOP 10 *
FROM order_items_raw;


SELECT COUNT(*)
FROM order_items_raw;

SELECT
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS null_shipping_limit,
SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight
FROM order_items_raw;


SELECT
order_id,
order_item_id,
COUNT(*) AS duplicate_count
FROM order_items_raw
GROUP BY
order_id,
order_item_id
HAVING COUNT(*) > 1;


SELECT *
FROM order_items_raw
WHERE TRY_CAST(price AS DECIMAL(10,2)) <= 0;

SELECT *
FROM order_items_raw
WHERE TRY_CAST(price AS DECIMAL(10,2)) IS NULL;

SELECT *
FROM order_items_raw
WHERE TRY_CAST(freight_value AS DECIMAL(10,2)) < 0;


SELECT *
FROM order_items_raw
WHERE TRY_CAST(shipping_limit_date AS DATETIME) IS NULL;


SELECT *
FROM order_items_raw
WHERE TRY_CAST(freight_value AS DECIMAL(10,2)) IS NULL;


SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM order_items_raw;


SELECT
    order_id,
    CAST(order_item_id AS INT) AS order_item_id,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS DATETIME) AS shipping_limit_date,
    CAST(price AS DECIMAL(10,2)) AS price,
    CAST(freight_value AS DECIMAL(10,2)) AS freight_value
INTO order_items_clean
FROM order_items_raw;


SELECT COUNT(*) AS raw_count
FROM order_items_raw;

SELECT COUNT(*) AS clean_count
FROM order_items_clean;


--Product Table

SELECT TOP 10 *
FROM products_raw;

SELECT COUNT(*)
FROM products_raw;


SELECT
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN product_name_length IS NULL THEN 1 ELSE 0 END) AS null_name_length,
    SUM(CASE WHEN product_description_length IS NULL THEN 1 ELSE 0 END) AS null_description_length,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS null_photos_qty,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_weight,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_length,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS null_height,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS null_width
FROM products_raw;


SELECT
	product_id,
	COUNT(*) AS duplicate_count
FROM products_raw
GROUP BY product_id
HAVING COUNT(*) > 1;


SELECT DISTINCT product_category_name
FROM products_raw
ORDER BY product_category_name;


SELECT TOP 20 *
FROM products_raw
WHERE product_category_name IS NULL;


SELECT *
FROM products_raw
WHERE product_weight_g <= 0
   OR product_length_cm <= 0
   OR product_height_cm <= 0
   OR product_width_cm <= 0;


SELECT
    product_id,
    ISNULL(product_category_name, 'UNKNOWN') AS product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
INTO products_clean
FROM products_raw;


SELECT COUNT(*) AS raw_count
FROM products_raw;


SELECT COUNT(*) AS clean_count
FROM products_clean;


-- Order_Payment_Table

SELECT TOP 10 *
FROM order_payments_raw;

SELECT COUNT(*)
FROM order_payments_raw;


SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS null_payment_sequence,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS null_installment,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_value
FROM order_payments_raw;


SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM order_payments_raw
GROUP BY
    order_id,
    payment_sequential
HAVING COUNT(*) > 1;


SELECT DISTINCT payment_type
FROM order_payments_raw
ORDER BY payment_type;


SELECT *
FROM order_payments_raw
WHERE TRY_CAST(payment_value AS DECIMAL(10,2)) <= 0;


SELECT *
FROM order_payments_raw
WHERE payment_installments <= 0;


SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    CAST(payment_value AS DECIMAL(10,2)) AS payment_value
INTO order_payments_clean
FROM order_payments_raw;


SELECT COUNT(*) AS raw_count
FROM order_payments_raw;


SELECT COUNT(*) AS clean_count
FROM order_payments_clean;


--Seller_Table

SELECT TOP 10 *
FROM sellers_raw;

SELECT COUNT(*)
FROM sellers_raw;


SELECT
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip_code_prefix,
    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM sellers_raw;


SELECT
    seller_id,
    COUNT(*) AS duplicate_count
FROM sellers_raw
GROUP BY seller_id
HAVING COUNT(*) > 1;


SELECT *
FROM sellers_raw
WHERE seller_zip_code_prefix IS NULL;


SELECT DISTINCT seller_state
FROM sellers_raw
ORDER BY seller_state;


SELECT DISTINCT seller_city
FROM sellers_raw
ORDER BY seller_city;


SELECT *
FROM sellers_raw
WHERE seller_city = '04482255';


SELECT
    seller_id,
    seller_zip_code_prefix,
    CASE
        WHEN seller_city = '04482255' THEN 'UNKNOWN'
        ELSE seller_city
    END AS seller_city,
    seller_state
INTO sellers_clean
FROM sellers_raw;


SELECT COUNT(*) AS raw_count
FROM sellers_raw;


SELECT COUNT(*) AS clean_count
FROM sellers_clean;


---order_reviews_table

SELECT TOP 10 *
FROM order_reviews_raw;

SELECT COUNT(*)
FROM order_reviews_raw;


SELECT
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS null_review_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_score,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS null_comment_title,
	SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS null_comment_message,
	SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS null_creation_date,
	SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS null_aswer_timestamp
FROM order_reviews_raw;


SELECT
    review_id,
    order_id,
    COUNT(*) AS duplicate_count
FROM order_reviews_raw
GROUP BY
    review_id,
    order_id
HAVING COUNT(*) > 1;


SELECT DISTINCT review_score
FROM order_reviews_raw
ORDER BY review_score;


SELECT *
FROM order_reviews_raw
WHERE review_score NOT BETWEEN 1 AND 5;


SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    CAST(review_creation_date AS DATETIME) AS review_creation_date,
    CAST(review_answer_timestamp AS DATETIME) AS review_answer_timestamp
INTO order_reviews_clean
FROM order_reviews_raw;


SELECT COUNT(*) AS raw_count
FROM order_reviews_raw;


SELECT COUNT(*) AS clean_count
FROM order_reviews_clean;


--Category_translation_table


SELECT TOP 10 *
FROM category_translation_raw;

SELECT COUNT(*) AS raw_count
FROM category_translation_raw;


SELECT
    SUM(CASE WHEN column1 IS NULL THEN 1 ELSE 0 END) AS null_portuguese,
    SUM(CASE WHEN column2 IS NULL THEN 1 ELSE 0 END) AS null_english
FROM category_translation_raw;


SELECT
    column1,
    COUNT(*) AS duplicate_count
FROM category_translation_raw
GROUP BY column1
HAVING COUNT(*) > 1;


SELECT
    column1 AS product_category_name,
    column2 AS product_category_name_english
INTO category_translation_clean
FROM category_translation_raw;


SELECT COUNT(*) AS raw_count
FROM category_translation_raw;

SELECT COUNT(*) AS clean_count
FROM category_translation_clean;


--EXPLORATORY DATA ANALYSIS--

--Revenue Analysis
SELECT
    SUM(price) AS total_sales
FROM order_items_clean;


--Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders_clean;

--Total Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM customers_clean;

--Payment Method Distribution
SELECT
    payment_type,
    COUNT(*) AS transactions
FROM order_payments_clean
GROUP BY payment_type
ORDER BY transactions DESC;


--Review Score Distribution
SELECT
    review_score,
    COUNT(*) AS reviews
FROM order_reviews_clean
GROUP BY review_score
ORDER BY review_score;


--Monthly Sales Trend
SELECT
    YEAR(o.purchase_date) AS sales_year,
    MONTH(o.purchase_date) AS sales_month,
    SUM(oi.price) AS revenue
FROM orders_clean o
JOIN order_items_clean oi
    ON o.order_id = oi.order_id
GROUP BY
    YEAR(o.purchase_date),
    MONTH(o.purchase_date)
ORDER BY
    sales_year,
    sales_month;


--Top Product Categories
SELECT TOP 10
    p.product_category_name,
    SUM(oi.price) AS revenue
FROM order_items_clean oi
JOIN products_clean p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC;


--Top Sellers
SELECT TOP 10
    seller_id,
    SUM(price) AS revenue
FROM order_items_clean
GROUP BY seller_id
ORDER BY revenue DESC;


--Order Status Distribution
SELECT
    order_status,
    COUNT(*) AS orders
FROM orders_clean
GROUP BY order_status
ORDER BY orders DESC;

