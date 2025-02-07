-- Retrieve the total number of orders placed. --

select * from order_;
select count(order_id) as total_order from order_;


-- Calculate the total revenue generated from pizza sales. --

select * from piza;
select * from order_detail;

SELECT 
    ROUND(SUM(piza.price * order_detail.quantity),
            2) AS total_revenue
FROM
    piza
        JOIN
    order_detail ON piza.pizza_id = order_detail.pizza_id;
    
    
-- Identify the highest-priced pizza. --

select * from piza;
select * from piza_type;

SELECT 
    piza_type.name, piza.price
FROM
    piza_type
        JOIN
    piza ON piza_type.pizza_type_id = piza.pizza_type_id
ORDER BY piza.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered. --

select * from piza;
select * from order_detail;

SELECT 
    piza.size,
    COUNT(order_detail.order_details_id) AS order_count
FROM
    piza
        JOIN
    order_detail ON piza.pizza_id = order_detail.pizza_id
GROUP BY piza.size
ORDER BY order_count DESC;


-- List the top 5 most ordered pizza types along with their quantities. --

select * from piza;
select * from piza_type;
select * from order_detail;

SELECT 
    piza_type.name, SUM(order_detail.quantity) AS quantities
FROM
    piza_type
        JOIN
    piza ON piza_type.pizza_type_id = piza.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = piza.pizza_id
GROUP BY piza_type.name
ORDER BY quantities DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered. --

select * from piza;
select * from piza_type;
select * from order_detail;


SELECT 
    piza_type.category, SUM(order_detail.quantity) AS quantity
FROM
    piza_type
        JOIN
    piza ON piza_type.pizza_type_id = piza.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = piza.pizza_id
GROUP BY piza_type.category
ORDER BY quantity DESC;


-- Determine the distribution of orders by hour of the day. --

select * from order_;
select hour(time) from order_;

SELECT 
    HOUR(time) AS hour, COUNT(order_id) AS order_count
FROM
    order_
GROUP BY HOUR(time);


-- join relevant tables to find the category-wise distribution of pizzas. --

select * from piza_type;

SELECT 
    category, COUNT(name)
FROM
    piza_type
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day. --

SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        order_.date, SUM(order_detail.quantity) AS quantity
    FROM
        order_
    JOIN order_detail ON order_.order_id = order_detail.order_id
    GROUP BY order_.date) AS order_quantity;
    
    
-- Determine the top 3 most ordered pizza types based on revenue. --

select * from piza;
select * from piza_type;
select * from order_detail;


SELECT 
    piza_type.name,
    SUM(order_detail.quantity * piza.price) AS revenue
FROM
    piza_type
        JOIN
    piza ON piza_type.pizza_type_id = piza.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = piza.pizza_id
GROUP BY piza_type.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue. --

SELECT 
    piza_type.category,
    ROUND(SUM(order_detail.quantity * piza.price) / (SELECT 
                    ROUND(SUM(order_detail.quantity * piza.price),
                                2) AS total_sales
                FROM
                    order_detail
                        JOIN
                    piza ON piza.pizza_id = order_detail.pizza_id) * 100,
            2) AS revenue
FROM
    piza_type
        JOIN
    piza ON piza_type.pizza_type_id = piza.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = piza.pizza_id
GROUP BY piza_type.category
ORDER BY revenue DESC; 


-- Analyze the cumulative revenue generated over time. --

select date, sum(revenue) over(order by date)as cum_revenue
from
(select order_.date,
round(sum(order_detail.quantity * piza.price),2)as revenue
from order_detail join piza
on order_detail.pizza_id = piza.pizza_id
join order_
on order_.order_id = order_detail.order_id
group by order_.date) as sales; 


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category. --

select name,revenue
from
(select category,name,revenue,rank()
over(partition by category order by revenue desc) as rn
from
(select piza_type.category, piza_type.name,
sum(order_detail.quantity * piza.price) as revenue
from piza_type join piza
on piza_type.pizza_type_id = piza.pizza_type_id
join order_detail
on order_detail.pizza_id = piza.pizza_id
group by piza_type.category, piza_type.name) as a) as b
where rn <=3;