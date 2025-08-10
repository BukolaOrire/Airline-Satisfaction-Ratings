                ----------------- ANALYZING SUPPLIER PERFORMANCE ------------------
```sql
  ```
--- Loading tables for Data Maniplulation. 
SELECT * 
FROM OSD_log

SELECT * 
FROM Item_Purchase_History_

SELECT * 
FROM PO_Ref

--  Records contains 29 distinct po line num, 234 po num

SELECT DISTINCT B.PO_Num, A.PO_Num
FROM OSD_log A
INNER JOIN
PO_Ref B ON A.PO_Num = B.PO_Num

UPDATE OSD_Log
SET Date_Closed = '0'
WHERE Date_Closed IS NULL;


                    --- DATA MANIPULATION---
SELECT DISTINCT CONCAT(PO_Num, '_', PO_Line_Num) As REF_unique_key, 
                COUNT(*) AS unique_count
FROM PO_Ref
GROUP BY CONCAT(PO_Num, '_', PO_Line_Num)
--Having COUNT(*) > 1


--- Create New table Supplier ID 
CREATE TABLE Suppliers_Num(
    Sup_ID NVARCHAR(50) PRIMARY KEY,
    Suppliers_name VARCHAR(50));


--- Use CTE to generate sequential IDs like Sup_1, Sup_2
WITH DistinctSuppliers AS (SELECT DISTINCT Suppliers_Name
    FROM OSD_log
	WHERE Suppliers_Name  IS NOT NULL),
NumberedSuppliers AS (SELECT 
        ROW_NUMBER() OVER (ORDER BY Suppliers_Name) AS RowNum, Suppliers_Name
FROM DistinctSuppliers)
--  Insert into Supplier_ID with formatted IDs
INSERT INTO Suppliers_Num (Sup_ID, Suppliers_Name)
SELECT 'Sup' + RIGHT('000' + CAST(RowNum AS VARCHAR), 3), Suppliers_Name
FROM NumberedSuppliers;

SELECT * FROM Suppliers_Num

--- Checking if the Item Num are unique to a distinct supplier
--- by linking the tables which determines the item with issues
SELECT DISTINCT 
      Item_Num, log.Suppliers_Name, COUNT(*) AS Item_Count
FROM PO_Ref
     INNER JOIN OSD_log log 
	 ON CONCAT(PO_Ref.PO_Num, '_', PO_Ref.PO_Line_Num)
	 = CONCAT(log.PO_Num, '_', log.PO_Line_Item_Num)
WHERE Item_Num IS NOT NULL 
      AND Suppliers_Name IS NOT NULL
GROUP BY Item_Num, log.Suppliers_Name
ORDER BY Item_Count DESC


--- Count/Sum item number, quantity ordered, returned, net quantity received per item number.
CREATE VIEW Quantity_Supplied AS 
SELECT Item_Num, COUNT(*) AS Item_Count,
    SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) AS Quantity_Ordered,
    SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity) ELSE 0 END) AS Quantity_Returned,
	SUM(CASE WHEN Quantity > 0 THEN Quantity ELSE 0 END) - 
    SUM(CASE WHEN Quantity < 0 THEN ABS(Quantity) ELSE 0 END) AS Net_Quantity_Received
FROM Item_Purchase_History_
GROUP BY Item_Num

-- Retrive Quantity supplied by item count in descending order
SELECT *  FROM Quantity_Supplied
ORDER BY Quantity_Returned DESC


-- Creates a view named Item_Suppliers_Issues that combines OS&D logs with purchase order and item history data.
-- Joins OSD_log with PO_Ref and Item_Purchase_History_ using PO number, line item, and item number.
-- Filters records where Posting_Date is on or before Date_Received and within the same calendar year.
-- Returns key fields including PO details, item description, supplier info, quantities, and issue category.
CREATE VIEW Item_Suppliers_Issues AS
SELECT DISTINCT  OSD.Year, PH.Posting_Date,
       OSD.Date_Received,
       OSD.PO_Num,PO_Line_Num,
	   PH.Item_Num,PO.Description,
	   OSD.OS_D_Num, OSD.Suppliers_Name,
	   OSD.OS_D_Category, OSD.Qty_affected
FROM OSD_log AS OSD
INNER JOIN PO_Ref AS PO  
    ON OSD.PO_Num = PO.PO_Num
    AND PO_Line_Num = PO_Line_Item_Num
INNER JOIN Item_Purchase_History_ AS PH
    ON PO.Item_Num = PH.Item_Num
    WHERE PH.Posting_Date <= OSD.Date_Received	
	AND YEAR( PH.Posting_Date ) >= YEAR(OSD.Date_Received)

-- Further linking records to the Quantity_Supplied view to retrieve quantities ordered,
-- returned, and affected up to date.
SELECT A.Year, 
       A.PO_Num,
       A.PO_Line_Num,A.Item_Num,Q.Item_Count,
       A.Description, OS_D_Num,
       A.Suppliers_Name, OS_D_Category, 
       Q.Quantity_Ordered, Q.Quantity_Returned,
	   Q.Net_Quantity_Received, A.Qty_affected
 FROM Item_Suppliers_Issues AS A
 INNER JOIN Quantity_Supplied AS  Q
 ON A.Item_Num = Q.Item_Num

 -- Retrieves the most recent issue record for each item.
-- Joins Item_Suppliers_Issues with Quantity_Supplied on Item_Num.
-- Uses ROW_NUMBER to rank issues by Posting_Date (latest first).
-- Filters to return only the top-ranked (latest) record per item.
 WITH Issues AS (
    SELECT 
        A.Year, A.Date_Received,
        A.PO_Num,
        A.PO_Line_Num,
        A.Item_Num,
        Q.Item_Count,
        A.Description,
        A.OS_D_Num,
        A.Suppliers_Name,
        A.OS_D_Category,
        Q.Quantity_Ordered,
        Q.Quantity_Returned,
        Q.Net_Quantity_Received,
        A.Qty_affected,
        ROW_NUMBER() OVER (
            PARTITION BY A.Item_Num 
            ORDER BY A.Posting_Date DESC
        ) AS distinct_value
FROM 
     Item_Suppliers_Issues AS  A
INNER JOIN 
     Quantity_Supplied AS  Q 
	 ON A.Item_Num = Q.Item_Num )
SELECT * FROM Issues
WHERE distinct_value = 1;


-- This query identifies purchase orders (PO) with multiple entries for the same PO number, line number, item, and supplier.
-- It groups records from the Item_Suppliers_Issues table and counts how many times each unique combination appears.
-- Only combinations with more than one occurrence (duplicates or repeated issues) are returned.
-- Useful for detecting repeated supplier issues or duplicate PO entries.
SELECT PO_Num, PO_Line_Num, Item_Num,
      Suppliers_Name, COUNT(*) AS PO_Count
FROM Item_Suppliers_Issues
WHERE Suppliers_Name IS NOT NULL
GROUP BY PO_Num,
         PO_Line_Num,Item_Num,
         Suppliers_Name
HAVING COUNT(*) > 1
ORDER BY PO_Num,
         PO_Line_Num,
         Suppliers_Name


 --- This query calculates how many OS&D reports were generated per item per year.
SELECT log.Year,
       log.Item_Num,
       COUNT(log.OS_D_Num) AS Item_OSD_Count
FROM 
    ( SELECT * from Item_Suppliers_Issues ) AS log
GROUP BY log.Item_Num,log.Year
ORDER BY log.Year, Item_OSD_Count DESC;

--- How many OS&D’s are generated per supplier per year?
SELECT Year,
       Suppliers_Name,
       COUNT(OS_D_Num) AS OSD_Count
FROM  Item_Suppliers_Issues 
WHERE Suppliers_Name IS NOT NULL
GROUP BY Suppliers_Name,Year
ORDER BY Year, OSD_Count DESC;

--- How many orders (for the OS&D parts) are generated per year?
SELECT  DISTINCT Year, PO_Num,
       COUNT( PO_Num) AS Total_Orders
FROM  Item_Suppliers_Issues 
WHERE PO_Num IS NOT NULL
GROUP BY PO_Num,Year
ORDER BY Year, PO_Num,Total_Orders DESC;
```
