DROP TABLE df_orders

CREATE TABLE df_orders(
	  [order_id] int primary key
	, [order_date] date
	, [ship_mode]varchar(20)
	, [segment] varchar(20)
	, [country] varchar(20)
	, [city] varchar(20)
	, [state] varchar(20)
	, [postal_code] varchar(20)
	, [region] varchar(20)
	, [category] varchar(20)
	, [sub_category] varchar(20)
	, [product_id] varchar(20)
	, [quantity] int
	, [discount] decimal(7,2)
	, [sale_price] decimal(7,2)
	, [profit] decimal(7,2)
)

SELECT * FROM df_orders

-- Find top 10 highest revenue generating products
SELECT TOP 10 product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC

-- Find 5 highest selling products in each region
WITH cte AS(
SELECT region, product_id,SUM(sale_price) as sales
FROM df_orders
GROUP BY region, product_id
)
SELECT * FROM (
SELECT * 
, ROW_NUMBER() OVER(
PARTITION BY region 
ORDER BY sales DESC
)
AS rn
FROM cte
) A 
WHERE rn<=5


-- Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month,
SUM(sale_price) as sales
FROM df_orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY MONTH(order_date), YEAR(order_date)

-- similar results different code for doing it
WITH cte AS (
SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month,
SUM(sale_price) as sales
FROM df_orders
GROUP BY YEAR(order_date), MONTH(order_date)
	)
SELECT order_month
, SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) as sales_2022
, SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) as sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month

-- For each category which month had the highest sales
WITH cte AS (
SELECT category, format(order_date, 'yyyy-MM') AS order_year_month
, SUM(sale_price) as sales
FROM df_orders
GROUP BY category, format(order_date, 'yyyy-MM') 
--ORDER BY category, format(order_date, 'yyyy-MM') 
)
SELECT * FROM (
SELECT *
, ROW_NUMBER() OVER(PARTITION BY category
					ORDER BY sales DESC
					)
AS rn
FROM cte
) a
WHERE rn=1



-- Which sub category had the highest profit growth in comparison between 2023 and 2022
SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month,
SUM(sale_price) as sales
FROM df_orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY MONTH(order_date), YEAR(order_date)

-- similar results different code for doing it
WITH cte AS (
SELECT sub_category, YEAR(order_date) AS order_year, 
SUM(sale_price) as sales
FROM df_orders
GROUP BY sub_category, YEAR(order_date)
	)
, cte2 as (
SELECT sub_category
, SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) as sales_2022
, SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) as sales_2023
FROM cte
GROUP BY sub_category
)
SELECT TOP 1 sub_category
, (sales_2023 - sales_2022) * 100 / sales_2022 AS percentual_growth
FROM cte2
ORDER BY (sales_2023 - sales_2022) * 100 / sales_2022 DESC