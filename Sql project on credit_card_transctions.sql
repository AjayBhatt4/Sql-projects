-- 1 write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
with cte as (select city,sum(amount) as amount_spent
from `credit_card_transcations (1)`
group by city
order by amount_spent desc 
limit 5  ),

cte_2 as (select distinct city,sum(amount)over() as total_amount from `credit_card_transcations (1)` ),
cte_3 as (select c.city,amount_spent,total_amount from cte c inner join cte_2 on c.city=cte_2.city)

select city , amount_spent, total_amount,(amount_spent/total_amount)*100 as prcent_con from cte_3
order by prcent_con desc;

-- 2 write a query to print highest spend month and amount spent in that month for each card type
select * from `credit_card_transcations (1)`;
select distinct exp_type from `credit_card_transcations (1)`;
SELECT STR_TO_DATE(transaction_date, '%Y-%m-%d') 
FROM `credit_card_transcations (1)`;
update `credit_card_transcations (1)`
set transaction_date =
	STR_TO_DATE(transaction_date, '%d-%b-%Y');
with cte as 
(select extract(month from transaction_date) as month_no,extract(year from transaction_date) as year_no,card_type,sum(amount) as total_sum
from `credit_card_transcations (1)`
group by extract(month from transaction_date),extract(year from transaction_date),card_type
order by month_no)

select * from (select *,dense_rank()over(partition by card_type order by total_sum desc) as rn from cte )A
where   rn=1;



-- 3- write a query to print the transaction details(all columns from the table) for each card type when it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
 select * from 
( 
 select * , rank () over(partition  by card_type order by cum_sum) as rn from (
 ( select *,sum(amount) over (partition by card_type order by  transaction_date,transaction_id ) 
as cum_sum 
from `credit_card_transcations (1)` as A))V
where cum_sum>=1000000
)B
 where rn=1;


-- -4 write a query to find city which had lowest percentage spend for gold card type
with cte as  (  select city,card_type,sum(amount) as sum_t
from `credit_card_transcations (1)`
group by city,card_type
having card_type='gold'
order by sum_t  ),

cte_2 as (select city, sum(amount) as total from `credit_card_transcations (1)` group by city )
select c.city,sum_t,total,(sum_t/total)*100 as p from cte c inner join cte_2 on c.city=cte_2.city
order by p
limit 1; 
-- 5 write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
select * from `credit_card_transcations (1)`;
with cte as (select city, exp_type,sum(amount) as exp
from `credit_card_transcations (1)`
group by city,exp_type
order by city),

 cte_2 as (select * , 
dense_rank()over(partition by city order by exp desc) as high_exp,
dense_rank()over(partition by city order by exp)as low_exp from cte)

select city,  
max(case when high_exp=1 then exp_type end) as highest_exp,
max(case when low_exp=1 then exp_type end )as lowest_exp
from  cte_2
group by city;

-- 6 write a query to find percentage contribution of spends by females for each expense type
select * from `credit_card_transcations (1)`;
with cte as 
(select gender,exp_type,sum(amount) as amount_spent
 from `credit_card_transcations (1)`
 group by gender,exp_type
 having gender='f'),
 
 cte_2 as (  select exp_type,sum(amount) as t_amount from `credit_card_transcations (1)` group by exp_type  ) 
select gender,exp_type,amount_spent,t_amount,(amount_spent/t_amount)* 100 as percent_f 
from (select gender,c.exp_type,t_amount,amount_spent from cte c inner join cte_2 x on c.exp_type=x.exp_type)A
order by percent_f desc;

--7 which card and expense type combination saw highest month over month growth in Jan-2014
with cte as(
select card_type,exp_type,amount,extract(month from transaction_date ) as month_m,extract( year from transaction_date ) as year_y
from `credit_card_transcations (1)`
where (extract(month from transaction_date )='12' and extract( year from transaction_date ) ='2013') or
(extract(month from transaction_date )='1' and extract( year from transaction_date ) ='2014')
order by card_type  ),

cte_2 as (select card_type,exp_type,month_m,year_y,sum(amount)as summ from cte
group by card_type,exp_type,month_m,year_y ),
cte_3 as (select *,lead(summ,1,summ)  over(partition by  card_type,exp_type) as next_sum from cte_2)
select * from (select card_type,exp_type,dense_rank()over (order by diff) as rn from (select * , (summ-next_sum) as diff from cte_3)A)B
where rn=1;


-- 8 during weekends which city has highest total spend to total no of transcations ratio
select city,transaction_date,count(*) as total_transcation from `credit_card_transcations (1)`
group by city,transaction_date
order by city,transaction_date;
with cte as ( select * from (
select *, weekday( transaction_date) day_no from `credit_card_transcations (1)`)A
 where day_no=5 or day_no=6  ),

cte_2 as
   (select city, sum(amount) as summ,count(*) as no_of_transaction from
cte
group by city )

select * from (select * , (summ/no_of_transaction) as ratio  from cte_2)S 
order by ratio desc;


-- 9 which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte as (select city,transaction_date, row_number()over(partition by city order by transaction_date) as rn
from `credit_card_transcations (1)`
)

select city,min(transaction_date),max(transaction_date),datediff(max(transaction_date),min(transaction_date) ) as no_of_day from cte 
where rn in (1,500)
group by city
having Count(*)=2
order by no_of_day

