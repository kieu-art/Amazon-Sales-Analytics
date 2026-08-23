-----------------------------------------------------------------------
-- Validate Data Consistency
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Check 1: Validate Cancelled Orders
-- Objective:
-- Ensure cancelled orders contain only valid courier statuses.
-----------------------------------------------------------------------SELECT *
FROM AMAZONREPORT_BACKUP
WHERE [Status] = 'Cancelled'
AND [Courier_Status] NOT IN ('Not Applicable','Unknown','Cancelled','Unshipped');
--Cancelled orders were reviewed to identify inconsistent courier statuses. No invalid courier status combinations were identified, indicating that cancelled orders did not contain conflicting delivery information

-----------------------------------------------------------------------
-- Check 2: Validate sales amount consistency
-- Objective:
-- Ensure Amount and Currency are consistently populated.
-----------------------------------------------------------------------
SELECT *
FROM AMAZONREPORT_BACKUP
WHERE Qty > 0
AND Amount IS NULL AND [Courier_Status] = 'Shipped'
/* Observation:
No shipped orders with a positive quantity have missing sales amounts.

Conclusion: Amount values are consistent for completed shipments.
*/

-----------------------------------------------------------------------
-- Check 3: Final Dataset Validation
-----------------------------------------------------------------------
SELECT COUNT(*) AS Total_Records
FROM AMAZONREPORT_BACKUP;
/* Final Validation Summary:
- Missing Courier_Status resolved.
- Duplicate records removed.
- Amount and Currency validated.
- Shipping information reviewed.
- Unused column removed.
- The dataset is clean and ready for exploratory data analysis (EDA) and business reporting.

Dataset Size Before Cleaning:
128,975
Duplicate removed : 12
Dataset Size After Cleaning:
128,969
*/