SELECT *
  FROM [walmart].[dbo].[WalmartSalesData#csv$]

  select 
  FORMAT(CAST(Time AS DATETIME), 'HH:mm:ss')
  from [dbo].[WalmartSalesData#csv$]
-- -------------------------- edit column time ----------------------------------
  UPDATE [dbo].[WalmartSalesData#csv$]
SET Time = FORMAT(CAST(Time AS DATETIME), 'HH:mm:ss')

ALTER TABLE [dbo].[WalmartSalesData#csv$]
ALTER COLUMN Time TIME;
-- -------------------------------------------------------------------------------
-- add new column to the dataset (time of day : 00 - 12 morning, 12:01 - 16:00 afternoon, else evening)
Alter table [dbo].[WalmartSalesData#csv$] add timeOfDay varchar(50)
update [dbo].[WalmartSalesData#csv$]
set timeofday = ( case 
					when [time] between '00:00:00' and '12:00:00' then 'morning'
					when [time] between '12:01:00' and '16:00:00' then 'afternoon'
					else 'evening'
					END)

-- -------------------------------------------------------------------------------
-- add new column to contain the day name ----------------------------------------

Alter table [dbo].[WalmartSalesData#csv$] add day_name varchar(50)
update [dbo].[WalmartSalesData#csv$]
set day_name = DATENAME(weekday, [date]);

----------------------------------------------------------------------------------
-- add new column to contain month name
Alter table [dbo].[WalmartSalesData#csv$] add month_name varchar(50)
update [dbo].[WalmartSalesData#csv$]
set month_name = DATENAME(month, [date]);
-- -------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------ Generic Questions -----------------------------------------------------------------
-- First Q: How many unique cities does the data have?
select distinct(city)
from [dbo].[WalmartSalesData#csv$] -- three cities

-- Second Q: In which city is each branch?
select city, branch
from [dbo].[WalmartSalesData#csv$]
group by City, branch

select distinct city , branch 
from [dbo].[WalmartSalesData#csv$]
-- ----------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------Product -------------------------------------------------------------------------
-- first Q: How many unique product lines does the data have?
select distinct ([Product line])
from [dbo].[WalmartSalesData#csv$] -- 6 product lines 
-- second Q: What is the most common payment method
select payment, count(payment) as commonPayments
from [dbo].[WalmartSalesData#csv$]
group by payment -- Ewallet 
order by commonPayments desc
-- third Q: What is the most selling product line?
select [product line], count([product line]) as mostSelling
from [dbo].[WalmartSalesData#csv$]
group by [Product line]
order by mostSelling desc -- fash ion accessories
-- fourth Q: What is the total revenue by month

select sum(total) as totalRevenue , month_name
from [dbo].[WalmartSalesData#csv$]
group by month_name

-- Fifth Q: What month had the largest COGS 

select top(1) sum(cogs) as COGS , month_name
from [dbo].[WalmartSalesData#csv$]
group by month_name 
order by COGS desc

-- sixth Q: What product line had the largest revenue?

select [product line], sum(total) as TotalRevenue
from [dbo].[WalmartSalesData#csv$]
group by [product line]
order by TotalRevenue desc

-- seventh Q: What is the city with the largest revenue?

select sum(total) as TotalRevenue, city 
from [dbo].[WalmartSalesData#csv$]
group by city
order by TotalRevenue desc

-- eighth Q: What product line had the largest VAT?

select [product line], round( avg([Tax 5%]),1) as AverageTax
from [dbo].[WalmartSalesData#csv$]
group by [Product line]
order by AverageTax desc 

-- ninth Q: Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

select p1.[product line], p1.totalsales,
	case when p1.totalsales > p2.avgsales then 'good'
		 when p1.totalsales < p2.Avgsales then 'bad' 
		 else 'equal' END
    from ( select [product line], sum(total) as totalsales
			from [dbo].[WalmartSalesData#csv$]
			group by [product line]) p1
join (select avg(total) as Avgsales from [dbo].[WalmartSalesData#csv$] ) p2 on 1=1 


-- tenth Q: Which branch sold more products than average product sold?

	select branch, sum(quantity) as QTY 
	from [dbo].[WalmartSalesData#csv$]
	group by branch 
	having sum(Quantity) > (select avg(quantity) from [dbo].[WalmartSalesData#csv$])


	-- eleventh Q: What is the most common product line by gender?
	select gender, [product line], count (gender) as total_cnt 
	from [dbo].[WalmartSalesData#csv$]
	group by gender, [product line]
	order by total_cnt desc

	--Q12: What is the average rating of each product line?

	select avg(rating) as Avg_rating, [product line]
	from [dbo].[WalmartSalesData#csv$]
	group by [product line]
	order by Avg_rating desc
   -- ---------------------------------------------------------------------------------------------------------------------------------------
	-- ---------------------------------------------------- Sales ----------------------------------------------------------------------------
	--Q1: Number of sales made in each time of the day per weekday?

	select timeofday, count (*) as countSales
	from [dbo].[WalmartSalesData#csv$]
	group by timeOfDay
	order by countsales desc


   -- Q2:Which of the customer types brings the most revenue?

   select [Customer type], sum(total) as totalRevenue 
   from [dbo].[WalmartSalesData#csv$]
   group by [Customer type]
   order by totalRevenue desc


   -- Q3: Which city has the largest tax percent/ VAT (Value Added Tax)?  VAT = 5% * COGS
   select city,
   round(avg([Tax 5%]),2) as VAT
   from [dbo].[WalmartSalesData#csv$]
   group by city
   order by VAT desc

   -- Q4: Which customer type pays the most in VAT?
select [Customer type],
   round(avg([Tax 5%]),2) as VAT
   from [dbo].[WalmartSalesData#csv$]
   group by [Customer type]
   order by VAT desc   
	-- ------------------------------------------------------------------------------------------------------------------
	-- ---------------------------------------- customer ----------------------------------------------------------------
	-- Q1: How many unique customer types does the data have? --2
	-- Q2: How many unique payment methods does the data have? --3
	select distinct ([Customer type]), ( payment)
	from [dbo].[WalmartSalesData#csv$]

	-- Q3: What is the most common customer type?
	select ([Customer type]), count(([Customer type])) countofCustomers
	from [dbo].[WalmartSalesData#csv$]
	group by [Customer type]
	order by countofCustomers desc

	--Q4: Which customer type buys the most? quantity & total 
	select ([Customer type]), count((Quantity)) as Quantity , sum(total) as Totalmoney
	from [dbo].[WalmartSalesData#csv$]
	group by [Customer type]
	order by Totalmoney desc

	-- Q5: What is the gender of most of the customers?
	select (gender), count((gender)) as Customersbygender 
	from [dbo].[WalmartSalesData#csv$]
	group by gender
	order by Customersbygender  desc

	-- Q6: What is the gender distribution per branch?
	SELECT branch, gender, COUNT(gender) AS CustomerCount
	FROM [dbo].[WalmartSalesData#csv$]
	GROUP BY branch, gender
	--ORDER BY CustomerCount DESC;

	--Q7: Which time of the day do customers give most ratings?
	select timeofday, round(avg(rating),2) as Rating
	from [dbo].[WalmartSalesData#csv$]
	GROUP BY timeOfDay
	ORDER BY Rating DESC;

	--Q8: Which time of the day do customers give most ratings per branch?
	select timeofday, Branch, round(avg(rating),2) as Rating
	from [dbo].[WalmartSalesData#csv$]
	GROUP BY timeOfDay, Branch
	ORDER BY Rating DESC;

	--Q9: Which day fo the week has the best avg ratings?

	select day_name, round(avg(rating),2) as Rating
	from [dbo].[WalmartSalesData#csv$]
	GROUP BY  day_name
	ORDER BY Rating DESC;

	-- Q10: Which day of the week has the best average ratings per branch?

	select day_name, Branch, round(avg(rating),2) as Rating
	from [dbo].[WalmartSalesData#csv$]
	GROUP BY day_name, Branch
	ORDER BY Rating DESC;


	
