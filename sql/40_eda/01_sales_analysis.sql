
-----------------------------------------------------------------------
-- EXECUTIVE SUMMARY (OVERALL KPI)
--- Total Orders
--- Revenue 
--- Cancelled Orders 
--- Shipping Success Rate 
--- Average Order Value 
-----------------------------------------------------------------------
SELECT COUNT(ORDER_ID) AS TOTAL_ORDER,
        SUM(CASE WHEN [Courier_Status] = 'Shipped' AND AMOUNT > 0 THEN Amount ELSE 0 END) AS TOTAL_REVENUE,
        SUM(CASE WHEN [Status] = 'Cancelled' THEN 1 ELSE 0 END) AS CANCELLED_ORDER,
        ROUND (100.0* SUM(CASE WHEN [Courier_Status] = 'Shipped' THEN 1 ELSE 0 END)/COUNT(*),2) AS SHIPPING_SUCCESS_RATE,
        ROUND( AVG(CASE WHEN [Courier_Status] = 'Shipped' AND Amount > 0 THEN AMOUNT END),2) AS AVERAGE_ORDER_VALUE
FROM AMAZONREPORT_BACKUP
/* Executive Summary:
-- The dataset consists of 128,969 orders, generating 710.56M in revenue from successfully shipped orders.
-- Overall, 18,329 orders were cancelled, resulting in a cancellation rate of 14.21%
-- The shipping success rate reached 84.89%, indicating that the majority of orders were successfully fulfilled.
-- The average order value (AOV) was 6,630.40 per successfully shipped order.
*/

-----------------------------------------------------------------------
-- 5.1 Order Distribution

-- Orders by Category
-- Objective: Analyze the distribution of customer orders across product categories
-- to identify the best-selling product groups.
-- =====================================================
SELECT [Category], COUNT(Order_ID) AS Total_Orders
FROM AMAZONREPORT_BACKUP
GROUP BY [Category]
ORDER BY [Total_Orders] DESC;
/* Observation: 
-- Set recorded the highest number of orders (50,281), closely followed by Kurta (49,874).
-- Together, these two categories account for the majority of customer orders,
-- indicating that customer demand is highly concentrated in these product groups.
-- In contrast, Dupatta, Saree, and Bottom generated relatively few orders, suggesting lower market demand.

-- Business Insight:
-- Set and Kurta dominate sales performance and should be prioritized for
-- inventory planning and marketing efforts. Lower-performing categories require further evaluation.
*/ 

-- =====================================================
-- Orders by Size
-- Objective: Analyze the distribution of customer orders across product size 
-- to identify the best-selling product size
-- =====================================================
SELECT [Size], COUNT(Order_ID)
FROM AMAZONREPORT_BACKUP
GROUP BY [Size]
ORDER BY COUNT(Order_ID) DESC;
/*-- Observation:
-- M size recorded the highest number of orders (22,709), followed by L (22,130)
-- and XL (20,875). These three sizes represent the majority of customer demand.
-- In contrast, 4XL, 5XL, 6XL, and Free sizes recorded significantly fewer orders.

-- Business Insight:
-- Inventory planning should prioritize M, L, and XL sizes due to their strong
-- customer demand. Lower-demand sizes should be monitored carefully to avoid overstocking.
*/

-- =====================================================
-- Orders by State
-- Objective: Analyze the distribution of customer orders across shipping states
-- to identify the regions with the highest order volume.
-- =====================================================
SELECT [Ship_State], COUNT(Order_ID) AS Total_Orders
FROM AMAZONREPORT_BACKUP
GROUP BY [Ship_State]
ORDER BY COUNT(Order_ID) DESC;
/*-- Observation:
-- Maharashtra has the highest order volume with 22,259 orders,
-- followed by Karnataka and Tamil Nadu.
-- This indicates that customer demand is concentrated in major
-- Indian states with larger populations and urban markets
*/

-----------------------------------------------------------------------
-- 5.2 Revenue Analysis

-- =====================================================
-- Revenue by Category
-- Objective: Identify product categories generating the highest revenue.
-- =====================================================
SELECT 
    Category,
    SUM(Amount) AS Total_Revenue
FROM AMAZONREPORT_BACKUP
WHERE [Status] <> 'Cancelled' AND [COURIER_STATUS] = 'Shipped'
GROUP BY Category
ORDER BY Total_Revenue DESC;
/* Observations: 
-- Set recorded highest and exceptional high revenue generated among categories with (354.38M), followed by Kurta(192.7M) and Western Dress(100.8M)
-- While Duppata (9150) and Saree (1.15M) recorded respectively the lowest revenue generation category 
--
*/

-- =====================================================
-- Revenue by State
-- Objective: Identify geographic regions generating the highest revenue.
-- =====================================================

SELECT 
    Ship_State,
    SUM(Amount) AS Total_Revenue
FROM AMAZONREPORT_BACKUP
WHERE [Status] <> 'Cancelled' AND [COURIER_STATUS] = 'Shipped'
GROUP BY Ship_State
ORDER BY Total_Revenue DESC;

-- =====================================================
-- Revenue by Size
-- Objective: Analyze revenue contribution from different product sizes.
-- =====================================================
SELECT 
    Size,
    SUM(Amount) AS Total_Revenue
FROM AMAZONREPORT_BACKUP
WHERE [Status] <> 'Cancelled' AND [COURIER_STATUS] = 'Shipped'
GROUP BY [Size]
ORDER BY Total_Revenue DESC;
/* Observations: 
-- Size M generated the highest revenue (124,924), followed by size L (119,587) and size XL (112,620).
-- These results indicate that medium and large sizes contribute the most to overall sales revenue.
-- Free Size generated the lowest revenue, likely because fewer products are offered in this size.
-- Larger sizes such as 4XL, 5XL, and 6XL also generated relatively low revenue, suggesting lower customer demand or more limited product availability.
*/  

-- =====================================================
-- Revenue by Month
-- Objective: Analyze monthly revenue trends over time.
-- =====================================================
SELECT YEAR(Date) AS Sale_Year, MONTH(Date) AS Sale_Month, SUM(Amount) AS REVENUE_BYMONTH
FROM AMAZONREPORT_BACKUP
WHERE [Status] <> 'Cancelled' AND [COURIER_STATUS] = 'Shipped'
GROUP BY YEAR(Date), MONTH(Date)
Order BY  Sale_Year, Sale_Month
/* Observations: 
-- Revenue peaked in 04/2022, reaching 262.3M
-- Revenue declined gradually after April, decreasing to 239.5M in May and 207.8M in June
-- March recorded significant lower revenue as the dataset only cover the last day of the month
*/    

-- =====================================================
-- Revenue by Date (Top 10 highest)
-- Objective: Identify the days generating the highest revenue.
-- =====================================================
SELECT TOP 10
         [DATE] AS Sale_Date, SUM(Amount) As Total_Revenue 
    FROM AMAZONREPORT_BACKUP
    WHERE [Status] <> 'Cancelled' AND [COURIER_STATUS] = 'Shipped'
    GROUP BY [Date]
    ORDER BY Total_Revenue DESC;
/* Observations: 
-- The highest revenue was recorded on 04 May, reaching approximately 11.05M
-- The top 10 highest revenue days was concentrated between April and early May 2022
-- Daily revenue among the top 10 range from 9.2M to 11.05M
*/   


-- =====================================================
-- Revenue by Fulfilment
-- Objective: Compare revenue generated by different fulfilment methods
-- =====================================================
SELECT [Fulfilment], SUM(Amount) AS TotalRevenue_ByFulfilment
FROM AMAZONREPORT_BACKUP
WHERE [Status] <> 'Cancelled' AND [COURIER_STATUS] = 'Shipped'
GROUP BY [Fulfilment]
ORDER BY TotalRevenue_ByFulfilment DESC;
/* Observations:
-- Amazon generates 503,2M, significantly higher than Merchant at 207,26M 
-- Amazon-managed fulfilment contributed the majority of total revenue, indicating stronger sales performance compared with merchant-fulfilled orders
*/

-- =====================================================
-- Revenue by Sales Channel
-- Objective: Compare revenue generated by different Sales Channels
-- =====================================================
SELECT [Sales_Channel], SUM(Amount) AS TotalRevenue_BySalesChannel
FROM AMAZONREPORT_BACKUP
WHERE [Status] <> 'Cancelled' AND [COURIER_STATUS] = 'Shipped'
GROUP BY [Sales_Channel]
ORDER BY TotalRevenue_BySalesChannel DESC;
/* Observation:
- Amazon.in represents the dominant sales channel with significantly higher transaction volume.
- Revenue comparison by Sales Channel is therefore mainly based on Amazon.in transactions with valid revenue values. */

-- =====================================================
-- Revenue by Customer Segment
-- Objective: Compare revenue generated by customer segment
-- Note: -- B2B is a Boolean field:
        --0 = B2C (individual customers)
        -- 1 = B2B (business customers)
        -- NULL indicates missing customer segment information
-- =====================================================
WITH REVENUE_BYSEGMENT AS (
    SELECT CASE WHEN B2B = 0 THEN 'B2C'
                WHEN B2B = 1 THEN 'B2B'
                ELSE 'UNKNOWN'
                END AS CUSTOMER_SEGMENT,
            SUM(AMOUNT) AS TOTAL_REVENUE 
    FROM AMAZONREPORT_BACKUP
    WHERE [Status] <> 'Cancelled' AND [COURIER_STATUS] = 'Shipped'
    GROUP BY CASE WHEN B2B = 0 THEN 'B2C'
                WHEN B2B = 1 THEN 'B2B'
                ELSE 'UNKNOWN'
                END
)

SELECT CUSTOMER_SEGMENT, TOTAL_REVENUE,
       ROUND(TOTAL_REVENUE/(
       SELECT SUM(TOTAL_REVENUE)
       FROM REVENUE_BYSEGMENT)*100.0, 3) AS REVENUE_CONTRIBUTION
FROM REVENUE_BYSEGMENT 
ORDER BY REVENUE_CONTRIBUTION DESC;
/* Observation:
-- B2C is the primary of revenue segment, contributing approximately 99,2% of total revenue 
-- The B2B segment only account for 0,78% of total revenue
-- A small proportion of records are classified as 'UNKNOWN' due to missing values and data quality 
-- 'UNKNOWN' contributed only arounf 0.005% of total revenue, so their impact on the overall is negligible 
*/

-- =====================================================
-- Running Revenue
-- Objective: 
-- =====================================================
WITH DAILYREVENUE AS (
    SELECT [DATE], SUM(AMOUNT) AS DAILY_REVENUE
    FROM AMAZONREPORT_BACKUP
    WHERE [Courier_Status] = 'Shipped'
    GROUP BY Date
)
SELECT [DATE], DAILY_REVENUE, SUM(DAILY_REVENUE) OVER(ORDER BY DATE) AS RUNNING_REVENUE
FROM DAILYREVENUE
/* Observation:
-- Cumulative revenue increasedd form 0.95M on 31 March to 710.56M by 29 June 2022
*/

