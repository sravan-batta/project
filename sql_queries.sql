
-- drop table Orders;

-- create table public.Orders(
-- 	order_id int primary key,
-- 	order_date date,
-- 	ship_mode varchar(20),
-- 	segment varchar(20),
-- 	country varchar(20),
-- 	city varchar(20),
-- 	state varchar(20),
-- 	postal_code varchar(20),
-- 	region varchar(20),
-- 	category varchar(20),
-- 	sub_category varchar(20),
-- 	product_id varchar(20),
-- 	quantity int,
-- 	discount decimal(7,2),
-- 	sale_price decimal(7,2),
-- 	profit decimal(7,2)	
-- )


select * from orders;


-- Find top 10 highest revenue generating products
select product_id, sum(sale_price) as total_revenue
from orders
group by product_id
order by total_revenue desc
limit 10

-- Find top 5 highest selling products in each region
select region,product_id,total_revenue from(
select region,product_id, 
sum(sale_price) as total_revenue, row_number() over(partition by region order by sum(sale_price) desc) as rnk
from orders
group by region,product_id)x
where x.rnk<=5

-- Find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
with cte_2022 as(
	select TO_CHAR(order_date, 'Mon')  as mn, sum(sale_price) as sales
	from orders
	where EXTRACT(year from order_date) = '2022'
	group by TO_CHAR(order_date, 'Mon') 
),
cte_2023 as(
	select TO_CHAR(order_date, 'Mon')  as mn, sum(sale_price) as sales
	from orders
	where EXTRACT(year from order_date) = '2023'
	group by TO_CHAR(order_date, 'Mon') 
)
select c1.mn as month,c1.sales as sales_2022, c2.sales as sales_2023
from cte_2022 c1 join cte_2023 c2 on c1.mn = c2.mn

-- For each category which month had highest values
with cte as(
SELECT TO_CHAR(order_date, 'Mon YYYY') AS month_year,category,sum(sale_price) as sales
from orders
group by TO_CHAR(order_date, 'Mon YYYY'),category),
cte1 as(
select month_year,category,sales,rank() over(partition by category order by sales desc) as rn
from cte)
select category,month_year,sales from cte1
where rn = 1

-- Which sub category had highest growth by profit in 2023 compare to 2022
with cte as(
select extract (year from order_date) as year,sub_category,sum(profit) as total_profits
from orders
group by extract (year from order_date),sub_category),
cte1 as(
select sub_category,
sum(case when year = 2022 then total_profits else 0 end) as profits_2022,
sum(case when year = 2023 then total_profits else 0 end) as profits_2023
from cte
group by sub_category)
select sub_category, (profits_2023-profits_2022)*100.0/profits_2022 as diff
from cte1
order by diff desc
