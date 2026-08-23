-----------------------------------------------------------------------
-- 5.3. Geographic Analysis 

-- =====================================================
--  Geographic Performance By State
-- =====================================================. 
SELECT Ship_State, COUNT(*) AS Total_Orders,
    SUM( CASE WHEN Status <> 'Cancelled' AND Courier_Status = 'Shipped' AND Amount > 0 THEN Amount ELSE 0 END
    ) AS Total_Revenue,     

    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders,
    ROUND(100.0 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS Cancellation_Rate,

    SUM(CASE WHEN Courier_Status = 'Shipped' THEN 1 ELSE 0 END) AS Shipped_Orders,
    ROUND(100.0 * SUM(CASE WHEN Courier_Status = 'Shipped' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS Shipping_Success_Rate

FROM AMAZONREPORT_BACKUP
WHERE Ship_State IS NOT NULL
GROUP BY Ship_State
HAVING COUNT(*) >= 500
ORDER BY Total_Orders DESC;
/* Observation:
-- Maharashtra recorded the highest order volume (22,259) and Revenue (121.25M)
-- Karnataka ranked second while mantaining a high shipping success rate (86.31%) and a low cancellation rate (12.95%)
-- Goa achieved the highest shipping success rate (87.51%) and the lowest cancellation rate (11.43%) among states with at least 500 orders
-- Himachal Pradesh (18.53%), Kerala (17.83%), and Jammu & Kashmir (16.95%) recorded the highest cancellation rates and comparatively lower shipping success rates
-- Overall, lower cancellation rates were generally associated with higher shipping success rates
*/
