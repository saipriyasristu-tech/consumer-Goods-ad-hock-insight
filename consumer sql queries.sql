
select * from dim_customer
where region="APAC" and customer="Atliq Exclusive"


select 
    count(distinct case when fiscal_year=2020 
    then product_code  end) as unique_product_2020,
    count(distinct case when fiscal_year=2021 
    then product_code  end) as unique_product_2021,
round(
(count(distinct case when fiscal_year=2021 then product_code  end) - 
count(distinct case when fiscal_year=2020 then product_code  end) )
/
count(distinct case when fiscal_year=2020 then product_code  end) *100,2) as percentage_chg
 from fact_sales_monthly;
 
 
 select segment,count(distinct product_code) as product_count
 from dim_product
 group by segment
order by product_count desc;

select d.segment,
count(distinct case when s.Fiscal_year=2020 then s.product_code end) as product_count_2020,
count(distinct case when s.Fiscal_year=2021 then s.product_code end) as product_count_2021,
(count(distinct case when s.Fiscal_year=2021 then s.product_code end)-
count(distinct case when s.Fiscal_year=2020 then s.product_code end)) as difference
from fact_sales_monthly s
join dim_product d
on s.product_code=d.product_code
group by segment
order by difference desc;

select p.product_code,p.product,m.manufacturing_cost from fact_manufacturing_cost m
join dim_product p
on p.product_code=m.product_code
where manufacturing_cost=(select max(m.manufacturing_cost) from fact_manufacturing_cost) or
 manufacturing_cost=(select min(m.manufacturing_cost) from fact_manufacturing_cost)
 order by manufacturing_cost;
 
 select c.customer_code,
 c.customer,
 round(avg(f.pre_invoice_discount_pct)*100,2)as avg_discount_percentage
 from fact_pre_invoice_deductions f
 join dim_customer c
 on f.customer_code=c.customer_code
 where fiscal_year=2021 and market="India"
 group by customer_code,customer
 order by avg_discount_percentage desc
 limit 5
 
 select
month(f.date) as month,
year(f.date) as year,
 sum(f.sold_quantity*g.gross_price)as gross_sale_amount
 from fact_sales_monthly f
 join fact_gross_price g
 on g.product_code=f.product_code
  join dim_customer c
 on f.customer_code=c.customer_code
 where c.customer="Atliq Exclusive"
 group by month(f.date),year(f.date)
 order by month(f.date),year(f.date);
 
 with cte1 as(
 select
      date,
      sold_quantity,
      case
          when month(date) in (9,10,11) then 'Q1'
          when month(date) in (12,1,2) then 'Q2'
          when month(date) in (3,4,5) then 'Q3'
          when month(date) in (6,7,8) then 'Q4'
          end as Quarter
          from fact_sales_monthly
 )
 select 
 quarter,
 sum(sold_quantity) as total_sold_quantity
 from cte1
 group by quarter
 order by total_sold_quantity desc;
 
with channel_sales as(
select 
c.channel,
sum(f.sold_quantity*g.gross_price) as gross_sale
 from fact_sales_monthly f
join fact_gross_price g
on f.product_code=g.product_code
and f.Fiscal_year=g.fiscal_year
join dim_customer c
on c.customer_code=f.customer_code
where f.Fiscal_year=2021
group by c.channel
)
select channel,
round(gross_sale/1000000,2) as gross_sales_mln,
round((gross_sale*100)/sum(gross_sale) over(),2) as percentage
 from channel_sales
 order by gross_sales_mln desc
 
  with cte as(select 
  p.division,
  p.product_code,
  p.product,
  sum(f.sold_quantity) as total_sold_quantity 
  from fact_sales_monthly f
  join dim_product p
  on p.product_code=f.product_code
  where f.fiscal_year=2021
  group by p.division,
  p.product_code,
  p.product
  ),
  ranked_cte as(
  select 
  division,
  product_code,
  product,
  total_sold_quantity,
  rank() over(
  partition by division
  order by total_sold_quantity desc
  ) as rank_order
  from cte
  )
  select * from ranked_cte
  where rank_order<=3;
  
 

