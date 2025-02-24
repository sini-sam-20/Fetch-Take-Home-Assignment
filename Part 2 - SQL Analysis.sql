-- 1. What are the top 5 brands by receipts scanned among users 21 and over?

WITH users_over_21 AS (
    -- The query below is used to filter out users who are 21 years old or older
    SELECT ID 
    FROM Users 
    WHERE DATE_DIFF('year', Birth_date, CURRENT_DATE) >= 21
),  

BrandCounts AS (
    -- The query below is used to count the total number of receipts scanned for each brand
    SELECT p.Brand, 
           COUNT(t.receipt_ID) AS total_receipts

    FROM Transactions t
    JOIN users_over_21 u 
        ON t.User_ID = u.ID
    JOIN Products p   
        ON t.Barcode = p.Barcode
    GROUP BY p.Brand

)  

-- Theis final query will give you the top 5 brands by the total number of receipts scanned
SELECT Brand,
       total_receipts
FROM (
        SELECT Brand, 
            total_receipts, 
            RANK() OVER (ORDER BY total_receipts DESC) AS rnk
        FROM BrandCounts
)
WHERE rnk <= 5;


--------------------------------------------------------------------------------------------------------------------------------  
-- 2. What are the top 5 brands by sales among users that have had their account for at least six months?

WITH users_over_6_months AS (
    -- The base query below is used to filter out users who have had their account for at least 6 months
    SELECT ID 
    FROM Users 
    WHERE DATE_DIFF('month', created_date, CURRENT_DATE) >= 6
),

BrandSales AS (
    -- The query below is used to calculate the total sales for each brand
    SELECT p.Brand, 
           SUM(t.Final_sale) AS total_sales

    FROM Transactions t
    JOIN users_over_6_months u 
        ON t.User_ID = u.ID
    JOIN Products p   
        ON t.barcode = p.barcode
    GROUP BY p.BRAND

)

-- This final query will give you the top 5 brands by the total sales
SELECT Brand,
       total_sales  
FROM (
        SELECT Brand, 
            total_sales, 
            RANK() OVER (ORDER BY total_sales DESC) AS rnk
        FROM BrandSales
)
WHERE rnk <= 5;


--------------------------------------------------------------------------------------------------------------------------------     
-- 3. What is the percentage of sales in the Health & Wellness category by generation?

WITH UserGen AS (
    -- The base query below is used to categorize users into different generations
    SELECT USER_ID,  
           CASE  
               WHEN DATE_DIFF('year', Birth_date, CURRENT_DATE) >= 58 THEN 'Boomer'  
               WHEN DATE_DIFF('year', Birth_date, CURRENT_DATE) BETWEEN 42 AND 57 THEN 'Gen X'  
               WHEN DATE_DIFF('year', Birth_date, CURRENT_DATE) BETWEEN 26 AND 41 THEN 'Millennial'  
               ELSE 'Gen Z'  
           END AS Generation  
    FROM USERS
),  
SalesByGen AS (
    -- The query below is used to calculate the total sales in the Health & Wellness category for each generation
    SELECT ug.Generation, 
           SUM(t.AMOUNT) AS health_sales  

    FROM Transactions t  
    JOIN UserGen ug 
        ON t.User_ID = ug.User_ID  
    JOIN Products p 
        ON t.Barcode = p.Barcode  

    WHERE p.Category = 'Health & Wellness'  
    GROUP BY ug.Generation
)  

SELECT s.Generation,  
       health_sales,  
       ROUND(health_sales * 1.0/ SUM(health_sales) OVER (), 2) AS pct_sales  
FROM SalesByGen s  
ORDER BY pct_sales DESC;


--------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------  

-- 5. Which is the leading brand in the Dips & Salsa category?

-- Assumptions:
-- Leading Brand definition: The brand with the highest total sales revenue is considered the 'Leading Brand'. Alternatively, we could define it based on total units sold, but I'm assuming Revenue as the key metric.
-- If multiple brands have the same sales, they will be ranked equally using RANK() 
-- Consider patterns like 'Dips & Salsa' and 'Salsa & Dips' as well 
-- The query does not filter by date, meaning it considers all available sales data
-- Assumping Data completeness - no missing data/NULLs in the relevant columns

WITH base AS (
    SELECT p.Brand, 
           SUM(t.Final_sale) AS total_sales

    FROM Transactions t
    JOIN Products p 
        ON t.Barcode = p.Barcode
    WHERE LOWER(p.Category_2) LIKE '%dip%' 
            AND LOWER(p.Category_2) LIKE '%salsa%'
    GROUP BY p.Brand
),
RankedBrands AS (
    SELECT Brand, 
           total_sales, 
           RANK() OVER (ORDER BY total_sales DESC) AS sales_rank

    FROM base
)
SELECT Brand, 
       total_sales

FROM RankedBrands
WHERE sales_rank = 1;


--------------------------------------------------------------------------------------------------------------------------------  
-- 6. At what percent has Fetch grown year over year?

-- Assumptions:
-- The query calculates the YoY growth rate based on the total sales for the current year and the previous year
-- Alternatively, growth could be measured by total transactions or active users, but I'm focussing on revenue growth
-- Timeframe : Considering the last 2 full years of date
-- Assumping Data completeness - no missing data/NULLs in the relevant columns

WITH YearlySales AS (
    SELECT 
        YEAR(Purchase_Date) AS Year, 
        SUM(Final_sale) AS Total_Sales

    FROM Transactions
    WHERE Purchase_Date >= DATEADD(YEAR, -1, GETDATE())  -- Ensures we have at least 2 years of data
    GROUP BY YEAR(Transaction_Date)
),
SalesComparison AS (
    SELECT 
        MAX(CASE WHEN Year = YEAR(GETDATE()) - 1 THEN Total_Sales END) AS last_year_sales,
        MAX(CASE WHEN Year = YEAR(GETDATE()) THEN Total_Sales END) AS current_year_sales
    FROM YearlySales
)
SELECT 
    current_year_sales, 
    last_year_sales, 
    ((current_year_sales - last_year_sales) / last_year_sales) * 100 AS YoY_Growth

FROM SalesComparison;


--------------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------------------------------------------------  
