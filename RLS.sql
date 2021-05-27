


-- Create a Table
CREATE SCHEMA Sales
GO
CREATE TABLE Sales.Territory 
    (  
    id int,  
    SalesRepName nvarchar(50),  
    Territory nvarchar(50),  
    Customer nvarchar(50)  
    );


-- Add Rows
INSERT INTO Sales.Territory  VALUES (1, 'Tayo', 'Central US', 'CUS1');
INSERT INTO Sales.Territory  VALUES (2, 'Bola', 'East US', 'EUS1');
INSERT INTO Sales.Territory  VALUES (3, 'Bola', 'East US', 'EUS2');
INSERT INTO Sales.Territory  VALUES (4, 'Remi', 'West US', 'WUS1');
INSERT INTO Sales.Territory  VALUES (5, 'Wale', 'Pacific Northwest', 'PNW1');
INSERT INTO Sales.Territory  VALUES (6, 'Bola', 'East US', 'EUS3');
INSERT INTO Sales.Territory  VALUES (7, 'Tayo', 'Central US', 'CUS2');
INSERT INTO Sales.Territory  VALUES (8, 'Remi', 'West US', 'WUS2');
INSERT INTO Sales.Territory  VALUES (9, 'Wale', 'Pacific Northwest', 'PNW2');
INSERT INTO Sales.Territory  VALUES (10, 'Remi', 'West US', 'WUS3');
INSERT INTO Sales.Territory  VALUES (11, 'Wale', 'Pacific Northwest', 'PNW3');
INSERT INTO Sales.Territory  VALUES (12, 'Tayo', 'Central US', 'CUS3');


-- View the rows in the table  
SELECT * FROM Sales.Territory
ORDER BY id;


-- Create Users
CREATE USER SalesManager WITHOUT LOGIN;  
CREATE USER Tayo WITHOUT LOGIN;  
CREATE USER Bola WITHOUT LOGIN;
CREATE USER Remi WITHOUT LOGIN;  
CREATE USER Wale WITHOUT LOGIN;



-- Grant Read Access to the Users
GRANT SELECT ON Sales.Territory TO SalesManager;  
GRANT SELECT ON Sales.Territory TO Tayo;  
GRANT SELECT ON Sales.Territory TO Bola; 
GRANT SELECT ON Sales.Territory TO Remi;  
GRANT SELECT ON Sales.Territory TO Wale;



--Create Schema for Security Predicate Function
CREATE SCHEMA spf;  
  

-- Create Security Filter Predicate Function 
-- The function returns 1 when a row in the SalesRepName column is the same as the user executing the query (@SalesRepName = USER_NAME()) or if the user executing the query is the Manager user (USER_NAME() = 'Manager').
CREATE FUNCTION spf.itvf_securitypredicate(@SalesRepName AS nvarchar(50))  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS tvf_securitypredicate_result
WHERE @SalesRepName = USER_NAME() OR USER_NAME() = 'SalesManager';  



--Bind Security Policy to Filter Predicate
CREATE SECURITY POLICY MySalesFilterPolicy  
ADD FILTER PREDICATE spf.itvf_securitypredicate(SalesRepName)
ON Sales.Territory
WITH (STATE = ON);  

--test our security predicate function SELECT permissions
GRANT SELECT ON spf.itvf_securitypredicate TO SalesManager;  
GRANT SELECT ON spf.itvf_securitypredicate TO Tayo;  
GRANT SELECT ON spf.itvf_securitypredicate TO Bola;
GRANT SELECT ON spf.itvf_securitypredicate TO Remi;  
GRANT SELECT ON spf.itvf_securitypredicate TO Wale;


EXECUTE AS USER = 'Tayo';  
SELECT * FROM Sales.Territory
ORDER BY id;
REVERT;  
  
EXECUTE AS USER = 'Bola';  
SELECT * FROM Sales.Territory
ORDER BY id;
REVERT;  
  
EXECUTE AS USER = 'Remi';  
SELECT * FROM Sales.Territory
ORDER BY id;
REVERT;

EXECUTE AS USER = 'Wale';  
SELECT * FROM Sales.Territory
ORDER BY id;
REVERT;

EXECUTE AS USER = 'SalesManager';  
SELECT * FROM Sales.Territory
ORDER BY id;
REVERT;


-- You can disable RLS by Altering the Security Policy 
ALTER SECURITY POLICY MySalesFilterPolicy  
WITH (STATE = OFF);



--Clean Up
DROP USER SalesManager;
DROP USER Tayo;
DROP USER Bola;
DROP USER Remi;
DROP USER Wale;


DROP SECURITY POLICY MySalesFilterPolicy;
DROP TABLE Sales.Territory;
DROP FUNCTION spf.itvf_securitypredicate;
DROP SCHEMA spf;
DROP SCHEMA Sales;
