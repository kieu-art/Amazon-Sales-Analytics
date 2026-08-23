-----------------------------------------------------------------------
-- Detect and Remove Duplicate Records
-----------------------------------------------------------------------
WITH DUPLICATE_CTE  AS (
    SELECT *, COUNT (*) OVER (PARTITION BY 
                                [Order_ID],
                                [Date],
                                [Status],
                                [Sales_Channel],
                                [Style],
                                [SKU],
                                [Category],
                                [Qty],
                                [Amount],
                                [Size],
                                [Courier_Status] ) AS Duplicate_Count 
FROM AMAZONREPORT_BACKUP
)
SELECT D.*
FROM DUPLICATE_CTE AS D
WHERE Duplicate_Count > 1


WITH Duplicate_CTE AS (
    SELECT *,
        ROW_NUMBER() OVER ( PARTITION BY 
                          [Order_ID],
                            [Date],
                            [Status],
                            [Sales_Channel],
                            [Style],
                            [SKU],
                            [Category],
                             [Qty],
                            [Amount],
                            [Size],
                            [Courier_Status] 
            ORDER BY [Order_ID]
        ) AS Row_Number
    FROM AMAZONREPORT_BACKUP
)
DELETE FROM Duplicate_CTE
WHERE Row_Number > 1;
/* Observation:
12 duplicate records were identified.

Conclusion: Duplicate records represent repeated transactions rather than legitimate multiple purchases.

Actions: Remove duplicate records
*/
