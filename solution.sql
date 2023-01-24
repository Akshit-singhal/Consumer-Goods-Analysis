use gdb023;

-- 1) Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.

-- Query
	select distinct(market) as market
	from dim_customer
	where customer = 'Atliq Exclusive' and region = 'APAC'
	order by market


/* The Market list is India,Indonesia,Japan,Philiphines,South Korea,Australia,Newzealand,
Bangladesh which customer "Atliq Exclusive" operates its business in the APAC region. */


-- 2) What is the percentage of unique product increase in 2021 vs. 2020?

-- Query

	with 2020_products as(
		select count(distinct(product_code)) as cnt
		from dim_product
		join fact_gross_price
		using (product_code)
		where fiscal_year = 2020),

	     2021_products as(
		select count(distinct(product_code)) as cnt
		from dim_product
		join fact_gross_price
		using (product_code)
		where fiscal_year = 2021)

	select a.cnt as unique_products_2020,
	       b.cnt as unique_products_2021, 
	       round(((b.cnt-a.cnt)/a.cnt)*100,2) as percentage_chg
	from 2020_products a
	join 2021_products b

/* Output
	+-----------------------------+---------------------------+-------------------------+
	| 	unique_product_count_2020 |	unique_product_count_2021 | percentage_chg  |	
	+-----------------------------+---------------------------+---------------------+
	|       245		              |	     334	          |    36.33	    |
	+---------------+-------------------------------+-----------------------------------+*/

/* 3)Provide a report with all the unique product counts for each segment 
     and sort them in descending order of product counts. */

-- Query

	select segment, count(distinct(product_code)) as product_count 
	from dim_product
	group by segment
	order  by product_count desc
	
	
/*
	-- +------------------+------------------
	|product_count      |   segment        |
	+------------------+--------------------+
	|        129        |	Notebook        |
	|	 116	    |	Accessories	|
	|	 84	    |	 Peripherals	|
	|        32         |	Desktop		|
	|	 27	    |	Storage		|
	|	  9	    |	Networking	|
	+-------------------+-------------------+*/

/* 4)Which segment had the most increase in unique products in 2021 vs 2020?  */

--Query

	with 2020_products as (
		select segment, count(distinct(p.product_code)) as product_count
		from dim_product p
		join fact_gross_price
		using(product_code)
		where fiscal_year = 2020
		group by segment),

	2021_products as(
		select segment, count(distinct(p.product_code)) as product_count
		from dim_product p
		join fact_gross_price
		using(product_code)
		where fiscal_year = 2021
		group by segment)

	select a.segment, a.product_count as product_count_2020, 
	b.product_count as product_count_2021, 
	b.product_count-a.product_count as difference,
	round(((b.product_count-a.product_count)/a.product_count)*100,2) as percinc
	from 2020_products a
	join 2021_products b
	using(segment)
	
	
/* Output
	-- +------------------+------------------+--------------------+--------------------------------------+
	|      segment          /    product_count_2020 | product_count_2021 |    differnce    |    percinc  /
	+-------------------+--------------------+--------------------+--------------------------------------+
	|    Accessories     	|	      69         |      103          |      34         |     49.28   |
	|    Desktop	        |             7    	 |      22           |      15         |     214.29  |
	|    Networking	        |	      6 	 |      9            |      3          |     50.00   |
	|    Notebook		|	      92	 |      108          |      16         |     17.39   |
	|    Preipherals        |	      59	 |      75           |      16         |     27.12   |  
	|    Storage	        |	      12	 |      17           |      5          |     41.67   |
	+-------------------+-------------------+--------------------+--------------------------------------+*/	
	
	
-- 5. Get the products that have the highest and lowest manufacturing costs.

-- Query
	select p.product_code, p.product,
	       m.manufacturing_cost from dim_product p
	join fact_manufacturing_cost m
	using (product_code)
	where manufacturing_cost = (select max(manufacturing_cost) 
				    from fact_manufacturing_cost)
				    
	union
	
	select p.product, p.product_code,
	       m.manufacturing_cost from dim_product p
	join fact_manufacturing_cost m
	using (product_code)
	where manufacturing_cost = (select min(manufacturing_cost) 
				    from fact_manufacturing_cost)
	
	
/* Output
	+-----------------------------+---------------------------+-------------------------+
	| 	product               |	       product_code       |	Manufacturing_cost  |	
	+-----------------------------+---------------------------+-------------------------+
	|    AQ HOME Allin1 Gen 2     |	    A6120110206           |	  240.54	    |
	|  AQ Master wired x1 Ms      |     A2118150101           |          0.89           |
	+---------------+-------------------------------+-----------------------------------+*/
	
	
/* 6)Top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market */

-- Query

	select customer_code, customer,
		round(pre_invoice_discount_pct*100,2) as average_discount_percentage
	from dim_customer
	join fact_pre_invoice_deductions
	using (customer_code)
	where market = 'India' and fiscal_year=2021
	order by pre_invoice_discount_pct desc
	limit 5

/* Output
	+---------------+--------------------+-----------------+
	/    customer   /   customer_code    /  avg_dct_perc   /
	+-----------------------------------------------------+
	/    Flipkart   /    90002009        /    30.83       /
	/    Viveks     /    90002006        /    30.38       /
	/    Ezone      /    90002003        /    30.28       /
	/    Croma      /    90002002        /    30.25       /
	/    Amazon     /    90002016        /    29.33       /
	+---------------+--------------------+----------------+ */
	

-- 7)Gross sales amount for the customer “Atliq Exclusive” for each month.

-- Query

	select month(date) as month,
	       year(date) as year ,
	       round(sum(sold_quantity*gross_price),2) as gross_sales_amount 
	from fact_sales_monthly
	join fact_gross_price
	using (product_code, fiscal_year)
	join  dim_customer
	using (customer_code)
	where customer = 'Atliq Exclusive'
	group by month, year
	order by year, month
	
/* Output
	+-------+------+--------------------+
	| Month | Year | Gross_sales_Amount |
	+-------+------+--------------------+
	| 9	| 2019 |    4493259.67      |
	| 10	| 2019 |    5135902.35      |
	| 11	| 2019 |    7522892.56      |
	| 12	| 2019 |    4830404.73      |
	|  1	| 2020 |    4740600.16      |
	|  2	| 2020 |    3996227.77      |
	|  3	| 2020 |    378770.97       |
	|  4	| 2020 |    395035.35       |
	|  5	| 2020 |    783813.42       |
	|  6	| 2020 |    1695216.60      |
	|  7	| 2020 |    2551159.16      |
	|  8	| 2020 |    2786648.26      |
	|  9	| 2020 |    12353509.79     |
	| 10	| 2020 |    13218636.20     |
	| 11	| 2020 |    20464999.10     |
	| 12	| 2020 |    12944659.65     |
	|  1	| 2021 |    12399392.98     |
	|  2	| 2021 |    10129735.57     |
	|  3	| 2021 |    12144061.25     |
	|  4	| 2021 |    7311999.95      |
	|  5	| 2021 |    12150225.01     |
	|  6	| 2021 |    9824521.01      |
	|  7	| 2021 |    12092346.32     |
	|  8	| 2021 |    7178707.59      |
	+-----+--------+--------------------+
	*/	


-- 8) In which quarter of 2020, got the maximum total_sold_quantity?

-- Query 

	select  case when month(date) in (9,10,11) then 'Qtr1'
		when month(date) in(12,1,2) then 'Qtr2'
		when month(date) in(3,4,5) then 'Qtr3'
		when month(date) in(6,7,8) then 'Qtr4'
		end as Quarter, 
		sum(sold_quantity) as total_sold_quantity
	from fact_sales_monthly
	where fiscal_year = 2020
	group by Quarter
	order by total_sold_quantity desc
	
/* Output
	+---------------------------------------+
	|	Quarter     |total_sold_quantity |
	+---------------------------------------+
	|       Qtr1        |	 7005619	|
	|	Qtr2	    |	 6649642	|
	|	Qt33        |	 5042541	|
	|	Qtr4	    |	 2075087    	|
	+---------------+-----------------------+*/
	
-- 9) Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution.

-- Query
	with gross_sales as(
		select channel, 
			round((sum(m.sold_quantity*p.gross_price)/1000000),2) as gross_sales_mln
		from dim_customer c
		join fact_sales_monthly m
		using (customer_code)
		join fact_gross_price p
		using (product_code, fiscal_year)
		where fiscal_year = 2021
		group by channel)

	select *, gross_sales_mln*100/sum(gross_sales_mln) over() as percentage
	from gross_sales
	
/* Output
	+--------------------+------------------------+-----------------+
	| 	CHANNEL      |	  gross_sales_mln     |	    Percentage  |	
	+--------------------+------------------------+-----------------+
	|    Retailer	     |	 1924170397.91        |	        73.22	|
	|    Direct          |   406686873.90         |         15.47   |
	|   Distributor      |   297175879.72         |         11.31   |
	+---------------+-------------------------------+---------------+ */	

/* 10) Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?  */

-- Query
	with top_products as(
		select division, product_code, product, 
			sum(sold_quantity) as total_sold_quantity,
			rank() over(partition by division order by sum(sold_quantity) desc) as rank_order
		from dim_product
		join fact_sales_monthly 
		using (product_code)
		where fiscal_year = 2021
		group by 1,2,3)

	select * from top_products 
	where rank_order < 4
	

/* Output
	+----------+---------------------------------------------------------------------------------------+ 
	| division |     product_code    |        product	    |   total_sold_quantity   |	Rank_order |
	---------- +---------------------+--------------------------+-------------------------+------------+
	| N & S	   |    A6720160103	 |  AQ Pen Drive 2 IN 1	    |        701373	      |    1       |
	| N & S    | 	A6818160202	 |   AQ Pen Drive DRC	    |        688003	      |    2       |
	| N & S	   |    A6819160203      |	 AQ Pen Drive DRC   |        676245	      |    3       |
	+----------+---------------------+--------------------------+-------------------------+------------+
	| P & A	   |    A2319150302	 |     AQ Gamers Ms	    |        428498	      |    1       |
	| P & A	   |    A2520150501	 |     AQ Maxima Ms	    |        419865           |    2       |
	| P & A	   |    A2520150504	 |     AQ Maxima Ms	    |        419471	      |    3       |
	+----------+---------------------+--------------------------+-------------------------+------------+
	| PC	   |    A4218110202	 |       AQ Digit	    |        17434	      |    1       |
	| PC	   |    A4319110306      |     AQ Velocity	    |        17280	      |    2       |
	| PC	   |    A4218110208	 |       AQ Digit	    |        17275	      |    3       |
	+----------+---------------------+--------------------------+-------------------------+------------+
	 */	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	



