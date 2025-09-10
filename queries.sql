-- 🍕 Pizza Sales Analysis with SQL
-- Author: Safina Shah
-- Description: All project queries (Basic + Intermediate + Advanced)

-------------------------------------------------------
-- BASIC QUERIES
-------------------------------------------------------

-- Q1. Total number of orders placed
SELECT COUNT(*) AS total_orders
FROM orders;

-- Q2. Total revenue generated from pizza sales
SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- Q3. Identify the highest-priced pizza
SELECT pizza_id, price
FROM pizzas
ORDER BY price DESC
LIMIT 1;

-- Q4. Identify the most common pizza size ordered
SELECT p.size, SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_ordered DESC
LIMIT 1;

-- Q5. List the top 5 most ordered pizza types along with their quantities
SELECT pt.name AS pizza_type, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-------------------------------------------------------
-- INTERMEDIATE QUERIES
-------------------------------------------------------

-- Q1. Total quantity of each pizza category ordered
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Q2. Distribution of orders by hour of the day
SELECT HOUR(STR_TO_DATE(o.`time`, '%H:%i:%s')) AS order_hour,
       COUNT(*) AS total_orders
FROM orders o
GROUP BY order_hour
ORDER BY order_hour;

-- Q3. Category-wise distribution of pizzas
SELECT pt.category, COUNT(DISTINCT p.pizza_id) AS total_pizzas
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Q4. Average number of pizzas ordered per day (per order)
SELECT daily.order_date,
       ROUND(AVG(daily.total_pizzas_per_order), 2) AS avg_pizzas_per_order
FROM (
  SELECT o.order_id, o.`date` AS order_date, SUM(od.quantity) AS total_pizzas_per_order
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  GROUP BY o.order_id, o.`date`
) AS daily
GROUP BY daily.order_date
ORDER BY daily.order_date;

-- Q5. Top 3 most ordered pizza types based on revenue
SELECT pt.name, ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-------------------------------------------------------
-- ADVANCED QUERIES
-------------------------------------------------------

-- Q1. Percentage contribution of each pizza type to total revenue
SELECT pt.name,
       ROUND(SUM(od.quantity * p.price), 2) AS revenue,
       ROUND(SUM(od.quantity * p.price) * 100.0 / 
             (SELECT SUM(od2.quantity * p2.price)
              FROM order_details od2
              JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id), 2) AS percentage_contribution
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC;

-- Q2. Cumulative revenue generated over time
SELECT o.`date` AS order_date,
       ROUND(SUM(od.quantity * p.price), 2) AS daily_revenue,
       ROUND(SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.`date`), 2) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.`date`
ORDER BY o.`date`;

-- Q3. Top 3 most ordered pizza types based on revenue for each pizza category
SELECT category, name, total_revenue
FROM (
    SELECT pt.category,
           pt.name,
           ROUND(SUM(od.quantity * p.price), 2) AS total_revenue,
           RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rnk
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) AS ranked
WHERE rnk <= 3
ORDER BY category, total_revenue DESC;
