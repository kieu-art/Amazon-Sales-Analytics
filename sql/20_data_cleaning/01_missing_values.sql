-----------------------------------------------------------------------
-- Step 1: Assess Missing Values
-- Objectives: 
-- Identify missing values across all variables before applying any
-- data cleaning operations 
-----------------------------------------------------------------------
SELECT
    COUNT(CASE WHEN [Order_ID] IS NULL THEN 1 END) AS Missing_OrderID,
    COUNT(CASE WHEN [Date] IS NULL THEN 1 END) AS Missing_Date,
    COUNT(CASE WHEN [Status] IS NULL THEN 1 END) AS Missing_Status,
    COUNT(CASE WHEN [Fulfilment] IS NULL THEN 1 END) AS Missing_Fulfilment,
    COUNT(CASE WHEN [Sales_Channel] IS NULL THEN 1 END) AS Missing_SalesChannel,
    COUNT(CASE WHEN [ship_service_level] IS NULL THEN 1 END) AS Missing_ServiceLevel,
    COUNT(CASE WHEN [Style] IS NULL THEN 1 END) AS Missing_Style,
    COUNT(CASE WHEN [SKU] IS NULL THEN 1 END) AS Missing_SKU,
    COUNT(CASE WHEN [Category] IS NULL THEN 1 END) AS Missing_Category,
    COUNT(CASE WHEN [Size] IS NULL THEN 1 END) AS Missing_Size,
    COUNT(CASE WHEN [ASIN] IS NULL THEN 1 END) AS Missing_ASIN,
    COUNT(CASE WHEN [Courier_Status] IS NULL THEN 1 END) AS Missing_CourierStatus,
    COUNT(CASE WHEN [Qty] IS NULL THEN 1 END) AS Missing_Qty,
    COUNT(CASE WHEN [Currency] IS NULL THEN 1 END) AS Missing_Currency,
    COUNT(CASE WHEN [Amount] IS NULL THEN 1 END) AS Missing_Amount,
    COUNT(CASE WHEN [ship_city] IS NULL THEN 1 END) AS Missing_City,
    COUNT(CASE WHEN [ship_state] IS NULL THEN 1 END) AS Missing_State,
    COUNT(CASE WHEN [ship_postal_code] IS NULL THEN 1 END) AS Missing_PostalCode,
    COUNT(CASE WHEN [ship_country] IS NULL THEN 1 END) AS Missing_Country,
    COUNT(CASE WHEN [promotion_ids] IS NULL THEN 1 END) AS Missing_PromotionIDs,
    COUNT(CASE WHEN [B2B] IS NULL THEN 1 END) AS Missing_B2B,
    COUNT(CASE WHEN [fulfilled_by] IS NULL THEN 1 END) AS Missing_FulfilledBy,
    COUNT(CASE WHEN [Unnamed_22] IS NULL THEN 1 END) AS Missing_Unnamed22
FROM AMAZONREPORT_BACKUP;
/* Observation: 
Several columns contain missing values, including Courier_Status, Amount, Currency, Promotion_ids, Fulfilled_by, and shipping location
attributes. Each column requires further investigation before deciding whether to impute, retain, or remove missing values.
*/


-----------------------------------------------------------------------
-- Step 2: Handle Missing Courier Status
-- Objective:
-- Determine whether missing Courier_Status values are valid according
-- to the business process.
-----------------------------------------------------------------------
SELECT *
FROM AMAZONREPORT_BACKUP
WHERE Courier_Status IS NULL 
-- A total of 6,872 records have missing values in the [Courier_Status] column.

SELECT [Status], COUNT(*) AS Missing_Count
FROM AMAZONREPORT_BACKUP
WHERE Courier_Status IS NULL
GROUP BY [Status]
ORDER BY Missing_Count DESC;
/* Observation:
99.84% of missing Courier_Status values belong to cancelled orders,
indicating that these orders never entered the shipping process.

Action:
Replace missing Courier_Status with 'Not Applicable' for cancelled orders, as these orders did not proceed to the shipping stage
*/
UPDATE  AMAZONREPORT_BACKUP
SET [Courier_Status] = 'Not Applicable'
WHERE [Courier_Status] IS NULL AND Status = 'Cancelled'


SELECT *
FROM AMAZONREPORT_BACKUP
WHERE Courier_Status IS NULL AND Status <> 'Cancelled';
/* Observation:
The remaining records also contain missing Amount and Currency with
Qty = 0, making the shipping status impossible to determine.

Action:
Replace the remaining missing values with 'Unknown'.
*/
UPDATE AMAZONREPORT_BACKUP 
SET [Courier_Status] = 'Unknown'
WHERE Courier_Status IS NULL AND Status <> 'Cancelled';


-----------------------------------------------------------------------
-- Step 3: Validate Amount and Currency
-- Objective:
-- Verify whether missing Amount and Currency occur consistently and
-- assess whether imputation is appropriate.
-----------------------------------------------------------------------
SELECT *
FROM AMAZONREPORT_BACKUP
WHERE [Amount] IS NULL 

SELECT COUNT(*) AS Not_Matching
FROM AMAZONREPORT_BACKUP
WHERE (Amount IS NULL AND Currency IS NOT NULL) OR (Amount IS NOT NULL AND Currency IS NULL);
/*
Observation:
Amount and Currency are consistently missing together. */

SELECT [Courier_Status], COUNT (*)
FROM AMAZONREPORT_BACKUP
WHERE Amount IS NULL
  AND Currency IS NULL 
GROUP BY [Courier_Status]
/*
Conclusion:
Missing values mainly occur in cancelled or unshipped orders.

Action:
Retain missing values because they reflect the original business
process and should not be artificially imputed.
*/

----------------------------------------------------------------------
-- Step 4: Standardize Shipping State Names
-- Objective:
-- Evaluate incomplete shipping address information.
-----------------------------------------------------------------------
SELECT DISTINCT 
    Ship_State COLLATE Latin1_General_CS_AS AS Ship_State
FROM AMAZONREPORT_BACKUP;

UPDATE AMAZONREPORT_BACKUP
SET Ship_State = 'RAJASTHAN'
WHERE [Ship_State] IN ('Rajshthan', 'Rajasthan', 'Rajsthan', 'RJ');

UPDATE AMAZONREPORT_BACKUP
SET Ship_State = 'ODISHA'
WHERE Ship_State IN ('Orissa', 'orisaa','Odisha');

UPDATE AMAZONREPORT_BACKUP
SET Ship_State = 'PUDUCHERRY'
WHERE Ship_State IN ('PONDICHERRY', 'Puducherry');

UPDATE AMAZONREPORT_BACKUP
SET Ship_State = 'PUNJAB'
WHERE Ship_State IN ('PB','punjab','PUNJAB/MOHALI/ZIRAKPUR');

UPDATE AMAZONREPORT_BACKUP
SET Ship_State = 'NAGALAND'
WHERE Ship_State = 'NL';

UPDATE AMAZONREPORT_BACKUP
SET Ship_State = 'ARUNACHAL PRADESH'
WHERE Ship_State = 'AR';

UPDATE AMAZONREPORT_BACKUP
SET Ship_State = UPPER(Ship_State);


-----------------------------------------------------------------------
-- Step 5: Assess Missing Shipping Information
-- Objective:
-- Evaluate incomplete shipping address information.
-----------------------------------------------------------------------
SELECT *
FROM AMAZONREPORT_BACKUP
WHERE [ship_city] IS NULL OR [ship_state] is NULL OR [ship_country] IS NULL;

SELECT Status, Courier_Status, COUNT(*) AS Missing_Count
FROM AMAZONREPORT_BACKUP
WHERE ship_city IS NULL
   OR ship_state IS NULL
   OR ship_country IS NULL
GROUP BY Status,  Courier_Status
ORDER BY Missing_Count DESC;
/*
Conclusion:
Missing shipping information occurs across multiple order statuses
and cannot be inferred reliably.

Action:
Retain missing values without imputation.
*/

-----------------------------------------------------------------------
-- Step 5: Missing Promotion IDs
-----------------------------------------------------------------------
SELECT *
FROM AMAZONREPORT
WHERE [Promotion_ids] IS NULL
/*
Observation:
Missing Promotion_ids indicate that no promotion was applied.

Action:
No cleaning is required.
*/

-----------------------------------------------------------------------
-- Step 6: Remove Missing and Unused Column
-----------------------------------------------------------------------
SELECT COUNT(*) AS Missing_Unnamed_22
FROM AMAZONREPORT_BACKUP
WHERE Unnamed_22 IS NULL;

SELECT DISTINCT Unnamed_22
FROM AMAZONREPORT_BACKUP;

ALTER TABLE AMAZONREPORT_BACKUP
DROP COLUMN Unnamed_22;
/* Observation: The column contains only NULL and FALSE values.

Conclusion: The field has no analytical or business value.

Action: Remove the column.
*/


-----------------------------------------------------------------------
-- Step 7: Review Fulfilled_By Missing Value
-----------------------------------------------------------------------
SELECT [fulfilled_by], Count(*)
FROM AMAZONREPORT_BACKUP
GROUP BY [Fulfilled_by]
/* Observation: Most records contain NULL values.

Conclusion: This attribute is not required for the scope of the analysis.

Action: Retain the column without modification.
*/