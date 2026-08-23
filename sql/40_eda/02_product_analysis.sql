
-----------------------------------------------------------------------
-- 5.5 Product Performance Analysis 

-- =====================================================
--  Top Products by Order Volume
-- =====================================================
SELECT TOP 10 [Style], [Category], COUNT(ORDER_ID) AS TOTAL_ORDERS, 
                SUM(QTY) AS TOTAL_QUANTITY
FROM AMAZONREPORT_BACKUP
GROUP BY [Style], [Category]
ORDER BY TOTAL_ORDERS DESC;
/* Observation:
-- JNE3797 (Western Dress) is the best-selling product with 4,224 orders and 3,692 units sold, significantly higher than other products
-- Top-performing products are mainly from Western Dress, Set, and Kurta categories, indicating strong customer demand for these product groups
-- Set category appears frequently among top products, suggesting it is a key contributor to sales volume
*/

-- =====================================================
--  Top Products by Revenue
-- =====================================================
SELECT TOP 10 [Style], [Category],
           SUM(Amount) AS Total_Revenue
FROM AMAZONREPORT_BACKUP
GROUP BY Style, Category
ORDER BY Total_Revenue DESC;
/* Observation:
-- JNE3797 (Western Dress) - the best-selling product also generate the highest revenue among product
- The lowest revenue generation product is JNE3405 (Kurta)
--
*/



-- ==================================================
-- 4. ORDERS BY SIZE
-- ==================================================
SELECT [Size],
    COUNT(*) AS total_orders
FROM AMAZONREPORT_BACKUP
GROUP BY [Size]
ORDER BY total_orders DESC;
/*
Observations:
-- Size M recorđe the highest order volumn, followed by Size L and Xl
-- Freesize and 4XL recorded the lowest order volumes, potentially due to 
-- lower product availability in these size 
*/

-- =====================================================
--  Average Order Value by Category
-- =====================================================
SELECT [CATEGORY],ROUND(AVG(AMOUNT),2) AS AVERAGE_ORDERVALUE
FROM AMAZONREPORT_BACKUP
WHERE STATUS <> 'Cancelled' AND Qty > 0 AND [Courier_Status] = 'Shipped'
GROUP BY [Category]
ORDER BY AVERAGE_ORDERVALUE DESC;

/*
Observations:
-- Set recorded the highest average order value (8,340.91), followed by Saree (8,020.56) and Western Dress (7,638.53).
-- Dupatta recorded the lowest average order value (3,050.00), indicating that orders containing Dupatta products generally generated lower transaction values.
-- Categories such as Set, Saree, and Western Dress tend to generate higher-value orders than other product categories.

Business Insight:  
-- Product categories with higher average order values contribute more revenue per transaction. Marketing campaigns and inventory planning should prioritize these high-value categories to maximize revenue, while lower-value categories may benefit from bundling or cross-selling strategies to increase order value.
*/

