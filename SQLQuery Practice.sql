--DATA PREPARATION AND UNDERSTANDING

--1)What is the total number of rows in each of the table in the database?
Select
(Select COUNT([customer_Id]) from [dbo].[Customer])as Total_rows_in_Customer_table,
(Select COUNT([prod_cat_code]) from [dbo].[prod_cat_info]) as Total_rows_in_prodcat_table,
(Select COUNT([transaction_id]) from [dbo].[Transactions]) as Total_rows_in_transaction_table

--2)What is the total number of transactions that have return
Select Count([transaction_id]) as return_transactions from [dbo].[Transactions]
where [total_amt] < 0

/*3)As you would have noticed, the dates provided across a datasets are not in correct formats. As first steps,
please convert the date variables into valid date formats before proceeding aheads.*/
Alter table [dbo].[Transactions]
Alter column [tran_date] date

Alter table [dbo].[Customer]
Alter column [DOB] date

Alter table [dbo].[Transactions]
Alter column [Qty] int

Select [tran_date] from [dbo].[Transactions]
Select [DOB] from [dbo].[Customer]

/*4)What is the time range of the transaction data available for analysis? Show the Output 
in number of days, months, years simultaneously in different columns*/
Select
(Select DATEDIFF(day,min([tran_date]),MAX([tran_date])) from [dbo].[Transactions]) as [Days] ,
(Select DATEDIFF(month,min([tran_date]),MAX([tran_date])) from [dbo].[Transactions]) as Months ,
(Select DATEDIFF(year,min([tran_date]),MAX([tran_date])) from [dbo].[Transactions]) as Years

--5)Which Product Category Does the Subcategory "DIY" belog to?
Select [prod_cat] from [dbo].[prod_cat_info] where [prod_subcat] like '%DIY%'

--DATA ANALYSIS
--1)Which channel is most frequently used for transactions?
Select top 1 [Store_type] from [dbo].[Transactions]
group by [Store_type] order by COUNT([Store_type]) desc

--2)What is the count of Male and Female customers in the database?
Select distinct [Gender] , count([Gender]) as Count_of_Customers from [dbo].[Customer]
group by [Gender]

--3)From which City do we have the Maximum No.of customers and How many?
Select top 1 [city_code] , COUNT([customer_Id]) as No_of_Customers from [dbo].[Customer]
Group by [city_code]  order by COUNT([customer_Id]) desc

--4)How many sub categories are there under the Books Category?
Select [prod_cat] , Count([prod_subcat]) as No_of_Subcat from [dbo].[prod_cat_info]
where [prod_cat] = 'Books' group by [prod_cat]

--5)What is the maximum quantity of product ever ordered?
Select p.[prod_cat] , max(t.[Qty]) AS max_quantity from [dbo].[prod_cat_info] as p 
join [dbo].[Transactions] as t on t.prod_cat_code = p.prod_cat_code and p.prod_sub_cat_code = t.prod_subcat_code
Group by p.prod_cat 

--6)What is the net total revenue generated in Categories Electronics and Books?

/*Select sum(net_total_revenue) from(
Select p.prod_cat ,sum(t.[total_amt]) as net_total_revenue from [dbo].[prod_cat_info] as p 
inner join [dbo].[Transactions] as t on t.prod_cat_code= p.prod_cat_code and p.prod_sub_cat_code = t.prod_subcat_code
where p.prod_cat in ('Electronics','Books' ) 
group by p.prod_cat)x*/

Select sum(t.[total_amt]) as net_total_revenue from [dbo].[Transactions] as t join [dbo].[prod_cat_info] as p 
on p.prod_cat_code = t.prod_cat_code and p.prod_sub_cat_code = t.prod_subcat_code 
where p.prod_cat in ('Electronics','Books')

--7)How many Customers have > 10 transactions with us excluding returns?

Select Count([customer_Id]) from (
Select c.[customer_Id] from [dbo].[Customer] c join
[dbo].[Transactions] t on t.cust_id = c.customer_Id
where t.total_amt > 0 group by c.[customer_Id] having Count(distinct t.[transaction_id]) > 10) x

--8)What is the Combined revenue Earned from the "Electronics" and "Clothing" categories from Flagship stores?
Select sum(t.total_amt) as Combined_revenue from [dbo].[prod_cat_info] as p 
join [dbo].[Transactions] as t on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code = t.prod_subcat_code
where p.prod_cat in ('Electronics','Clothing') and t.Store_type = 'Flagship store'

/*9)What is the total revenue generated from "Male" Customers in "Electronics" category? 
 Output should display total revenue by product sub_category*/

 Select p.[prod_subcat], sum(t.[total_amt]) as Total_Revenue from [dbo].[Transactions] as t 
 join [dbo].[prod_cat_info] as p on t.prod_cat_code=p.prod_cat_code and p.prod_sub_cat_code = t.prod_subcat_code join [dbo].[Customer] as c 
 on c.customer_Id = t.cust_id where c.Gender = 'M' and p.prod_cat = 'Electronics'
 group by p.prod_subcat

/*10)What is the percentage of Sales and returns by product Sub_category;
display only top 5 sub_category in terms of sales*/


Select top 5 r.prod_subcat_code,r.[%_of_returns],s.[%_of_Sales] from (select t.prod_subcat_code,sum(total_amt)*100/(select sum(total_amt) from Transactions
where total_amt<0) as [%_of_returns]  from Transactions t where t.total_amt<0
group by t.prod_subcat_code) r inner join (select t.prod_subcat_code,sum(total_amt)*100/(select sum(total_amt) from Transactions
where total_amt>0) as [%_of_Sales]  from Transactions t where t.total_amt>0
group by t.prod_subcat_code) s on r.prod_subcat_code=s.prod_subcat_code
order by [%_of_Sales] desc

/*11)For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers 
in last 30 days of transaction from max transaction date available in the data?*/

Select Sum(t.[total_amt]) as Total_revenue from [dbo].[Customer] as c inner join 
[dbo].[Transactions] as t on c.[customer_Id]=t.[cust_id] 
where DATEDIFF(year,c.[DOB],(SElect max(tran_date) from [dbo].[Transactions])) between 25 and 35
and DATEDIFF(day, t.[tran_date], (select max([tran_date]) from [dbo].[Transactions])) <= 30

 /*12)Which product category has seen the maximum value of returns in the last three
 months of transactions?*/

Select p.[prod_cat], Sum(t.[total_amt]) as return_value, sum(t.Qty) return_qty from [dbo].[prod_cat_info] as p join
[dbo].[Transactions] as t on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code = t.prod_subcat_code where t.total_amt < 0 and 
Datediff(month, [tran_date], (select max([tran_date]) from [dbo].[Transactions])) <=3
group by p.prod_cat
order by Sum(t.[total_amt])

 --13)Which store type sells the maximum products; by value of sales amount and by Quantity sold 
 Select top 1 [Store_type], sum([Qty]) as Quantity_sold,Sum([total_amt]) as sales_amount from [dbo].[Transactions] 
 Group by [Store_type] order by Sum([total_amt]) desc

 --14)What are the categories for which average revenue is about the overall average.

Select p.[prod_cat], AVG(t.[total_amt]) as Avg_Revenue from [dbo].[prod_cat_info] as p left join
[dbo].[Transactions] as t on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code = t.prod_subcat_code
Group by p.prod_cat having AVG(t.[total_amt])>= ( select AVG(t.[total_amt]) from [dbo].[Transactions] as t)

 /*15)Find the average and total revenue for each sub_category for the categories which are among top5 categories in 
 terms of quantity sold*/

With Top5Cat as (
Select top 5 p.prod_cat_code ,p.[prod_cat], sum(t.[Qty]) as Quantity_sold from [dbo].[prod_cat_info] as p join [dbo].[Transactions] as t
on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code = t.prod_subcat_code group by p.prod_cat,p.prod_cat_code order by sum(t.[Qty]) desc)

Select tc.prod_cat,p.[prod_subcat], Avg(t.[total_amt]) as Average_revenue, Sum(t.[total_amt]) as Total_revenue from [dbo].[prod_cat_info] as p
join [dbo].[Transactions] as t on t.prod_cat_code = p.prod_cat_code join Top5Cat as tc on tc.prod_cat_code = p.prod_cat_code
group by p.prod_subcat, tc.prod_cat
