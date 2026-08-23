
-----------------------------------------------------------------------
-- 5.2 Cancellation Analysis

-- =====================================================
-- Overall Cancellation Performance
-- Objective: Measure the overall order cancellation rate
-- =====================================================
SELECT COUNT (*) AS TOTAL_ORDERS,
        SUM(CASE WHEN [Status] = 'Cancelled' THEN 1
              ELSE 0
              END) AS CANCELLED_ORDER,
        ROUND(
            100.0* SUM(CASE WHEN [Status] = 'Cancelled' THEN 1 
            ELSE 0 
            END)/COUNT(*),3) AS CANCELLATION_RATE
FROM AMAZONREPORT_BACKUP
/* Observation:
-- Out of 128,969 orders, 18,327 were cancelled, resulting in an overall cancellation rate of 14.21%
-- Approximately 1 in every 7 orders was cancelled, representing a significant proportion of total orders 
*/

-- =====================================================
-- Cancellation by Size
-- =====================================================
SELECT [Size],
    COUNT(Order_ID) AS Total_Orders,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders,
    CAST( SUM(CASE 
                WHEN Status = 'Cancelled' THEN 1
                ELSE 0 
            END) * 100.0 / COUNT(Order_ID)
        AS DECIMAL(5,2)
    ) AS Cancellation_Rate
FROM AMAZONREPORT_BACKUP
GROUP BY Size
ORDER BY Cancellation_Rate DESC;
/* Observation:
-- Size XS recorded the highest cancellation rate (16,7%). followed by Size S (15.17%) and M (14,86%)
*/

-- =====================================================
-- Cancellation by Category  
-- =====================================================
SELECT [Category], SUM(CASE WHEN [Status] ='Cancelled' THEN 1 ELSE 0 END ) As Cancelled_Orders,
    ROUND(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) *100.0/COUNT(*), 2) As Cancellation_Rate
FROM AMAZONREPORT_BACKUP
GROUP BY [Category]
ORDER BY Cancellation_Rate DESC;
-- Set, kurta remained the highest cancellation rate among Category

-- =====================================================
-- Cancellation by State 
-- =====================================================
SELECT [Ship_state],COUNT(*) AS Total_Orders, SUM(CASE WHEN [Status] ='Cancelled' THEN 1 ELSE 0 END ) As Cancelled_Orders,
        ROUND(100.0*SUM(CASE WHEN [Status] ='Cancelled' THEN 1 ELSE 0 END )/COUNT(*),2) AS Cancellation_Rate
FROM AMAZONREPORT_BACKUP
GROUP BY [Ship_State]
HAVING COUNT(*) >= 500
ORDER BY Cancellation_Rate DESC;

-- =====================================================
-- Cancellation by Fulfilment
-- =====================================================
SELECT [Fulfilment], Count(*) AS TOTAL_ORDER,
        SUM(CASE WHEN [Status] = 'Cancelled' THEN 1 END) AS CANCELLED_ORDER,
        ROUND(100.0* 
        SUM (CASE WHEN [Status] = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS CANCELLATION_RATE
FROM AMAZONREPORT_BACKUP
GROUP BY [Fulfilment]
/* Observation:
-- Amazon handled the majority of orders (89,962), while Merchant handled 39,277 orders 
-- Merchant had a higher cancellation rate (17,4%) than Amazon(12,79%)
-- Merchant indicating a greater likelihood of order cancellations despite its lower order volume 
-- This indicates that orders fulfilled by merchants were more likely to be cancelled 
*/


-- =====================================================
-- Cancellation by Shipping Service Level
-- =====================================================
SELECT [Ship_service_level], COUNT(*) AS TOTAL_ORDERS,
        SUM(CASE WHEN [Status] = 'Cancelled' THEN 1 ELSE 0 END) AS TOTAL_CANCELLED_ORDER,
        ROUND (100.0*
        SUM(CASE WHEN [Status] = 'Cancelled' THEN 1 ELSE 0 END)/COUNT(*),2) AS CANCELLATION_RATE
FROM AMAZONREPORT_BACKUP
GROUP BY [Ship_service_level]
/* Observation:
-- Expedited shipping handled the majority of orders (88,609) but had a lower cancellation rate (12.89%)
-- Standard shipping processed fewer orders (40,360) but recorded a higher cancellation rate (17.12%)
-- This indicates that Standard shipping orders were more likely to be cancelled than Expedited shipping orders
*/

-- =====================================================
-- Cancellation by Sales Channel
-- =====================================================
SELECT [Sales_Channel], Count(*) AS TOTAL_ORDERS,
    SUM(CASE WHEN [Status] = 'Cancelled' THEN 1 ELSE 0 END) AS CANCELLED_ORDER,
    ROUND(100.0*
          SUM(CASE WHEN [Status] = 'Cancelled' THEN 1 ELSE 0 END)/COUNT(*),2) AS CANCELLATION_ORDERS
FROM AMAZONREPORT_BACKUP
GROUP BY [Sales_Channel]
/* Observation:
-- Amazon.in dominates sales volume with 128,845 orders, compared with only 124 Non-Amazon orders.
-- Amazon.in had more cancellations (18,328) due to its larger order volume.
-- Non-Amazon recorded a lower cancellation rate, but the result is not statistically reliable for comparison because the segment contains only 124 orders
*/

-- =====================================================
-- Cancellation by B2B
-- =====================================================
WITH CANCELLATION_CTE AS (
        SELECT CASE WHEN[B2B] = 0 THEN 'B2C' 
                WHEN [B2B] = 1 THEN 'B2B' 
                ELSE 'UNKNOWN'
                END AS CUSTOMER_SEGMENT, [STATUS]
        FROM AMAZONREPORT_BACKUP)

SELECT CUSTOMER_SEGMENT, COUNT(*) AS TOTAL_ORDER, 
        ROUND(100.0 * COUNT(*)/
        (SELECT COUNT(*)
        FROM AMAZONREPORT_BACKUP),2) AS ORDER_SHARE,
        SUM(CASE WHEN [STATUS] = 'Cancelled' THEN 1 ELSE 0 END) AS CANCELLED_ORDER,
        ROUND(100.0*SUM(CASE WHEN [STATUS] = 'Cancelled' THEN 1 ELSE 0 END)/COUNT(*),2) AS CANCELLATION_RATE
FROM CANCELLATION_CTE
GROUP BY CUSTOMER_SEGMENT
ORDER BY CANCELLATION_RATE DESC;
/* Observation:
-- The B2C segment accounted for 99.32% of all orders and recorded a cancellation rate of 14.25%, reflecting both its dominant order volume and a relatively high number of cancelled transactions.
-- The B2B segment represented only 0.68% of total orders but had a high cancellation rate of 8.38%, indicating better order retention than the B2C segment.
*/


-- =====================================================
-- Lost Revenue from Cancellation
-- =====================================================
SELECT SUM(Amount) AS Lost_Revenue
FROM AMAZONREPORT_BACKUP
WHERE Status = 'Cancelled' AND Amount IS NOT NULL;;
/* Observation:
-- The observed lost revenue represents the total recorded Amount from cancelled orders with available revenue values. Cancelled orders with missing Amount are excluded from this calculation
*/

-- =====================================================
-- Cancellation Over time
-- =====================================================

SELECT YEAR(Date) AS [Year],
    MONTH(Date) AS [Month],
    COUNT(*) AS Cancelled_Orders
FROM AMAZONREPORT_BACKUP
WHERE Status = 'Cancelled'
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY [Year], [Month];
/* Observation:
-- April recorded the highest number of cancelled orders, while cancellations showed a downward trend in the following months.
*/
