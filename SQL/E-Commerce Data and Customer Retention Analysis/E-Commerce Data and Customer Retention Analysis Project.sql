

select * from cust_dimen

select * from orders_dimen

select * from shipping_dimen




SELECT SUBSTRING(Ord_id,5,6) Order_ID
from orders_dimen

SELECT SUBSTRING(Ship_id,5,6) Ship_ID,*
from shipping_dimen

SELECT SUBSTRING(Cust_id,6,6) Customer_ID,*
from cust_dimen



--Editing the orders_dimen table
ALTER TABLE orders_dimen
ADD Order_ID INT IDENTITY PRIMARY KEY
;
ALTER TABLE orders_dimen
DROP COLUMN Ord_id

--Editing the shipping_dimen table
ALTER TABLE shipping_dimen
ADD Ship_ID INT IDENTITY PRIMARY KEY
;

ALTER TABLE shipping_dimen
DROP COLUMN Ship_id
;
ALTER TABLE shipping_dimen ALTER COLUMN Order_ID INT NOT NULL

--Editing the cust_dimen table

ALTER TABLE cust_dimen
ADD Customer_ID INT IDENTITY PRIMARY KEY
;

ALTER TABLE cust_dimen
DROP COLUMN Cust_id

------------------------------------------------------

select * from cust_dimen


select * from orders_dimen

select * from shipping_dimen
-----

select * from market_fact

select * from prod_dimen


--- Update the market_fact table

UPDATE market_fact
SET Ord_id = SUBSTRING(Ord_id,5,6)
;

UPDATE market_fact
SET Prod_id = SUBSTRING(Prod_id,6,6)
;

UPDATE market_fact
SET Ship_id = SUBSTRING(Ship_id,5,6)
;

UPDATE market_fact
SET Cust_id = SUBSTRING(Cust_id,6,6)
;

ALTER TABLE market_fact
ALTER COLUMN Ord_id BIGINT NOT NULL
;
ALTER TABLE market_fact
ALTER COLUMN Prod_id BIGINT NOT NULL
;
ALTER TABLE market_fact
ALTER COLUMN Ship_id BIGINT NOT NULL
;
ALTER TABLE market_fact
ALTER COLUMN Cust_id BIGINT NOT NULL
;

----- prod_dimen tablosunu güncelleme
select * from prod_dimen

UPDATE prod_dimen
SET Prod_id = SUBSTRING(Prod_id,6,6)
;
ALTER TABLE prod_dimen
ALTER COLUMN Prod_id int NOT NULL;
;

ALTER TABLE prod_dimen ADD CONSTRAINT pk_prod_id PRIMARY KEY (Prod_id)

-------

ALTER TABLE market_fact ADD CONSTRAINT FK FOREIGN KEY (Order_ID) REFERENCES orders_dimen (Order_ID)

----1.Using the columns of “market_fact”, “cust_dimen”, “orders_dimen”,“prod_dimen”, “shipping_dimen”, Create a new table, named as “combined_table”.

select mf.Order_ID ,mf.Cust_ID,mf.Prod_ID,mf.Ship_ID,mf.Sales,mf.Discount,mf.Order_Quantity,mf.Product_Base_Margin,od.Order_Date,od.Order_Priority,cd.Customer_Name,cd.Province,cd.Region,cd.Customer_Segment,pd.Product_Category,pd.Product_Sub_Category,sd.Ship_Mode,sd.Ship_Date
into combined_table
from market_fact mf, cust_dimen cd, orders_dimen od, prod_dimen pd, shipping_dimen sd
where mf.Order_ID = od.Order_ID and mf.Cust_ID = cd.Cust_ID and mf.Prod_ID = pd.Prod_ID and mf.Ship_ID = sd. Ship_ID




---2. Find the top 3 customers who have the maximum count of orders.

select TOP 3 Cust_ID,Customer_Name, sum(Order_Quantity) Sum_Order_Quantity
from combined_table
group by Cust_ID,Order_Quantity,Customer_Name
order by Sum_Order_Quantity DESC

---3.. Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.

select *,DATEDIFF(DAY, Order_Date, Ship_Date) DaysTakenForDelivery
from combined_table

ALTER TABLE combined_table ADD DaysTakenForDelivery INT NULL
;

UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF(DAY, Order_Date, Ship_Date)

select * from combined_table


---4.Find the customer whose order took the maximum time to get delivered.


select top 1 Cust_ID,DaysTakenForDelivery
from combined_table
group by Cust_ID,DaysTakenForDelivery
order by DaysTakenForDelivery DESC

----5 Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011


select * from combined_table

select distinct Cust_ID
from combined_table
where Month(Order_Date) = 01
;

--Subquery
select distinct Month(Order_Date) as [Month],count(*) over(partition by Month(Order_Date)) CountOfCustomer
from combined_table
where YEAR(Order_Date) = 2011  and Cust_ID in(
											select distinct Cust_ID
											from combined_table
											where Month(Order_Date) = 01
											)
order by Month(Order_Date)


----6.Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, in ascending order by Customer ID.


select Cust_ID,Order_Date
from combined_table
order by Cust_ID,Order_Date




-----
with t1 as(
select Cust_ID,Order_Date,count(*) Over(partition by Cust_ID) OrderCountOfTheCustomers
from combined_table
)
select *, ROW_NUMBER() OVER(Partition By Cust_ID Order BY Cust_ID, Order_Date) as [Row Number]
into #MoreThanThreeOrders
from t1
where OrderCountOfTheCustomers > 3

select * from #MoreThanThreeOrders




Select Cust_ID,Order_Date as First_Date
into #First_Date
from #MoreThanThreeOrders
where  [Row Number] =1



Select Cust_ID,Order_Date as Third_Date
into #Third_Date
from #MoreThanThreeOrders
where  [Row Number] =3



select * from #MoreThanThreeOrders

-------Time between first purchase and third purchase for each user
select F.Cust_ID, DATEDIFF(DAY,First_Date,Third_Date) DateDiffOfPurchasing 
from #First_Date F, #Third_Date T
where F.Cust_ID =T.Cust_ID

-------7. Write a query that returns customers who purchased both product 11 and product 14, as well as the ratio of these products to the total number of products purchased by the customer.


select Cust_ID, Order_Quantity
into #11and14_purchased
from combined_table
where Prod_ID=14 
and Cust_ID in(
					select Cust_ID
					from combined_table
					where Prod_ID=11 )


select round (
(select sum(Order_Quantity) as sum_quantity
from #11and14_purchased) 
/ 
(select sum(Order_Quantity)
from combined_table
where Prod_ID=14 or Prod_ID=11 ), 3) as Purchased_ratio

---- Customer Segmentetion

---1.Create a “view” that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)

CREATE VIEW MONTHLY_LOG as
select Cust_ID, YEAR(Order_Date) as [Year], MONTH(Order_Date) as [Month]
from combined_table
;

select * 
from MONTHLY_LOG
order by [Year] DESC, [Month] DESC

---2.Create a “view” that keeps the n umber of monthly visits by users. (Show separately all months from the beginning business)

select * from combined_table

CREATE VIEW CountOFVisitorsForMonths as
select distinct COUNT(Cust_ID) OVER(Partition By Month(Order_Date)) CountOfVisitors, Month(Order_Date) [Months]
from combined_table

select * from CountOFVisitorsForMonths ORDER BY Months

---3.For each visit of customers, create the next month of the visit as a separate column


SELECT *
FROM
			(
			SELECT Cust_ID,Order_ID, MONTH(Order_Date) [MONTH]
			FROM combined_table
			) A
PIVOT
(
	count(Order_ID)
	FOR [MONTH] IN
	(
	[1] , [2], [3], [4],[5],[6],[7],[8],[9],[10],[11],[12]
	)
) AS PIVOT_TABLE
ORDER BY Cust_ID
;


---4. Calculate the monthly time gap between two consecutive visits by each customer.

select Cust_ID,Order_ID,Order_Date, DATEDIFF(MONTH,LAG(Order_Date,1)OVER(PARTITION BY Cust_ID ORDER BY Order_Date),Order_Date) [OrderDateDiff]
from combined_table
order by Cust_ID, Order_Date


---5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.

select distinct Order_ID,Cust_ID,Order_Date
into #OrderDate
from combined_table
order by Cust_ID, Order_Date
;
select Cust_ID,Order_ID,Order_Date,LAG(Order_Date,1)OVER(PARTITION BY Cust_ID ORDER BY Order_Date) Previous_Visit ,DATEDIFF(MONTH,LAG(Order_Date,1)OVER(PARTITION BY Cust_ID ORDER BY Order_Date),Order_Date) [OrderMonthDiff]
into #OrderDateDiff
from #OrderDate
order by Cust_ID, Order_Date
;
select * from #OrderDateDiff
;
select distinct Cust_ID,Order_Date,avg(OrderMonthDiff) OVER(Partition By Cust_ID) AVGOrderDateDiff
into #AVGOrderDateDiff
from #OrderDateDiff

select * from #AVGOrderDateDiff


--- Average Order Date Diff
select avg(AVGOrderDateDiff) avg
from #AVGOrderDateDiff

---Irregular Customer
select *
into #IrregularCustomer
from #AVGOrderDateDiff
where AVGOrderDateDiff > (select avg(AVGOrderDateDiff) 
					   from #AVGOrderDateDiff
					   ) 

;
select distinct Cust_ID from #IrregularCustomer order by Cust_ID


---- Lost Customer

select Cust_ID,Order_Date,count(Order_Date) OVER(PARTITION BY Cust_ID) CountofOrder
into #LostCustomer
from #AVGOrderDateDiff
order by Cust_ID
;

select *
into #LossCustomer
from #LostCustomer
where CountofOrder = 1
;

select distinct Cust_ID from #LossCustomer


---- Regular Customer

select distinct Cust_ID
into #RegularCustomer
from #AVGOrderDateDiff A
where AVGOrderDateDiff <= (select avg(AVGOrderDateDiff) avg
					   from #AVGOrderDateDiff
					   )


;

select distinct Cust_ID from #RegularCustomer order by Cust_ID


---Checking for intersection for IrregularCustomer

select distinct Cust_ID 
from #IrregularCustomer A
where NOT EXISTS(select 1 from #RegularCustomer B where A.Cust_ID = B.Cust_ID)
;
--- Checking for intersection for RegularCustomer
select distinct Cust_ID
from #AVGOrderDateDiff A
where AVGOrderDateDiff <= (select avg(AVGOrderDateDiff) avg
					   from #AVGOrderDateDiff
					   ) AND
	  NOT EXISTS (select 1 from #LossCustomer B where A.Cust_ID = B.Cust_ID)

----
------ Checking for intersection for LossCustomer

select distinct Cust_ID 
from #LossCustomer A
Where NOT EXISTS (select 1 from #IrregularCustomer B where A.Cust_ID = B.Cust_ID)


--- Checking from Combined Table
select distinct Cust_ID from combined_table


-----Month-Wise Retention Rate---
--There are many different variations in the calculation of Retention Rate. But we will try to calculate the month-wise retention rate in this project.
--So, we will be interested in how many of the customers in the previous month could be retained in the next month.
--Proceed step by step by creating “views”. You can use the view you got at the end of the Customer Segmentation section as a source.




---1. Find the number of customers retained month-wise. (You can use time gaps)

select distinct *, count(Cust_ID) OVER(Partition by Previous_Visit Order By Cust_ID, Previous_Visit) Retention_Month_Wise
into #RetentionMonthWise
from #OrderDateDiff
where OrderMonthDiff =1

select * from #RetentionMonthWise


---2.Calculate the month-wise retention rate

select Cust_ID,Month(Order_Date) as MonthOrder, Year(Order_Date) as YearOrder,OrderMonthDiff,
							Case WHEN OrderMonthDiff = 1 THEN 'Retained'
							END AS Retained_Number
into #OrderDateRetained
from #OrderDateDiff
;

select * from #OrderDateRetained

------

Select YearOrder,MonthOrder,Count(Cust_ID) TotalRetained
into #TotalRetained
from #OrderDateRetained
where Retained_Number = 'Retained'
Group By YearOrder,MonthOrder
;

select * from #TotalRetained order by YearOrder,MonthOrder
----
select distinct YEAR(Order_Date) Yearly, MONTH(Order_Date) Monthly, COUNT(Cust_ID) OVER(PARTITION BY YEAR(Order_Date),MONTH(Order_Date)) as MonthlyCustomer
into #YearMonthCustomer
from combined_table
group by YEAR(Order_Date), MONTH(Order_Date), Cust_ID
;

select * from #YearMonthCustomer

----

with Retained_Table as (
select A.*, B.TotalRetained, 1.0*B.TotalRetained/A.MonthlyCustomer as Retantion
From #YearMonthCustomer A, #TotalRetained B
Where A.Yearly = B.YearOrder and A.Monthly = B.MonthOrder
)
SELECT Yearly,Monthly,MonthlyCustomer,TotalRetained,CAST(Retantion AS NUMERIC(3,2)) as Retention_Rate
From Retained_Table
order by Yearly,Monthly