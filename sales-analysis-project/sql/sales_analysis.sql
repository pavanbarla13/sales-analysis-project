CREATE DATABASE superstore_db;
USE superstore_db;

CREATE TABLE orders (
    row_id INT,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code INT,
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales FLOAT,
    quantity INT,
    discount FLOAT,
    profit FLOAT
);


-- Total sales & profits
SELECT 
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit,
ROUND(SUM(profit)/SUM(sales),2) AS margin
FROM orders;

-- Profit by category
SELECT category,
ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY category;

-- Loss making category
SELECT category,
ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY category
HAVING total_profit < 0;

-- Which sub-category is causing losses?
SELECT `sub-category`,
ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY `sub-category`
HAVING total_profit < 0;

SELECT * FROM orders;

-- Which products are causing losses?
SELECT product_name,
ROUND(SUM(profit),2) AS total_profits
FROM orders
GROUP BY product_name
ORDER BY total_profits ASC
LIMIT 10;

-- Does discount cause loss?
SELECT discount,
AVG(profit) AS avg_profit
FROM orders
GROUP BY discount
ORDER BY avg_profit ASC;

-- Which category suffers due to discounts?
SELECT category, 
discount,
AVG(profit) AS avg_profit
FROM orders
GROUP BY category, discount
ORDER BY avg_profit ASC;

-- Which categories are profitable or loss

SELECT category,
ROUND(SUM(profit),2) AS total_profit,
CASE
	WHEN SUM(profit) < 0 THEN 'loss'
    ELSE 'profit'
    END AS profit_status
FROM orders
GROUP BY category;


-- Top 3 three products in each category
SELECT * 
FROM
(SELECT product_name,
category,
SUM(profit) AS total_profit,
RANK() OVER(PARTITION BY category ORDER BY SUM(profit) DESC) rnk
FROM orders
GROUP BY category, product_name)t
WHERE rnk<=3;

-- Worst 5 products(loss focus)
SELECT product_name,
ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 5;

-- Discount impact analysis
SELECT discount,
COUNT(*) AS total_orders,
ROUND(AVG(profit),2) AS avg_profit
FROM orders
GROUP BY discount
ORDER BY avg_profit ASC;

-- Monthly sales trend(Time analysis)
SELECT 
YEAR(order_date) AS year,
MONTH(order_date) AS month,
ROUND(SUM(sales),2) AS total_sales
FROM orders
GROUP BY year, month
ORDER BY year, month;

-- Sales vs profit efficiency
SELECT category,
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit,
(SUM(profit)/SUM(sales))* 100 AS profit_percentage
FROM orders
GROUP BY category;

-- Which products are responsible for those losses?
WITH loss_categories AS(
SELECT category
FROM orders
GROUP BY category
HAVING SUM(profit) < 0
)
SELECT product_name,
SUM(profit) AS total_profit
FROM orders
WHERE category IN(
SELECT category
FROM loss_categories)
GROUP BY product_name
ORDER BY total_profit ASC
LIMIT 10;

-- Which product categories are generating losses for the business?
WITH category_profit AS(
SELECT category,SUM(profit) AS total_profit
FROM orders
GROUP BY category
)
SELECT * 
FROM category_profit
WHERE total_profit < 0;

-- How is sales changing month by month
WITH monthly_sales AS(
SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(sales) AS total_sales
    FROM orders
    GROUP BY year,month
)
SELECT 
YEAR,
month,
total_sales,
LAG(total_sales) OVER(ORDER BY year,month) AS prev_month,
total_sales-LAG(total_sales) OVER(ORDER BY year,month) AS growth
FROM monthly_sales;
