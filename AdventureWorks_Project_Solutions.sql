
-- Q0 :UNION OF TWO FACT TABLES --

CREATE DATABASE AdventureWorks;
use  AdventureWorks;

CREATE DATABASE AdventureWorks;
USE AdventureWorks;

SELECT COUNT(*) AS TotalRows
FROM FactInternetSales;

USE adventureworks;

SELECT COUNT(*) AS NewSalesRows
FROM fact_internet_sales_new;

DESC factinternetsales;

DESC fact_internet_sales_new;

SELECT COUNT(*) AS ColumnCount
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'adventureworks'
  AND TABLE_NAME = 'factinternetsales';

SELECT COUNT(*) AS ColumnCount
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'adventureworks'
  AND TABLE_NAME = 'factinternetsales_new';
  
  USE adventureworks;

SELECT *
FROM factinternetsales

UNION ALL

SELECT *
FROM fact_internet_sales_new;

CREATE TABLE Fact_Internet_Sales_Union AS
SELECT *
FROM factinternetsales

UNION ALL

SELECT *
FROM fact_internet_sales_new;

SELECT COUNT(*) AS TotalRows
FROM Fact_Internet_Sales_Union;


#Q-1 :

DESC DimProduct;

SELECT S.SALESORDERNUMBER, S.PRODUCTKEY, D.ENGLISHPRODUCTNAME AS PRODUCTNAME,
S.ORDERQUANTITY, S.UNITPRICE FROM FACT_INTERNET_SALES_UNION S LEFT JOIN DIMPRODUCT D 
ON S.PRODUCTKEY = D.PRODUCTKEY;


/*CREATE TABLE Sales_all AS
SELECT *
FROM fact_internet_sales_union;

SELECT COUNT(*) AS TotalRows
FROM Sales_all;
*/


-- Q-2:Customer Full Name and Unit Price Lookup--
SELECT concat_ws(' ',firstname,middlename,lastname) as Fullname, s.UnitPrice as unitprice 
FROM Sales_all as  s LEFT JOIN dimCustomer as  c
ON s.CustomerKey = c.CustomerKey
LEFT JOIN dimProduct as p
ON s.ProductKey = p.ProductKey;

 
-- Q-3 :Creating Date and Financial Date Fields-- 
SELECT
    T.*,
    YEAR(T.ORDERDATE_ACTUAL) AS YEAR,
    MONTH(T.ORDERDATE_ACTUAL) AS MONTHNO,
    MONTHNAME(T.ORDERDATE_ACTUAL) AS MONTHFULLNAME,
    CONCAT('Q', QUARTER(T.ORDERDATE_ACTUAL)) AS QUARTER,
    DATE_FORMAT(T.ORDERDATE_ACTUAL, '%Y-%b') AS YEARMONTH,
    DAYOFWEEK(T.ORDERDATE_ACTUAL) AS WEEKDAYNO,
    DAYNAME(T.ORDERDATE_ACTUAL) AS WEEKDAYNAME,

    MOD(MONTH(T.ORDERDATE_ACTUAL) - 7 + 12, 12) + 1
        AS FINANCIALMONTH,

    CONCAT(
        'FQ',
        CEIL(
            (MOD(MONTH(T.ORDERDATE_ACTUAL) - 7 + 12, 12) + 1) / 3
        )
    ) AS FINANCIALQUARTER

FROM (
    SELECT
        S.*,
        STR_TO_DATE(
            S.ORDERDATEKEY,
            '%Y%m%d'
        ) AS ORDERDATE_ACTUAL
    FROM FACT_INTERNET_SALES_UNION S
) T;

 -- Q-4:Calculate Sales Amount --
SELECT 
    S.*,
    D.ENGLISHPRODUCTNAME AS PRODUCTNAME,
    (S.UNITPRICE * S.ORDERQUANTITY * (1 - S.UNITPRICEDISCOUNTPCT)) AS CALCULATED_SALESAMOUNT
FROM FACT_INTERNET_SALES_UNION S
JOIN DIMPRODUCT D 
    ON S.PRODUCTKEY = D.PRODUCTKEY;

-- Q-5 :Calculate Production Cost------
SELECT 
    S.*,
    (D.STANDARDCOST * S.ORDERQUANTITY) AS CALCULATED_PRODUCTIONCOST
FROM FACT_INTERNET_SALES_UNION S
JOIN DIMPRODUCT D 
    ON S.PRODUCTKEY = D.PRODUCTKEY;
    
-- Q6:Calculate Profit ----

SELECT S.*,(S.UNITPRICE * S.ORDERQUANTITY * (1 - S.UNITPRICEDISCOUNTPCT)) AS CALCULATED_SALESAMOUNT,
(D.STANDARDCOST * S.ORDERQUANTITY) AS CALCULATED_PRODUCTIONCOST,
((S.UNITPRICE * S.ORDERQUANTITY * (1 - S.UNITPRICEDISCOUNTPCT)) - (D.STANDARDCOST * S.ORDERQUANTITY)) 
AS CALCULATED_PROFIT
FROM FACT_INTERNET_SALES_UNION S JOIN DIMPRODUCT D ON S.PRODUCTKEY = D.PRODUCTKEY;
  
  
  -- Q7: Monthwise Sales with Year

SELECT
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS YEAR,
    MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MONTHNO,
    MONTHNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MONTHFULLNAME,
    ROUND(
        SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)) / 1000,
        0
    ) AS SALESAMOUNT_K
FROM sales_all
GROUP BY
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')),
    MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')),
    MONTHNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d'))
ORDER BY
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')),
    MONTHNO;

-- Q8:Yearwise Sales--
select year(orderdatekey)Order_year, round(sum(salesamount),0) Total_sales from sales_all
group by Order_year order by Order_year;

-- Q9:Monthwise sales --
SELECT
    MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MONTHNO,
    MONTHNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MONTHFULLNAME,
    ROUND(SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)), 0) AS SALESAMOUNT
FROM sales_all
GROUP BY
    MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')),
    MONTHNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d'))
ORDER BY MONTHNO;

-- Q10:Quarterwise sales --

SELECT
    CONCAT('Q', QuarterNo) AS QUARTER,
    ROUND(SalesAmount / 1000, 0) AS SALESAMOUNT_K
FROM
(
    SELECT
        QUARTER(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS QuarterNo,
        SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)) AS SalesAmount
    FROM sales_all
    GROUP BY QUARTER(STR_TO_DATE(OrderDateKey, '%Y%m%d'))
) AS Q
ORDER BY QuarterNo;


#Q - 11:
SELECT S.SALESORDERNUMBER, S.PRODUCTKEY, D.ENGLISHPRODUCTNAME AS PRODUCTNAME,
(S.UNITPRICE * S.ORDERQUANTITY * (1 - S.UNITPRICEDISCOUNTPCT)) AS CALCULATED_SALESAMOUNT,
(D.STANDARDCOST * S.ORDERQUANTITY) AS CALCULATED_PRODUCTIONCOST
FROM FACT_INTERNET_SALES_UNION S JOIN DIMPRODUCT D ON S.PRODUCTKEY = D.PRODUCTKEY;






-------------------------------------------------------------------------------------------------------
