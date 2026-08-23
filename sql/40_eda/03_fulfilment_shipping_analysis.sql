
-----------------------------------------------------------------------
-- 5.4 Fulfilment and Logistics Performance

-- =====================================================
--  Shipping Success Rate 
-- =====================================================

SELECT
        Fulfilment, 
        COUNT(*) AS TOTAL_ORDERS,
        SUM(CASE WHEN [Courier_Status] = 'Shipped' THEN 1 ELSE 0 END) AS SUCCESSFUL_SHIPMENTS,
        ROUND ( 100.0 *  SUM(CASE WHEN [Courier_Status] = 'Shipped' THEN 1 ELSE 0 END) / COUNT(*), 2) AS SHIPPING_SUCCESSFULRATE
FROM AMAZONREPORT_BACKUP
GROUP BY Fulfilment

/* Observations:
-- Shipping Success Rate is defined as:
-- Shipped Courier_Status / Total Orders
*/

-- =====================================================
--  Courier Status Distribution
-- =====================================================
SELECT
    [Courier_Status],
    COUNT(*) AS TOTAL_ORDERS,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2
    ) AS ORDER_SHARE
FROM AMAZONREPORT_BACKUP
GROUP BY [Courier_Status]
ORDER BY TOTAL_ORDERS DESC;
/* Observation:
-- Shipped is the dominant Courier Status, accounting for 84,9% of all orders 
-- The majority of orders were successfully delivered
-- Not Applicable represents 5.32% of orders
-- corresponding primarily to cancelled orders that never entered the shipping process
-- 5.18% remained Unshipped, suggesting potential processing shipment
-- 4.6% of orders had a courier status of Cancelled
*/

-- =====================================================
--  Shipping Status by Fulfilment
-- =====================================================
SELECT Fulfilment, [Courier_Status], COUNT(*) AS TOTAL_ORDERS, 
ROUND (
    100.0 * COUNT(*)/ SUM(COUNT(*)) OVER (PARTITION BY [Fulfilment]),2) AS ORDER_SHARE
FROM AMAZONREPORT_BACKUP
GROUP BY  Fulfilment, [Courier_Status]
ORDER BY Fulfilment, Total_Orders DESC;
/* Observation:
-- Amazon fulfilment achieved a higher shipping completion rate with 86,52% orders reaching the Shipped Status
-- Compare with 81.17% for Merchant successful fulfilment 
-- Merchant fulfilment recorded a substantially higher proportion of Not Applicable orders (17.47%), indicating that more orders were cancelled before entering the shipping process
-- Only 11 Merchant orders (0.03%) remained classified as Unknown after data cleaning
*/

-- =====================================================
--  Shipping Status by Ship Service Level
-- =====================================================
SELECT [ship_service_level], [Courier_Status],
        COUNT(*) AS TOTAL_ORDERS, 
        ROUND(
            100.0 * COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY [ship_service_level]), 2
        ) AS ORDER_SHARE 
FROM AMAZONREPORT_BACKUP
GROUP BY [ship_service_level], [Courier_Status]
ORDER BY [ship_service_level], TOTAL_ORDERS DESC;
/* Observation:
-- Expidited shipping recorded a higher proportion of shipped order (86.55%)
-- compared with Standard Shipping (81,2%)
-- All Not Applicable were associated with Standard shipping, accounting for 17% of Standard Orders
-- Expedited shipping recorded a higher proportion of Unshipped orders (6.8%) than Standard Shipping (1.62%)
-- 'Cancelled' status accounted for 6.65% of Expidited orders but only 0.11% of Standard Orders */
