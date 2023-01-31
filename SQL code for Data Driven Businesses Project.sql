use magist;
-- How many orders are there in the dataset?
SELECT 
    COUNT(*) AS orders_count
FROM
    orders;
-- Are orders actually delivered?
SELECT 
    order_status, 
    COUNT(order_id) AS orders
FROM
    orders
GROUP BY order_status;

-- Is Magist having user growth? 
SELECT
  YEAR(order_purchase_timestamp) AS year,
  MONTH(order_purchase_timestamp) AS month,
  COUNT(order_id) AS count
FROM orders
GROUP BY
  MONTH(order_purchase_timestamp),
  YEAR(order_purchase_timestamp)
ORDER BY YEAR;

-- How many products are there on the products table?
-- There are no duplicates
SELECT COUNT(DISTINCT(product_id)) 
FROM products;

-- Which are the categories with the most products?
SELECT COUNT(DISTINCT product_id), product_category_name
FROM products
GROUP BY product_category_name
ORDER BY COUNT(product_id) DESC;

-- How many of those products were present in actual transactions? 
-- Total: 112625 orders and in each one of them participated at lest one of the products
SELECT COUNT(DISTINCT(product_id))
FROM order_items;

SELECT count(order_id)
FROM order_items;

-- What’s the price for the most expensive and cheapest products?
SELECT MAX(price), order_id
FROM order_items
GROUP BY order_id
ORDER BY MAX(price) DESC
LIMIT 1;

SELECT MIN(price), order_id 
FROM order_items
GROUP BY order_id
ORDER BY MAX(price) 
LIMIT 1;

-- What are the highest and lowest payment values?
SELECT MAX(payment_value) AS highest_payment_value FROM order_payments;

SELECT MIN(payment_value) AS lowest_payment_value FROM order_payments;

-- What categories of tech products does Magist have?
-- '32951' number of all products
-- categories of tech products: computer accessories(1639), electronics(517), audio(58), computers(30), telephony(1134), pc gamer(3)
-- total: 3381
SELECT * FROM product_category_name_translation;

SELECT tr.product_category_name_english, COUNT(DISTINCT(p.product_id)) AS product
FROM product_category_name_translation tr
LEFT JOIN products p ON tr.product_category_name = p.product_category_name
GROUP BY tr.product_category_name
ORDER BY COUNT(p.product_id) DESC;

-- How many products of these tech categories have been sold? 
-- computer acc - 7827 items sold, telephony - 4545, electronics - 2767, audio - 364, computers - 203, pc gamer - 9
-- total number of items that were sold 112.650, of those items only 15.715 products are tech products
-- around 13-14% of sold products are tech
SELECT p.product_category_name, COUNT(DISTINCT(p.product_id)) AS product_number, COUNT(oi.order_item_id) AS orders
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name;

-- What’s the average price of the products in the tech products being sold?
-- 106
SELECT MIN(price), AVG(price), MAX(price)
FROM order_items AS o_i
LEFT JOIN products AS p ON o_i.product_id = p.product_id 
RIGHT JOIN product_category_name_translation AS p_c_n_t ON p.product_category_name = p_c_n_t.product_category_name
WHERE product_category_name_english IN ('audio', 'electronics','computers', 'computers_accessories', 'pc_gamer', 'telephony');

-- Are expensive tech products popular?
-- Expensive tech products are not so popular on the Magist platform
SELECT COUNT(*) 
FROM order_items AS oi
LEFT JOIN products p ON p.product_id = oi.product_id
WHERE price > 500 AND (product_category_name = 'informatica_acessorios' OR product_category_name = 'pcs' OR 
product_category_name = 'telefonia' OR product_category_name = 'pc_gamer' OR 
product_category_name = 'eletronicos' OR product_category_name = 'audio');

-- How many months of data are included in the magist database?
-- 10 months of 2018, 12 months in 2017 and 3 months in 2016

-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
-- 3095 sellers
-- 454 of them are selling tech products
-- only 14-15% of overall sellers are Tech sellers
SELECT COUNT(DISTINCT seller_id) FROM sellers;

SELECT COUNT(DISTINCT s.seller_id)
FROM order_items oi
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE product_category_name IN ('informatica_acessorios','audio','pc_gamer', 'pcs', 'telefonia', 'eletronicos');

-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
-- total amount: 13.595.730
-- electronics: 160.247; comp acc: 911.954; audio: 50.688; pcs: 222.963; telephony: 323.668, pc gamer: 1546
-- total amount by tech sellers: 1.671.084/ 12% of income is earned by Tech sellers
SELECT p.product_category_name, ROUND(SUM(price))
FROM order_items oi
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
LEFT JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
HAVING product_category_name IN ('informatica_acessorios','audio','pc_gamer', 'pcs', 'telefonia', 'eletronicos');

-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?
-- average monthly income of all sellers : 543.830
-- average monthly income of tech sellers: 541.97

-- What’s the average time between the order being placed and the product being delivered?
SELECT ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_approved_at)),2) AS DateDiff
FROM orders;

-- How many orders are delivered on time vs orders delivered with a delay?
-- 88.808 orders are delivered on time
-- 8.861 are not delivered on time
-- there should be 96.478 delivered orders in total
SELECT COUNT(DISTINCT(o.order_id)) 
FROM order_items
LEFT JOIN orders o ON order_items.order_id = o.order_id
WHERE order_items.shipping_limit_date >= o.order_delivered_carrier_date;

SELECT COUNT(DISTINCT order_id) 
FROM order_items;

-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
-- the avg weight in gr for products delivered on time is '2023.88', and for the ones not delivered on time 2755.56
-- Did not find significant patterns for the delayed orders
SELECT COUNT(*), product_category_name
FROM order_items
LEFT JOIN orders o ON order_items.order_id = o.order_id
LEFT JOIN products p ON order_items.product_id = p.product_id
WHERE order_items.shipping_limit_date >= o.order_delivered_carrier_date
GROUP BY p.product_category_name
ORDER BY COUNT(*) DESC;