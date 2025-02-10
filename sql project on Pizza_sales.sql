/* For this project we have 4 tables namely
1 Orderss
2 Order_details
3 Pizza types
4 Pizzas
*/

describe Orderss;
update Orderss
set date =
	STR_TO_DATE(date, '%Y-%m-%d');
 ALTER TABLE Orderss
MODIFY COLUMN date DATE;
select * from pizzas;
ALTER TABLE Orderss
MODIFY COLUMN time TIME;

--  till now we have changed the data type of date column and time column
-- Now Analysis of the data using sql 
-- 1 Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_no_of_orders
FROM
    orderss;

-- 2 Calculate the total revenue generated from pizza sales.
select * from pizzas;
select * from pizza_types;
select * from orderss;
with cte as (select pizza_id,sum(quantity) 
as total_quantity_asPer_pizza_id from order_details
group by pizza_id)
 
 select round(sum(revenue_per_pizza_id ),2) as total_revenue 
 from (select *,(price*total_quantity_asPer_pizza_id) as revenue_per_pizza_id 
  from (select C.pizza_id,pizza_type_id,price, total_quantity_asPer_pizza_id 
  from pizzas P inner join cte c on P.pizza_id=c.pizza_id )A)B;
 
 
 -- 3  Identify the highest-priced pizza.
SELECT 
    pizza_id, MAX(price) AS max_price
FROM
    pizzas
GROUP BY pizza_id
ORDER BY max_price DESC
LIMIT 1;

-- same query Identify the highest-priced pizza. but,( not the size wise , just the pizza name  )
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- 4 Identify the most common pizza size ordered.

SELECT 
    size, SUM(quantity) AS total_quantity_size_wise
FROM
    pizzas P
        INNER JOIN
    order_details O ON P.pizza_id = O.pizza_id
GROUP BY size
ORDER BY total_quantity_size_wise DESC
LIMIT 1;

 -- 5 the top 5 most ordered pizza types along with their quantities.
 
select * from Orderss;
select * from order_details;
select * from pizza_types ;
select * from pizzas;

SELECT 
    SUM(quantity) AS total_quantity_name_wise, name
FROM
    (SELECT 
        pizzas.pizza_id, pizza_type_id, quantity
    FROM
        pizzas
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id) A
        INNER JOIN
    pizza_types ON A.pizza_type_id = pizza_types.pizza_type_id
GROUP BY name
ORDER BY total_quantity_name_wise DESC
LIMIT 5;

-- 6  find the total quantity of each pizza category wise.
SELECT 
    category, SUM(quantity) AS total_cat_wise
FROM
    (SELECT 
        pizzas.pizza_type_id,
            order_details.pizza_id,
            pizza_types.category,
            order_details.quantity
    FROM
        pizzas
    JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id) A
GROUP BY category;


-- 7 Determine the distribution of orders by hour of the day.
SELECT 
    EXTRACT(HOUR FROM time) AS hour_t,
    -- SUM(quantity) AS hourly_quantity
    quantity
FROM
    order_details
        JOIN
    orderss ON orderss.order_id = order_details.order_id
    
GROUP BY EXTRACT(HOUR FROM time)
ORDER BY hourly_quantity DESC;


 --  8 find the category-wise distribution of pizzas.( here we have to find how many different types of pizza  are available with in each category)
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;
 
 /* o/p = Chicken	6
Classic	8
Supreme	9
Veggie	9  this means 6 different types of chicken pizza,8 diff types of classis pizza available
*/

-- 9  calculate the average number of pizzas ordered per day.
-- the below two query are wrong 
select date, avg(quantity) from orderss
inner join order_details on orderss.order_id=order_details.order_id
group by date;
-- in this the avg is not perday as after sum it will dive with toatal members in that particular group
select avg (quantity) from order_details; -- in this also it will take each row when dividing but each date should be considered one time only

-- correct query , here it will divide with total no of days 
SELECT 
    ROUND(AVG(total_sum_day_wise), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        date, SUM(quantity) AS total_sum_day_wise
    FROM
        orderss
    INNER JOIN order_details ON orderss.order_id = order_details.order_id
    GROUP BY date) A;
    
    
-- 10  Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    name, cost
FROM
    (SELECT 
        pizza_type_id, SUM((quantity * price)) AS cost
    FROM
        pizzas
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizza_type_id) A
        INNER JOIN
    pizza_types ON A.pizza_type_id = pizza_types.pizza_type_id
ORDER BY cost DESC
LIMIT 3;


-- 11  Calculate the percentage contribution of each pizza type to total revenue.
select * , round((revenue_of_each_pizza_type/total_revenue)*100,2) as percent_contribution from( with cte as 

(select name ,sum(quantity* price ) as revenue_of_each_pizza_type from pizzas
join order_details on order_details.pizza_id=pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by name
order by  revenue_of_each_pizza_type desc),

cte_2 as (select round(sum( revenue_of_each_pizza_type),2) as total_revenue from cte   )
select * from cte join cte_2 on 1=1) A;

-- The above problem can also be interpreted, as to calculate percentage contribution category wise
select *, round((revenue_of_each_pizza_type/total_revenue)*100,2) from (with cte as (
select category ,round(sum(quantity* price ),2) as revenue_of_each_pizza_type from pizzas
join order_details on order_details.pizza_id=pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by category
order by  revenue_of_each_pizza_type desc),

  cte_2 as (select round(sum( revenue_of_each_pizza_type),2) as total_revenue from cte )
select * from cte join cte_2 on 1=1) A;

-- 12 Analyze the cumulative revenue generated over time.(day wise)

with cte as 
(select date,( price*quantity) as revenue  from pizzas
join order_details on order_details.pizza_id=pizzas.pizza_id
join Orderss on Orderss.order_id=order_details.order_id),

cte_2 as (
select date, round(sum(revenue),2) as total_sum
from cte 
group by date
)

select * , round(sum(total_sum) over(order by date),2)as cum_sum from cte_2;


-- 13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select * from(select *,dense_rank() over(partition by category order by revenue desc) as rn
 from (  select category,name,sum(quantity*price)as revenue from order_details
 inner join pizzas on order_details.pizza_id=pizzas.pizza_id
 join pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id
 group by category,name
 order by category )A )B
 where rn<=3
 
 
 